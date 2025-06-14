import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // -------------------- AUTH --------------------

  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );
    if (res.statusCode == 200) {
      final token = json.decode(res.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    }
    return false;
  }

  static Future<bool> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'name': name, 'email': email, 'password': password},
    );
    return res.statusCode == 200;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // -------------------- TASK --------------------

  static Future<List<Task>> getTasks({
    String kategori = 'SEMUA',
    String search = '',
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final queryParams = {
      if (kategori != 'SEMUA') 'kategori': kategori,
      if (search.isNotEmpty) 'search': search,
    };

    final uri =
        Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams);

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = json.decode(res.body)['data'];
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat tugas');
    }
  }

  static Future<void> createTask({
    required String judul,
    String? deskripsi,
    String? kategori,
    required DateTime deadline,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final res = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'deadline': deadline.toIso8601String(),
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal menambah tugas');
    }
  }

  static Future<void> updateTask({
    required int id,
    required String judul,
    String? deskripsi,
    String? kategori,
    required DateTime deadline,
    required bool selesai,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final res = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'deadline': deadline.toIso8601String(),
        'status': selesai ? 'selesai' : 'berjalan',
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengupdate tugas');
    }
  }

  static Future<void> deleteTask(int id) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final res = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus tugas');
    }
  }

  static Future<void> updateTaskStatus(int id, bool selesai) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final res = await http.put(
      Uri.parse('$baseUrl/tasks/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'selesai': selesai}),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengubah status tugas');
    }
  }
}
