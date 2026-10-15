import 'package:flutter/material.dart';
import 'ingredient_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

 void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific factory setup
  if (kIsWeb) {
    // Web (Chrome) setup
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.linux ||
             defaultTargetPlatform == TargetPlatform.macOS) {
    // Desktop setup
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android and iOS need no special setup; they use native sqflite automatically.

  runApp(const IngredientScreen());
}