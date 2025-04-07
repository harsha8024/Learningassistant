// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Main Application Widget (Stateful) - (No changes needed here for the font issue)
class LearningApp extends StatefulWidget {
  @override
  _LearningAppState createState() => _LearningAppState();
}

class _LearningAppState extends State<LearningApp> {
  bool useOpenDyslexicFont = false;
  bool useHighContrast = false;

  void _toggleFont() {
    setState(() {
      useOpenDyslexicFont = !useOpenDyslexicFont;
    });
  }

  void _toggleContrast() {
    setState(() {
      useHighContrast = !useHighContrast;
    });
  }


  @override
  Widget build(BuildContext context) {
    // Define the High Contrast Theme
    final highContrastTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow, // Color for AppBar icons and title
        titleTextStyle: TextStyle( // Explicitly style AppBar title
            color: Colors.yellow,
            fontSize: 20, // Example size
            fontWeight: FontWeight.bold,
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
          ),
      ),
      primaryColor: Colors.black, // Primary color for the theme
      textTheme: ThemeData.dark().textTheme.apply( // Apply base dark theme text colors
            bodyColor: Colors.white,
            displayColor: Colors.white,
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null, // Apply font globally
          ).copyWith( // Customize specific text styles
            // ignore: prefer_const_constructors
            titleLarge: TextStyle( // Used for main titles like lesson titles in ExpansionTile
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            titleMedium: TextStyle( // Used for subtitles like module titles in ListTile
              color: Colors.cyan, // Changed for contrast, adjust as needed
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            bodyLarge: TextStyle( // Used for main body content
              color: Colors.white,
              fontSize: 16,
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            // Define other styles if needed (bodyMedium, labelLarge, etc.)
          ),
      // Define other theme properties like button themes if needed
      switchTheme: SwitchThemeData( // Style switches for consistency
         thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.yellow; // Thumb color when switch is ON
              }
              return Colors.grey; // Thumb color when switch is OFF
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.yellow.withOpacity(0.5); // Track color when switch is ON
              }
              return Colors.grey.withOpacity(0.5); // Track color when switch is OFF
            }),
      ),
       dialogTheme: DialogTheme( // Style dialogs
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
          contentTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
        ),
       textButtonTheme: TextButtonThemeData( // Style text buttons
          style: TextButton.styleFrom(foregroundColor: Colors.yellow)
       ),
       listTileTheme: ListTileThemeData( // Style ListTiles
          textColor: Colors.white // Default text color for ListTiles
       ),
       expansionTileTheme: ExpansionTileThemeData( // Style ExpansionTiles
         textColor: Colors.yellow, // Color for the title when closed
         iconColor: Colors.yellow, // Color for the expand/collapse icon
         collapsedTextColor: Colors.yellow, // Ensure title color is yellow when collapsed
         collapsedIconColor: Colors.yellow // Ensure icon color is yellow when collapsed
       )
    );

    // Define the Light Theme
final lightTheme = ThemeData.light().copyWith(
       appBarTheme: AppBarTheme(
          // Default background is light, ensure title text is dark
          titleTextStyle: TextStyle(
            // *** FIX: Explicit dark color for visibility ***
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            // Explicit font setting
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
          ),
          // Optional: Set icon/action colors if needed
          // foregroundColor: Colors.black,
      ),
      textTheme: ThemeData.light().textTheme.apply(
            // Base font setting
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
          ).copyWith(
            // --- Explicit Font Setting in Specific Styles ---
            titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              // Explicit font setting
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              // Explicit font setting
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              // Explicit font setting *** ENSURED HERE ***
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              // Explicit font setting *** ENSURED HERE ***
              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            labelLarge: TextStyle( // Example for Button text
               // Explicit font setting
               fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
            ),
            titleSmall: TextStyle( // Example if used
                // Explicit font setting
                fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
             ),
             bodySmall: TextStyle( // Example (caption) if used
                // Explicit font setting
                fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
             ),
          ),
      dialogTheme: DialogTheme(
           // Explicit font settings for dialogs in light theme
           titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
           contentTextStyle: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
      ),
       // Define other light theme properties if needed
       // switchTheme: SwitchThemeData(/* ... default or custom light switch colors ... */),
    );

    // Build the MaterialApp using the selected theme
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


