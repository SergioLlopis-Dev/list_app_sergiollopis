import 'package:flutter/material.dart';
import 'package:gym_list/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ──────────────────────────────────────────
//   AHORA ES STATEFUL
// ──────────────────────────────────────────
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color seed = const Color(0xFF4B6477); // color por defecto

  @override
  void initState() {
    super.initState();
    _loadSeed();
  }

  Future<void> _loadSeed() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt("seedColor");

    if (value != null) {
      setState(() => seed = Color(value));
    }
  }

  Future<void> changeSeed(Color newSeed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("seedColor", newSeed.value);

    setState(() => seed = newSeed);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gym List App",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.5),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          color: ColorScheme.fromSeed(seedColor: seed).primaryContainer,
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          side: const BorderSide(width: 1.5, color: Colors.grey),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return seed;
            return Colors.transparent;
          }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
