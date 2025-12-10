import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CheckItem.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gym List App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CheckItem> checklist = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadChecklist();
  }

  // ------------------------------
  //     GUARDAR / CARGAR DATOS
  // ------------------------------

  Future<void> saveChecklist() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> jsonList =
    checklist.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList("checklist", jsonList);
  }

  Future<void> loadChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList("checklist");

    if (jsonList != null) {
      setState(() {
        checklist = jsonList
            .map((item) => CheckItem.fromJson(jsonDecode(item)))
            .toList();
      });
    } else {
      // Lista inicial por defecto si no había datos guardados
      checklist = [
        CheckItem(name: "Toalla"),
        CheckItem(name: "Ropa"),
        CheckItem(name: "Auriculares"),
      ];
      saveChecklist();
    }
  }

  // ------------------------------
  //         AÑADIR ÍTEM
  // ------------------------------

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir nuevo ítem"),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(labelText: "Nombre del ítem"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                _textController.clear();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text("Añadir"),
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  setState(() {
                    checklist.add(CheckItem(
                        name: _textController.text.trim()));
                  });
                  saveChecklist();
                }
                _textController.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ------------------------------
  //       RESETEAR ÍTEMS
  // ------------------------------

  void _resetChecklist() {
    setState(() {
      for (var item in checklist) {
        item.checked = false;
      }
    });
    saveChecklist();
  }

  // ------------------------------
  //         UI PRINCIPAL
  // ------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: checklist.length,
                  itemBuilder: (context, index) {
                    final item = checklist[index];
                    return GestureDetector(
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.red),
                                    title: Text("Eliminar '${item.name}'?"),
                                    onTap: () {
                                      setState(() {
                                        checklist.removeAt(index);
                                      });
                                      saveChecklist();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: item.checked ? Colors.green : Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Text(item.name),
                          value: item.checked,
                          onChanged: (value) {
                            setState(() {
                              item.checked = value!;
                            });
                            saveChecklist();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Botón reset
          Positioned(
            left: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: "resetButton",
              backgroundColor: Colors.red,
              child: const Icon(Icons.refresh),
              onPressed: _resetChecklist,
            ),
          ),

          // Botón añadir
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: "addButton",
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
              onPressed: _addNewItem,
            ),
          ),
        ],
      ),
    );
  }
}
