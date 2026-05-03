import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class TrainingTrackerApp extends StatelessWidget {
  const TrainingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('Training Tracker — bootstrap OK'),
        ),
      ),
    );
  }
}
