enum MediaType { image, video, audio, unknown }

class PostMedia {
  final String? mediaId;
  final String? fileName;
  final String? fileUrl;
  final String? contentType;

  PostMedia({this.mediaId, this.fileName, this.fileUrl, this.contentType});

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      mediaId: json['mediaId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      contentType: json['contentType'],
    );
  }

  Map<String, dynamic> toJson() => {
    'mediaId': mediaId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'contentType': contentType,
  };

  MediaType get mediaType {
    if (contentType == null) return MediaType.unknown;

    if (contentType!.startsWith('image')) {
      return MediaType.image;
    } else if (contentType!.startsWith('video')) {
      return MediaType.video;
    } else if (contentType!.startsWith('audio')) {
      return MediaType.audio;
    }

    return MediaType.unknown;
  }

  bool get isImage => mediaType == MediaType.image;
  bool get isVideo => mediaType == MediaType.video;
  bool get isAudio => mediaType == MediaType.audio;
}
