import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/outreach.dart';
import 'screens/tasks.dart';
import 'screens/projects.dart';
import 'screens/revenue.dart';
import 'screens/library.dart';

class FreelanceOpsApp extends StatefulWidget {
  const FreelanceOpsApp({super.key});
  @override State<FreelanceOpsApp> createState() => _AppState();
}
class _AppState extends State<FreelanceOpsApp> {
  int index = 0;
  final pages = const [DashboardScreen(), OutreachScreen(), TasksScreen(), ProjectsScreen(), RevenueScreen(), LibraryScreen()];
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Freelance Ops',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xff0b0d12)),
    home: Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Outreach'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.video_library_outlined), selectedIcon: Icon(Icons.video_library), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Revenue'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Library'),
        ],
      ),
    ),
  );
}