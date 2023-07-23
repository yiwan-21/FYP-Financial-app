import '../components/split_expense_card.dart';

class SplitGroup {
  String? id;
  String? name;
  String? owner;
  List<String>? members;
  List<SplitExpenseCard>? expenses;

  SplitGroup({this.id, this.name, this.owner, this.members, this.expenses});
}