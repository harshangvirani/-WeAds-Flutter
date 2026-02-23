import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaDeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const MediaDeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 10.r,
        backgroundColor: Colors.black54,
        child: Icon(Icons.close, size: 12, color: Colors.white),
      ),
    );
  }
}
