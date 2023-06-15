import 'package:flutter/material.dart';

class Constants {
  static const double mobileMaxWidth = 768.0;
  static const double tabletMaxWidth = 992.0;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  static const List<String> expenseCategories = [
    'Food',
    'Transportation',
    'Rental',
    'Bill',
    'Education',
    'Personal Items',
    'Other Expenses'
  ];
  static const List<String> incomeCategories = [
    'Savings',
    'Pocket Money',
    'Part-time Job',
    'Scholarship/PTPTN/Sponsorship Programme',
    'Other Income'
  ];

  static const List<String> monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

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
}