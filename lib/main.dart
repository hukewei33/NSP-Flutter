import 'package:flutter/material.dart';
import 'package:nsp_mobile/landing_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xff0fedc7), // Rich black for background
        scaffoldBackgroundColor: Color(0xff030810),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xff0fedc7)), // Aquamarine text color
          bodyMedium: TextStyle(color: Color(0xff0fedc7)),
        ),
        buttonTheme: ButtonThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xff0fedc7), // Aquamarine for buttons
            surface: Color(0xff030810), // Rich black for background
          ),
          buttonColor: Color(0xff0fedc7),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xff0fedc7)),
            foregroundColor: MaterialStateProperty.all(Color(0xff030810)),
          )
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xff030810),
          foregroundColor: Color(0xff0fedc7),
          elevation: 0,
        ),
        
      ),
      home: LandingScreen(),
    );
  }
}
