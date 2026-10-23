import 'package:flutter/foundation.dart';

bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
defaultTargetPlatform == TargetPlatform.linux ||
defaultTargetPlatform == TargetPlatform.macOS);

bool get isMac => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
bool get showCustomWindowButtons => isDesktop && !isMac;