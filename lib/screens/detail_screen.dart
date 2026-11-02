import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';

/// Isi lengkap satu pengumuman beserta komentarnya (GET /posts/{id}/comments).
///
/// Isi pengumuman sudah kita punya dari halaman Home,
/// jadi yang perlu diambil dari server hanya komentarnya.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.post, required this.service});

  final Post post;
  final PostService service;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = widget.service.fetchComments(widget.post.id);
  }

  void _reload() {
    setState(() {
      _commentsFuture = widget.service.fetchComments(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #${widget.post.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.post.title, style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(widget.post.body, style: textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text('Komentar', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<Comment>>(
            future: _commentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        pesanError(snapshot.error!),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              final comments = snapshot.data!;
              return Column(
                children: [
                  for (final comment in comments)
                    Card(
                      child: ListTile(
                        title: Text(comment.name),
                        subtitle: Text('${comment.email}\n${comment.body}'),
                        isThreeLine: true,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
