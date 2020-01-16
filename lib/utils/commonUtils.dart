import 'package:intl/intl.dart';

class CommonUtils {
  /// ------------------------------------------------------------
  /// Method that returns the current date.
  /// ------------------------------------------------------------
  static String getCurrentDate() {
    return DateFormat('dd-MMM-yyyy').format(new DateTime.now());
  }

  /// ------------------------------------------------------------
  /// Method that calculate difference between two dates.
  /// ------------------------------------------------------------
  static String calculateDifference(String lastSeen) {
    DateTime lastSeenDate = new DateFormat("dd-MMM-yyyy").parse(lastSeen);
    final currentDate = DateTime.now();
    return currentDate.difference(lastSeenDate).inDays.toString();
  }
}
