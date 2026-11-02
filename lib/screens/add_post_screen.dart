import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';

/// Formulir untuk mengirim pengumuman baru (POST /posts).
class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key, required this.service});

  final PostService service;

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  /// true selama request berjalan; tombol Kirim dinonaktifkan.
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    // id diisi 0 karena belum ada; server yang akan memberi id baru.
    final draft = Post(
      id: 0,
      userId: 1,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );

    try {
      final created = await widget.service.createPost(draft);
      if (!mounted) return;
      Navigator.pop(context, created); // Kirim hasilnya ke Home Screen.
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesanError(error))),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().length < 5)
                  ? 'Judul minimal 5 karakter'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Isi pengumuman',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              validator: (value) => (value == null || value.trim().length < 20)
                  ? 'Isi minimal 20 karakter'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSending ? null : _submit,
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSending ? 'Mengirim...' : 'Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
