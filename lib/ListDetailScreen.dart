import 'package:flutter/material.dart';
import 'package:gym_list/CheckItem.dart';
import 'package:gym_list/CheckList.dart';
import 'package:gym_list/EditListStyleScreen.dart';

class ListDetailScreen extends StatefulWidget {
  final CheckList list;
  final VoidCallback onUpdate;

  const ListDetailScreen({
    super.key,
    required this.list,
    required this.onUpdate,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  Color darkenColor(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  // --------------------------------------------
  // CREATE COLOR SCHEME BASED ON LIST STYLE
  // --------------------------------------------
  late ColorScheme listColorScheme;

  @override
  void initState() {
    super.initState();

    listColorScheme = ColorScheme.fromSeed(
      seedColor: widget.list.style.seedColor,
      brightness: Brightness.light,
    );
  }

  // --------------------------------------------
  // ADD ITEM
  // --------------------------------------------
  void _addItem() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Añadir ítem"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: "Nombre",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;

              setState(() {
                widget.list.items.add(CheckItem(name: _controller.text.trim()));
              });
              widget.onUpdate();
              _controller.clear();
              Navigator.pop(context);
            },
            child: const Text("Añadir"),
          )
        ],
      ),
    );
  }

  // --------------------------------------------
  // RESET LIST
  // --------------------------------------------
  void _reset() {
    setState(() {
      for (var item in widget.list.items) {
        item.checked = false;
      }
    });
    widget.onUpdate();
  }

  // --------------------------------------------
  // REORDER
  // --------------------------------------------
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = widget.list.items.removeAt(oldIndex);
      widget.list.items.insert(newIndex, item);
    });
    widget.onUpdate();
  }

  // --------------------------------------------
  // ITEM TILE
  // --------------------------------------------
  Widget _buildItem(CheckItem item, int index) {
    final primary = listColorScheme.primaryContainer;

    return AnimatedContainer(
      key: ValueKey(item),
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: listColorScheme.surface,
        borderRadius: BorderRadius.circular(widget.list.style.borderRadius),
        border: Border.all(
          color: item.checked
              ? darkenColor(primary, 0.30)
              : listColorScheme.outlineVariant,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.08),
          )
        ],
      ),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle_rounded,
            color: listColorScheme.primary,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 16,
            decoration: item.checked ? TextDecoration.lineThrough : null,
            color: item.checked ? listColorScheme.secondary : null,
          ),
        ),
        trailing: Transform.scale(
          scale: 1.4,
          child: Checkbox(
            value: item.checked,
            onChanged: (v) {
              setState(() => item.checked = v!);
              widget.onUpdate();
            },
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return widget.list.style.seedColor;
              }
              return Colors.transparent;
            }),
            side: BorderSide(
              color: widget.list.style.seedColor,
              width: 1.6,
            ),
          ),
        ),
        onTap: () {
          setState(() => item.checked = !item.checked);
          widget.onUpdate();
        },
      ),
    );
  }

  // --------------------------------------------
  // UI
  // --------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: listColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: listColorScheme.primaryContainer,
          foregroundColor: listColorScheme.onPrimaryContainer,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.list.title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditListStyleScreen(
                      list: widget.list,
                      onSave: widget.onUpdate,
                    ),
                  ),
                ).then((_) {
                  setState(() {
                    listColorScheme = ColorScheme.fromSeed(
                      seedColor: widget.list.style.seedColor,
                      brightness: Brightness.light,
                    );
                  });
                });

              },
            ),
          ],

        ),

        body: ReorderableListView(
          onReorder: _onReorder,
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            for (int i = 0; i < widget.list.items.length; i++)
              _buildItem(widget.list.items[i], i),
          ],
        ),

        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "reset",
              backgroundColor: Colors.red.shade400,
              child: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: "add",
              backgroundColor: listColorScheme.primary,
              child: const Icon(Icons.add),
              onPressed: _addItem,
            ),
          ],
        ),
      ),
    );
  }
}
