import 'dart:async';
import 'package:flutter/services.dart';
import 'storage_service.dart';

class ReminderAlertItem {
  final int id;
  final String title;
  final String type; // 'Catatan' or 'To-Do'
  final DateTime time;

  ReminderAlertItem({
    required this.id,
    required this.title,
    required this.type,
    required this.time,
  });
}

class ReminderService {
  static Timer? _timer;
  static final Set<String> _triggeredReminders = {};
  static final StreamController<ReminderAlertItem> _alertController =
      StreamController<ReminderAlertItem>.broadcast();

  static Stream<ReminderAlertItem> get onReminderAlert => _alertController.stream;

  static void startListening() {
    _timer?.cancel();
    // Check every 10 seconds for any due reminders
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkReminders();
    });
    _checkReminders();
  }

  static void stopListening() {
    _timer?.cancel();
    _timer = null;
  }

  static void _checkReminders() {
    final now = DateTime.now();

    // 1. Check active notes reminders
    final activeNotes = StorageService.getActiveNotes();
    for (final note in activeNotes) {
      if (note.reminder != null) {
        final key = 'note_${note.id}_${note.reminder!.millisecondsSinceEpoch}';
        // If reminder time is due (within past 5 minutes and not already triggered)
        if (now.isAfter(note.reminder!) &&
            now.difference(note.reminder!).inMinutes < 60 &&
            !_triggeredReminders.contains(key)) {
          _triggeredReminders.add(key);
          _triggerAlert(
            ReminderAlertItem(
              id: note.id,
              title: note.title.isNotEmpty ? note.title : 'Catatan Tanpa Judul',
              type: 'Catatan',
              time: note.reminder!,
            ),
          );
        }
      }
    }

    // 2. Check todos reminders
    final todos = StorageService.getTodos();
    for (final todo in todos) {
      if (todo.reminder != null && !todo.isCompleted) {
        final key = 'todo_${todo.id}_${todo.reminder!.millisecondsSinceEpoch}';
        if (now.isAfter(todo.reminder!) &&
            now.difference(todo.reminder!).inMinutes < 60 &&
            !_triggeredReminders.contains(key)) {
          _triggeredReminders.add(key);
          _triggerAlert(
            ReminderAlertItem(
              id: todo.id,
              title: todo.text,
              type: 'To-Do',
              time: todo.reminder!,
            ),
          );
        }
      }
    }
  }

  static void _triggerAlert(ReminderAlertItem item) {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    } catch (_) {}

    _alertController.add(item);
  }

  // Snooze reminder by minutes
  static Future<void> snoozeReminder(ReminderAlertItem item, int minutes) async {
    final newTime = DateTime.now().add(Duration(minutes: minutes));

    if (item.type == 'Catatan') {
      final notes = StorageService.getActiveNotes();
      final index = notes.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        final updated = notes[index].copyWith(reminder: newTime);
        await StorageService.saveNote(updated);
      }
    } else {
      final todos = StorageService.getTodos();
      final index = todos.indexWhere((t) => t.id == item.id);
      if (index != -1) {
        final updated = todos[index].copyWith(reminder: newTime);
        await StorageService.saveTodo(updated);
      }
    }
  }

  // Dismiss / Clear reminder
  static Future<void> dismissReminder(ReminderAlertItem item) async {
    if (item.type == 'Catatan') {
      final notes = StorageService.getActiveNotes();
      final index = notes.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        final updated = notes[index].copyWith(reminder: null);
        await StorageService.saveNote(updated);
      }
    } else {
      final todos = StorageService.getTodos();
      final index = todos.indexWhere((t) => t.id == item.id);
      if (index != -1) {
        final updated = todos[index].copyWith(reminder: null);
        await StorageService.saveTodo(updated);
      }
    }
  }
}
