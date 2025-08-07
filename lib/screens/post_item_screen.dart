// lib/screens/post_item_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/item.dart';
import '../../services/auth_service.dart';
import '../../services/item_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/city_dropdown.dart';

class PostItemScreen extends StatefulWidget {
  final Item? itemToEdit;

  const PostItemScreen({super.key, this.itemToEdit});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  late String _selectedCity;
  late String _imagePath;
  bool _isLoading = false;
  // bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.itemToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.itemToEdit?.description ?? '');
    _selectedCategory = widget.itemToEdit?.category ?? 'Books';
    _selectedCity = widget.itemToEdit?.city ?? 'Ondipudur';
    _imagePath = widget.itemToEdit?.imagePath ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  Future<void> _postItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.getCurrentUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first'), behavior: SnackBarBehavior.floating));
      setState(() => _isLoading = false);
      return;
    }

    final item = Item(
      id: widget.itemToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      city: _selectedCity,
      school: user.school,
      imagePath: _imagePath,
      postedDate: widget.itemToEdit?.postedDate ?? DateTime.now(),
    );

    final itemService = Provider.of<ItemService>(context, listen: false);

    try {
      if (widget.itemToEdit == null) {
        await itemService.postItem(item);
      } else {
        await itemService.updateItem(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.itemToEdit == null ? 'Item posted successfully!' : 'Item updated successfully!'), behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit == null ? 'Post New Item' : 'Edit Item', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  ),
                  child: _imagePath.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('Tap to add photo', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(_imagePath, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              Text('Item Title', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter item title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter detailed description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text('Category', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryChip(label: 'Books', selected: _selectedCategory == 'Books', onSelected: () => setState(() => _selectedCategory = 'Books')),
                    const SizedBox(width: 8),
                    CategoryChip(label: 'Guides', selected: _selectedCategory == 'Guides', onSelected: () => setState(() => _selectedCategory = 'Guides')),
                    const SizedBox(width: 8),
                    CategoryChip(label: 'Shoes', selected: _selectedCategory == 'Shoes', onSelected: () => setState(() => _selectedCategory = 'Shoes')),
                    const SizedBox(width: 8),
                    CategoryChip(label: 'Notes', selected: _selectedCategory == 'Notes', onSelected: () => setState(() => _selectedCategory = 'Notes')),
                    const SizedBox(width: 8),
                    CategoryChip(label: 'Uniforms', selected: _selectedCategory == 'Uniforms', onSelected: () => setState(() => _selectedCategory = 'Uniforms')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // City Selection
              Text('Location', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CityDropdown(selectedCity: _selectedCity, onChanged: (city) => setState(() => _selectedCity = city!)),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _postItem,
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.itemToEdit == null ? 'Post Item' : 'Update Item', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
