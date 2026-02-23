import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:we_ads/core/network/local_storage_service.dart';
import 'package:we_ads/features/auth/data/modals/login_response_model.dart';
import 'package:we_ads/features/auth/data/modals/user_model.dart';

enum UserRole { normal, admin }

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.normal);
final userProvider = StateProvider<UserData?>((ref) => null);

final authCheckProvider = FutureProvider<bool>((ref) async {
  final user = await LocalStorageService.getUser();
  if (user != null) {
    ref.read(userProvider.notifier).state = user;
    return true; // Logged in
  }
  return false; // Not logged in
});
