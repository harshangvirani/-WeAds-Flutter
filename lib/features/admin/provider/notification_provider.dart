import 'package:flutter_riverpod/legacy.dart';

final selectedImagesProvider = StateProvider<List<String>>((ref) => []);
final selectedTimeProvider = StateProvider<String>((ref) => "Select time");
final selectedDateProvider = StateProvider<String>((ref) => "Jan 12");
final selectedLocationsProvider = StateProvider<List<String>>(
  (ref) => [
    "India",
    "Taiwan, Taipei",
    "NYC, NY",
    "Florida, USA",
    "Chicago, USA",
  ],
);
final selectedRepeatProvider = StateProvider<String>((ref) => "Daily");
final repeatDescriptionProvider = StateProvider<String>((ref) => "");
final selectedTimesProvider = StateProvider<List<String>>((ref) => []);
final selectedDaysProvider = StateProvider<List<String>>((ref) => []);
