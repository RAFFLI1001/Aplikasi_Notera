import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPinToggle;
  final VoidCallback? onArchive;
  final bool isTrashView;
  final bool isArchiveView;
  final bool isListView;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onPinToggle,
    this.onArchive,
    this.isTrashView = false,
    this.isArchiveView = false,
    this.isListView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(note.date);
    final isLightColor = ThemeData.estimateBrightnessForColor(note.color) == Brightness.light;
    final textColor = isLightColor ? const Color(0xFF1E2022) : Colors.white;
    final subtextColor = isLightColor ? const Color(0xFF555B62) : const Color(0xFFD0D0D0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: note.color,
            borderRadius: BorderRadius.circular(16),
            border: note.isPinned && !isTrashView && !isArchiveView
                ? Border.all(color: const Color(0xFFF6C90E), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top badges row (Category, Reminder, Lock, Pin)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (note.category.isNotEmpty && note.category != 'Umum') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${note.category}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (note.reminder != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6C90E).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm, size: 10, color: Color(0xFFD69E2E)),
                            const SizedBox(width: 3),
                            Text(
                              DateFormat('dd/MM HH:mm').format(note.reminder!),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD69E2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    const Spacer(),
                    if (note.isLocked)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.lock, size: 15, color: textColor),
                      ),
                    if (note.isPinned && !isTrashView && !isArchiveView)
                      const Icon(Icons.push_pin, size: 16, color: Color(0xFFE6A700)),
                  ],
                ),
                if ((note.category.isNotEmpty && note.category != 'Umum') || note.reminder != null || note.isLocked || note.isPinned)
                  const SizedBox(height: 8),

                // Title or Locked Content
                if (note.isLocked) ...[
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 22, color: textColor.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note.title.isNotEmpty ? note.title : 'Catatan Terkunci',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🔒 Dilindungi PIN. Ketuk untuk membuka.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: subtextColor,
                    ),
                  ),
                ] else ...[
                  if (note.title.isNotEmpty) ...[
                    Text(
                      note.title,
                      maxLines: isListView ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (note.content.isNotEmpty) ...[
                    Text(
                      note.content,
                      maxLines: isListView ? 3 : 7,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        height: 1.4,
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 10),

                // Bottom actions row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: subtextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isTrashView) ...[
                      InkWell(
                        onTap: onEdit, // Restore action in trash view
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.restore_from_trash, size: 18, color: textColor),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onDelete, // Permanent delete in trash view
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete_forever, size: 18, color: Colors.redAccent),
                        ),
                      ),
                    ] else if (isArchiveView) ...[
                      InkWell(
                        onTap: onArchive, // Unarchive
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.unarchive_outlined, size: 18, color: textColor),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onDelete, // Trash
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline, size: 18, color: subtextColor),
                        ),
                      ),
                    ] else ...[
                      if (onPinToggle != null) ...[
                        InkWell(
                          onTap: onPinToggle,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                              size: 17,
                              color: note.isPinned ? const Color(0xFFE6A700) : subtextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                      if (onArchive != null) ...[
                        InkWell(
                          onTap: onArchive,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.archive_outlined, size: 17, color: subtextColor),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.edit_outlined, size: 17, color: subtextColor),
                        ),
                      ),
                      const SizedBox(width: 2),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline, size: 17, color: subtextColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
