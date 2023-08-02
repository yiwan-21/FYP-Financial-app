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
    'Savings Goal',
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

   static const List<String> splitMethod = [
    'Equally',
    'Unequally',
    ''
   ];
}
