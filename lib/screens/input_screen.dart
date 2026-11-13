import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants/color_scheme.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/pin_dialog.dart';

class InputScreen extends StatefulWidget {
  final Note? note;

  const InputScreen({super.key, this.note});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color _selectedColor;
  late DateTime _noteDate;
  bool _isPinned = false;
  bool _isArchived = false;
  bool _isLocked = false;
  String _selectedCategory = 'Umum';
  DateTime? _reminderDate;
  bool _isEditing = false;
  Note? _existingNote;

  final List<Color> _availableColors = const [
    Color(0xFFFFFFFF), // White
    Color(0xFFFFF9C4), // Soft Yellow
    Color(0xFFC8E6C9), // Soft Mint Green
    Color(0xFFBBDEFB), // Soft Sky Blue
    Color(0xFFE1BEE7), // Soft Lavender
    Color(0xFFFFCCBC), // Soft Peach
    Color(0xFFFFCDD2), // Soft Rose
    Color(0xFF37474F), // Slate Dark
  ];

  @override
  void initState() {
    super.initState();
    _existingNote = widget.note;
    _isEditing = _existingNote != null;
    _titleController = TextEditingController(text: _existingNote?.title ?? '');
    _contentController = TextEditingController(text: _existingNote?.content ?? '');
    _selectedColor = _existingNote?.color ?? const Color(0xFFFFFFFF);
    _noteDate = _existingNote?.date ?? DateTime.now();
    _isPinned = _existingNote?.isPinned ?? false;
    _isArchived = _existingNote?.isArchived ?? false;
    _isLocked = _existingNote?.isLocked ?? false;
    _selectedCategory = _existingNote?.category ?? 'Umum';
    _reminderDate = _existingNote?.reminder;

    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_existingNote == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Note) {
        _existingNote = args;
        _isEditing = true;
        _titleController.text = args.title;
        _contentController.text = args.content;
        _selectedColor = args.color;
        _noteDate = args.date;
        _isPinned = args.isPinned;
        _isArchived = args.isArchived;
        _isLocked = args.isLocked;
        _selectedCategory = args.category;
        _reminderDate = args.reminder;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  int get _charCount => _contentController.text.length;

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(2035),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _reminderDate != null
            ? TimeOfDay.fromDateTime(_reminderDate!)
            : const TimeOfDay(hour: 9, minute: 0),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pengingat diatur: ${DateFormat('dd MMM yyyy, HH:mm').format(_reminderDate!)}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleLock() async {
    if (!_isLocked) {
      // Prompt user to verify they know the PIN
      final verified = await PinDialog.verify(context);
      if (verified) {
        setState(() {
          _isLocked = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan dikunci dengan PIN'), duration: Duration(seconds: 1)),
          );
        }
      }
    } else {
      setState(() {
        _isLocked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunci catatan dilepas'), duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _saveNote({bool closeScreen = true}) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (closeScreen && mounted) Navigator.pop(context);
      return;
    }

    final noteToSave = Note(
      id: _isEditing ? _existingNote!.id : DateTime.now().millisecondsSinceEpoch,
      title: title.isEmpty ? 'Tanpa Judul' : title,
      content: content,
      date: DateTime.now(),
      color: _selectedColor,
      isPinned: _isPinned,
      isArchived: _isArchived,
      isDeleted: false,
      category: _selectedCategory,
      reminder: _reminderDate,
      isLocked: _isLocked,
    );

    await StorageService.saveNote(noteToSave);
    _existingNote = noteToSave;
    _isEditing = true;

    if (!mounted) return;
    if (closeScreen) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan disimpan'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _copyNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final textToCopy = title.isNotEmpty ? '$title\n\n$content' : content;

    if (textToCopy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan masih kosong!')),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disalin ke clipboard!'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _deleteNote() async {
    if (!_isEditing || _existingNote == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGreyColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Catatan', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: const Text(
          'Catatan akan dipindahkan ke Kotak Sampah.',
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
      await StorageService.trashNote(_existingNote!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan dipindahkan ke Kotak Sampah'), duration: Duration(seconds: 2)),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkBg = ThemeData.estimateBrightnessForColor(_selectedColor) == Brightness.dark;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF1F2421);
    final hintColor = isDarkBg ? Colors.white54 : const Color(0xFF757575);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveNote(closeScreen: false);
        if (mounted) Navigator.pop(context, true);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _selectedColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => _saveNote(),
            ),
            actions: [
              IconButton(
                icon: Icon(_isLocked ? Icons.lock : Icons.lock_open_rounded),
                tooltip: _isLocked ? 'Catatan Terkunci' : 'Kunci Catatan',
                color: _isLocked ? const Color(0xFFE6A700) : textColor,
                onPressed: _toggleLock,
              ),
              IconButton(
                icon: Icon(_reminderDate != null ? Icons.alarm_on : Icons.alarm_add_outlined),
                tooltip: 'Atur Pengingat',
                color: _reminderDate != null ? const Color(0xFFE6A700) : textColor,
                onPressed: _pickReminder,
              ),
              IconButton(
                icon: Icon(
                  _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: _isPinned ? const Color(0xFFE6A700) : textColor,
                ),
                tooltip: _isPinned ? 'Lepas Sematan' : 'Sematkan Catatan',
                onPressed: () {
                  setState(() => _isPinned = !_isPinned);
                },
              ),
              IconButton(
                icon: Icon(_isArchived ? Icons.archive : Icons.archive_outlined),
                tooltip: _isArchived ? 'Buka Arsip' : 'Arsipkan',
                color: _isArchived ? primaryColor : textColor,
                onPressed: () {
                  setState(() => _isArchived = !_isArchived);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isArchived ? 'Catatan diarsipkan' : 'Catatan dikeluarkan dari arsip'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Salin Catatan',
                onPressed: _copyNote,
              ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Hapus Catatan',
                  onPressed: _deleteNote,
                ),
              IconButton(
                icon: const Icon(Icons.check_rounded, size: 28),
                tooltip: 'Simpan',
                onPressed: () => _saveNote(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Info bar (Timestamp & Word count)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: hintColor),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm').format(_noteDate),
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: hintColor),
                      ),
                      const Spacer(),
                      Text(
                        '$_wordCount kata  •  $_charCount karakter',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: hintColor),
                      ),
                    ],
                  ),
                ),

                // Reminder Pill (if set)
                if (_reminderDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6C90E).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alarm, size: 14, color: Color(0xFFD69E2E)),
                          const SizedBox(width: 6),
                          Text(
                            'Pengingat: ${DateFormat('dd MMM, HH:mm').format(_reminderDate!)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD69E2E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _reminderDate = null),
                            child: const Icon(Icons.close, size: 14, color: Color(0xFFD69E2E)),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Category Chips Selector
                Container(
                  height: 38,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: StorageService.noteCategories.length - 1, // Exclude 'Semua'
                    itemBuilder: (context, index) {
                      final cat = StorageService.noteCategories[index + 1];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('#$cat'),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : textColor,
                          ),
                          selectedColor: primaryColor,
                          backgroundColor: textColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    },
                  ),
                ),

                // Title Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: TextField(
                    controller: _titleController,
                    autofocus: !_isEditing,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Judul Catatan...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: hintColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Content Input
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        height: 1.6,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mulai menulis catatan di sini...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: hintColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                // Color palette
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isKeyboardOpen ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkBg ? Colors.black26 : Colors.white.withOpacity(0.55),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.palette_outlined, size: 20, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        'Warna:',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _availableColors.map((color) {
                              final isSelected = _selectedColor.value == color.value;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = color),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? primaryColor : Colors.grey.withOpacity(0.5),
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
