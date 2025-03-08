// screens/note_editor.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/settings.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../utils/localization.dart';
import '../widgets/infinite_canvas.dart';
import '../widgets/toolbar.dart';

class NoteEditor extends StatefulWidget {
  final Note note;

  NoteEditor({required this.note});

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late Note _note;
  late StorageService _storageService;
  late AIService _aiService;
  final TextEditingController _titleController = TextEditingController();
  
  // 录音相关
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _recordingPath;
  
  // AI整理相关
  bool _isOrganizing = false;
  Note? _organizedNote;
  
  // 图片选择器
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleController.text = _note.title;
    _storageService = StorageService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsModel>(context);
    _aiService = AIService(settings);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: localizations.untitled,
            border: InputBorder.none,
          ),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (value) {
            setState(() {
              _note.title = value;
            });
            _saveNote();
          },
        ),
        actions: [
          if (_organizedNote != null)
            Row(
              children: [
                TextButton(
                  child: Text(localizations.undo),
                  onPressed: _revertOrganizedNote,
                ),
                TextButton(
                  child: Text(localizations.save),
                  onPressed: _keepOrganizedNote,
                ),
              ],
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isOrganizing
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(localizations.organize),
                      ],
                    ),
                  )
                : InfiniteCanvas(
                    elements: _organizedNote?.elements ?? _note.elements,
                    onElementTap: _handleElementTap,
                    onElementMove: _handleElementMove,
                    onElementResize: _handleElementResize,
                  ),
          ),
          // 底部工具栏
          NoteToolbar(
            onAddText: _addTextElement,
            onAddImage: _showImageSourceOptions,
            onAddVoice: _toggleRecording,
            onOrganize: _organizeNote,
            onExport: _exportNote,
          ),
          // 录音指示器
          if (_isRecording)
            Container(
              height: 50,
              color: Colors.red.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Recording...'),
                  SizedBox(width: 16),
                  CupertinoButton(
                    padding: EdgeInsets.all(8),
                    color: Colors.red,
                    child: Text('Stop'),
                    onPressed: _stopRecording,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleElementTap(NoteElement element) {
    // 处理元素点击
    if (element.type == 'text') {
      _showTextEditor(element);
    } else if (element.type == 'audio') {
      // 处理音频播放
    }
  }

  void _handleElementMove(NoteElement updatedElement) {
    setState(() {
      final index = _note.elements.indexWhere((e) => e.id == updatedElement.id);
      if (index != -1) {
        _note.elements[index] = updatedElement;
      }
    });
    _saveNote();
  }

  void _handleElementResize(NoteElement updatedElement) {
    setState(() {
      final index = _note.elements.indexWhere((e) => e.id == updatedElement.id);
      if (index != -1) {
        _note.elements[index] = updatedElement;
      }
    });
    _saveNote();
  }

  void _addTextElement() async {
    final newElement = NoteElement(
      type: 'text',
      data: {'text': ''},
      x: 100,
      y: 100,
    );
    
    setState(() {
      _note.addElement(newElement);
    });
    
    await _saveNote();
    
    // 立即打开文本编辑器
    _showTextEditor(newElement);
  }

  void _showTextEditor(NoteElement element) {
    final textController = TextEditingController(text: element.data['text'] ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Enter text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                autofocus: true,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    child: Text('Save'),
                    onPressed: () {
                      final updatedElement = NoteElement(
                        id: element.id,
                        type: 'text',
                        data: {'text': textController.text},
                        x: element.x,
                        y: element.y,
                        width: element.width,
                        height: element.height,
                      );
                      
                      setState(() {
                        final index = _note.elements.indexWhere((e) => e.id == element.id);
                        if (index != -1) {
                          _note.elements[index] = updatedElement;
                        }
                      });
                      
                      _saveNote();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context);
        return CupertinoActionSheet(
          title: Text(localizations.addImage),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: Text(localizations.takePhoto),
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            CupertinoActionSheetAction(
              child: Text(localizations.chooseFromGallery),
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(localizations.cancel),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        final savedPath = await _storageService.saveImage(File(pickedFile.path));
        
        final newElement = NoteElement(
          type: 'image',
          data: {'path': savedPath},
          x: 100,
          y: 100,
          width: 300,
          height: 200,
        );
        
        setState(() {
          _note.addElement(newElement);
        });
        
        await _saveNote();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(path: filePath);
        
        setState(() {
          _isRecording = true;
          _recordingPath = filePath;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
      });
      
      if (path != null && _recordingPath != null) {
        // 保存录音文件
        final savedPath = await _storageService.saveAudio(File(path));
        
        // 尝试转录
        String transcription = '';
        try {
          transcription = await _aiService.speechToText(savedPath);
        } catch (e) {
          print('Error transcribing audio: $e');
          transcription = 'Audio Recording';
        }
        
        // 添加录音元素
        final newElement = NoteElement(
          type: 'audio',
          data: {
            'path': savedPath,
            'text': transcription,
          },
          x: 100,
          y: 100,
          width: 200,
          height: 100,
        );
        
        // 添加文本元素（如果成功转录）
        if (transcription.isNotEmpty && transcription != 'Audio Recording') {
          final textElement = NoteElement(
            type: 'text',
            data: {'text': transcription},
            x: 100,
            y: 210,
            width: 300,
            height: 150,
          );
          
          setState(() {
            _note.addElement(newElement);
            _note.addElement(textElement);
          });
        } else {
          setState(() {
            _note.addElement(newElement);
          });
        }
        
        await _saveNote();
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _organizeNote() async {
    if (_note.elements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No content to organize')),
      );
      return;
    }

    setState(() {
      _isOrganizing = true;
    });

    try {
      final organizedNote = await _aiService.organizeNoteWithAI(_note);
      
      setState(() {
        _organizedNote = organizedNote;
        _isOrganizing = false;
      });
      
      _showOrganizationConfirmation();
    } catch (e) {
      print('Error organizing note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to organize note: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isOrganizing = false;
      });
    }
  }

  void _showOrganizationConfirmation() {
    final localizations = AppLocalizations.of(context);
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(localizations.confirmOrganize),
        actions: [
          CupertinoDialogAction(
            child: Text(localizations.no),
            onPressed: () {
              Navigator.pop(context);
              _revertOrganizedNote();
            },
          ),
          CupertinoDialogAction(
            child: Text(localizations.yes),
            onPressed: () {
              Navigator.pop(context);
              _keepOrganizedNote();
            },
          ),
        ],
      ),
    );
  }

  void _revertOrganizedNote() {
    setState(() {
      _organizedNote = null;
    });
  }

  void _keepOrganizedNote() async {
    if (_organizedNote != null) {
      setState(() {
        _note = _organizedNote!;
        _organizedNote = null;
      });
      
      await _saveNote();
    }
  }

  Future<void> _exportNote() async {
    try {
      final filePath = await _storageService.exportNoteToFile(_note);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note exported to: $filePath'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveNote() async {
    _note.updatedAt = DateTime.now();
    await _storageService.saveNote(_note);
  }
}