// services/storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String NOTES_KEY = 'notes';

  // 保存所有笔记的ID列表
  Future<void> saveNotesList(List<String> noteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(NOTES_KEY, noteIds);
  }

  // 获取所有笔记的ID列表
  Future<List<String>> getNotesList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(NOTES_KEY) ?? [];
  }

  // 保存单个笔记
  Future<void> saveNote(Note note) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes/${note.id}.json');
    
    // 确保目录存在
    await Directory('${directory.path}/notes').create(recursive: true);
    
    // 将笔记保存为JSON文件
    await file.writeAsString(note.toJsonString());
    
    // 更新笔记列表
    final noteIds = await getNotesList();
    if (!noteIds.contains(note.id)) {
      noteIds.add(note.id);
      await saveNotesList(noteIds);
    }
  }

  // 获取单个笔记
  Future<Note?> getNote(String noteId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes/${noteId}.json');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return Note.fromJsonString(jsonString);
      }
      return null;
    } catch (e) {
      print('Error loading note: $e');
      return null;
    }
  }

  // 获取所有笔记
  Future<List<Note>> getAllNotes() async {
    final noteIds = await getNotesList();
    final List<Note> notes = [];
    
    for (final id in noteIds) {
      final note = await getNote(id);
      if (note != null) {
        notes.add(note);
      }
    }
    
    // 按更新时间排序，最新的在前面
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  // 删除笔记
  Future<void> deleteNote(String noteId) async {
    // 删除文件
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes/${noteId}.json');
    
    if (await file.exists()) {
      await file.delete();
    }
    
    // 从列表中移除
    final noteIds = await getNotesList();
    noteIds.remove(noteId);
    await saveNotesList(noteIds);
  }

  // 导出笔记到本地文件
  Future<String> exportNoteToFile(Note note) async {
    final directory = await getExternalStorageDirectory() ?? 
                     await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    await exportDir.create(recursive: true);
    
    final file = File('${exportDir.path}/${note.title.isEmpty ? "Untitled" : note.title}_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(note.toJsonString());
    
    return file.path;
  }

  // 保存图片
  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    await imagesDir.create(recursive: true);
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await imageFile.copy('${imagesDir.path}/$fileName');
    
    return savedFile.path;
  }

  // 保存录音
  Future<String> saveAudio(File audioFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/audio');
    await audioDir.create(recursive: true);
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final savedFile = await audioFile.copy('${audioDir.path}/$fileName');
    
    return savedFile.path;
  }
}