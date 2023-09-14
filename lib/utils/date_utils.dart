DateTime getOnlyDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime getNextMonth(DateTime date) {
  DateTime nextMonth = DateTime(date.year, date.month + 1, date.day);
  if (nextMonth.month - date.month > 1) {
    nextMonth = DateTime(date.year, date.month, 0);
  }
  return nextMonth;
}