// Table of Contents Screen Widget (Stateful)
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
     try {
      final String response = await rootBundle.loadString('/data.json');
      final data = json.decode(response);
      if (mounted) { // Check if the widget is still in the tree
         setState(() {
           lessons = data['lessons'];
         });
      }
    } catch (e) {
      print('Error loading lessons: $e');
       if (mounted) { // Check if mounted before showing SnackBar
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Failed to load lesson data.'))
           );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table of Contents'), // Style comes from theme
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AccessibilitySettingsDialog(
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
      body: lessons.isEmpty
      ? Center(child: CircularProgressIndicator())
      : ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, lessonIndex) {
          var lesson = lessons[lessonIndex];
          return ExpansionTile(
            // *** REMOVED explicit style override ***
            // The style now purely comes from the theme's ExpansionTileTheme or TextTheme.titleLarge
            title: Text(lesson['title']),
            children: List.generate(lesson['modules'].length, (moduleIndex) {
              var module = lesson['modules'][moduleIndex];
              String title = module['title'] ?? module['subtopics']?[0]['title'] ?? 'Untitled';
              return ListTile(
                // *** REMOVED explicit style override ***
                // Style comes from theme's ListTileTheme or TextTheme.titleMedium
                title: Text(title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonPage(
                        lessonTitle: lesson['title'],
                        module: module,
                        // Pass settings - LessonPage will use theme context
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
}


// Accessibility Settings Dialog Widget (Stateful)
class AccessibilitySettingsDialog extends StatefulWidget {
  // Current state and callbacks passed from TOCScreen
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
  // Local state to manage the switch values within the dialog
  late bool _useOpenDyslexicFont;
  late bool _useHighContrast;

  @override
  void initState() {
    super.initState();
    // Initialize local state with values passed from the parent
    _useOpenDyslexicFont = widget.useOpenDyslexicFont;
    _useHighContrast = widget.useHighContrast;
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme's DialogTheme for styling
    return AlertDialog(
      title: Text('Accessibility Settings'), // Style from DialogTheme
      content: Column(
        mainAxisSize: MainAxisSize.min, // Make column height fit content
        children: [
          SwitchListTile(
            title: Text('OpenDyslexic Font'), // Style from DialogTheme/TextTheme
            value: _useOpenDyslexicFont,
            onChanged: (bool value) {
              // Update local state
              setState(() {
                _useOpenDyslexicFont = value;
              });
              // Call the toggle function passed from the parent to update global state
              widget.toggleFont();
            },
             // Switch colors adapt based on theme's switchTheme
          ),
          SwitchListTile(
            title: Text('High Contrast Mode'), // Style from DialogTheme/TextTheme
            value: _useHighContrast,
            onChanged: (bool value) {
              // Update local state
              setState(() {
                _useHighContrast = value;
              });
              // Call the toggle function passed from the parent to update global state
              widget.toggleContrast();
            },
             // Switch colors adapt based on theme's switchTheme
          ),
        ],
      ),
      actions: [
        // Close button
        TextButton(
          child: Text('Close'), // Style from theme's textButtonTheme
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}

// Lesson Page Widget (Stateless)
class LessonPage extends StatelessWidget {
  final String lessonTitle;
  final Map<String, dynamic> module;
  final bool useHighContrast; // Still useful for conditional logic *other* than font
  final bool useOpenDyslexicFont; // Still useful for conditional logic *other* than font

  LessonPage({
    required this.lessonTitle,
    required this.module,
    required this.useHighContrast,
    required this.useOpenDyslexicFont,
  });

  @override
  Widget build(BuildContext context) {
    final subtopics = module['subtopics'] as List<dynamic>?;
    final String pageTitle = module['title'] ?? 'Lesson';

    // Get the current theme's text styles ONCE for efficiency
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // *** REMOVED explicit style override ***
        // Title style comes from the theme's AppBarTheme
        title: Text(pageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display module content
            if (module['content'] != null)
              Padding(
                 padding: const EdgeInsets.only(bottom: 16.0),
                 child: Text(
                  module['content'],
                  // *** Use theme directly ***
                  style: textTheme.bodyLarge,
                ),
              ),

            // Display module image
            if (module['image'] != null && module['image'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(module['image']),
              ),

            // Display module video
            if (module['video'] != null && module['video'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WebViewWidget( // WebView itself doesn't use Flutter text theme
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(const Color(0x00000000))
                      ..loadRequest(Uri.parse(module['video'].replaceFirst('watch?v=', 'embed/'))),
                  ),
                ),
              ),

            // Display subtopics
            if (subtopics != null)
              ...subtopics.map((sub) => Padding(
                 padding: const EdgeInsets.only(top: 20.0),
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtopic title
                      Text(
                        sub['title'] ?? 'Subtopic',
                        // *** Use theme directly ***
                        style: textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),

                      // Subtopic content
                      if (sub['content'] != null)
                         Padding(
                           padding: const EdgeInsets.only(bottom: 8.0),
                           child: Text(
                            sub['content']!,
                            // *** Use theme directly ***
                            style: textTheme.bodyLarge,
                          ),
                         ),

                      // Subtopic image
                      if (sub['image'] != null && sub['image'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(sub['image']),
                        ),

                      // Subtopic video
                      if (sub['video'] != null && sub['video'].toString().isNotEmpty)
                         Padding(
                           padding: const EdgeInsets.symmetric(vertical: 8.0),
                           child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: WebViewWidget( // WebView itself doesn't use Flutter text theme
                              controller: WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..setBackgroundColor(const Color(0x00000000))
                                ..loadRequest(Uri.parse(sub['video'].replaceFirst('watch?v=', 'embed/'))),
                            ),
                           ),
                         ),
                    ],
                  ),
              )
              ).toList(),
          ],
        ),
      ),
    );
  }
}