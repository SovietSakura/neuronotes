// models/note.dart
import 'dart:convert';
import 'package:uuid/uuid.dart';

class NoteElement {
  final String id;
  final String type; // 'text', 'image', 'audio'
  final Map<String, dynamic> data;
  final double x;
  final double y;
  final double width;
  final double height;

  NoteElement({
    String? id,
    required this.type,
    required this.data,
    required this.x,
    required this.y,
    this.width = 200,
    this.height = 100,
  }) : id = id ?? Uuid().v4();

  factory NoteElement.fromJson(Map<String, dynamic> json) {
    return NoteElement(
      id: json['id'],
      type: json['type'],
      data: json['data'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}

class Note {
  final String id;
  String title;
  List<NoteElement> elements;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    String? id,
    this.title = '',
    List<NoteElement>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? Uuid().v4(),
    elements = elements ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      elements: (json['elements'] as List)
          .map((e) => NoteElement.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'elements': elements.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  void addElement(NoteElement element) {
    elements.add(element);
    updatedAt = DateTime.now();
  }

  void removeElement(String elementId) {
    elements.removeWhere((element) => element.id == elementId);
    updatedAt = DateTime.now();
  }

  void updateElement(String elementId, NoteElement newElement) {
    final index = elements.indexWhere((element) => element.id == elementId);
    if (index != -1) {
      elements[index] = newElement;
      updatedAt = DateTime.now();
    }
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static Note fromJsonString(String jsonString) {
    return Note.fromJson(jsonDecode(jsonString));
  }
}