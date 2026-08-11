import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateConverter {

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  static String dateToTimeOnly(DateTime dateTime) {
    return DateFormat(_timeFormatter()).format(dateTime);
  }

  static String dateToDateAndTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static String dateToDateAndTimeAm(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd ${_timeFormatter()}').format(dateTime);
  }

  static String dateToDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String dateToReadableDate(DateTime dateTime) {
    return DateFormat('dd MMM, yyy').format(dateTime);
  }

  static String dateTimeStringToDateTime(String dateTime) {
    DateTime d;
    try{
      d = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
    } catch(_) {
     d = isoStringToLocalDate(dateTime);
    }
    return '\u200E${DateFormat('dd MMM yyyy,  ${_timeFormatter()}').format(d)}';
  }

  static String taxiDateTimeToString(DateTime dateTime) {
    return DateFormat('dd MMM yyyy,  ${_timeFormatter()}').format(dateTime);
  }

  static String dateTimeStringToUTCTime(String dateTime) {
    try {
      DateTime dt;
      try {
        dt = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
      } catch (_) {
        dt = DateTime.parse(dateTime);
      }
      return DateFormat('dd MMM yyyy  ${_timeFormatter()}').format(dt);
    } catch (_) {
      return dateTime;
    }
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    try {
      return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
    }catch(_) {
      return DateTime.parse(dateTime).toLocal();
    }
  }

  static String isoStringToLocalString(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(dateTime).toLocal());
  }

  static String isoStringToReadableString(String dateTime) {
    return DateFormat('dd MMMM, yyyy HH:mm a').format(DateTime.parse(dateTime).toLocal());
  }

  static String stringToReadableString(String dateTime) {
    return DateFormat('dd MMMM, yyyy').format(DateTime.parse(dateTime).toLocal());
  }

  static String isoStringToDateTimeString(String dateTime) {
    String? languageCode = Get.locale?.languageCode;
    return '\u200E${DateFormat('dd MMM yyyy  ${_timeFormatter()}', languageCode).format(isoStringToLocalDate(dateTime))}';
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd-MM-yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String stringToLocalDateOnly(String dateTime) {
    return DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String convertTimeToTime(String time) {
    return DateFormat(_timeFormatter()).format(DateFormat('HH:mm').parse(time));
  }

  static DateTime convertStringTimeToDate(String time) {
    return DateFormat('HH:mm').parse(time);
  }

  static String convertTimeToTimeDate(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static bool isAvailable(String? start, String? end, {DateTime? time}) {
    DateTime currentTime;
    if(time != null) {
      currentTime = time;
    }else {
      currentTime = Get.find<SplashController>().currentTime;
    }
    DateTime start0 = start != null ? DateFormat('HH:mm').parse(start) : DateTime(currentTime.year);
    DateTime end0 = end != null ? DateFormat('HH:mm').parse(end) : DateTime(currentTime.year, currentTime.month, currentTime.day, 23, 59, 59);
    DateTime startTime = DateTime(currentTime.year, currentTime.month, currentTime.day, start0.hour, start0.minute, start0.second);
    DateTime endTime = DateTime(currentTime.year, currentTime.month, currentTime.day, end0.hour, end0.minute, end0.second);
    if(endTime.isBefore(startTime)) {
      if(currentTime.isBefore(startTime) && currentTime.isBefore(endTime)){
        startTime = startTime.add(const Duration(days: -1));
      }else {
        endTime = endTime.add(const Duration(days: 1));
      }
    }
    return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
  }

  static String _timeFormatter() {
    try {
      if (Get.isRegistered<SplashController>() && Get.find<SplashController>().configModel != null) {
        return Get.find<SplashController>().configModel!.timeformat == '24' ? 'HH:mm' : 'hh:mm a';
      }
    } catch (_) {}
    return 'hh:mm a';
  }

  static String convertFromMinute(int minMinute, int maxMinute) {
    int firstValue = minMinute;
    int secondValue = maxMinute;
    String type = 'min';
    if(minMinute >= 525600) {
      firstValue = (minMinute / 525600).floor();
      secondValue = (maxMinute / 525600).floor();
      type = 'year';
    }else if(minMinute >= 43200) {
      firstValue = (minMinute / 43200).floor();
      secondValue = (maxMinute / 43200).floor();
      type = 'month';
    }else if(minMinute >= 10080) {
      firstValue = (minMinute / 10080).floor();
      secondValue = (maxMinute / 10080).floor();
      type = 'week';
    }else if(minMinute >= 1440) {
      firstValue = (minMinute / 1440).floor();
      secondValue = (maxMinute / 1440).floor();
      type = 'day';
    }else if(minMinute >= 60) {
      firstValue = (minMinute / 60).floor();
      secondValue = (maxMinute / 60).floor();
      type = 'hour';
    }
    return '$firstValue-$secondValue ${type.tr}';
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('${_timeFormatter()} | d-MMM-yyyy ').format(dateTime.toLocal());
  }

  static bool isBeforeTime(String? dateTime) {
    if(dateTime == null) {
      return false;
    }
    DateTime scheduleTime = dateTimeStringToDate(dateTime);
    return scheduleTime.isBefore(DateTime.now());
  }

  static int differenceInMinute(String? deliveryTime, String? orderTime, int? processingTime, String? scheduleAt) {
    // 'min', 'hours', 'days'
    int minTime = processingTime ?? 0;
    if(deliveryTime != null && deliveryTime.isNotEmpty && processingTime == null) {
      try {
        List<String> timeList = deliveryTime.split('-'); // ['15', '20']
        minTime = int.parse(timeList[0]);
      }catch(_) {}
    }
    final targetTimeStr = scheduleAt ?? orderTime;
    if (targetTimeStr == null || targetTimeStr.isEmpty) return 0;
    try {
      DateTime deliveryTime0 = dateTimeStringToDate(targetTimeStr).add(Duration(minutes: minTime));
      return deliveryTime0.difference(DateTime.now()).inMinutes;
    } catch (_) {
      return 0;
    }
  }

  static String containTAndZToUTCFormat(String time) {
    try {
      // Need at least 23 chars for "yyyy-MM-ddTHH:mm:ss.SSS"
      if (time.length >= 23) {
        final newTime = '${time.substring(0, 10)} ${time.substring(11, 23)}';
        return DateFormat('dd MMM, yyyy').format(
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(newTime),
        );
      }
      // Fallback: parse whatever we have (date-only, short ISO, etc.)
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(time.split('T').first));
    } catch (_) {
      // Last resort: return the raw string rather than crashing
      return time;
    }
  }

  static String convertTodayYesterdayFormat(String createdAt) {
    final now = DateTime.now();
    final createdAtDate = DateTime.parse(createdAt).toLocal();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final createdDay = DateTime(createdAtDate.year, createdAtDate.month, createdAtDate.day);

    if (createdDay == today) {
      return 'Today, ${DateFormat.jm().format(createdAtDate)}';
    } else if (createdDay == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(createdAtDate)}';
    } else {
      return DateConverter.localDateToIsoStringAMPM(createdAtDate);
    }
  }

  static String convertOnlyTodayTime(String createdAt) {
    final now = DateTime.now();
    final createdAtDate = DateTime.parse(createdAt).toLocal();

    if (createdAtDate.year == now.year &&
        createdAtDate.month == now.month &&
        createdAtDate.day == now.day) {
      return DateFormat('h:mm a').format(createdAtDate);
    } else {
      return DateConverter.localDateToIsoStringAMPM(createdAtDate);
    }
  }

  static String convertRestaurantOpenTime(String time) {
    return DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(time).toLocal());
  }

  static String dateTimeStringToFormattedTime(String dateTime) {
    return DateFormat(_timeFormatter()).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static DateTime formattingTripDateTime(DateTime pickedTime, DateTime pickedDate) {
    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
  }

  static bool isSameDate(DateTime pickedTime) {
    return pickedTime.year == DateTime.now().year && pickedTime.month == DateTime.now().month && pickedTime.day == DateTime.now().day && pickedTime.hour == DateTime.now().hour && pickedTime.minute == DateTime.now().minute;
  }

  static bool isAfterCurrentDateTime(DateTime pickedTime) {
    DateTime pick = DateTime(pickedTime.year, pickedTime.month, pickedTime.day, pickedTime.hour, pickedTime.minute);
    DateTime current = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute);
    return pick.isAfter(current);
  }

  static int durationFromNow(String time) {
    DateTime parsedTime = DateTime.parse(time);
    return parsedTime.difference(DateTime.now()).inMinutes;
  }

  static String dateToDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static String convertTodayYesterdayDate(String createdAt) {
    final DateTime createdDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    if (createdDate.year == now.year && createdDate.month == now.month && createdDate.day == now.day) {
      return 'Today';
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (createdDate.year == yesterday.year && createdDate.month == yesterday.month && createdDate.day == yesterday.day) {
      return 'Yesterday';
    }

    return formatter.format(createdDate);
  }

  static String stringDateTimeToDate(String dateTime) {
    return DateFormat('dd MMM, yyyy').format(DateFormat('yyyy-MM-dd').parse(dateTime));
  }

}
