import 'package:flutter/material.dart';
import 'package:flutter_note/constants/color_scheme.dart';
import 'package:flutter_note/widgets/search_input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Todo {
  String text;
  bool isCompleted;
  Color color;

  Todo({
    required this.text,
    this.isCompleted = false,
    this.color = const Color(0xFF6E6E6E),
  });
}

class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  late TextEditingController _inputSearchController;
  late TextEditingController _newTodoController;

  List<Todo> _todos = [];
  String _searchQuery = '';
  bool _isDialogOpen = false;
  Color _selectedColor = const Color(0xFF6E6E6E);

  @override
  void initState() {
    super.initState();
    _inputSearchController = TextEditingController();
    _newTodoController = TextEditingController();
  }

  @override
  void dispose() {
    _inputSearchController.dispose();
    _newTodoController.dispose();
    super.dispose();
  }

  void _addTodo() {
    _newTodoController.clear();
    _selectedColor = Colors.primaries[_todos.length % Colors.primaries.length];
    setState(() => _isDialogOpen = true);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('New Todo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newTodoController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Enter todo...'),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: Colors.primaries.map((color) {
                    return GestureDetector(
                      onTap: () => setStateDialog(() => _selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isDialogOpen = false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = _newTodoController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _todos.add(Todo(text: text, color: _selectedColor));
                    });
                  }
                  Navigator.pop(context);
                  setState(() => _isDialogOpen = false);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editTodo(int index) {
    _newTodoController.text = _todos[index].text;
    _selectedColor = _todos[index].color;
    setState(() => _isDialogOpen = true);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Todo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newTodoController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Edit todo...'),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: Colors.primaries.map((color) {
                    return GestureDetector(
                      onTap: () => setStateDialog(() => _selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isDialogOpen = false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _todos[index].text = _newTodoController.text.trim();
                    _todos[index].color = _selectedColor;
                  });
                  Navigator.pop(context);
                  setState(() => _isDialogOpen = false);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _toggleComplete(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  List<Todo> get _filteredTodos {
    if (_searchQuery.isEmpty) return _todos;
    return _todos
        .where((todo) =>
            todo.text.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !_isDialogOpen,
        child: FloatingActionButton(
          onPressed: _addTodo,
          backgroundColor: Colors.yellow[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Colors.indigo),
        ),
      ),
      body: Column(
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
            hint: 'Search Todos',
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          Expanded(
            child: _filteredTodos.isEmpty
                ? const Center(
                    child: Text(
                      "No Todos found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredTodos.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final todo = _filteredTodos[index];
                      final todoIndex = _todos.indexOf(todo);

                      return Slidable(
                        key: ValueKey(todoIndex),
                        endActionPane: ActionPane(
                          extentRatio: 0.35,
                          motion: const ScrollMotion(),
                          children: [
                            GestureDetector(
                              onTap: () => _editTodo(todoIndex),
                              child: Container(
                                height: 50,
                                width: 50,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _deleteTodo(todoIndex),
                              child: Container(
                                height: 50,
                                width: 50,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: dangerColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SvgPicture.asset('assets/icons/trash.svg'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () => _toggleComplete(todoIndex),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: todo.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  todo.isCompleted
                                      ? 'assets/icons/todo-checked.svg'
                                      : 'assets/icons/todo-unchecked.svg',
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    todo.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      decoration: todo.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                  ),
          ),
        ],
      ),
    );
  }
}
