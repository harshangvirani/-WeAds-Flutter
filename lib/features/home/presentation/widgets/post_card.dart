import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/app_toast.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/audio_post_player.dart';
import 'package:we_ads/core/widgets/common_skeleton.dart';
import 'package:we_ads/core/widgets/video_post_player.dart';
import 'package:we_ads/features/posts/data/modals/post_model.dart';
import 'package:we_ads/features/posts/presentation/providers/post_provider.dart';
import 'package:we_ads/features/posts/presentation/providers/saved_posts_provider.dart';
import 'package:we_ads/core/providers/user_provider.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  final String? profileImg;
  final String? firstName;
  final String? lastName;
  final String? mobileNo;
  final bool? isMyProfile;
  final bool showSaveButton;

  const PostCard({
    super.key,
    required this.post,
    this.profileImg,
    this.firstName,
    this.lastName,
    this.mobileNo,
    this.isMyProfile = false,
    this.showSaveButton = true,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardConsumerState();
}

class _PostCardConsumerState extends ConsumerState<PostCard> {
  bool _isSaving = false;
  late bool _isSavedLocal;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _isSavedLocal = widget.post.isSaved ?? false;
  }

  Future<void> _handleSaveToggle() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _isSavedLocal = !_isSavedLocal;
    });

    final currentUser = ref.read(userProvider);
    final String userId = currentUser?.userId ?? "";

    final success = await ref.read(postProvider.notifier).toggleSavePost(
          postId: widget.post.postId!,
          userId: userId,
          isSaved: _isSavedLocal,
        );

    if (!success) {
      setState(() => _isSavedLocal = !_isSavedLocal);

      if (mounted) {
        AppToast.show(
          context: context,
          message: "Action failed",
          type: ToastType.error,
        );
      }
    } else {
      ref.invalidate(savedPostsProvider);
    }

    if (mounted) setState(() => _isSaving = false);
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();
    final diff = now.difference(dateTime).inDays;

    if (diff == 0) return "Today";

    return DateFormat('MMM d').format(dateTime);
  }

  Widget _buildMediaContent() {
    final mediaList = widget.post.media ?? [];

    if (mediaList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          widget.post.description ?? "",
          style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
        ),
      );
    }

    final firstMedia = mediaList.first;

    /// IMAGES
    if (firstMedia.isImage) {
      return SizedBox(
        height: 180.h,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: mediaList.length,
              onPageChanged: (index) =>
                  setState(() => _currentPage = index + 1),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: mediaList[index].fileUrl ?? "",
                  fit: BoxFit.cover,
                  placeholder: (_, __) => CommonSkeleton.box(height: 200.h),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                );
              },
            ),
            if (mediaList.length > 1)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "$_currentPage/${mediaList.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    /// VIDEO
    if (firstMedia.isVideo) {
      return VideoPostPlayer(videoUrl: firstMedia.fileUrl ?? "");
    }

    /// AUDIO
    if (firstMedia.isAudio) {
      return AudioPostPlayer(url: firstMedia.fileUrl ?? "");
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          ListTile(
            leading:
                (widget.profileImg != null && widget.profileImg!.isNotEmpty)
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.profileImg!,
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _buildPlaceholderAvatar(),
                    ),
                  )
                : widget.isMyProfile == false
                ? _buildPlaceholderAvatar()
                : null,

            contentPadding: widget.isMyProfile == true
                ? EdgeInsets.only(left: 16.w, right: 0)
                : EdgeInsets.symmetric(horizontal: 16.w),
            title: widget.isMyProfile == false
                ? Text(
                    "${widget.firstName ?? "User"} ${widget.lastName ?? ""}"
                        .trim(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundDark,
                    ),
                  )
                : _dateAndView(),

            subtitle: widget.isMyProfile == false ? _dateAndView() : null,

            trailing: widget.isMyProfile == true
                ? PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.more_vert, color: AppColors.darkGrey),
                    onSelected: (String result) {
                      if (result == 'Edit') {
                        context.push('/edit-post', extra: widget.post);
                      } else if (result == 'Delete') {
                        FilterUtils.showDeleteDialog(context, () async {
                          final success = await ref
                              .read(postProvider.notifier)
                              .deletePost(postId: widget.post.postId ?? "");
                              
                          if (success && context.mounted) {
                            AppToast.show(
                              context: context,
                              message: "Post deleted successfully",
                              type: ToastType.success,
                            );
                          } else if (context.mounted) {
                            AppToast.show(
                              context: context,
                              message: "Failed to delete post",
                              type: ToastType.error,
                            );
                          }
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'Edit',
                        height: 30.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20.w, color: AppColors.darkGrey),
                            SizedBox(width: 8.w),
                            Text('Edit', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Delete',
                        height: 30.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20.w, color: AppColors.errorRed),
                            SizedBox(width: 8.w),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.errorRed, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : widget.mobileNo != null
                    ? IconButton(
                        onPressed: () => FilterUtils.showPhoneDialog(
                          context,
                          widget.mobileNo ?? "",
                        ),
                        icon: const Icon(Icons.phone_outlined),
                      )
                    : null,
          ),

          /// DESCRIPTION
          if (widget.post.media != null && widget.post.media!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Text(
                widget.post.description ?? "",
                style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
              ),
            ),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(children: [_buildMediaContent(), _buildFooter()]),

              /// BOOKMARK
              if (widget.showSaveButton)
                Positioned(
                  bottom: 20.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: _handleSaveToggle,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlue,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _isSavedLocal
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: AppColors.primary,
                              size: 20,
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return CircleAvatar(
      radius: 18.r,
      backgroundColor: AppColors.surfaceBlue,
      child: Text(
        widget.firstName?.substring(0, 1).toUpperCase() ?? "U",
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _dateAndView() {
    return Row(
      children: [
        Text(
          _formatDate(widget.post.enteredOn),
          style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: const Icon(Icons.circle, size: 4, color: AppColors.mediumGrey),
        ),
        const Icon(Icons.group_outlined, size: 14, color: AppColors.mediumGrey),
        SizedBox(width: 4.w),
        Text(
          "${widget.post.viewCount ?? 0} views",
          style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBlueTint,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              widget.post.categories ?? "",
              style: const TextStyle(fontSize: 12, color: AppColors.mediumGrey),
            ),
          ),
          Row(
            children: [
              Text(
                "${widget.post.savedCount ?? 0} Saved",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
              SizedBox(width: 40.w),
            ],
          ),
        ],
      ),
    );
  }
}