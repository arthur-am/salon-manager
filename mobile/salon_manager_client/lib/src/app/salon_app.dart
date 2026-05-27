import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/client/presentation/screens/client_shell.dart';

class SalonManagerClientApp extends StatelessWidget {
  const SalonManagerClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SALON.OS Cliente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ClientShell(),
    );
  }
}
