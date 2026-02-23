import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_ads/features/auth/data/modals/user_model.dart';

class LocalStorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  static const _userIdKey = 'user_id';
  static const _countryIsoKey = 'country_iso';
  static const _dialCodeKey = 'dial_code';

  static Future<void> saveCountryData(String iso, String dialCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryIsoKey, iso);
    await prefs.setString(_dialCodeKey, dialCode);
  }

  static Future<Map<String, String?>> getCountryData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'iso': prefs.getString(_countryIsoKey),
      'dialCode': prefs.getString(_dialCodeKey),
    };
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Save User Data
  static Future<void> saveUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await _storage.write(key: _userIdKey, value: user.userId);
  }

  // Get User Data
  static Future<UserData?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return UserData.fromJson(jsonDecode(userStr));
  }

  // Clear Storage (Logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_countryIsoKey);
    await prefs.remove(_dialCodeKey);
    await prefs.clear();
    await _storage.delete(key: _userIdKey);
    await _storage.deleteAll();
  }
}
