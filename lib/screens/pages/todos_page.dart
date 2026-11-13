import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../constants/color_scheme.dart';
import '../../models/todo.dart';
import '../../services/storage_service.dart';
import '../../widgets/search_input.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);

  @override
  TodosPageState createState() => TodosPageState();
}

class TodosPageState extends State<TodosPage>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _inputSearchController;
  late TextEditingController _todoInputController;

  List<Todo> _todos = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<Color> _todoColors = const [
    Color(0xFF4A5568), // Slate Grey
    Color(0xFF2B6CB0), // Blue
    Color(0xFF2F855A), // Green
    Color(0xFFC53030), // Red
    Color(0xFFD69E2E), // Amber
    Color(0xFF6B46C1), // Purple
    Color(0xFFD53F8C), // Pink
    Color(0xFF319795), // Teal
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _inputSearchController = TextEditingController();
    _todoInputController = TextEditingController();
    _loadTodos();
  }

  @override
  void dispose() {
    _inputSearchController.dispose();
    _todoInputController.dispose();
    super.dispose();
  }

  void _loadTodos() {
    if (!mounted) return;
    setState(() {
      _todos = StorageService.getTodos(category: _selectedCategory);
    });
  }

  List<Todo> get _filteredTodos {
    var list = _todos;
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((todo) => todo.text.toLowerCase().contains(query)).toList();
    }
    return list;
  }

  Future<void> addTodo() async {
    _todoInputController.clear();
    Color selectedColor = _todoColors.first;
    String selectedCategory = _selectedCategory == 'Semua' ? 'Umum' : _selectedCategory;
    DateTime? reminderDate;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          return AlertDialog(
            backgroundColor: darkGreyColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Tambah To-Do',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _todoInputController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                    decoration: const InputDecoration(
                      hintText: 'Tulis to-do...',
                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  const Text('Kategori:', style: TextStyle(color: lightGreyColor, fontSize: 13, fontFamily: 'Poppins')),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: StorageService.todoCategories.where((c) => c != 'Semua').map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setStateDialog(() => selectedCategory = cat);
                        },
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                        selectedColor: primaryColor,
                        backgroundColor: greycolor.withOpacity(0.4),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Reminder Picker
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: dialogCtx,
                            initialDate: now.add(const Duration(days: 1)),
                            firstDate: now,
                            lastDate: DateTime(2035),
                          );
                          if (pickedDate != null && dialogCtx.mounted) {
                            final pickedTime = await showTimePicker(
                              context: dialogCtx,
                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (pickedTime != null) {
                              setStateDialog(() {
                                reminderDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.alarm_add, size: 18, color: primaryColor),
                        label: Text(
                          reminderDate == null
                              ? 'Atur Deadline'
                              : DateFormat('dd/MM HH:mm').format(reminderDate!),
                          style: const TextStyle(color: primaryColor, fontSize: 12, fontFamily: 'Poppins'),
                        ),
                      ),
                      if (reminderDate != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                          onPressed: () => setStateDialog(() => reminderDate = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Color Picker
                  const Text('Pilih Warna:', style: TextStyle(color: lightGreyColor, fontSize: 13, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _todoColors.map((color) {
                      final isSelected = selectedColor.value == color.value;
                      return GestureDetector(
                        onTap: () => setStateDialog(() => selectedColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final text = _todoInputController.text.trim();
                  if (text.isNotEmpty) {
                    final newTodo = Todo(
                      id: DateTime.now().millisecondsSinceEpoch,
                      text: text,
                      color: selectedColor,
                      category: selectedCategory,
                      reminder: reminderDate,
                    );
                    await StorageService.saveTodo(newTodo);
                  }
                  if (mounted) {
                    Navigator.pop(dialogCtx);
                    _loadTodos();
                  }
                },
                child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              ),
            ],
          );
        },
      ),
    );

    if (mounted) _loadTodos();
  }

  Future<void> _editTodo(Todo todo) async {
    _todoInputController.text = todo.text;
    Color selectedColor = todo.color;
    String selectedCategory = todo.category;
    DateTime? reminderDate = todo.reminder;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          return AlertDialog(
            backgroundColor: darkGreyColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Edit To-Do',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _todoInputController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                    decoration: const InputDecoration(
                      hintText: 'Edit to-do...',
                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  const Text('Kategori:', style: TextStyle(color: lightGreyColor, fontSize: 13, fontFamily: 'Poppins')),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: StorageService.todoCategories.where((c) => c != 'Semua').map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setStateDialog(() => selectedCategory = cat);
                        },
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                        selectedColor: primaryColor,
                        backgroundColor: greycolor.withOpacity(0.4),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Reminder Picker
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: dialogCtx,
                            initialDate: reminderDate ?? now.add(const Duration(days: 1)),
                            firstDate: now,
                            lastDate: DateTime(2035),
                          );
                          if (pickedDate != null && dialogCtx.mounted) {
                            final pickedTime = await showTimePicker(
                              context: dialogCtx,
                              initialTime: reminderDate != null
                                  ? TimeOfDay.fromDateTime(reminderDate!)
                                  : const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (pickedTime != null) {
                              setStateDialog(() {
                                reminderDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.alarm, size: 18, color: primaryColor),
                        label: Text(
                          reminderDate == null
                              ? 'Atur Deadline'
                              : DateFormat('dd/MM HH:mm').format(reminderDate!),
                          style: const TextStyle(color: primaryColor, fontSize: 12, fontFamily: 'Poppins'),
                        ),
                      ),
                      if (reminderDate != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                          onPressed: () => setStateDialog(() => reminderDate = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Color Picker
                  const Text('Pilih Warna:', style: TextStyle(color: lightGreyColor, fontSize: 13, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _todoColors.map((color) {
                      final isSelected = selectedColor.value == color.value;
                      return GestureDetector(
                        onTap: () => setStateDialog(() => selectedColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final text = _todoInputController.text.trim();
                  if (text.isNotEmpty) {
                    final updatedTodo = todo.copyWith(
                      text: text,
                      color: selectedColor,
                      category: selectedCategory,
                      reminder: reminderDate,
                    );
                    await StorageService.saveTodo(updatedTodo);
                  }
                  if (mounted) {
                    Navigator.pop(dialogCtx);
                    _loadTodos();
                  }
                },
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              ),
            ],
          );
        },
      ),
    );

    if (mounted) _loadTodos();
  }

  Future<void> _deleteTodo(Todo todo) async {
    await StorageService.deleteTodo(todo.id);
    _loadTodos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('To-do dihapus'),
        action: SnackBarAction(
          label: 'Batal',
          textColor: primaryColor,
          onPressed: () async {
            await StorageService.saveTodo(todo);
            _loadTodos();
          },
        ),
      ),
    );
  }

  Future<void> _toggleComplete(Todo todo) async {
    final updated = todo.copyWith(isCompleted: !todo.isCompleted);
    await StorageService.saveTodo(updated);
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final filtered = _filteredTodos;
    final totalTodos = _todos.length;
    final completedTodos = _todos.where((t) => t.isCompleted).length;
    final progress = totalTodos > 0 ? (completedTodos / totalTodos) : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
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
            hint: 'Cari To-Do...',
            onChanged: (query) {
              setState(() => _searchQuery = query);
            },
            onClear: () {
              setState(() => _searchQuery = '');
            },
          ),
          const SizedBox(height: 8),

          // Horizontal Category Filter Chips
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: StorageService.todoCategories.length,
              itemBuilder: (context, index) {
                final cat = StorageService.todoCategories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat == 'Semua' ? 'Semua' : '#$cat'),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                      _loadTodos();
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

          // Progress tracker card
          if (totalTodos > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: greycolor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Tugas: $completedTodos dari $totalTodos selesai',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: lightGreyColor,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: darkGreyColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 4),
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist_rtl_rounded, size: 72, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategory == 'Semua'
                                ? "Belum ada to-do list"
                                : "Belum ada to-do kategori '$_selectedCategory'",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Tekan tombol + untuk menambah to-do baru",
                            style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              "To-do tidak ditemukan",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final todo = filtered[index];

                          return Slidable(
                            key: ValueKey(todo.id),
                            endActionPane: ActionPane(
                              extentRatio: 0.35,
                              motion: const ScrollMotion(),
                              children: [
                                GestureDetector(
                                  onTap: () => _editTodo(todo),
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _deleteTodo(todo),
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: const BoxDecoration(
                                      color: dangerColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () => _toggleComplete(todo),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: todo.color,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      todo.isCompleted
                                          ? 'assets/icons/todo-checked.svg'
                                          : 'assets/icons/todo-unchecked.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              if (todo.category != 'Umum') ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    '#${todo.category}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                              ],
                                              if (todo.reminder != null) ...[
                                                const Icon(Icons.alarm, size: 12, color: Color(0xFFF6C90E)),
                                                const SizedBox(width: 3),
                                                Text(
                                                  DateFormat('dd/MM HH:mm').format(todo.reminder!),
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFF6C90E),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (todo.category != 'Umum' || todo.reminder != null)
                                            const SizedBox(height: 4),
                                          Text(
                                            todo.text,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              decoration: todo.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              decorationColor: Colors.white70,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                      ),
          ),
        ],
      ),
    );
  }
}
