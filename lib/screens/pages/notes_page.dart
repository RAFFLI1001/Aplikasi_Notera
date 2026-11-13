import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../constants/color_scheme.dart';
import '../../models/note.dart';
import '../../routes/route_names.dart';
import '../../services/storage_service.dart';
import '../../widgets/note_card.dart';
import '../../widgets/pin_dialog.dart';
import '../../widgets/search_input.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _inputSearchController;
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _selectedCategory = 'Semua';
  bool _isGridView = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isGridView = StorageService.isGridView();
    _inputSearchController = TextEditingController();
    _inputSearchController.addListener(_filterNotes);
    _loadNotes();
  }

  @override
  void dispose() {
    _inputSearchController.dispose();
    super.dispose();
  }

  void toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
    StorageService.setGridView(_isGridView);
  }

  bool get isGridView => _isGridView;

  void _loadNotes() {
    final activeNotes = StorageService.getActiveNotes(category: _selectedCategory);
    if (!mounted) return;
    setState(() {
      _notes = activeNotes;
      _filterNotes();
    });
  }

  void _filterNotes() {
    final query = _inputSearchController.text.toLowerCase().trim();
    final allCategoryNotes = StorageService.getActiveNotes(category: _selectedCategory);

    setState(() {
      _notes = allCategoryNotes;
      if (query.isEmpty) {
        _filteredNotes = List.from(allCategoryNotes);
      } else {
        _filteredNotes = allCategoryNotes.where((note) {
          return note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query) ||
              note.category.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> addNote() async {
    await Navigator.pushNamed(context, RouteNames.inputScreen);
    if (mounted) {
      _loadNotes();
    }
  }

  Future<void> _openNote(Note note) async {
    if (note.isLocked) {
      final unlocked = await PinDialog.verify(context);
      if (!unlocked) return;
    }

    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      RouteNames.inputScreen,
      arguments: note,
    );
    if (mounted) {
      _loadNotes();
    }
  }

  Future<void> _deleteNote(Note note) async {
    await StorageService.trashNote(note.id);
    _loadNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Catatan dipindahkan ke Kotak Sampah'),
        action: SnackBarAction(
          label: 'Batal',
          textColor: primaryColor,
          onPressed: () async {
            await StorageService.restoreNote(note.id);
            _loadNotes();
          },
        ),
      ),
    );
  }

  Future<void> _archiveNote(Note note) async {
    await StorageService.archiveNote(note.id, true);
    _loadNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Catatan diarsipkan'),
        action: SnackBarAction(
          label: 'Batal',
          textColor: primaryColor,
          onPressed: () async {
            await StorageService.archiveNote(note.id, false);
            _loadNotes();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 14, bottom: 6),
            child: Center(
              child: Text(
                'Hi, Sobat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          SearchInput(
            controller: _inputSearchController,
            hint: 'Cari Catatan atau #kategori...',
            onChanged: (_) => _filterNotes(),
            onClear: () => _filterNotes(),
          ),
          const SizedBox(height: 8),

          // Horizontal Category Filter Chips
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: StorageService.noteCategories.length,
              itemBuilder: (context, index) {
                final cat = StorageService.noteCategories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat == 'Semua' ? 'Semua' : '#$cat'),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      _loadNotes();
                    },
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                    selectedColor: primaryColor,
                    backgroundColor: greycolor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 72,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategory == 'Semua'
                                ? "Belum ada catatan"
                                : "Belum ada catatan kategori '$_selectedCategory'",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Tekan tombol + untuk menambah catatan baru",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _filteredNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Catatan tidak ditemukan",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? MasonryGridView.count(
                            itemCount: _filteredNotes.length,
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemBuilder: (context, index) {
                              final note = _filteredNotes[index];
                              return NoteCard(
                                key: ValueKey(note.id),
                                note: note,
                                isListView: false,
                                onTap: () => _openNote(note),
                                onEdit: () => _openNote(note),
                                onDelete: () => _deleteNote(note),
                                onArchive: () => _archiveNote(note),
                                onPinToggle: () async {
                                  final updated = note.copyWith(isPinned: !note.isPinned);
                                  await StorageService.saveNote(updated);
                                  _loadNotes();
                                },
                              );
                            },
                          )
                        : ListView.separated(
                            itemCount: _filteredNotes.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final note = _filteredNotes[index];
                              return NoteCard(
                                key: ValueKey(note.id),
                                note: note,
                                isListView: true,
                                onTap: () => _openNote(note),
                                onEdit: () => _openNote(note),
                                onDelete: () => _deleteNote(note),
                                onArchive: () => _archiveNote(note),
                                onPinToggle: () async {
                                  final updated = note.copyWith(isPinned: !note.isPinned);
                                  await StorageService.saveNote(updated);
                                  _loadNotes();
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
