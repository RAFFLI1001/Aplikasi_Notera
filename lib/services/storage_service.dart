import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/todo.dart';

class StorageService {
  static const String notesBoxName = 'notes_box';
  static const String todosBoxName = 'todos_box';
  static const String settingsBoxName = 'settings_box';

  static Box? _notesBox;
  static Box? _todosBox;
  static Box? _settingsBox;

  static final Map<int, Note> _memoryNotes = {};
  static final Map<int, Todo> _memoryTodos = {};

  static const List<String> noteCategories = [
    'Semua',
    'Umum',
    'Kuliah',
    'Kerja',
    'Pribadi',
    'Ide',
    'Belanja',
  ];

  static const List<String> todoCategories = [
    'Semua',
    'Umum',
    'Penting',
    'Harian',
    'Belanja',
  ];

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      _notesBox = Hive.isBoxOpen(notesBoxName)
          ? Hive.box(notesBoxName)
          : await Hive.openBox(notesBoxName);

      _todosBox = Hive.isBoxOpen(todosBoxName)
          ? Hive.box(todosBoxName)
          : await Hive.openBox(todosBoxName);

      _settingsBox = Hive.isBoxOpen(settingsBoxName)
          ? Hive.box(settingsBoxName)
          : await Hive.openBox(settingsBoxName);

      _loadDataFromHive();
      debugPrint('StorageService: Initialized successfully.');
    } catch (e, stack) {
      debugPrint('StorageService: Init fallback to memory ($e)\n$stack');
    }
  }

  static void _loadDataFromHive() {
    if (_notesBox != null && _notesBox!.isOpen) {
      for (final key in _notesBox!.keys) {
        try {
          final val = _notesBox!.get(key);
          if (val is Map) {
            final note = Note.fromMap(val);
            _memoryNotes[note.id] = note;
          }
        } catch (e) {
          debugPrint('Error loading note $key: $e');
        }
      }
    }

    if (_todosBox != null && _todosBox!.isOpen) {
      for (final key in _todosBox!.keys) {
        try {
          final val = _todosBox!.get(key);
          if (val is Map) {
            final todo = Todo.fromMap(val);
            _memoryTodos[todo.id] = todo;
          }
        } catch (e) {
          debugPrint('Error loading todo $key: $e');
        }
      }
    }
  }

  // --- SETTINGS (PIN & VIEW MODE) ---
  static String getPin() {
    return _settingsBox?.get('app_pin', defaultValue: '1234')?.toString() ?? '1234';
  }

  static Future<void> setPin(String newPin) async {
    try {
      await _settingsBox?.put('app_pin', newPin);
    } catch (e) {
      debugPrint('Error saving PIN: $e');
    }
  }

  static bool isGridView() {
    return _settingsBox?.get('is_grid_view', defaultValue: true) == true;
  }

  static Future<void> setGridView(bool value) async {
    try {
      await _settingsBox?.put('is_grid_view', value);
    } catch (e) {
      debugPrint('Error saving view mode: $e');
    }
  }

  // --- NOTES QUERY ---
  static List<Note> getActiveNotes({String category = 'Semua'}) {
    final list = _memoryNotes.values
        .where((n) => !n.isDeleted && !n.isArchived)
        .where((n) => category == 'Semua' || n.category == category)
        .toList();

    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.date.compareTo(a.date);
    });
    return list;
  }

  static List<Note> getArchivedNotes() {
    final list = _memoryNotes.values
        .where((n) => n.isArchived && !n.isDeleted)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static List<Note> getTrashNotes() {
    final list = _memoryNotes.values
        .where((n) => n.isDeleted)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Backward-compatible getNotes()
  static List<Note> getNotes() => getActiveNotes();

  static Future<void> saveNote(Note note) async {
    _memoryNotes[note.id] = note;
    try {
      if (_notesBox != null && _notesBox!.isOpen) {
        await _notesBox!.put(note.id, note.toMap());
      } else {
        _notesBox = await Hive.openBox(notesBoxName);
        await _notesBox!.put(note.id, note.toMap());
      }
    } catch (e) {
      debugPrint('StorageService: Error persisting note: $e');
    }
  }

  // Move to Trash (Soft delete)
  static Future<void> trashNote(int id) async {
    final note = _memoryNotes[id];
    if (note != null) {
      final trashed = note.copyWith(isDeleted: true);
      await saveNote(trashed);
    }
  }

  // Restore from Trash / Archive
  static Future<void> restoreNote(int id) async {
    final note = _memoryNotes[id];
    if (note != null) {
      final restored = note.copyWith(isDeleted: false, isArchived: false);
      await saveNote(restored);
    }
  }

  // Toggle Archive
  static Future<void> archiveNote(int id, bool archive) async {
    final note = _memoryNotes[id];
    if (note != null) {
      final updated = note.copyWith(isArchived: archive, isDeleted: false);
      await saveNote(updated);
    }
  }

  // Permanent Delete
  static Future<void> deleteNote(int id) async {
    _memoryNotes.remove(id);
    try {
      if (_notesBox != null && _notesBox!.isOpen) {
        await _notesBox!.delete(id);
      }
    } catch (e) {
      debugPrint('StorageService: Error deleting note: $e');
    }
  }

  static Future<void> emptyTrash() async {
    final trashIds = _memoryNotes.values
        .where((n) => n.isDeleted)
        .map((n) => n.id)
        .toList();

    for (final id in trashIds) {
      await deleteNote(id);
    }
  }

  // --- TODOS ---
  static List<Todo> getTodos({String category = 'Semua'}) {
    final list = _memoryTodos.values
        .where((t) => category == 'Semua' || t.category == category)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static Future<void> saveTodo(Todo todo) async {
    _memoryTodos[todo.id] = todo;
    try {
      if (_todosBox != null && _todosBox!.isOpen) {
        await _todosBox!.put(todo.id, todo.toMap());
      } else {
        _todosBox = await Hive.openBox(todosBoxName);
        await _todosBox!.put(todo.id, todo.toMap());
      }
    } catch (e) {
      debugPrint('StorageService: Error persisting todo: $e');
    }
  }

  static Future<void> deleteTodo(int id) async {
    _memoryTodos.remove(id);
    try {
      if (_todosBox != null && _todosBox!.isOpen) {
        await _todosBox!.delete(id);
      }
    } catch (e) {
      debugPrint('StorageService: Error deleting todo: $e');
    }
  }

  // --- BACKUP & RESTORE (JSON) ---
  static String exportBackupJson() {
    final data = {
      'app': 'Notera',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'notes': _memoryNotes.values.map((n) => n.toMap()).toList(),
      'todos': _memoryTodos.values.map((t) => t.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<int> importBackupJson(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map) return 0;

      int count = 0;
      if (decoded['notes'] is List) {
        for (final item in decoded['notes']) {
          if (item is Map) {
            final note = Note.fromMap(item);
            await saveNote(note);
            count++;
          }
        }
      }

      if (decoded['todos'] is List) {
        for (final item in decoded['todos']) {
          if (item is Map) {
            final todo = Todo.fromMap(item);
            await saveTodo(todo);
            count++;
          }
        }
      }
      return count;
    } catch (e) {
      debugPrint('StorageService: Import backup failed: $e');
      return 0;
    }
  }
}
