// lib/services/storage_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _configFileName = 'school_exchange_config.json';
  late SharedPreferences _prefs;
  Map<String, dynamic> _configData = {'users': [], 'items': []};
  static const String _configKey = 'school_exchange_config';
  Future<void> init() async {
    await _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final configString = _prefs.getString(_configKey);
      if (configString != null) {
        _configData = json.decode(configString);
      }
    } catch (e) {
      print('Error loading config: $e');
    }
  }

  Future<void> _saveConfig() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_configFileName');
      await file.writeAsString(json.encode(_configData));
    } catch (e) {
      print('Error saving config: $e');
    }
  }

  // User methods
  Future<void> addUser(User user) async {
    _configData['users'].add(user.toJson());
    await _saveConfig();
  }

  Future<User?> getUser(String email) async {
    final userJson = _configData['users'].firstWhere((user) => user['email'] == email, orElse: () => null);
    return userJson != null ? User.fromJson(userJson) : null;
  }

  // Item methods
  Future<void> addItem(Item item) async {
    _configData['items'].add(item.toJson());
    await _saveConfig();
  }

  Future<List<Item>> getItems({String? city, String? category}) async {
    List<dynamic> itemsJson = _configData['items'];

    if (city != null) {
      itemsJson = itemsJson.where((item) => item['city'] == city).toList();
    }

    if (category != null) {
      itemsJson = itemsJson.where((item) => item['category'] == category).toList();
    }

    return itemsJson.map((json) => Item.fromJson(json)).toList();
  }
  // lib/services/storage_service.dart
  // Add these methods to the StorageService class

  Future<void> updateItem(Item updatedItem) async {
    final index = _configData['items'].indexWhere((item) => item['id'] == updatedItem.id);
    if (index != -1) {
      _configData['items'][index] = updatedItem.toJson();
      await _saveConfig();
    }
  }

  Future<void> deleteItem(String itemId) async {
    _configData['items'].removeWhere((item) => item['id'] == itemId);
    await _saveConfig();
  }
}
