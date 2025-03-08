// utils/localization.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'AI Notes',
      'notes': 'Notes',
      'newNote': 'New Note',
      'settings': 'Settings',
      'language': 'Language',
      'aiModel': 'AI Model',
      'apiKey': 'API Key',
      'apiBaseUrl': 'API Base URL',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'export': 'Export',
      'organize': 'Organize with AI',
      'undo': 'Undo',
      'confirmOrganize': 'Keep organized note?',
      'yes': 'Yes',
      'no': 'No',
      'chinese': 'Chinese',
      'english': 'English',
      'untitled': 'Untitled',
      'addText': 'Add Text',
      'addImage': 'Add Image',
      'addVoice': 'Add Voice',
      'takePhoto': 'Take Photo',
      'chooseFromGallery': 'Choose from Gallery',
    },
    'zh': {
      'appTitle': 'AI 笔记',
      'notes': '笔记',
      'newNote': '新建笔记',
      'settings': '设置',
      'language': '语言',
      'aiModel': 'AI 模型',
      'apiKey': 'API 密钥',
      'apiBaseUrl': 'API 基础 URL',
      'save': '保存',
      'cancel': '取消',
      'delete': '删除',
      'export': '导出',
      'organize': '用AI整理',
      'undo': '撤销',
      'confirmOrganize': '保留整理后的笔记？',
      'yes': '是',
      'no': '否',
      'chinese': '中文',
      'english': '英文',
      'untitled': '未命名',
      'addText': '添加文本',
      'addImage': '添加图片',
      'addVoice': '添加语音',
      'takePhoto': '拍照',
      'chooseFromGallery': '从相册选择',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get notes => _localizedValues[locale.languageCode]!['notes']!;
  String get newNote => _localizedValues[locale.languageCode]!['newNote']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get aiModel => _localizedValues[locale.languageCode]!['aiModel']!;
  String get apiKey => _localizedValues[locale.languageCode]!['apiKey']!;
  String get apiBaseUrl => _localizedValues[locale.languageCode]!['apiBaseUrl']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get export => _localizedValues[locale.languageCode]!['export']!;
  String get organize => _localizedValues[locale.languageCode]!['organize']!;
  String get undo => _localizedValues[locale.languageCode]!['undo']!;
  String get confirmOrganize => _localizedValues[locale.languageCode]!['confirmOrganize']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get chinese => _localizedValues[locale.languageCode]!['chinese']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get untitled => _localizedValues[locale.languageCode]!['untitled']!;
  String get addText => _localizedValues[locale.languageCode]!['addText']!;
  String get addImage => _localizedValues[locale.languageCode]!['addImage']!;
  String get addVoice => _localizedValues[locale.languageCode]!['addVoice']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['takePhoto']!;
  String get chooseFromGallery => _localizedValues[locale.languageCode]!['chooseFromGallery']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}