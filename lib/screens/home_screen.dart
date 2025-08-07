// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../services/auth_service.dart';
import 'post_item_screen.dart';
import 'item_detail_screen.dart';
import '../widgets/category_chip.dart';
import '../widgets/city_dropdown.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> _items = [];
  bool _isLoading = false;
  String? _selectedCity;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    final itemService = Provider.of<ItemService>(context, listen: false);
    final items = await itemService.getItems(city: _selectedCity, category: _selectedCategory);

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
    });
    _loadItems();
  }

  void _filterByCity(String? city) {
    setState(() => _selectedCity = city);
    _loadItems();
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Exchange', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Logout')],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PostItemScreen())).then((_) => _loadItems());
        },
        icon: const Icon(Icons.add, color: Color.fromARGB(255, 214, 213, 213)),
        label: const Text('Post Item', style: TextStyle(color: Color.fromARGB(255, 214, 213, 213))),
        backgroundColor: theme.primaryColor,
      ),
      body: Column(
        children: [
          // Filter Section
          Material(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find School Items', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  CityDropdown(selectedCity: _selectedCity, onChanged: _filterByCity, showAllOption: true),
                  const SizedBox(height: 12),
                  Text('Categories', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryChip(label: 'Books', selected: _selectedCategory == 'Books', onSelected: () => _filterByCategory('Books')),
                        const SizedBox(width: 8),
                        CategoryChip(label: 'Guides', selected: _selectedCategory == 'Guides', onSelected: () => _filterByCategory('Guides')),
                        const SizedBox(width: 8),
                        CategoryChip(label: 'Shoes', selected: _selectedCategory == 'Shoes', onSelected: () => _filterByCategory('Shoes')),
                        const SizedBox(width: 8),
                        CategoryChip(label: 'Notes', selected: _selectedCategory == 'Notes', onSelected: () => _filterByCategory('Notes')),
                        const SizedBox(width: 8),
                        CategoryChip(label: 'Uniforms', selected: _selectedCategory == 'Uniforms', onSelected: () => _filterByCategory('Uniforms')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No items found', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Try adjusting your filters or post a new item', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final currentUser = authService.getCurrentUser();
                      final isOwner = currentUser != null && item.isOwner(currentUser.id);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item))).then((_) => _loadItems());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: item.imagePath.isNotEmpty
                                            ? Image.network(item.imagePath, width: 80, height: 80, fit: BoxFit.cover)
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[100],
                                                child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.category,
                                              style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text('${item.city}, ${item.school}', style: theme.textTheme.bodySmall),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isOwner)
                                        PopupMenuButton(
                                          icon: const Icon(Icons.more_vert),
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) => PostItemScreen(itemToEdit: item))).then((_) => _loadItems());
                                            } else if (value == 'delete') {
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

                                              if (confirmed == true) {
                                                final itemService = Provider.of<ItemService>(context, listen: false);
                                                await itemService.deleteItem(item.id);
                                                _loadItems();
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted successfully'), behavior: SnackBarBehavior.floating));
                                              }
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
