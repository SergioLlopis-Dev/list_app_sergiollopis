import 'package:flutter/material.dart';

class CheckItem {
  String name;
  bool checked;

  CheckItem({
    required this.name,
    this.checked = false,
  });

  void toggle() {
    checked = !checked;
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "checked": checked,
  };

  factory CheckItem.fromJson(Map<String, dynamic> json) {
    return CheckItem(name: json["name"], checked: json["checked"]);
  }
}