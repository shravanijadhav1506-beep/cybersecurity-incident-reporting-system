import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static List<Map<String, String>> users = [];

  static Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final savedUsers = prefs.getString('users');

    if (savedUsers != null) {
      final List<dynamic> decodedUsers = jsonDecode(savedUsers);

      users = decodedUsers.map<Map<String, String>>((user) {
        return Map<String, String>.from(user);
      }).toList();
    }
  }

  static Future<void> saveUsers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'users',
      jsonEncode(users),
    );
  }

  static Future<void> addUser(Map<String, String> user) async {
    users.add(user);
    await saveUsers();
  }
}