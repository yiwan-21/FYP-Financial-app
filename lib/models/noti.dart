class NotificationModel {
  final String title;
  final String message;
  final DateTime time;
  bool read;
  final Function navigateTo;

  NotificationModel(this.title, this.message, this.time, this.read, this.navigateTo);
}