// questions.dart
import 'package:flutter/material.dart';

class QuestionsPage extends StatelessWidget {
  final bool useHighContrast;
  final bool useOpenDyslexicFont;
  final List<dynamic> mcqs;

  const QuestionsPage({
    required this.useHighContrast,
    required this.useOpenDyslexicFont,
    required this.mcqs,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Practice Questions',
          style: TextStyle(
            fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mcqs.length,
        itemBuilder: (context, topicIndex) {
          final topic = mcqs[topicIndex];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ExpansionTile(
              title: Text(
                topic['topic'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                ),
              ),
              children: (topic['questions'] as List).map<Widget>((question) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['question'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(question['options'] as List).map<Widget>((option) {
                        final isCorrect = option == question['correctAnswer'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: useHighContrast && isCorrect
                                  ? Colors.green
                                  : Colors.transparent,
                              border: useHighContrast && isCorrect
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Radio(
                                value: option,
                                groupValue: null,
                                onChanged: (value) {},
                              ),
                              title: Text(
                                option,
                                style: TextStyle(
                                  fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      if (useHighContrast)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Correct Answer: ${question['correctAnswer']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontFamily: useOpenDyslexicFont ? 'OpenDyslexic' : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}