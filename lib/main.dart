import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // google-services.json handles native init; this just bridges the Dart layer.
  await Firebase.initializeApp();
  setupDependencies();
  runApp(const App());
}
