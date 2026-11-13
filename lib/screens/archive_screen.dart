import 'package:flutter/material.dart';
import '../constants/color_scheme.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/note_card.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Note> _archivedNotes = [];

  @override
  void initState() {
    super.initState();
    _loadArchived();
  }

  void _loadArchived() {
    setState(() {
      _archivedNotes = StorageService.getArchivedNotes();
    });
  }

  Future<void> _unarchiveNote(Note note) async {
    await StorageService.archiveNote(note.id, false);
    _loadArchived();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan dikembalikan dari arsip'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _deleteNote(Note note) async {
    await StorageService.trashNote(note.id);
    _loadArchived();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan dipindahkan ke kotak sampah'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreyColor,
      appBar: AppBar(
        title: const Text('Arsip Catatan', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: darkGreyColor,
        elevation: 0,
      ),
      body: _archivedNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 72, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada catatan yang diarsipkan',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Poppins', fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _archivedNotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = _archivedNotes[index];
                return NoteCard(
                  note: note,
                  onTap: () {},
                  onEdit: () => _unarchiveNote(note),
                  onDelete: () => _deleteNote(note),
                  onArchive: () => _unarchiveNote(note),
                  isArchiveView: true,
                );
              },
            ),
    );
  }
}
