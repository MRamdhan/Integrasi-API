import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import 'add_post_screen.dart';
import 'detail_screen.dart';

/// Halaman utama: daftar pengumuman dari server (GET /posts).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.service});

  final PostService service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Future dibuat SEKALI di initState(), bukan di dalam build().
  // Kalau dipanggil di build(), request terkirim ulang setiap layar digambar.
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = widget.service.fetchPosts();
  }

  /// Dipakai oleh RefreshIndicator dan tombol "Coba Lagi".
  Future<void> _reload() async {
    setState(() {
      _postsFuture = widget.service.fetchPosts();
    });
    try {
      await _postsFuture;
    } catch (_) {
      // Error sudah ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _openAddPost(List<Post> posts) async {
    // AddPostScreen mengembalikan Post baru jika berhasil dikirim.
    final newPost = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => AddPostScreen(service: widget.service)),
    );
    if (newPost == null || !mounted) return;

    // JSONPlaceholder tidak benar-benar menyimpan data,
    // jadi kita tambahkan sendiri ke daftar yang sedang tampil.
    setState(() => posts.insert(0, newPost));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Pengumuman berhasil dibuat (id ${newPost.id}).'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('NusaInfo Kampus')),
          body: _buildBody(snapshot),
          floatingActionButton: snapshot.hasData
              ? FloatingActionButton.extended(
                  onPressed: () => _openAddPost(snapshot.data!),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Post>> snapshot) {
    // Keadaan 1: masih menunggu response
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Keadaan 2: request gagal -> pesan error + tombol "Coba Lagi"
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                pesanError(snapshot.error!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Keadaan 3: data berhasil diterima
    final posts = snapshot.data!;
    if (posts.isEmpty) {
      return const Center(child: Text('Belum ada pengumuman.'));
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        // Agar tarik-untuk-muat-ulang tetap bisa dipakai walau list pendek.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${post.id}')),
              title: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(
                    post: post,
                    service: widget.service,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
