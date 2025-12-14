import 'package:flutter/material.dart';
import 'package:gym_list/CheckList.dart';

class EditListStyleScreen extends StatefulWidget {
  final CheckList list;
  final VoidCallback onSave;

  const EditListStyleScreen({
    super.key,
    required this.list,
    required this.onSave,
  });

  @override
  State<EditListStyleScreen> createState() => _EditListStyleScreenState();
}

class _EditListStyleScreenState extends State<EditListStyleScreen> {
  late Color seedColor;
  late IconData icon;
  late double radius;

  final List<Color> presetColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  final List<IconData> presetIcons = [
    Icons.list,
    Icons.fitness_center,
    Icons.shopping_cart,
    Icons.book,
    Icons.star,
    Icons.check_circle,
    Icons.directions_run,
  ];

  @override
  void initState() {
    super.initState();
    seedColor = widget.list.style.seedColor;
    icon = widget.list.style.icon;
    radius = widget.list.style.borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primaryContainer,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Estilo de la lista"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 40, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 16),
                    Text(
                      widget.list.title,
                      style: TextStyle(
                        fontSize: 20,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("Color", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: presetColors.map((c) {
                  return GestureDetector(
                    onTap: () => setState(() => seedColor = c),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: c,
                      child: seedColor == c ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("Icono", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: presetIcons.map((ic) {
                  return GestureDetector(
                    onTap: () => setState(() => icon = ic),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(ic, color: icon == ic ? colorScheme.primary : Colors.grey),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("Radio del borde", style: TextStyle(fontSize: 18)),
              Slider(
                value: radius,
                min: 4,
                max: 32,
                divisions: 7,
                label: "${radius.toInt()}",
                onChanged: (v) => setState(() => radius = v),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final newStyle = CheckListStyle(
                    seedColor: seedColor,
                    icon: icon,
                    borderRadius: radius,
                  );
                  widget.list.style = newStyle;
                  widget.onSave();
                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
