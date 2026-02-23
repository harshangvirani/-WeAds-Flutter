// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:we_ads/core/theme/app_colors.dart';
// import 'package:we_ads/core/theme/app_text_styles.dart';
// import 'package:we_ads/core/utils/filter_utils.dart';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:we_ads/features/posts/data/modals/post_model.dart';

// class PostCard extends StatefulWidget {
//   final PostModel post;
//   const PostCard({super.key, required this.post});

//   @override
//   State<PostCard> createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {
//   // Logic to determine what to show
//   Widget _buildMediaContent() {
//     final mediaList = widget.post.media;

//     if (mediaList == null || mediaList.isEmpty) {
//       // Text-only post
//       return Container(
//         height: 100.h,
//         padding: EdgeInsets.all(16.w),
//         child: Text(widget.post.description ?? ""),
//       );
//     }

//     final firstMedia = mediaList.first;

//     if (firstMedia.contentType?.contains('image') ?? false) {
//       return SizedBox(
//         height: 180.h,
//         child: PageView.builder(
//           itemCount: mediaList.length,
//           itemBuilder: (context, index) {
//             return CachedNetworkImage(
//               imageUrl: mediaList[index].fileUrl ?? "",
//               fit: BoxFit.cover,
//               placeholder: (context, url) =>
//                   Center(child: CircularProgressIndicator()),
//               errorWidget: (context, url, error) => Icon(Icons.broken_image),
//             );
//           },
//         ),
//       );
//     } else if (firstMedia.contentType?.contains('video') ?? false) {
//       return Container(
//         height: 180.h,
//         color: Colors.black,
//         child: Center(
//           child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50.sp),
//         ),
//       );
//     }

//     return const SizedBox.shrink();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
//             leading: CircleAvatar(
//               radius: 18.r,
//               backgroundColor: AppColors.surfaceBlue,
//               child: Icon(Icons.person, color: AppColors.primary, size: 20.sp),
//             ),
//             title: Text(
//               widget.post.userId ?? "Unknown", // user name pending
//               style: AppTextStyles.bodyMedium.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Row(
//               children: [
//                 Text("Today", style: AppTextStyles.labelSmall),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                   child: Icon(
//                     Icons.circle,
//                     size: 4,
//                     color: AppColors.mediumGrey,
//                   ),
//                 ),
//                 Icon(
//                   Icons.group_outlined,
//                   size: 14,
//                   color: AppColors.mediumGrey,
//                 ),
//                 SizedBox(width: 4.w),
//                 Text("230 views", style: AppTextStyles.labelSmall),
//               ],
//             ),
//             trailing: IconButton(
//               onPressed: () {
//                 FilterUtils.showPhoneDialog(context);
//               },
//               icon: Icon(
//                 Icons.phone_outlined,
//                 color: AppColors.backgroundDark,
//                 size: 24,
//               ),
//             ),
//           ),

//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//             child: Text(
//               "I will share feedback for everything that has been shared today.",
//               style: AppTextStyles.bodyMedium,
//             ),
//           ),
//           SizedBox(height: 8.h),

//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Column(
//                 children: [
//                   _buildMediaContent(),

