import 'dart:io';

class AddPostRequest {
  final String description;
  final String categories;
  final List<File> mediaFiles; // Can contain images, video, or audio

  AddPostRequest({
    required this.description,
    required this.categories,
    required this.mediaFiles,
  });
}
