// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../utils/localization.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _apiBaseUrlController = TextEditingController();
  String _selectedModel = 'gpt-4';
  
  final List<String> _availableModels = [
    'gpt-4',
    'gpt-4o',
    'gpt-4-vision-preview',
    'claude-3-opus-20240229',
    'claude-3-sonnet-20240229',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsModel>(context, listen: false);
      _apiKeyController.text = settings.apiKey;
      _apiBaseUrlController.text = settings.apiBaseUrl;
      _selectedModel = settings.aiModel;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiBaseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final settings = Provider.of<SettingsModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 语言设置
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.language,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  CupertinoSegmentedControl<String>(
                    children: {
                      'zh': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(localizations.chinese),
                      ),
                      'en': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(localizations.english),
                      ),
                    },
                    onValueChanged: (value) {
                      final locale = value == 'zh' ? Locale('zh', 'CN') : Locale('en', 'US');
                      settings.setLocale(locale);
                    },
                    groupValue: settings.locale.languageCode,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // AI 模型设置
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.aiModel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedModel,
                        isExpanded: true,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        borderRadius: BorderRadius.circular(8),
                        items: _availableModels.map((model) {
                          return DropdownMenuItem<String>(
                            value: model,
                            child: Text(model),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedModel = value;
                            });
                            settings.setAiModel(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // API 设置
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API ' + localizations.settings,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: localizations.apiKey,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _apiBaseUrlController,
                    decoration: InputDecoration(
                      labelText: localizations.apiBaseUrl,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: Color(0xFF007AFF),
                      child: Text(localizations.save),
                      onPressed: () {
                        settings.setApiKey(_apiKeyController.text);
                        settings.setApiBaseUrl(_apiBaseUrlController.text);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Settings saved')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}