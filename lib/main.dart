// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_exchange/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/item_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_item_screen.dart';
import 'screens/item_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>(create: (_) => sharedPreferences),
        Provider<StorageService>(create: (_) => storageService),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ItemService>(create: (_) => ItemService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Exchange Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/post-item': (context) => const PostItemScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/item-detail') {
          final item = settings.arguments as Item;
          return MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item));
        }
        if (settings.name == '/edit-item') {
          final item = settings.arguments as Item;
          return MaterialPageRoute(builder: (context) => PostItemScreen(itemToEdit: item));
        }
        return null;
      },
    );
  }
}
