import 'package:gym_list/CheckItem.dart';
import 'package:gym_list/CheckList.dart';

import '../CheckItem.dart';
import '../CheckList.dart';

class TemplateDefinition {
  final String name;
  final List<CheckItem> items;

  TemplateDefinition({required this.name, required this.items});

  CheckList toCheckList() {
    return CheckList(
      title: name,
      items: items.map((i) => CheckItem(name: i.name)).toList(),
    );
  }
}


class Templates {
  static final List<TemplateDefinition> all = [
    TemplateDefinition(
      name: "Gimnasio",
      items: [
        CheckItem(name: "Toalla"),
        CheckItem(name: "Ropa deportiva"),
        CheckItem(name: "Botella de agua"),
        CheckItem(name: "Auriculares"),
      ],
    ),
    TemplateDefinition(
      name: "Compras",
      items: [
        CheckItem(name: "Leche"),
        CheckItem(name: "Pan"),
        CheckItem(name: "Huevos"),
      ],
    ),
    TemplateDefinition(
      name: "Viaje",
      items: [
        CheckItem(name: "Pasaporte"),
        CheckItem(name: "Cargador"),
        CheckItem(name: "Ropa"),
      ],
    ),
    TemplateDefinition(
      name: "Mañana",
      items: [
        CheckItem(name: "Lavarse los dientes"),
        CheckItem(name: "Enchufar el ordenador"),
        CheckItem(name: "Recoger la ropa"),
      ],
    ),
  ];
}
