

import 'package:flutter/material.dart';



class TodoFormScreen extends StatefulWidget {
  final String? initialTitle;
  final DateTime? initialDate;
  final bool initialDone;

  const TodoFormScreen({
    super.key,
    this.initialTitle,
    this.initialDate,
    this.initialDone = false,
  });

  @override
  State<TodoFormScreen> createState() => TodoFormScreenState();
}

class TodoFormScreenState extends State<TodoFormScreen> {
  late final TextEditingController _titleController;
  DateTime? _selectedDate;
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedDate = widget.initialDate;
    _isDone = widget.initialDone;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    Navigator.pop<Map<String, dynamic>>(context, {
      'title': title,
      'dueDate': _selectedDate,
      'isDone': _isDone,
    });
  }

  String _dateText() {
    if (_selectedDate == null) return 'Sin fecha objetivo';
    return _selectedDate!.toLocal().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialTitle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Todo' : 'Nuevo Todo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('Fecha: ${_dateText()}')),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Elegir fecha'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Completado'),
              value: _isDone,
              onChanged: (value) {
                setState(() {
                  _isDone = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}