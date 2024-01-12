import 'package:ai_image/resources/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppThemes{
  ThemeData lightTheme = ThemeData(
    fontFamily: GoogleFonts.fanwoodText().fontFamily,
    scaffoldBackgroundColor: Pallete.whiteColor,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.whiteColor,
        ),
  );

  ThemeData darkTheme = ThemeData(
     fontFamily: GoogleFonts.fanwoodText().fontFamily,
    scaffoldBackgroundColor: Pallete.blackColor,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.borderColor,
        ),
  );
}
