// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String city;
  final String school;

  User({required this.id, required this.name, required this.email, required this.password, required this.city, required this.school});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], email: json['email'], password: json['password'], city: json['city'], school: json['school']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'password': password, 'city': city, 'school': school};
  }
}
