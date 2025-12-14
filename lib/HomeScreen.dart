import 'package:flutter/material.dart';
import 'package:gym_list/CheckList.dart';
import 'package:gym_list/ListDetailScreen.dart';
import 'package:gym_list/data/templates.dart';
import 'package:gym_list/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CheckList> allLists = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAllLists();
  }

  // ------------------------------
  // GUARDAR / CARGAR
  // ------------------------------

  Future<void> saveAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonLists =
    allLists.map((list) => jsonEncode(list.toJson())).toList();
    await prefs.setStringList("allLists", jsonLists);
  }

  Future<void> loadAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonLists = prefs.getStringList("allLists");

    setState(() {
      if (jsonLists != null) {
        allLists = jsonLists
            .map((json) => CheckList.fromJson(jsonDecode(json)))
            .toList();
      } else {
        allLists = [];
      }
    });
  }

  // ------------------------------
  // CREAR LISTA NUEVA
  // ------------------------------

  void _createList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear lista"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "O elige una plantilla:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Templates.all.map((t) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(t.name),
                  onPressed: () {
                    setState(() {
                      allLists.add(t.toCheckList());
                    });
                    saveAllLists();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () {
              _controller.clear();
              Navigator.pop(context);
            },
          ),
          FilledButton(
            child: const Text("Crear lista vacía"),
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;
              setState(() {
                allLists.add(
                  CheckList(title: _controller.text.trim(), items: []),
                );
              });
              saveAllLists();
              _controller.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _openColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Elige un color de tema",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                children: [
                  _colorDot(Colors.blueGrey, context),
                  _colorDot(Colors.teal, context),
                  _colorDot(Colors.deepPurple, context),
                  _colorDot(Colors.indigo, context),
                  _colorDot(Colors.orange, context),
                  _colorDot(Colors.green, context),
                  _colorDot(Colors.pink, context),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorDot(Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        MyApp.of(context)!.changeSeed(color);
        Navigator.pop(context);
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: color,
      ),
    );
  }


  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;

      final item = allLists.removeAt(oldIndex);
      allLists.insert(newIndex, item);

      saveAllLists();
    });
  }

  Widget _buildListTile(CheckList list, int index) {
    return Card(
      key: ValueKey(list),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: list.style.seedColor,
                        child: Icon(
                          list.style.icon,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(list.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListDetailScreen(
                              list: list,
                              onUpdate: saveAllLists,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),

                  ],
                ),
              );
            },
          );
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListDetailScreen(
                list: list,
                onUpdate: () {
                  saveAllLists();
                  setState(() {});
                },
              ),
            ),
          );
        },
        child: ListTile(
          leading: ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_handle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            list.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // ------------------------------
  // UI PRINCIPAL
  // ------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text(
          "Mis Listas",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              _openColorPicker(context);
            },
          )
        ],

      ),

      body: ReorderableListView(
        padding: const EdgeInsets.only(bottom: 100),
        onReorder: _onReorder,
        children: [
          for (int index = 0; index < allLists.length; index++)
            _buildListTile(allLists[index], index),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
        onPressed: _createList,
      ),
    );
  }
}
