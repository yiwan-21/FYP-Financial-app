DateTime getOnlyDate(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

DateTime getNextMonth(DateTime date) {
  DateTime nextMonth = DateTime.utc(date.year, date.month + 1, date.day);
  if (nextMonth.month - date.month > 1) {
    nextMonth = DateTime.utc(date.year, date.month, 0);
  }
  return nextMonth;
}

// @return: 0 - 11
List<int> getLatestNmonthIndex(int n) {
  List<int> months = [];
  int month = DateTime.now().month;
  for (int i = 0; i < n; i++) {
    months.add((month - i - 1 + 12) % 12);
  }

  return months;
}