import 'package:flutter/material.dart';
import '../constants/color_scheme.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/note_card.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<Note> _trashNotes = [];

  @override
  void initState() {
    super.initState();
    _loadTrash();
  }

  void _loadTrash() {
    setState(() {
      _trashNotes = StorageService.getTrashNotes();
    });
  }

  Future<void> _restore(Note note) async {
    await StorageService.restoreNote(note.id);
    _loadTrash();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil dipulihkan!'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _deletePermanent(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGreyColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Permanen', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: const Text(
          'Catatan ini akan dihapus secara permanen dan tidak dapat dipulihkan lagi. Lanjutkan?',
          style: TextStyle(color: lightGreyColor, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteNote(note.id);
      _loadTrash();
    }
  }

  Future<void> _emptyTrash() async {
    if (_trashNotes.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGreyColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kosongkan Kotak Sampah', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: const Text(
          'Semua catatan di dalam kotak sampah akan dihapus secara permanen. Lanjutkan?',
          style: TextStyle(color: lightGreyColor, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kosongkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.emptyTrash();
      _loadTrash();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreyColor,
      appBar: AppBar(
        title: const Text('Kotak Sampah', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: darkGreyColor,
        elevation: 0,
        actions: [
          if (_trashNotes.isNotEmpty)
            TextButton.icon(
              onPressed: _emptyTrash,
              icon: const Icon(Icons.delete_forever, color: dangerColor, size: 20),
              label: const Text('Kosongkan', style: TextStyle(color: dangerColor, fontFamily: 'Poppins')),
            ),
        ],
      ),
      body: _trashNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 72, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Kotak sampah kosong',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Poppins', fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _trashNotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = _trashNotes[index];
                return NoteCard(
                  note: note,
                  onTap: () {},
                  onEdit: () => _restore(note),
                  onDelete: () => _deletePermanent(note),
                  isTrashView: true,
                );
              },
            ),
    );
  }
}
