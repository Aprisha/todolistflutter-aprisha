import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:8000/api';

  // Simpan token di shared_preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Hapus token saat logout
  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await http.post(Uri.parse('$_baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token'});
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Cek login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Login user
  static Future<dynamic> login(String email, String password) async {
    final response = await http.post(Uri.parse('$_baseUrl/login'),
        body: {'email': email, 'password': password});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['token']);
      return true;
    } else {
      final error = json.decode(response.body);
      return error['message'] ?? 'Login gagal';
    }
  }

  // Register user
  static Future<dynamic> register(
      String name, String email, String password) async {
    final response = await http.post(Uri.parse('$_baseUrl/register'),
        body: {'name': name, 'email': email, 'password': password});

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      await saveToken(data['token']);
      return true;
    } else {
      final error = json.decode(response.body);
      return error['message'] ?? 'Registrasi gagal';
    }
  }
}
