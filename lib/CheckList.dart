import 'package:flutter/material.dart';
import 'package:gym_list/CheckItem.dart';

class CheckList {
  String title;
  List<CheckItem> items;
  CheckListStyle style;

  CheckList({
    required this.title,
    required this.items,
    CheckListStyle? style,
  }) : style = style ?? defaultStyle;

  Map<String, dynamic> toJson() => {
    "title": title,
    "items": items.map((e) => e.toJson()).toList(),
    "style": style.toJson(),
  };

  factory CheckList.fromJson(Map<String, dynamic> json) {
    return CheckList(
      title: json["title"] ?? "Lista sin nombre",
      items: (json["items"] as List)
          .map((e) => CheckItem.fromJson(e))
          .toList(),
      style: json["style"] != null
          ? CheckListStyle.fromJson(json["style"])
          : defaultStyle,
    );
  }
}



const CheckListStyle defaultStyle = CheckListStyle(
  seedColor: Color(0xFF4B6477),
  icon: Icons.list,
  borderRadius: 18,
);


class CheckListStyle {
  final Color seedColor;
  final IconData icon;
  final double borderRadius;

  const CheckListStyle({
    required this.seedColor,
    this.icon = Icons.list,
    this.borderRadius = 18,
  });

  Map<String, dynamic> toJson() => {
    "seedColor": seedColor.value,
    "icon": icon.codePoint,
    "borderRadius": borderRadius,
  };

  factory CheckListStyle.fromJson(Map<String, dynamic> json) {
    return CheckListStyle(
      seedColor: Color(json["seedColor"] ?? Colors.blue.value),
      icon: json["icon"] != null
          ? IconData(json["icon"], fontFamily: "MaterialIcons")
          : Icons.list,
      borderRadius: (json["borderRadius"] ?? 18).toDouble(),
    );
  }
}
