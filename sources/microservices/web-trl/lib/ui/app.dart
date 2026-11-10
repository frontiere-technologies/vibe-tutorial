import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import 'app_shell.dart';
import 'theme/app_theme.dart';

class TrlApp extends StatelessWidget {
  const TrlApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        title: 'TRL Readiness',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: controller.themeMode,
        home: const AppShell(),
      ),
    ),
  );
}
