import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nusa_info/models/post.dart';
import 'package:nusa_info/services/post_service.dart';

// MockClient berpura-pura menjadi server, jadi test berjalan tanpa internet.
void main() {
  group('Post', () {
    test('fromJson membaca semua field', () {
      final post = Post.fromJson({
        'userId': 1,
        'id': 7,
        'title': 'Jadwal UTS',
        'body': 'UTS dimulai Senin.',
      });

      expect(post.id, 7);
      expect(post.userId, 1);
      expect(post.title, 'Jadwal UTS');
      expect(post.body, 'UTS dimulai Senin.');
    });

    test('toJson tidak mengirim id', () {
      const post = Post(id: 0, userId: 1, title: 'Judul', body: 'Isi');

      expect(post.toJson(), {'userId': 1, 'title': 'Judul', 'body': 'Isi'});
    });
  });

  group('PostService', () {
    test('fetchPosts mengubah JSON list menjadi List<Post>', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/posts');
        return http.Response(
          jsonEncode([
            {'userId': 1, 'id': 1, 'title': 'A', 'body': 'a'},
            {'userId': 1, 'id': 2, 'title': 'B', 'body': 'b'},
          ]),
          200,
        );
      });

      final posts = await PostService(client: client).fetchPosts();

      expect(posts.length, 2);
      expect(posts.first.title, 'A');
    });

    test('fetchPosts melempar Exception jika status bukan 200', () async {
      final client = MockClient((_) async => http.Response('Not Found', 404));

      expect(PostService(client: client).fetchPosts(), throwsException);
    });

    test('fetchComments memanggil /posts/{id}/comments', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/posts/3/comments');
        return http.Response(
          jsonEncode([
            {
              'postId': 3,
              'id': 11,
              'name': 'Budi',
              'email': 'budi@mail.com',
              'body': 'Terima kasih infonya.',
            },
          ]),
          200,
        );
      });

      final comments = await PostService(client: client).fetchComments(3);

      expect(comments.length, 1);
      expect(comments.first.name, 'Budi');
    });

    test('createPost mengirim JSON dan membaca balasan 201', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], contains('application/json'));
        final sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({...sent, 'id': 101}), 201);
      });

      const draft = Post(id: 0, userId: 1, title: 'Judul', body: 'Isi');
      final created = await PostService(client: client).createPost(draft);

      expect(created.id, 101);
      expect(created.title, 'Judul');
    });
  });
}
