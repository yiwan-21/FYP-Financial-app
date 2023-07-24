import '../components/split_record_card.dart';

class SplitExpense {
  String? id;
  String? title;
  double? amount;
  User? paidBy;
  List<User>? sharedBy;
  List<SplitRecordCard>? records;

  SplitExpense({
    this.id,
    this.title,
    this.amount,
    this.paidBy,
    this.sharedBy,
    this.records,
  });
}

class User {
  String id;
  String name;

  User(this.id, this.name);
}