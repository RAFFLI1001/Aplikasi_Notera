import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/note.dart';
import '../../widgets/search_input.dart';
import '../../widgets/note_card.dart';

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
  int _nextId = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _inputSearchController = TextEditingController();
    _inputSearchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _inputSearchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  void addNote() {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  Color _selectedColor = Colors.white; // default color

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Notes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Pilihan warna
                Row(
                  children: [
                    const Text("Choose color: "),
                    const SizedBox(width: 12),
                    ...[
                      Colors.white,
                      Colors.yellow,
                      Colors.greenAccent,
                      Colors.blueAccent,
                      Colors.pinkAccent,
                      Colors.orangeAccent,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setStateModal(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _selectedColor == color
                                ? Border.all(width: 3, color: Colors.black)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final content = contentController.text.trim();

                          if (title.isEmpty || content.isEmpty) return;

                          setState(() {
                            _notes.add(Note(
                              id: _nextId++,
                              title: title,
                              content: content,
                              date: DateTime.now(),
                              color: _selectedColor,  // simpan warna
                            ));
                            _onSearchChanged();
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}

  void _editNote(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Note"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: "Title"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(hintText: "Content"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = titleController.text.trim();
                final newContent = contentController.text.trim();

                if (newTitle.isEmpty || newContent.isEmpty) return;

                setState(() {
                  note.title = newTitle;
                  note.content = newContent;
                  _onSearchChanged();
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(Note note) {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
      _onSearchChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
  padding: EdgeInsets.only(top: 24, bottom: 8),
  child: Center(
    child: Text(
      'Hi, Sobat',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
),

          SearchInput(
            controller: _inputSearchController,
            hint: 'Search Notes',
            onChanged: (_) => _onSearchChanged(),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(
                    child: Text(
                      "No Notes found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : MasonryGridView.count(
                    itemCount: _filteredNotes.length,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return NoteCard(
                        note: note,
                        onEdit: () => _editNote(note),
                        onDelete: () => _deleteNote(note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add),
        backgroundColor: Colors.yellow[700],
      ),
    );
  }
}