//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.lightBlueTint,
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(16.r),
//                         bottomRight: Radius.circular(16.r),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16.w,
//                         vertical: 12.h,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             widget.post.categories ?? "General",
//                             style: AppTextStyles.labelSmall.copyWith(
//                               color: AppColors.mediumGrey,
//                             ),
//                           ),
//                           Spacer(),
//                           Text(
//                             "${widget.post.savedCount ?? 0} Saved",
//                             style: AppTextStyles.labelSmall.copyWith(
//                               color: AppColors.mediumGrey,
//                             ),
//                           ),
//                           SizedBox(width: 32.w),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               // Positioned(
//               //   top: (widget.mediaType == 'audio' ? 60.h : 180.h) - 20.h,
//               //   right: 16.w,
//               //   child: GestureDetector(
//               //     onTap: () => setState(() => isBookmarked = !isBookmarked),
//               //     child: Container(
//               //       padding: EdgeInsets.all(8.w),
//               //       decoration: BoxDecoration(
//               //         color: AppColors.surfaceBlue,
//               //         borderRadius: BorderRadius.circular(10.r),
//               //         boxShadow: [
//               //           BoxShadow(
//               //             color: Colors.black.withOpacity(0.1),
//               //             blurRadius: 4,
//               //             offset: const Offset(0, 2),
//               //           ),
//               //         ],
//               //       ),
//               //       child: Icon(
//               //         isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//               //         color: AppColors.primary,
//               //         size: 20,
//               //       ),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildMediaContent() {
//   //   if (widget.mediaType == 'image_scroll') {
//   //     return SizedBox(
//   //       height: 180.h,
//   //       child: Stack(
//   //         children: [
//   //           PageView.builder(
//   //             itemCount: _totalImages,
//   //             controller: PageController(viewportFraction: 1.0),
//   //             onPageChanged: (index) =>
//   //                 setState(() => _currentPage = index + 1),
//   //             itemBuilder: (context, index) {
//   //               return Container(
//   //                 color: AppColors.lightGrey.withOpacity(0.3),
//   //                 child: const Center(
//   //                   child: Icon(Icons.image, color: AppColors.mediumGrey),
//   //                 ),
//   //               );
//   //             },
//   //           ),
//   //           Positioned(
//   //             top: 12.h,
//   //             right: 12.w,
//   //             child: Container(
//   //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//   //               decoration: BoxDecoration(
//   //                 color: Colors.black.withOpacity(0.5),
//   //                 borderRadius: BorderRadius.circular(12.r),
//   //               ),
//   //               child: Text(
//   //                 "$_currentPage/$_totalImages",
//   //                 style: TextStyle(color: Colors.white, fontSize: 10.sp),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   } else if (widget.mediaType == 'video') {
//   //     return Container(
//   //       height: 180.h,
//   //       color: Colors.black.withOpacity(0.1),
//   //       child: Center(
//   //         child: Icon(
//   //           Icons.play_circle_fill,
//   //           color: AppColors.white,
//   //           size: 50,
//   //         ),
//   //       ),
//   //     );
//   //   } else if (widget.mediaType == 'audio') {
//   //     return Container(
//   //       height: 60.h,
//   //       padding: EdgeInsets.symmetric(horizontal: 12.w),
//   //       decoration: BoxDecoration(color: AppColors.lightBlueTint),
//   //       child: Row(
//   //         crossAxisAlignment: CrossAxisAlignment.center,
//   //         children: [
//   //           Container(
//   //             padding: EdgeInsets.all(4.w),
//   //             decoration: BoxDecoration(
//   //               color: AppColors.mediumGrey.withOpacity(0.2),
//   //               shape: BoxShape.circle,
//   //             ),
//   //             child: Icon(
//   //               Icons.play_arrow_rounded,
//   //               color: AppColors.mediumGrey,
//   //               size: 28,
//   //             ),
//   //           ),
//   //           SizedBox(width: 10.w),
//   //           Expanded(
//   //             child: Stack(
//   //               alignment: Alignment.centerLeft,
//   //               children: [
//   //                 CustomPaint(
//   //                   size: Size(double.infinity, 25.h),
//   //                   painter: CurvedWavePainter(
//   //                     color: AppColors.mediumGrey.withOpacity(0.2),
//   //                     percentPlayed: 0.4,
//   //                     isBackground: true,
//   //                   ),
//   //                 ),
//   //                 CustomPaint(
//   //                   size: Size(double.infinity, 25.h),
//   //                   painter: CurvedWavePainter(
//   //                     color: AppColors.primary,
//   //                     percentPlayed: 0.4,
//   //                     isBackground: false,
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           SizedBox(width: 10.w),
//   //           Text(
//   //             "00:00:45",
//   //             style: AppTextStyles.labelSmall.copyWith(
//   //               color: AppColors.mediumGrey,
//   //               fontSize: 10,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   } else if (widget.mediaType == 'text') {
//   //     return SizedBox(
//   //       height: 180.h,
//   //       child: Stack(
//   //         children: [
//   //           Padding(
//   //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//   //             child: Text(
//   //               "This is a sample text content for the post. It can span multiple lines and provides information to the user.",
//   //               style: AppTextStyles.bodyMedium,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   }
//   //   return const SizedBox.shrink();
//   // }
// }

// // class PostCard extends StatefulWidget {
// //   final String mediaType; // 'image_scroll', 'video', 'audio', 'text'

// //   const PostCard({super.key, required this.mediaType});

// //   @override
// //   State<PostCard> createState() => _PostCardState();
// // }

