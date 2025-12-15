

import 'package:flutter/material.dart';



class CategoryFormScreen extends StatefulWidget {
  final String? categoryId;
  final String? initialName;

  const CategoryFormScreen({
    super.key,
    this.categoryId,
    this.initialName,
  });

  @override
  State<CategoryFormScreen> createState() => CategoryFormScreenState();
}

class CategoryFormScreenState extends State<CategoryFormScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.categoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Categoría' : 'Nueva Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
              ),
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