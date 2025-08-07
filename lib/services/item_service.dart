// lib/services/item_service.dart
import '../models/item.dart';
import 'storage_service.dart';

class ItemService {
  final StorageService _storageService = StorageService();

  Future<void> postItem(Item item) async {
    await _storageService.addItem(item);
  }

  Future<List<Item>> getItems({String? city, String? category}) async {
    return await _storageService.getItems(city: city, category: category);
  } // lib/services/item_service.dart
  // Add these methods to the ItemService class

  Future<void> updateItem(Item item) async {
    await _storageService.updateItem(item);
  }

  Future<void> deleteItem(String itemId) async {
    await _storageService.deleteItem(itemId);
  }
}
