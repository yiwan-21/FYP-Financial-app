import '../models/group_user.dart';
import '../models/split_record.dart';

class SplitExpense {
  String? id;
  String title;
  double amount;
  double paidAmount;
  String splitMethod;
  GroupUser paidBy;
  List<SplitRecord> sharedRecords; // also determine the shared users
  DateTime createdAt;

  SplitExpense({
    this.id,
    required this.title,
    required this.amount,
    required this.paidAmount,
    required this.splitMethod,
    required this.paidBy,
    required this.sharedRecords,
    required this.createdAt,
  });
}
