import 'group_user.dart';
import '../components/split_expense_card.dart';

class SplitGroup {
  String? id;
  String? name;
  String? owner;
  List<GroupUser>? members;
  List<SplitExpenseCard>? expenses;

  SplitGroup({
    this.id, 
    this.name, 
    this.owner, 
    this.members, 
    this.expenses,
  });
}