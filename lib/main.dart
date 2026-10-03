import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'character_service.dart';
import 'characters_screen.dart';

void main() {
  runApp(const CharacterApp());
}

class CharacterApp extends StatelessWidget {
  const CharacterApp({super.key, this.service});

  final CharacterService? service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Characters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 109, 19, 19),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 76, 4, 4),
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: CharactersScreen(service: service),
    );
  }
}
