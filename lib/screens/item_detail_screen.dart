// lib/screens/item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../services/auth_service.dart';
import 'post_item_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isDeleting = false;

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final itemService = Provider.of<ItemService>(context, listen: false);
      await itemService.deleteItem(widget.item.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted successfully'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting item: $e'), behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.getCurrentUser();
    final isOwner = currentUser != null && widget.item.isOwner(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isOwner) IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEditScreen(context), tooltip: 'Edit Item'),
          if (isOwner)
            IconButton(
              icon: _isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deleteItem,
              tooltip: 'Delete Item',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[100],
              child: widget.item.imagePath.isNotEmpty ? Image.network(widget.item.imagePath, fit: BoxFit.cover) : Center(child: Icon(Icons.image, size: 80, color: Colors.grey[400])),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Categories
                  Text(widget.item.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(widget.item.category),
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
                      ),
                      Chip(
                        label: Text(widget.item.city),
                        backgroundColor: Colors.green[50],
                        labelStyle: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500),
                      ),
                      Chip(
                        label: Text(widget.item.school),
                        backgroundColor: Colors.orange[50],
                        labelStyle: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  Text('Description', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.item.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),

                  // Posted Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text('Posted on ${_formatDate(widget.item.postedDate)}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact information sent to your email'), behavior: SnackBarBehavior.floating));
                      },
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('I want this item', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PostItemScreen(itemToEdit: widget.item))).then((_) {
      if (mounted) setState(() {});
    });
  }
}
