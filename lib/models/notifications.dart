import 'package:provider/provider.dart';

import '../main.dart';
import '../constants/route_name.dart';
import '../providers/navigation_provider.dart';
import '../providers/split_money_provider.dart';
import '../services/chat_service.dart';
import '../services/split_money_service.dart';

class NotificationModel {
  String title;
  String message;
  final Function navigateTo;
  
  NotificationModel(this.title, this.message, this.navigateTo);

  Function navigateFunction() {
    return navigateTo;
  }
}

class NewExpenseNotification extends NotificationModel {
  NewExpenseNotification(groupName, groupID) :
  super(
    'New Group Expense', 
    'You have a new group expense from $groupName.', 
    () {
      Provider.of<SplitMoneyProvider>(navigatorKey.currentContext!, listen: false).setNewSplitGroup(groupID);
      navigatorKey.currentState!.pushNamed(RouteName.splitMoneyGroup, arguments: {'id': groupID}).then((_) {
        SplitMoneyService.resetGroupID();
      });
    },
  );
}

class ExpenseReminderNotification extends NotificationModel {
  ExpenseReminderNotification(expenseName, expenseID) :
  super(
    'Group Expense to Settle', 
    'You have a group expense to settle from $expenseName.', 
    () async {
      await SplitMoneyService.setGroupIDbyExpenseID(expenseID);
      navigatorKey.currentState!.pushNamed(RouteName.splitMoneyExpense, arguments: {'id': expenseID, 'tabIndex': 0});
    },
  );
}

class NewGroupNotification extends NotificationModel {
  NewGroupNotification(groupName) :
  super(
    'New Group',
    'You have been added to a new group $groupName.',
    () {
      Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).goToSplitMoney();
    },
  );
}

class RemoveFromGroupNotification extends NotificationModel {
  RemoveFromGroupNotification(groupName) :
  super(
    'Removed from Group',
    'You have been removed from $groupName.',
    () {
      Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).goToSplitMoney();
    },
  );
}

class NewChatNotification extends NotificationModel {
  NewChatNotification(expenseName, expenseID) :
  super(
    'New Chat Message',
    'You have a new chat message from $expenseName.',
    () async {
      await SplitMoneyService.setGroupIDbyExpenseID(expenseID);
      navigatorKey.currentState!.pushNamed(RouteName.splitMoneyExpense, arguments: {'id': expenseID, 'tabIndex': 1})
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
  ExpiringGoalNotification(goalNames) :
  super(
    'Goal Expiring Soon', 
    '$goalNames expiring soon.',
    () {
      Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).goToGoal();
    },
  );
}

class ExpiredGoalNotification extends NotificationModel {
  ExpiredGoalNotification(goalNames) :
  super(
    'Goal Expired', 
    '$goalNames expired.',
    () {
      Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).goToGoal();
    },
  );
}
