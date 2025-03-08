// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/settings.dart';
import '../services/storage_service.dart';
import '../utils/localization.dart';
import 'note_editor.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _storageService.getAllNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notes),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => SettingsScreen()),
              );
              // 重新加载笔记，以防设置变化影响显示
              _loadNotes();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState(localizations)
              : _buildNotesList(localizations),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF007AFF),
        onPressed: () => _createNewNote(context),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '${localizations.notes} ${localizations.newNote}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          CupertinoButton(
            color: Color(0xFF007AFF),
            child: Text(localizations.newNote),
            onPressed: () => _createNewNote(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(AppLocalizations localizations) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              note.title.isEmpty ? localizations.untitled : note.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              _getNoteSummary(note),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              _formatDate(note.updatedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            onTap: () => _openNote(context, note),
            onLongPress: () => _showNoteOptions(context, note, localizations),
          ),
        );
      },
    );
  }

  String _getNoteSummary(Note note) {
    final textElements = note.elements.where((e) => e.type == 'text');
    if (textElements.isNotEmpty) {
      final firstText = textElements.first.data['text'] as String;
      return firstText.length > 100 ? '${firstText.substring(0, 100)}...' : firstText;
    }
    
    final hasImages = note.elements.any((e) => e.type == 'image');
    final hasAudio = note.elements.any((e) => e.type == 'audio');
    
    final List<String> contents = [];
    if (hasImages) contents.add('Images');
    if (hasAudio) contents.add('Audio');
    
    return contents.isEmpty ? 'Empty note' : contents.join(', ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      // Today
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // This week
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      // Older
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _createNewNote(BuildContext context) async {
    final newNote = Note(title: '');
    await _storageService.saveNote(newNote);
    
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => NoteEditor(note: newNote),
      ),
    );
    
    // 重新加载笔记列表
    _loadNotes();
  }

  void _openNote(BuildContext context, Note note) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => NoteEditor(note: note),
      ),
    );
    
    // 重新加载笔记列表
    _loadNotes();
  }

  void _showNoteOptions(BuildContext context, Note note, AppLocalizations localizations) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          note.title.isEmpty ? localizations.untitled : note.title,
          style: TextStyle(fontSize: 16),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text(localizations.export),
            onPressed: () async {
              Navigator.pop(context);
              await _exportNote(note);
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text(localizations.delete),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNote(note);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(localizations.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _exportNote(Note note) async {
    try {
      final filePath = await _storageService.exportNoteToFile(note);
      
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

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _storageService.deleteNote(note.id);
      _loadNotes();
    }
  }
}