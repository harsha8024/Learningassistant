import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  WebViewPlatform? platform = WebViewPlatform.instance;
  if (platform is AndroidWebViewController) {
    AndroidWebViewPlatform.registerPlatform(AndroidWebViewPlatform());
  } else if (platform is WebKitWebViewController) {
    WebKitWebViewPlatform.registerPlatform(WebKitWebViewPlatform());
  }

  runApp(LearningApp());
}

class LearningApp extends StatefulWidget {
  @override
  _LearningAppState createState() => _LearningAppState();
}

class _LearningAppState extends State<LearningApp> {
  bool useOpenDyslexicFont = false;
  bool useHighContrast = false;

  @override
  Widget build(BuildContext context) {
    final highContrastTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow,
      ),
      primaryColor: Colors.black,
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
          ).copyWith(
            titleLarge: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            titleMedium: TextStyle(
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            bodyLarge: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
          ),
    );

    final lightTheme = ThemeData.light().copyWith(
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
          ).copyWith(
            bodyLarge: TextStyle(fontSize: 16),
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
    );

    return MaterialApp(
      title: 'Accessible Learning Platform',
      theme: useHighContrast ? highContrastTheme : lightTheme,
      home: TOCScreen(
        toggleFont: () => setState(() => useOpenDyslexicFont = !useOpenDyslexicFont),
        toggleContrast: () => setState(() => useHighContrast = !useHighContrast),
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

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  Future<void> loadLessons() async {
    final String response = await rootBundle.loadString('/data.json');
    final data = json.decode(response);
    setState(() {
      lessons = data['lessons'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table of Contents'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return buildAccessibilitySettingsDialog(
                    useOpenDyslexicFont: widget.useOpenDyslexicFont,
                    useHighContrast: widget.useHighContrast,
                    toggleFont: widget.toggleFont,
                    toggleContrast: widget.toggleContrast,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, lessonIndex) {
          var lesson = lessons[lessonIndex];
          return ExpansionTile(
            title: Text(
              lesson['title'],
              style: widget.useHighContrast
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: widget.useOpenDyslexicFont ? 'OpenDyslexic' : null,
                    ),
            ),
            children: List.generate(lesson['modules'].length, (moduleIndex) {
              var module = lesson['modules'][moduleIndex];
              String title = module['title'] ?? module['subtopics']?[0]['title'] ?? 'Untitled';
              return ListTile(
                title: Text(
                  title,
                  style: widget.useHighContrast
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: widget.useOpenDyslexicFont ? 'OpenDyslexic' : null,
                        ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonPage(
                        lessonTitle: lesson['title'],
                        module: module,
                        useHighContrast: widget.useHighContrast,
                        useOpenDyslexicFont: widget.useOpenDyslexicFont,
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }

  Widget buildAccessibilitySettingsDialog({
    required bool useOpenDyslexicFont,
    required bool useHighContrast,
    required VoidCallback toggleFont,
    required VoidCallback toggleContrast,
  }) {
    return AccessibilitySettingsDialog(
      useOpenDyslexicFont: useOpenDyslexicFont,
      useHighContrast: useHighContrast,
      toggleFont: toggleFont,
      toggleContrast: toggleContrast,
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
            onChanged: (bool value) {
              setState(() {
                _useOpenDyslexicFont = value;
              });
              widget.toggleFont();
            },
          ),
          SwitchListTile(
            title: Text('High Contrast Mode'),
            value: _useHighContrast,
            onChanged: (bool value) {
              setState(() {
                _useHighContrast = value;
              });
              widget.toggleContrast();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class LessonPage extends StatelessWidget {
  final String lessonTitle;
  final Map<String, dynamic> module;
  final bool useHighContrast;
  final bool useOpenDyslexicFont;

  LessonPage({
    required this.lessonTitle,
    required this.module,
    required this.useHighContrast,
    required this.useOpenDyslexicFont,
  });

  @override
  Widget build(BuildContext context) {
    final subtopics = module['subtopics'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          module['title'] ?? 'Lesson',
          style: useHighContrast
              ? TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)
              : TextStyle(fontWeight: FontWeight.bold, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (module['content'] != null)
              Text(
                module['content'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                    ),
              ),
            if (module['image'] != null && module['image'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.asset(module['image']),
              ),
            if (module['video'] != null && module['video'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(Uri.parse(module['video'].replaceFirst('watch?v=', 'embed/'))),
                  ),
                ),
              ),
            if (subtopics != null)
              ...subtopics.map((sub) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        sub['title'],
                        style: useHighContrast
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                              ),
                      ),
                      if (sub['content'] != null)
                        Text(
                          sub['content']!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                              ),
                        ),
                      if (sub['image'] != null && sub['image'].toString().isNotEmpty)
                        Image.asset(sub['image']),
                      if (sub['video'] != null && sub['video'].toString().isNotEmpty)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: WebViewWidget(
                            controller: WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..loadRequest(Uri.parse(sub['video'].replaceFirst('watch?v=', 'embed/'))),
                          ),
                        ),
                    ],
                  ))
          ],
        ),
      ),
    );
  }
}