import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_compress/video_compress.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/app_toast.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/audio_post_player.dart';
import 'package:we_ads/core/widgets/category_chip.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/posts/presentation/providers/post_provider.dart';

class NewPostScreen extends ConsumerStatefulWidget {
  const NewPostScreen({super.key});

  @override
  ConsumerState<NewPostScreen> createState() => _NewPostScreenConsumerState();
}

class _NewPostScreenConsumerState extends ConsumerState<NewPostScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _timer;
  int _recordDuration = 0;
  bool _isRecording = false;
  String selectedCategory = "";
  File? _videoThumbnail;
  @override
  void initState() {
    Future.microtask(() {
      ref.read(selectedCategoriesProvider.notifier).state = [];
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();

      final targetPath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg, // ← forces compatibility
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint("Image compression error: $e");
      return null;
    }
  }

  Future<void> _handlePost() async {
    final selectedCats = ref.read(selectedCategoriesProvider);
    if (_textController.text.isEmpty) {
      AppToast.show(
        context: context,
        message: "Please enter a description",
        type: ToastType.info,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<File> filesToUpload = [];

      // PHOTO COMPRESSION
      if (mediaType == 'images') {
        for (var image in selectedImages) {
          final compressed = await _compressImage(image);
          if (compressed != null) filesToUpload.add(compressed);
        }
      }
      // VIDEO COMPRESSION
      else if (mediaType == 'video' && selectedVideo != null) {
        final compressed = await _compressVideo(selectedVideo!);
        if (compressed != null) {
          filesToUpload = [compressed];
        } else {
          // Fallback to original if compression fails or just cancel
          filesToUpload = [selectedVideo!];
        }
      }
      // AUDIO
      else if (mediaType == 'audio' && selectedAudio != null) {
        filesToUpload = [selectedAudio!];
      }

      final response = await ref
          .read(postProvider.notifier)
          .addPost(
            description: _textController.text.trim(),
            categories: selectedCats.isEmpty ? "" : selectedCats.join(", "),
            mediaFiles: filesToUpload,
          );

      if (response != null) {
        // Clear compression cache after successful upload
        if (mediaType == 'video') await VideoCompress.deleteAllCache();

        AppToast.show(
          context: context,
          message: response.statusMessage ?? "Success",
          type: ToastType.success,
        );
        if (mounted) context.go('/home');
      } else {
        final error = ref.read(postProvider).error;
        AppToast.show(
          context: context,
          message: ApiErrorHandler.getErrorMessage(error),
          type: ToastType.error,
        );
      }
    } catch (e) {
      print(e);
      AppToast.show(
        context: context,
        message: "An error occurred",
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Media State
  String mediaType = "none";
  List<File> selectedImages = [];
  File? selectedVideo;
  File? selectedAudio;

  // _imagePicker now accepts source to handle both camera and gallery for images
  Future<void> _pickImages(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      List<File> newFiles = [];

      if (source == ImageSource.camera) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
        );
        if (image != null) {
          newFiles.add(File(image.path));
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          newFiles = images.map((e) => File(e.path)).toList();
        }
      }

      if (newFiles.isNotEmpty) {
        setState(() {
          mediaType = 'images';
          selectedImages = [...selectedImages, ...newFiles].take(7).toList();

          selectedVideo = null;
          selectedAudio = null;
        });

        if (selectedImages.length >= 7 &&
            newFiles.length > (7 - (selectedImages.length - newFiles.length))) {
          AppToast.show(
            context: context,
            message: "Limit of 7 photos reached",
            type: ToastType.info,
          );
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // _videoPicker now accepts source to handle both camera and gallery for videos
  Future<void> _pickVideo(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        final thumbnailFile = await VideoCompress.getFileThumbnail(
          video.path,
          quality: 50,
          position: -1,
        );

        setState(() {
          mediaType = 'video';
          selectedVideo = File(video.path);
          _videoThumbnail = thumbnailFile;
          selectedImages = [];
          selectedAudio = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<File?> _compressVideo(File file) async {
    try {
      // MediaInfo contains the compressed video details
      final MediaInfo? info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.LowQuality, // Balanced compression
        deleteOrigin: false, // Keep the original file in gallery
        includeAudio: true,
      );
      return info?.file;
    } catch (e) {
      debugPrint("Video Compression Error: $e");
      return null;
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      if (selectedImages.isEmpty) mediaType = 'none';
    });
  }

  Future<void> _pickAudio() async {
    setState(() {
      selectedAudio = null;
    });
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          mediaType = 'audio';
          selectedAudio = File(result.files.single.path!);
          selectedImages = [];
          selectedVideo = null;
        });
      }
    } catch (e) {
      debugPrint("Audio Pick Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      selectedAudio = null;
    });
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory =
            await getTemporaryDirectory(); // Use temp for recording
        final path =
            '${directory.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Clear other media first
        setState(() {
          selectedImages = [];
          selectedVideo = null;
        });

        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          mediaType = 'audio';
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint("Recording Error: $e");
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    _timer?.cancel();
    if (path != null) {
      setState(() {
        _isRecording = false;
        selectedAudio = File(path);
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Select Video from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiLoading = ref.watch(postProvider).isLoading;
    final showLoader = _isLoading || apiLoading;
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: Colors.white,
        showBackButton: !showLoader, // Prevent going back while uploading
        title: "New post",
        titleColor: AppColors.backgroundDark,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserHeader(),
                              _buildTextField(),
                              SizedBox(height: 20.h),
                              if (mediaType == 'images') _buildImageGrid(),
                              if (mediaType == 'video') _buildVideoPreview(),
                              if (mediaType == 'audio' && selectedAudio == null)
                                _buildAudioRecordingCard(),
                              if (mediaType == 'audio' && selectedAudio != null)
                                AudioPostPlayer(url: selectedAudio!.path),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                isKeyboardVisible
                    ? _buildKeyboardActionBar()
                    : _buildBottomPanel(),
              ],
            ),

            // IMPROVED LOADING OVERLAY
            if (showLoader)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16.h),
                      Text(
                        _isLoading
                            ? "Compressing media..."
                            : "Uploading post...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          // fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final userNameLetters =
        "${ref.read(userProvider)?.firstName!.substring(0, 1).toUpperCase()}"
        "${ref.read(userProvider)?.lastName!.substring(0, 1).toUpperCase()}";

    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primary,
          child: Text(
            userNameLetters,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              // fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _textController,
      maxLines: null,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 14,
        // fontFamily: 'Roboto',
        color: AppColors.darkGrey,
      ),
      decoration: const InputDecoration(
        hintText: "Type something...",
        hintStyle: TextStyle(
          fontSize: 14,
          // fontFamily: 'Roboto',
          color: AppColors.mediumGrey,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildKeyboardActionBar() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ClipOval(
        child: Container(
          color: AppColors.surfaceBlue,
          padding: EdgeInsets.all(8.w),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showAudioOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.mic, color: AppColors.primary),
                title: const Text('Record Audio'),
                onTap: () {
                  Navigator.pop(context);
                  _startRecording();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.file_upload,
                  color: AppColors.primary,
                ),
                title: const Text('Select from Device'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAudio();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel() {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCats = ref.watch(selectedCategoriesProvider);
    return Container(
      padding: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withOpacity(0.3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Select category",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        // fontFamily: 'Roboto',
                        color: AppColors.backgroundDark,
                      ),
                      children: [
                        TextSpan(
                          text: " *",
                          style: TextStyle(color: AppColors.errorRed),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: GestureDetector(
                          onTap: () => FilterUtils.showCategorySheet(
                            context,
                            safeArea: true,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.borderGrey),
                            ),
                            child: Icon(
                              Icons.filter_list,
                              color: AppColors.backgroundDark,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 35.h,
                          child: categoriesAsync.when(
                            data: (categoryList) {
                              if (categoryList.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No categories found",
                                    style: TextStyle(
                                      fontSize: 12,
                                      // fontFamily: 'Roboto',
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categoryList.length,
                                itemBuilder: (context, index) {
                                  final cat = categoryList[index];
                                  final catName = cat.categoryName ?? "";
                                  final bool isSelected = selectedCats.contains(
                                    catName,
                                  );
                                  return AnimatedScale(
                                    scale: isSelected ? 1.05 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: CategoryChip(
                                      label: catName,
                                      isSelected: isSelected,
                                      onTap: () {
                                        final notifier = ref.read(
                                          selectedCategoriesProvider.notifier,
                                        );
                                        if (isSelected) {
                                          notifier.state = selectedCats
                                              .where((name) => name != catName)
                                              .toList();
                                        } else {
                                          notifier.state = [
                                            ...selectedCats,
                                            catName,
                                          ];
                                        }
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const SizedBox(),
                            error: (err, stack) => Text(
                              "Error loading categories",
                              style: const TextStyle(
                                fontSize: 12,
                                // fontFamily: 'Roboto',
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Utility Icons Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  _utilityIcon(
                    Icons.image_outlined,
                    _showImageSourceOptions, // _pickImages
                  ),
                  _utilityIcon(
                    Icons.camera_alt_outlined,
                    _showVideoSourceOptions, // _pickVideo
                  ),
                  _utilityIcon(Icons.mic_none_outlined, _showAudioOptions),
                  const Spacer(),
                  // Post Button
                  GestureDetector(
                    onTap: _handlePost,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlue,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _utilityIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: AppColors.mediumGrey, size: 26),
      onPressed: onTap,
    );
  }

  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: selectedImages.asMap().entries.map((entry) {
            int index = entry.key;
            File file = entry.value;
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    file,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: CircleAvatar(
                      radius: 10.r,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 8.h),
        Text(
          "${selectedImages.length}/7",
          style: const TextStyle(
            fontSize: 12,
            // fontFamily: 'Roboto',
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioRecordingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isRecording ? "Recording..." : "Recorded Audio",
                style: const TextStyle(
                  fontSize: 12,
                  // fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _stopRecording();
                  setState(() => mediaType = 'none');
                },
                child: Icon(Icons.close, size: 18, color: AppColors.mediumGrey),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 60.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD5A1),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Center(
              child: Icon(Icons.graphic_eq, color: AppColors.primary, size: 30),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                _formatDuration(_recordDuration),
                style: const TextStyle(
                  fontSize: 16,
                  // fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: AppColors.backgroundDark,
                ),
              ),

              const Spacer(),
              if (_isRecording) ...[
                IconButton(
                  icon: Icon(
                    Icons.stop_circle,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  onPressed: _stopRecording,
                ),
              ] else ...[
                Icon(
                  Icons.play_circle_fill,
                  size: 32,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (selectedVideo == null) return const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            context.push('/video-preview', extra: selectedVideo);
          },
          child: Container(
            width: 150.w,
            height: 150.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.black,
              image: _videoThumbnail != null
                  ? DecorationImage(
                      image: FileImage(_videoThumbnail!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() {
              selectedVideo = null;
              _videoThumbnail = null;
              mediaType = 'none';
            }),
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: Colors.black54,
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
