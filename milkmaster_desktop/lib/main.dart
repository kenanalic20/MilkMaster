import 'dart:io';

import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/providers/auth_provider.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/providers/cattle_provider.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/providers/orders_provider.dart';
import 'package:milkmaster_desktop/providers/product_category_provider.dart';
import 'package:milkmaster_desktop/providers/products_provider.dart';
import 'package:milkmaster_desktop/widgets/home_shell.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  windowManager.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowManager.instance.setMinimumSize(const Size(1366, 768));
    WindowManager.instance.setTitle('MilkMaster');
    WindowManager.instance.setMaximumSize(const Size(1366, 768));
    WindowManager.instance.setSize(const Size(1366, 768));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => CattleCategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductCategoryProvider()),
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => CattleProvider()),

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
      debugShowCheckedModeBanner: false,
      title: 'MilkMaster',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromRGBO(253, 216, 53, 1),
          onPrimary: Colors.black,
          secondary: Color.fromRGBO(249, 168, 37, 1),
          onSecondary: Colors.white,
          tertiary: Colors.grey,
          surface: Colors.white,
          onSurface: Color(0xFF212121),
          error: Color(0xFFD32F2F),
          onError: const Color.fromARGB(255, 0, 0, 0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtonStyles.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFFC107), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.white,
        ),
        iconTheme: IconThemeData(color: Color(0xFF212121)),
        // Example of custom spacing extension
        extensions: <ThemeExtension<dynamic>>[
          AppSpacing(small: 8.0, medium: 16.0, large: 32.0),
        ],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeShell(),
      },
    );
  }
}

class AppButtonStyles {

  static ButtonStyle primary = ElevatedButton.styleFrom(
    foregroundColor:  Color.fromRGBO(249,168,37,1),
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    side: BorderSide(
      color: Color.fromRGBO(249,168,37,1),
    ),
  );

  static ButtonStyle secondary = ElevatedButton.styleFrom(
     backgroundColor: Colors.transparent,
    foregroundColor: Colors.black,
    shadowColor: Colors.transparent,
    side: BorderSide(color:Colors.black ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // Danger / Delete button
  static ButtonStyle danger = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFFD32F2F),
    shadowColor: Colors.transparent,
    side: BorderSide(color:Color(0xFFD32F2F) ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
     
    ),
  );
}

class AppSpacing extends ThemeExtension<AppSpacing> {
  final double small;
  final double medium;
  final double large;

  const AppSpacing({
    required this.small,
    required this.medium,
    required this.large,
  });

  @override
  AppSpacing copyWith({double? small, double? medium, double? large}) {
    return AppSpacing(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      small: lerpDouble(small, other.small, t),
      medium: lerpDouble(medium, other.medium, t),
      large: lerpDouble(large, other.large, t),
    );
  }
}

double lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
