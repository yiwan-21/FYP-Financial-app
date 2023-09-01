import 'package:provider/provider.dart';

import '../main.dart';
import '../constants/route_name.dart';
import '../providers/navigation_provider.dart';
import '../providers/split_money_provider.dart';
import '../services/chat_service.dart';
import '../services/split_money_service.dart';

class NotificationModel {
  final String title;
  final String message;
  final DateTime date;
  final bool read;
  final Function navigateTo;
  
  const NotificationModel(this.title, this.message, this.date, this.read, this.navigateTo);
}

class NewExpenseNotification extends NotificationModel {
  NewExpenseNotification(groupID, date, read) :
  super(
    'New Group Expense', 
    'You have a new group expense from ${SplitMoneyService.getGroupName(groupID)}', 
    date,
    read, 
    () {
      Provider.of<SplitMoneyProvider>(navigatorKey.currentContext!, listen: false).setNewSplitGroup(groupID);
      navigatorKey.currentState!.pushNamed(RouteName.splitMoneyGroup, arguments: {'id': groupID}).then((_) {
        SplitMoneyService.resetGroupID();
      });
    },
  );
}

class ExpenseReminderNotification extends NotificationModel {
  ExpenseReminderNotification(expenseID, date, read) :
  super(
    'Group Expense to Settle', 
    'You have a group expense to settle from ${SplitMoneyService.getExpenseName(expenseID)}.', 
    date,
    read, 
    () {
      
    },
  );
}

class NewGroupNotification extends NotificationModel {
  NewGroupNotification(date, read) :
  super(
    'New Group',
    'You have been added to a new group.',
    date,
    read, 
    () {
      Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).goToSplitMoney();
    },
  );
}

class RemoveFromGroupNotification extends NotificationModel {
  RemoveFromGroupNotification(groupID, date, read) :
  super(
    'Removed from Group',
    'You have been removed from ${SplitMoneyService.getGroupName(groupID)}.',
    date,
    read, 
    () {
      Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).goToSplitMoney();
    },
  );
}

class NewChatNotification extends NotificationModel {
  NewChatNotification(expenseID, date, read) :
  super(
    'New Chat Message',
    'You have a new chat message from ${SplitMoneyService.getExpenseName(expenseID)}.',
    date,
    read, 
    () {
      navigatorKey.currentState!.pushNamed(RouteName.splitMoneyExpense, arguments: {'id': expenseID})
      .then((mssg) {
        if (mssg != null) {
          Provider.of<SplitMoneyProvider>(navigatorKey.currentContext!, listen: false).updateExpenses();
        }
        // reset expense ID in chat service
        ChatService.resetExpenseID();
      });
    },
  );
}

class ExpiringGoalNotification extends NotificationModel {
  ExpiringGoalNotification(date, read) :
  super(
    'Goal Expiring Soon', 
    'Your goal is expiring soon.',
    date,
    read, 
    () {
      Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).goToGoal();
    },
  );
}
