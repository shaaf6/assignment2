import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';

//group 5 
//muhammad shahaf k22-4230
//muhammad taha wala k22-4312
//muhammad ai zuberi k22-4177

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // google-services.json handles native init; this just bridges the Dart layer.
  await Firebase.initializeApp();
  setupDependencies();
  runApp(const App());
}
