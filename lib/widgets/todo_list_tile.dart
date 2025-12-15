

import 'package:flutter/material.dart';
import '../models/todo_item.dart';



class TodoListTile extends StatelessWidget {
  final TodoItem todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return date.toLocal().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.isDone,
        onChanged: onToggle,
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration:
          todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      subtitle: Text('Fecha objetivo: ${_formatDate(todo.dueDate)}'),
      onTap: onEdit,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}