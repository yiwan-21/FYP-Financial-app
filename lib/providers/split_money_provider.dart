import 'package:flutter/material.dart';

class SplitMoneyProvider extends ChangeNotifier {
  String id = '';
  String groupName = '';
  List<String> members = [];
  List<String> expenses = [];


    Future<void> setGroup() async {

    notifyListeners();
  }
}