// // class _PostCardState extends State<PostCard> {
// //   bool isBookmarked = true;
// //   int _currentPage = 1;
// //   final int _totalImages = 7;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.white,
// //         borderRadius: BorderRadius.circular(16.r),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           ListTile(
// //             contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
// //             leading: CircleAvatar(
// //               radius: 18.r,
// //               backgroundColor: AppColors.surfaceBlue,
// //               child: Icon(Icons.person, color: AppColors.primary, size: 20.sp),
// //             ),
// //             title: Text(
// //               "Smit Sakariya",
// //               style: AppTextStyles.bodyMedium.copyWith(
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             subtitle: Row(
// //               children: [
// //                 Text("Today", style: AppTextStyles.labelSmall),
// //                 Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 4.w),
// //                   child: Icon(
// //                     Icons.circle,
// //                     size: 4,
// //                     color: AppColors.mediumGrey,
// //                   ),
// //                 ),
// //                 Icon(
// //                   Icons.group_outlined,
// //                   size: 14,
// //                   color: AppColors.mediumGrey,
// //                 ),
// //                 SizedBox(width: 4.w),
// //                 Text("230 views", style: AppTextStyles.labelSmall),
// //               ],
// //             ),
// //             trailing: IconButton(
// //               onPressed: () {
// //                 FilterUtils.showPhoneDialog(context);
// //               },
// //               icon: Icon(
// //                 Icons.phone_outlined,
// //                 color: AppColors.backgroundDark,
// //                 size: 24,
// //               ),
// //             ),
// //           ),

// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
// //             child: Text(
// //               "I will share feedback for everything that has been shared today.",
// //               style: AppTextStyles.bodyMedium,
// //             ),
// //           ),
// //           SizedBox(height: 8.h),

// //           Stack(
// //             clipBehavior: Clip.none,
// //             children: [
// //               Column(
// //                 children: [
// //                   _buildMediaContent(),

// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: AppColors.lightBlueTint,
// //                       borderRadius: BorderRadius.only(
// //                         bottomLeft: Radius.circular(16.r),
// //                         bottomRight: Radius.circular(16.r),
// //                       ),
// //                     ),
// //                     child: Padding(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 16.w,
// //                         vertical: 12.h,
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             "Cooking",
// //                             style: AppTextStyles.labelSmall.copyWith(
// //                               color: AppColors.mediumGrey,
// //                             ),
// //                           ),
// //                           Spacer(),
// //                           Text(
// //                             "24 Saved",
// //                             style: AppTextStyles.labelSmall.copyWith(
// //                               color: AppColors.mediumGrey,
// //                             ),
// //                           ),
// //                           SizedBox(width: 32.w),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),

// //               Positioned(
// //                 top: (widget.mediaType == 'audio' ? 60.h : 180.h) - 20.h,
// //                 right: 16.w,
// //                 child: GestureDetector(
// //                   onTap: () => setState(() => isBookmarked = !isBookmarked),
// //                   child: Container(
// //                     padding: EdgeInsets.all(8.w),
// //                     decoration: BoxDecoration(
// //                       color: AppColors.surfaceBlue,
// //                       borderRadius: BorderRadius.circular(10.r),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.1),
// //                           blurRadius: 4,
// //                           offset: const Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Icon(
// //                       isBookmarked ? Icons.bookmark : Icons.bookmark_border,
// //                       color: AppColors.primary,
// //                       size: 20,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildMediaContent() {
// //     if (widget.mediaType == 'image_scroll') {
// //       return SizedBox(
// //         height: 180.h,
// //         child: Stack(
// //           children: [
// //             PageView.builder(
// //               itemCount: _totalImages,
// //               controller: PageController(viewportFraction: 1.0),
// //               onPageChanged: (index) =>
// //                   setState(() => _currentPage = index + 1),
// //               itemBuilder: (context, index) {
// //                 return Container(
// //                   color: AppColors.lightGrey.withOpacity(0.3),
// //                   child: const Center(
// //                     child: Icon(Icons.image, color: AppColors.mediumGrey),
// //                   ),
// //                 );
// //               },
// //             ),
// //             Positioned(
// //               top: 12.h,
// //               right: 12.w,
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
// //                 decoration: BoxDecoration(
// //                   color: Colors.black.withOpacity(0.5),
// //                   borderRadius: BorderRadius.circular(12.r),
// //                 ),
// //                 child: Text(
// //                   "$_currentPage/$_totalImages",
// //                   style: TextStyle(color: Colors.white, fontSize: 10.sp),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     } else if (widget.mediaType == 'video') {
// //       return Container(
// //         height: 180.h,
// //         color: Colors.black.withOpacity(0.1),
// //         child: Center(
// //           child: Icon(
// //             Icons.play_circle_fill,
// //             color: AppColors.white,
// //             size: 50,
// //           ),
// //         ),
// //       );
// //     } else if (widget.mediaType == 'audio') {
// //       return Container(
// //         height: 60.h,
// //         padding: EdgeInsets.symmetric(horizontal: 12.w),
// //         decoration: BoxDecoration(color: AppColors.lightBlueTint),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(4.w),
// //               decoration: BoxDecoration(
// //                 color: AppColors.mediumGrey.withOpacity(0.2),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.play_arrow_rounded,
// //                 color: AppColors.mediumGrey,
// //                 size: 28,
// //               ),
// //             ),
// //             SizedBox(width: 10.w),
// //             Expanded(
// //               child: Stack(
// //                 alignment: Alignment.centerLeft,
// //                 children: [
// //                   CustomPaint(
// //                     size: Size(double.infinity, 25.h),
// //                     painter: CurvedWavePainter(
// //                       color: AppColors.mediumGrey.withOpacity(0.2),
// //                       percentPlayed: 0.4,
// //                       isBackground: true,
// //                     ),
// //                   ),
// //                   CustomPaint(
// //                     size: Size(double.infinity, 25.h),
// //                     painter: CurvedWavePainter(
// //                       color: AppColors.primary,
// //                       percentPlayed: 0.4,
// //                       isBackground: false,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(width: 10.w),
// //             Text(
// //               "00:00:45",
// //               style: AppTextStyles.labelSmall.copyWith(
// //                 color: AppColors.mediumGrey,
// //                 fontSize: 10,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     } else if (widget.mediaType == 'text') {
// //       return SizedBox(
// //         height: 180.h,
// //         child: Stack(
// //           children: [
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
// //               child: Text(
// //                 "This is a sample text content for the post. It can span multiple lines and provides information to the user.",
// //                 style: AppTextStyles.bodyMedium,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //     return const SizedBox.shrink();
// //   }
// // }
