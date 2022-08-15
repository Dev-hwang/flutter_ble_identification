import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => buildThemeData(
    // App Theme
    brightness: Brightness.light,
    primarySwatch: const MaterialColor(0xFF001B5B, {
      50: Color(0xFFE5E8F1),
      100: Color(0xFFBEC5DD),
      200: Color(0xFF939FC6),
      300: Color(0xFF6A7AAF),
      400: Color(0xFF4B5FA0),
      500: Color(0xFF284591),
      600: Color(0xFF223E88),
      700: Color(0xFF18357D),
      800: Color(0xFF0F2B71),
      900: Color(0xFF001B5B),
    }),
    secondaryColor: const Color(0xFF001B5B),
    surfaceColor: Colors.white,
    canvasColor: Colors.white,
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    dividerColor: const Color(0xFFD2D2D2),
    disabledColor: const Color(0xFFAAABAB),

    // AppBar Theme
    appBarColor: const Color(0xFF001B5B),
    appBarIconColor: Colors.white,
    appBarTextColor: Colors.white,

    // Dialog Theme
    dialogColor: Colors.white,
    dialogTitleColor: const Color(0xFF222222),
    dialogContentColor: const Color(0xFF444444),

    // Button Theme
    buttonColor: const Color(0xFF001B5B),
    buttonTextColor: Colors.white,

    // Text Theme
    fontFamily: 'NotoSansCJKkr',
    headlineColor: const Color(0xFF222222),
    subtitleColor: const Color(0xFF222222),
    bodyTextColor: const Color(0xFF444444),
    captionColor: const Color(0xFF666666),
    overlineColor: const Color(0xFF666666),
  );

  static ThemeData buildThemeData({
    required Brightness brightness,
    required MaterialColor primarySwatch,
    required Color secondaryColor,
    Color? surfaceColor,
    Color? canvasColor,
    Color? backgroundColor,
    Color? scaffoldBackgroundColor,
    Color? errorColor,
    Color? dividerColor,
    Color? disabledColor,
    Color? appBarColor,
    Color? appBarIconColor,
    Color? appBarTextColor,
    double? appBarElevation,
    Color? cardColor,
    double? cardElevation,
    Color? dialogColor,
    Color? dialogTitleColor,
    Color? dialogContentColor,
    Color? buttonColor,
    Color? buttonTextColor,
    String? fontFamily,
    Color? headlineColor,
    Color? subtitleColor,
    Color? bodyTextColor,
    Color? captionColor,
    Color? overlineColor,
  }) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      // App Theme
      brightness: brightness,
      colorScheme: ColorScheme(
        primary: primarySwatch,
        primaryVariant: primarySwatch.shade700,
        secondary: secondaryColor,
        secondaryVariant: secondaryColor,
        surface: surfaceColor ??
            cardColor ??
            (isDark ? const Color(0xFF121212) : Colors.white),
        background: backgroundColor ??
            (isDark ? const Color(0xFF121212) : Colors.white),
        error: errorColor ??
            (isDark ? const Color(0xFFCF6679) : const Color(0xFFB00020)),
        onPrimary: isDark ? Colors.black : Colors.white,
        onSecondary: isDark ? Colors.black : Colors.black,
        onSurface: isDark ? Colors.white : Colors.black,
        onBackground: isDark ? Colors.white : Colors.black,
        onError: isDark ? Colors.black : Colors.white,
        brightness: brightness,
      ),
      primarySwatch: primarySwatch,
      primaryColor: primarySwatch,
      canvasColor: canvasColor,
      backgroundColor: backgroundColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      errorColor: errorColor,
      dividerColor: dividerColor,
      disabledColor: disabledColor,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        color: appBarColor,
        elevation: appBarElevation,
        iconTheme: IconThemeData(
          color: appBarIconColor,
        ),
        titleTextStyle: TextStyle(
          color: appBarTextColor,
          fontSize: 19.0,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: cardElevation,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: dialogColor,
        titleTextStyle: TextStyle(
          color: dialogTitleColor,
          fontSize: 19.0,
        ),
        contentTextStyle: TextStyle(
          color: dialogContentColor,
          fontSize: 17.0,
        ),
      ),

      // Button Theme
      buttonTheme: ButtonThemeData(
        buttonColor: buttonColor,
      ),

      // Text Theme
      fontFamily: fontFamily,
      textTheme: TextTheme(
        headline1: TextStyle(color: headlineColor, fontSize: 96.0),
        headline2: TextStyle(color: headlineColor, fontSize: 60.0),
        headline3: TextStyle(color: headlineColor, fontSize: 48.0),
        headline4: TextStyle(color: headlineColor, fontSize: 34.0),
        headline5: TextStyle(color: headlineColor, fontSize: 24.0),
        headline6: TextStyle(color: headlineColor, fontSize: 19.0),
        subtitle1: TextStyle(color: subtitleColor, fontSize: 17.0),
        subtitle2: TextStyle(color: subtitleColor, fontSize: 15.0),
        bodyText1: TextStyle(color: bodyTextColor, fontSize: 17.0),
        bodyText2: TextStyle(color: bodyTextColor, fontSize: 15.0),
        button: TextStyle(color: buttonTextColor, fontSize: 15.0),
        caption: TextStyle(color: captionColor, fontSize: 13.0),
        overline: TextStyle(color: overlineColor, fontSize: 11.0),
      ),
    );
  }
}
