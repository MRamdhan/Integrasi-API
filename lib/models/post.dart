/// Satu pengumuman kampus.
///
/// Contoh JSON dari GET /posts/1:
///
/// ```json
/// {
///   "userId": 1,
///   "id": 1,
///   "title": "Jadwal UTS semester ganjil",
///   "body": "UTS dimulai tanggal ..."
/// }
/// ```
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// JSON -> Post. Dipakai setelah MENERIMA data dari server.
  ///
  /// Nama key ('userId', 'title', ...) harus sama persis dengan JSON.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// Post -> JSON. Dipakai saat MENGIRIM data ke server.
  ///
  /// `id` tidak dikirim karena server yang akan membuatkannya.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}

/// Satu komentar pada pengumuman.
///
/// Contoh JSON dari GET /posts/1/comments:
///
/// ```json
/// {
///   "postId": 1,
///   "id": 1,
///   "name": "id labore ex et quam laborum",
///   "email": "Eliseo@gardner.biz",
///   "body": "laudantium enim quasi ..."
/// }
/// ```
///
/// Diletakkan di file ini agar struktur folder tetap sederhana.
class Comment {
  final int id;
  final String name;
  final String email;
  final String body;

  const Comment({
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}
