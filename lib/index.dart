import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'questions.dart';
import 'package:webview_flutter/webview_flutter.dart';
// For Android hybrid composition (required for videos)
import 'package:webview_flutter_android/webview_flutter_android.dart';
// For iOS (optional but recommended)
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'; // Make sure this file exists in your lib folder

void main() {
  runApp(LearningApp());
}

class LearningApp extends StatefulWidget {
  @override
  _LearningAppState createState() => _LearningAppState();
}

class _LearningAppState extends State<LearningApp> {
  bool useOpenDyslexicFont = false;
  bool useHighContrast = false;

  void _toggleFont() => setState(() => useOpenDyslexicFont = !useOpenDyslexicFont);
  void _toggleContrast() => setState(() => useHighContrast = !useHighContrast);

  @override
  Widget build(BuildContext context) {
    final highContrastTheme = ThemeData.dark().copyWith(
      // Your existing high contrast theme configuration
    );

    final lightTheme = ThemeData.light().copyWith(
      // Your existing light theme configuration
    );

    return MaterialApp(
      title: 'Accessible Learning Platform',
      theme: useHighContrast ? highContrastTheme : lightTheme,
      home: TOCScreen(
        toggleFont: _toggleFont,
        toggleContrast: _toggleContrast,
        useOpenDyslexicFont: useOpenDyslexicFont,
        useHighContrast: useHighContrast,
      ),
    );
  }
}

class TOCScreen extends StatefulWidget {
  final VoidCallback toggleFont;
  final VoidCallback toggleContrast;
  final bool useOpenDyslexicFont;
  final bool useHighContrast;

  TOCScreen({
    required this.toggleFont,
    required this.toggleContrast,
    required this.useOpenDyslexicFont,
    required this.useHighContrast,
  });

  @override
  _TOCScreenState createState() => _TOCScreenState();
}

class _TOCScreenState extends State<TOCScreen> {
  List<dynamic> lessons = [];
  List<dynamic> mcqs = [];

  @override
  void initState() {
    super.initState();
    loadLessons();
    loadMCQs();
  }

  Future<void> loadLessons() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final data = json.decode(response);
      setState(() => lessons = data['lessons']);
    } catch (e) {
      print('Error loading lessons: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load lesson data.'))
      );
    }
  }

  Future<void> loadMCQs() async {
    try {
      final String response = await rootBundle.loadString('assets/all_mcqs_combined.json');
      final data = json.decode(response);
      setState(() => mcqs = data['mcqs']);
    } catch (e) {
      print('Error loading MCQs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table of Contents'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AccessibilitySettingsDialog(
                useOpenDyslexicFont: widget.useOpenDyslexicFont,
                useHighContrast: widget.useHighContrast,
                toggleFont: widget.toggleFont,
                toggleContrast: widget.toggleContrast,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: mcqs.isEmpty 
                  ? null 
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionsPage(
                            useHighContrast: widget.useHighContrast,
                            useOpenDyslexicFont: widget.useOpenDyslexicFont,
                            mcqs: mcqs,
                          ),
                        ),
                      ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Practice Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: widget.useOpenDyslexicFont ? 'OpenDyslexic' : null,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: lessons.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: lessons.length,
                    itemBuilder: (context, lessonIndex) {
                      final lesson = lessons[lessonIndex];
                      return ExpansionTile(
                        title: Text(lesson['title']),
                        children: List.generate(
                          lesson['modules'].length,
                          (moduleIndex) {
                            final module = lesson['modules'][moduleIndex];
                            final title = module['title'] ?? module['subtopics']?[0]['title'] ?? 'Untitled';
                            return ListTile(
                              title: Text(title),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LessonPage(
                                    lessonTitle: lesson['title'],
                                    module: module,
                                    useHighContrast: widget.useHighContrast,
                                    useOpenDyslexicFont: widget.useOpenDyslexicFont,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AccessibilitySettingsDialog extends StatefulWidget {
  final bool useOpenDyslexicFont;
  final bool useHighContrast;
  final VoidCallback toggleFont;
  final VoidCallback toggleContrast;

  AccessibilitySettingsDialog({
    required this.useOpenDyslexicFont,
    required this.useHighContrast,
    required this.toggleFont,
    required this.toggleContrast,
  });

  @override
  _AccessibilitySettingsDialogState createState() => _AccessibilitySettingsDialogState();
}

class _AccessibilitySettingsDialogState extends State<AccessibilitySettingsDialog> {
  late bool _useOpenDyslexicFont;
  late bool _useHighContrast;

  @override
  void initState() {
    super.initState();
    _useOpenDyslexicFont = widget.useOpenDyslexicFont;
    _useHighContrast = widget.useHighContrast;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Accessibility Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: Text('OpenDyslexic Font'),
            value: _useOpenDyslexicFont,
            onChanged: (value) {
              setState(() => _useOpenDyslexicFont = value);
              widget.toggleFont();
            },
          ),
          SwitchListTile(
            title: Text('High Contrast Mode'),
            value: _useHighContrast,
            onChanged: (value) {
              setState(() => _useHighContrast = value);
              widget.toggleContrast();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class LessonPage extends StatefulWidget {
  final String lessonTitle;
  final Map<String, dynamic> module;
  final bool useHighContrast;
  final bool useOpenDyslexicFont;

  const LessonPage({
    required this.lessonTitle,
    required this.module,
    required this.useHighContrast,
    required this.useOpenDyslexicFont,
    Key? key,
  }) : super(key: key);

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://flutter.dev'), // your URL here
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
