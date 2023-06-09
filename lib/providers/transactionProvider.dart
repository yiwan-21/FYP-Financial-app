import 'package:flutter/foundation.dart';
import '../constants.dart';

class TransactionProvider extends ChangeNotifier {
  String id = '';
  String title = '';
  String? notes;
  double amount = 0;
  DateTime date = DateTime.now();
  bool isExpense = true;
  String category = '';
  
  TransactionProvider();

  String get getId => id;
  String get getTitle => title;
  String? get getNotes => notes;
  double get getAmount => amount;
  DateTime get getDate => date;
  bool get getIsExpense => isExpense;
  String get getCategory => category;

  Future<void> setTransaction(String id, String title, double amount, DateTime date, bool isExpense, String category, {String? notes}) async {
    this.id = id;
    this.title = title;
    this.amount = amount;
    this.date = date;
    this.isExpense = isExpense;
    this.category = category;
    this.notes = notes;
    notifyListeners();
  }
}