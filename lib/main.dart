import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(LearningApp());

class LearningApp extends StatefulWidget {
  @override
  _LearningAppState createState() => _LearningAppState();
}

class _LearningAppState extends State<LearningApp> {
  bool useOpenDyslexicFont = false;
  bool useHighContrast = false;

  @override
  Widget build(BuildContext context) {
    final baseTheme = useHighContrast
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            primaryColor: Colors.black,
            textTheme: ThemeData.dark().textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                  fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                ),
          )
        : ThemeData.light().copyWith(
            textTheme: ThemeData.light().textTheme.apply(
                  fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                ),
          );

    return MaterialApp(
      title: 'Accessible Learning Platform',
      theme: baseTheme,
      home: TOCScreen(
        toggleFont: () => setState(() => useOpenDyslexicFont = !useOpenDyslexicFont),
        toggleContrast: () => setState(() => useHighContrast = !useHighContrast),
      ),
    );
  }
}

class TOCScreen extends StatefulWidget {
  final VoidCallback toggleFont;
  final VoidCallback toggleContrast;

  TOCScreen({required this.toggleFont, required this.toggleContrast});

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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Toggle Font') widget.toggleFont();
              if (value == 'Toggle Contrast') widget.toggleContrast();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Toggle Font', child: Text('Toggle Dyslexic Font')),
              PopupMenuItem(value: 'Toggle Contrast', child: Text('Toggle High Contrast')),
            ],
          )
        ],
      ),
      body: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, lessonIndex) {
          var lesson = lessons[lessonIndex];
          return ExpansionTile(
            title: Text(lesson['title']),
            children: List.generate(lesson['modules'].length, (moduleIndex) {
              var module = lesson['modules'][moduleIndex];
              String title = module['title'] ?? module['subtopics']?[0]['title'] ?? 'Untitled';
              return ListTile(
                title: Text(title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonPage(
                        lessonTitle: lesson['title'],
                        module: module,
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
}

class LessonPage extends StatelessWidget {
  final String lessonTitle;
  final Map<String, dynamic> module;

  LessonPage({required this.lessonTitle, required this.module});

  @override
  Widget build(BuildContext context) {
    final subtopics = module['subtopics'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(title: Text(module['title'] ?? 'Lesson')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (module['content'] != null)
              Text(
                module['content'],
                style: Theme.of(context).textTheme.bodyLarge,
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (sub['content'] != null) Text(sub['content']!),
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
