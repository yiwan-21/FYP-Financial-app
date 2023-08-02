import 'group_user.dart';
import '../components/split_record_card.dart';

class SplitExpense {
  String? id;
  String? title;
  double? amount;
  String? splitMethod;
  GroupUser? paidBy;
  List<GroupUser>? sharedBy;
  List<SplitRecordCard>? records;

  SplitExpense({
    this.id,
    this.title,
    this.amount,
    this.splitMethod,
    this.paidBy,
    this.sharedBy,
    this.records,
  });
}