import 'group_user.dart';
import '../components/split_record_card.dart';

class SplitExpense {
  String? id;
  String? title;
  double? amount;
  GroupUser? paidBy;
  List<GroupUser>? sharedBy;
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