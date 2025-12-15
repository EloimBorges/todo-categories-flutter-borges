

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/todo_list_tile.dart';
import 'todo_form_screen.dart';



enum TodoFilter { all, pending, completed }


class TodoListScreen extends StatefulWidget {
  final String categoryId;

  const TodoListScreen({super.key, required this.categoryId});

  @override
  State<TodoListScreen> createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  TodoFilter _filter = TodoFilter.all;

  List<TodoItem> _applyFilter(List<TodoItem> todos) {
    switch (_filter) {
      case TodoFilter.pending:
        return todos.where((t) => !t.isDone).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.isDone).toList();
      case TodoFilter.all:
      default:
        return todos;
    }
  }

  Future<void> _openTodoForm(
      BuildContext context, {
        TodoItem? todo,
      }) async {
    final provider = context.read<TodoProvider>();
    final category = provider.getCategoryById(widget.categoryId);
    if (category == null) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => TodoFormScreen(
          initialTitle: todo?.title,
          initialDate: todo?.dueDate,
          initialDone: todo?.isDone ?? false,
        ),
      ),
    );

    if (result == null) return;

    final title = (result['title'] as String).trim();
    final dueDate = result['dueDate'] as DateTime?;
    final isDone = result['isDone'] as bool;

    if (title.isEmpty) return;

    if (todo == null) {
      provider.addTodo(widget.categoryId, title, dueDate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo creado')),
      );
    } else {
      provider.updateTodo(
        widget.categoryId,
        todo.id,
        title: title,
        dueDate: dueDate,
        isDone: isDone,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo actualizado')),
      );
    }
  }

  Future<void> _confirmDeleteTodo(
      BuildContext context,
      TodoItem todo,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDeleteDialog(
        title: 'Eliminar Todo',
        content: '¿Seguro que deseas eliminar este Todo?',
      ),
    );

    if (confirm == true) {
      context.read<TodoProvider>().deleteTodo(widget.categoryId, todo.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final category = provider.getCategoryById(widget.categoryId);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categoría no encontrada')),
        body: const Center(child: Text('La categoría ya no existe.')),
      );
    }

    final filteredTodos = _applyFilter(category.todos);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          PopupMenuButton<TodoFilter>(
            initialValue: _filter,
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: TodoFilter.all,
                child: Text('Todos'),
              ),
              PopupMenuItem(
                value: TodoFilter.pending,
                child: Text('Pendientes'),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Text('Completados'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(label: Text('Total: ${category.totalTodos}')),
                Chip(label: Text('Pend: ${category.pendingTodos}')),
                Chip(label: Text('Comp: ${category.completedTodos}')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredTodos.isEmpty
                ? const Center(child: Text('No hay Todos en esta vista.'))
                : ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return TodoListTile(
                  todo: todo,
                  onToggle: (value) {
                    provider.updateTodo(
                      widget.categoryId,
                      todo.id,
                      isDone: value ?? false,
                    );
                  },
                  onEdit: () => _openTodoForm(context, todo: todo),
                  onDelete: () => _confirmDeleteTodo(context, todo),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTodoForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}