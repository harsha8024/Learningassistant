import 'dart:convert'; // For json decoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:webview_flutter/webview_flutter.dart'; // For WebViewWidget

// Main Application Widget (Stateful)
class LearningApp extends StatefulWidget {
  @override
  _LearningAppState createState() => _LearningAppState();
}

class _LearningAppState extends State<LearningApp> {
  bool useOpenDyslexicFont = false;
  bool useHighContrast = false;

  // Callback function to toggle the font state
  void _toggleFont() {
    setState(() {
      useOpenDyslexicFont = !useOpenDyslexicFont;
    });
  }

  // Callback function to toggle the contrast state
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
         thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.yellow; // Thumb color when switch is ON
              }
              return Colors.grey; // Thumb color when switch is OFF
            }),
            trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
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
      appBarTheme: AppBarTheme( // Ensure AppBar looks good in light theme too
          titleTextStyle: TextStyle( // Explicitly style AppBar title
            color: ThemeData.light().primaryTextTheme.titleLarge?.color, // Use default color
            fontSize: 20, // Example size
            fontWeight: FontWeight.bold,
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
          ),
      ),
      textTheme: ThemeData.light().textTheme.apply( // Apply base light theme text colors
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null, // Apply font globally
          ).copyWith( // Customize specific text styles
            bodyLarge: TextStyle(fontSize: 16, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
            titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null),
             // Define other styles if needed
          ),
      // Define other light theme properties if needed
    );

    // Build the MaterialApp using the selected theme
    return MaterialApp(
      title: 'Accessible Learning Platform',
      theme: useHighContrast ? highContrastTheme : lightTheme, // Apply the selected theme
      home: TOCScreen( // Set the initial screen
        // Pass down the state and toggle functions to the child widget
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
  // State and callbacks passed from LearningApp
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
  List<dynamic> mcqs = []; // Add this line to store MCQ data

  @override
  void initState() {
    super.initState();
    loadLessons();
    loadMCQs(); // Add this line to load MCQ data
  }

  // Add this new method to load MCQ data
  Future<void> loadMCQs() async {
    try {
      final String response = await rootBundle.loadString('assets/all_mcqs_combined.json');
      final data = json.decode(response);
      setState(() {
        mcqs = data['mcqs'];
      });
    } catch (e) {
      print('Error loading MCQs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load MCQ data.'))
      );
    }
  }

  // Asynchronously load lesson data from the JSON file in assets
  Future<void> loadLessons() async {
    try {
      // Load the JSON file from the assets folder
      // Make sure 'assets/data.json' exists and is declared in pubspec.yaml
      final String response = await rootBundle.loadString('/data.json');
      // Decode the JSON string into a Dart object
      final data = json.decode(response);
      // Update the state with the loaded lessons
      setState(() {
        lessons = data['lessons'];
      });
    } catch (e) {
      // Handle potential errors during file loading or JSON parsing
      print('Error loading lessons: $e');
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to load lesson data.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title style is now handled by the AppBarTheme in MaterialApp
        title: Text('Table of Contents'),
        actions: [
          // Settings button to open the accessibility dialog
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // Show the accessibility settings dialog
                  // Pass the current state and toggle functions down
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
      ? Center(child: CircularProgressIndicator()) // Show loading indicator while lessons load
      : ListView.builder(
        itemCount: lessons.length, // Number of lessons
        itemBuilder: (context, lessonIndex) {
          var lesson = lessons[lessonIndex];
          return ExpansionTile(
            // Title style comes from theme's expansionTileTheme or textTheme.titleLarge
            title: Text(lesson['title']),
            // Children are the modules within each lesson
            children: List.generate(lesson['modules'].length, (moduleIndex) {
              var module = lesson['modules'][moduleIndex];
              // Determine the title for the module/subtopic
              String title = module['title'] ?? module['subtopics']?[0]['title'] ?? 'Untitled';
              return ListTile(
                 // Title style comes from theme's listTileTheme or textTheme.titleMedium
                title: Text(title),
                onTap: () {
                  // Navigate to the LessonPage when a module is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonPage(
                        lessonTitle: lesson['title'],
                        module: module,
                        // Pass accessibility settings to the LessonPage
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
  // Data and settings passed when navigating to this page
  final String lessonTitle;
  final Map<String, dynamic> module;
  final bool useHighContrast;
  final bool useOpenDyslexicFont;

  // Constructor
  LessonPage({
    required this.lessonTitle,
    required this.module,
    required this.useHighContrast,
    required this.useOpenDyslexicFont,
  });

  @override
  Widget build(BuildContext context) {
    // Extract subtopics, handling null case
    final subtopics = module['subtopics'] as List<dynamic>?;
    // Determine the title for the AppBar
    final String pageTitle = module['title'] ?? 'Lesson';

    return Scaffold(
      appBar: AppBar(
        // Title style is handled by AppBarTheme set in MaterialApp
        title: Text(pageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: ListView( // Use ListView to allow scrolling if content exceeds screen height
          children: [
            // Display module content if available
            if (module['content'] != null)
              Padding(
                 padding: const EdgeInsets.only(bottom: 16.0), // Space below content
                 child: Text(
                  module['content'],
                  // Use bodyLarge style from the current theme
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

            // Display module image if available
            if (module['image'] != null && module['image'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0), // Space around image
                // Load image from assets. Ensure path is correct and declared in pubspec.yaml
                child: Image.asset(module['image']),
              ),

            // Display module video if available
            if (module['video'] != null && module['video'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0), // Space around video
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Standard video aspect ratio
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JS for YouTube embeds
                      ..setBackgroundColor(const Color(0x00000000)) // Optional: set background color
                      ..loadRequest(Uri.parse(module['video'].replaceFirst('watch?v=', 'embed/'))), // Load YouTube embed URL
                  ),
                ),
              ),

            // Display subtopics if available
            if (subtopics != null)
              // Use spread operator (...) to insert subtopic widgets directly into the list
              ...subtopics.map((sub) => Padding( // Add padding around each subtopic block
                 padding: const EdgeInsets.only(top: 20.0), // Space above each subtopic
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                    children: [
                      // Display subtopic title
                      Text(
                        sub['title'] ?? 'Subtopic', // Use default if title is missing
                        // Use titleMedium style from the current theme
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8), // Space between title and content

                      // Display subtopic content if available
                      if (sub['content'] != null)
                         Padding(
                           padding: const EdgeInsets.only(bottom: 8.0), // Space below text
                           child: Text(
                            sub['content']!, // Assert non-null as we checked
                            // Use bodyLarge style from the current theme
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                         ),

                      // Display subtopic image if available
                      if (sub['image'] != null && sub['image'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0), // Space around image
                          child: Image.asset(sub['image']), // Load image from assets
                        ),

                      // Display subtopic video if available
                      if (sub['video'] != null && sub['video'].toString().isNotEmpty)
                         Padding(
                           padding: const EdgeInsets.symmetric(vertical: 8.0), // Space around video
                           child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: WebViewWidget(
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
              ).toList(), // Convert the mapped iterable to a List
          ],
        ),
      ),
    );
  }
}