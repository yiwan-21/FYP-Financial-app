import 'package:flutter/material.dart';

class StyleConstant {
  static Icon getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return const Icon(Icons.fastfood);
      case 'Transportation':
        return const Icon(Icons.directions_bus);
      case 'Rental':
        return const Icon(Icons.house);
      case 'Bill':
        return const Icon(Icons.event_note_outlined);
      case 'Savings Goal':
        return const Icon(Icons.star);
      case 'Education':
        return const Icon(Icons.cases_outlined);
      case 'Personal Items':
        return const Icon(Icons.face);
      case 'Other Expenses':
        return const Icon(Icons.money_off);
      case 'Savings':
        return const Icon(Icons.attach_money);
      case 'Pocket Money':
        return const Icon(Icons.attach_money);
      case 'Part-time Job':
        return const Icon(Icons.attach_money);
      case 'Scholarship/PTPTN/Sponsorship Programme':
        return const Icon(Icons.attach_money);
      case 'Other Income':
        return const Icon(Icons.attach_money);
      default:
        return const Icon(Icons.category);
    }
  }

  static Icon getPaidIcon(bool paid) {
    if (paid) {
      return const Icon(Icons.account_balance_wallet_outlined);
    }
    if (!paid) {
      return const Icon(Icons.money_outlined);
    }
    return const Icon(Icons.category);
  }
}

class ColorConstant {
  static const List<Color> chartColors = [
    Color.fromRGBO(128, 221, 220, 1),
    Color.fromRGBO(246, 214, 153, 1),
    Color.fromRGBO(255, 174, 164, 1),
    Color.fromRGBO(31, 120, 190, 1),
    Color.fromRGBO(231, 93, 111, 1),
    Color.fromRGBO(174, 74, 174, 1),
    Colors.lightBlue,
  ];

  static const Color lightBlue = Color.fromARGB(255, 213, 242, 255);
}

class TextStyleConstant {
  static const TextStyle text12Normal = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );
  static const TextStyle text14Bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle text16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle text20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}

// Custom Swatch color
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

MaterialColor lightRed = createMaterialColor(const Color.fromARGB(255, 220, 46, 69));
