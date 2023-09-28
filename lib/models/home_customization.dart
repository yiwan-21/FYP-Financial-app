import 'package:cloud_firestore/cloud_firestore.dart';

class HomeCustomization {
  final List<String> items;
  final String groupID;
  final String budgetCategory;

  HomeCustomization({
    required this.items,
    required this.groupID,
    required this.budgetCategory,
  });

  HomeCustomization.fromDocument(DocumentSnapshot doc)
      : items = List<String>.from(doc['items']),
        groupID = doc['groupID'],
        budgetCategory = doc['budgetCategory'];
}