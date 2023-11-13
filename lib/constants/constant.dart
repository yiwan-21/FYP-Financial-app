import 'package:flutter/material.dart';

class Constant {
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
    'Scholarships',
    'Other Income'
  ];

  // excluded from analytics features
  static const List<String> excludedCategories = [
    'Savings Goal',
  ];

  static const List<String> analyticsCategories = [
    ...expenseCategories,
    ...incomeCategories,
  ];

  static const List<String> allCategories = [
    ...expenseCategories,
    ...incomeCategories,
    ...excludedCategories,
  ];
  static const String noFilter = 'All Categories';

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

  static const List<String> splitMethod = [
    splitEqually,
    splitUnequally,
  ];
  static const String splitEqually = 'Equally';
  static const String splitUnequally = 'Unequally';
}
