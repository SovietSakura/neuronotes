// widgets/toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/localization.dart';

class NoteToolbar extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddImage;
  final VoidCallback onAddVoice;
  final VoidCallback onOrganize;
  final VoidCallback onExport;

  const NoteToolbar({
    required this.onAddText,
    required this.onAddImage,
    required this.onAddVoice,
    required this.onOrganize,
    required this.onExport,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            context: context,
            icon: Icons.text_fields,
            label: localizations.addText,
            onTap: onAddText,
          ),
          _buildToolbarButton(
            context: context,
            icon: Icons.image,
            label: localizations.addImage,
            onTap: onAddImage,
          ),
          _buildToolbarButton(
            context: context,
            icon: Icons.mic,
            label: localizations.addVoice,
            onTap: onAddVoice,
          ),
          _buildToolbarButton(
            context: context,
            icon: Icons.auto_fix_high,
            label: localizations.organize,
            onTap: onOrganize,
          ),
          _buildToolbarButton(
            context: context,
            icon: Icons.ios_share,
            label: localizations.export,
            onTap: onExport,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFF007AFF), size: 24),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF007AFF),
            ),
          ),
        ],
      ),
      onPressed: onTap,
    );
  }
}