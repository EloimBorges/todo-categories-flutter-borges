

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'category_form_screen.dart';
import 'todo_list_screen.dart';





class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  Future<void> _openCategoryForm(
      BuildContext context, {
        String? categoryId,
        String? currentName,
      }) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(
          categoryId: categoryId,
          initialName: currentName,
        ),
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    final provider = context.read<TodoProvider>();

    if (categoryId == null) {
      provider.addCategory(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría creada')),
      );
    } else {
      provider.updateCategory(categoryId, result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría actualizada')),
      );
    }
  }

  Future<void> _confirmDelete(
      BuildContext context,
      String categoryId,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDeleteDialog(
        title: 'Eliminar categoría',
        content: '¿Seguro que deseas eliminar esta categoría?',
      ),
    );

    if (confirm == true) {
      context.read<TodoProvider>().deleteCategory(categoryId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: categories.isEmpty
          ? const Center(
        child: Text('No hay categorías. Agrega una nueva.'),
      )
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TodoListScreen(categoryId: category.id),
                ),
              );
            },
            onEdit: () => _openCategoryForm(
              context,
              categoryId: category.id,
              currentName: category.name,
            ),
            onDelete: () => _confirmDelete(context, category.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCategoryForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}