import 'package:flutter/material.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class EcocapturaApp extends StatelessWidget {
  const EcocapturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ecocaptura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}