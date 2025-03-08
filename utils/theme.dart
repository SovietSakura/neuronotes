// utils/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

ThemeData getAppTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Color(0xFF007AFF), // iOS blue
    scaffoldBackgroundColor: Color(0xFFF2F2F2), // iOS light gray
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFF2F2F2),
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headline2: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyText1: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF007AFF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color(0xFF007AFF),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.black12,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

// iOS风格的控件样式
class IOSStyleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const IOSStyleButton({
    required this.text,
    required this.onPressed,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color ?? Color(0xFF007AFF),
      borderRadius: BorderRadius.circular(8),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: onPressed,
    );
  }
}