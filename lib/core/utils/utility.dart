import 'package:image_picker/image_picker.dart';

Future<String?> pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source, imageQuality: 80);

  if (image != null) {
    return image.path; // Returns the local file path
  }
  return null;
}

String formatDateRange(DateTime date) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return "${months[date.month - 1]} ${date.day}";
}
