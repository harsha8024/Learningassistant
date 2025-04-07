import 'package:flutter/material.dart';
import 'index.dart'; // Import the new UI file

void main() {
  // Ensure Flutter bindings are initialized before doing anything else.
  WidgetsFlutterBinding.ensureInitialized();

  // No need for manual platform registration here with newer webview_flutter versions
  // using WebViewWidget.

  // Run the main application widget defined in index.dart
  runApp(LearningApp());
}