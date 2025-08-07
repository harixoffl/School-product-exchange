// lib/models/item.dart
class Item {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String city;
  final String school;
  final String imagePath;
  final DateTime postedDate;

  Item({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    required this.school,
    required this.imagePath,
    required this.postedDate,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      city: json['city'],
      school: json['school'],
      imagePath: json['imagePath'],
      postedDate: DateTime.parse(json['postedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'city': city,
      'school': school,
      'imagePath': imagePath,
      'postedDate': postedDate.toIso8601String(),
    };
  } // lib/models/item.dart
  // Add this method to the Item class

  bool isOwner(String userId) {
    return this.userId == userId;
  }
}
