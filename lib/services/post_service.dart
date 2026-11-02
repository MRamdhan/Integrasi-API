import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

/// Mengubah error teknis menjadi kalimat yang dimengerti pengguna.
String pesanError(Object error) {
  if (error is TimeoutException) {
    return 'Server terlalu lama merespons. Coba lagi sebentar lagi.';
  }
  final text = error.toString();
  if (error is http.ClientException ||
      text.contains('SocketException') ||
      text.contains('Failed host lookup')) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  return text.replaceFirst('Exception: ', '');
}

/// Semua komunikasi dengan server ada di kelas ini.
///
/// Setiap method mengikuti RESEP 4 LANGKAH yang sama:
///   1. Buat alamat (Uri)
///   2. Kirim request, lalu tunggu response (await)
///   3. Cek status code
///   4. Ubah JSON menjadi objek Dart
class PostService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Batas waktu menunggu server. Lewat dari ini, request dianggap gagal.
  static const Duration timeout = Duration(seconds: 10);

  /// Client bisa diganti dengan MockClient saat testing.
  final http.Client client;

  PostService({http.Client? client}) : client = client ?? http.Client();

  /// GET /posts - ambil semua pengumuman.
  Future<List<Post>> fetchPosts() async {
    // 1. Buat alamat
    final url = Uri.parse('$baseUrl/posts');

    // 2. Kirim request
    final response = await client.get(url).timeout(timeout);

    // 3. Cek status code (200 = OK)
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat pengumuman (kode ${response.statusCode})');
    }

    // 4. Ubah JSON menjadi objek
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Post.fromJson(item)).toList();
  }

  /// GET /posts/{id}/comments - ambil komentar milik satu pengumuman.
  Future<List<Comment>> fetchComments(int postId) async {
    // 1. Buat alamat
    final url = Uri.parse('$baseUrl/posts/$postId/comments');

    // 2. Kirim request
    final response = await client.get(url).timeout(timeout);

    // 3. Cek status code
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat komentar (kode ${response.statusCode})');
    }

    // 4. Ubah JSON menjadi objek
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Comment.fromJson(item)).toList();
  }

  /// POST /posts - kirim pengumuman baru.
  ///
  /// Server membalas dengan pengumuman yang sudah diberi `id`.
  Future<Post> createPost(Post post) async {
    // 1. Buat alamat
    final url = Uri.parse('$baseUrl/posts');

    // 2. Kirim request beserta header dan body JSON
    final response = await client
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(post.toJson()),
        )
        .timeout(timeout);

    // 3. Cek status code (201 = Created)
    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim pengumuman (kode ${response.statusCode})');
    }

    // 4. Ubah JSON menjadi objek
    return Post.fromJson(jsonDecode(response.body));
  }
}
