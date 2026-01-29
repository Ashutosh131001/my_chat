import 'package:flutter/material.dart';

enum SettingType{profile ,privacy,logout,deleteAccount,
feedback
}

class SettingModel {
  final SettingType type;
  final String title;
  final IconData icon;

  const SettingModel({
    required this.type,
    required this.title,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name, 
      'title': title,
      'icon': icon.codePoint,
    };
  }

  factory SettingModel.fromMap(Map<String, dynamic> map) {
    return SettingModel(
      type: SettingType.values.byName(map['type']),
      title: map['title'],
      icon: IconData(
        map['icon'],
        fontFamily: 'MaterialIcons',
      ),
    );
  }
}