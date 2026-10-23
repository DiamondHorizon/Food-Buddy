import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:window_manager/window_manager.dart';
import 'app_state.dart';
import 'platform.dart';
import 'app_shell.dart';
import 'app_theme.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific factory setup
  if (kIsWeb) {
    // Web (Chrome) setup
    databaseFactory = databaseFactoryFfiWeb;
  } else if (isDesktop) {
    // Desktop setup
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1200, 780),
      minimumSize: Size(820, 560),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  // Android and iOS need no special setup; they use native sqflite automatically.

  final state = AppState();
  await state.load();
  runApp(PantryApp(state: state));
}

class PantryApp extends StatelessWidget {
  final AppState state;
  const PantryApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Buddy',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AppShell(state: state),
    );
  }
}