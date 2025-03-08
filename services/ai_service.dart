// services/ai_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/note.dart';
import '../models/settings.dart';

class AIService {
  final SettingsModel settings;

  AIService(this.settings);

  // 语音转文字
  Future<String> speechToText(String audioPath) async {
    if (settings.apiKey.isEmpty) {
      throw Exception('API Key is not configured');
    }

    final uri = Uri.parse('${settings.apiBaseUrl}/audio/transcriptions');
    final request = http.MultipartRequest('POST', uri);
    
    // 添加API密钥
    request.headers['Authorization'] = 'Bearer ${settings.apiKey}';
    
    // 添加音频文件
    final file = File(audioPath);
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();
    
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: 'audio.m4a',
      contentType: MediaType('audio', 'm4a'),
    );
    
    request.files.add(multipartFile);
    request.fields['model'] = 'whisper-1';
    
    try {
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final respJson = jsonDecode(respStr);
        return respJson['text'] ?? '';
      } else {
        throw Exception('Failed to transcribe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in speech to text: $e');
    }
  }

  // 使用AI整理笔记
  Future<Note> organizeNoteWithAI(Note note) async {
    if (settings.apiKey.isEmpty) {
      throw Exception('API Key is not configured');
    }

    // 创建一个note的副本
    final organizedNote = Note(
      id: note.id,
      title: note.title,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );

    // 准备发送给AI的数据
    final Map<String, dynamic> requestData = {
      'model': settings.aiModel,
      'messages': [
        {
          'role': 'system',
          'content': 'You are a helpful assistant that organizes notes. Analyze the content and organize it in a structured way.'
        },
        {
          'role': 'user',
          'content': []
        }
      ]
    };

    // 添加文本内容
    final userContent = requestData['messages'][1]['content'] as List;
    
    // 添加文本元素
    final textElements = note.elements.where((e) => e.type == 'text').toList();
    if (textElements.isNotEmpty) {
      userContent.add({
        'type': 'text',
        'text': 'Here are the text elements from my notes:'
      });
      
      for (var element in textElements) {
        userContent.add({
          'type': 'text',
          'text': element.data['text']
        });
      }
    }
    
    // 添加图片元素
    final imageElements = note.elements.where((e) => e.type == 'image').toList();
    if (imageElements.isNotEmpty) {
      userContent.add({
        'type': 'text',
        'text': 'Here are some images from my notes (please organize the text with them):'
      });
      
      for (var element in imageElements) {
        final imagePath = element.data['path'];
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(imageBytes);
        
        final imageType = imagePath.endsWith('.png') ? 'png' : 'jpeg';
        
        userContent.add({
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/$imageType;base64,$base64Image'
          }
        });
      }
    }
    
    // 添加请求整理的指令
    userContent.add({
      'type': 'text',
      'text': 'Please organize these notes into a coherent structure. Identify the main topics and subtopics, and create a well-organized note.'
    });

    // 发送请求
    final response = await http.post(
      Uri.parse('${settings.apiBaseUrl}/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.apiKey}'
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final respJson = jsonDecode(response.body);
      final content = respJson['choices'][0]['message']['content'];
      
      // 创建一个新的文本元素，包含AI整理后的内容
      organizedNote.addElement(
        NoteElement(
          type: 'text',
          data: {'text': content},
          x: 50,
          y: 50,
          width: 400,
          height: 600,
        )
      );
      
      // 复制原始笔记中的图片元素
      for (var element in imageElements) {
        organizedNote.addElement(element);
      }
      
      return organizedNote;
    } else {
      throw Exception('Failed to organize note: ${response.statusCode}');
    }
  }
}