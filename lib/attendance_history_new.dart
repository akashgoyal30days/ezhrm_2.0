/*
credit to data
0 -> Absent
1 -> Leave Full Day
2 -> Leave Half Day
3 -> Attendance Full Day
4 -> Attendance Half Day
5 -> Work From Home
6 -> Short Leave
7 -> Attendance Submitted
8 -> ---------
9 -> Official Holiday
 */

import 'dart:convert';
import 'dart:developer';

import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import 'constants.dart';
import 'drawer.dart';
import 'services/shared_preferences_singleton.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime? userSelectedDate = DateTime.now(), dateTimeToday;

  final List loadedMonths = [];
  final Map allLoadedDates = {};
  // final Map<DateTime, List> holidays = {};
  bool showLoading = false;
  String? sundaytext;
  DateTime focusday = DateTime.now();
  CalendarFormat calenderformat = CalendarFormat.month;

  @override
  void initState() {
    dateTimeToday =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    getAttendanceHistory(userSelectedDate!);
    super.initState();
  }

  getAttendanceHistory(DateTime date) async {
    if (showLoading) return;
    setState(() {
      showLoading = true;
    });
    String month = "${date.month.toString()}-${date.year.toString()}";
    if (loadedMonths.contains(month)) {
      setState(() {
        showLoading = false;
      });
      return;
    }
    loadedMonths.add(month);
    var urii = "$customurl/controller/process/app/attendance.php";
    final responsenew = await http.post(Uri.parse(urii), body: {
      'type': 'fetch',
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'uid': SharedPreferencesInstance.getString('uid'),
      'month': date.month.toString(),
      'year': date.year.toString(),
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    log("Data We are Sending in Attendance History : " +
        {
          'type': 'fetch',
          'cid': SharedPreferencesInstance.getString('comp_id'),
          'uid': SharedPreferencesInstance.getString('uid'),
          'month': date.month.toString(),
          'year': date.year.toString(),
        }.toString());
    var mydataatt = json.decode(responsenew.body);
    log("Attendance History Response : " + mydataatt.toString());
    List responseDates = mydataatt["data"]["attendance"] ?? [];
    for (var element in responseDates) {
      if (element["date"] == null) continue;
      String creditID = element["credit_id"].toString();
      element["color"] = creditID == '0'
          ? Colors.red[800]
          : creditID == '1'
              ? Colors.green
              : creditID == '2'
                  ? Colors.red.shade100
                  : creditID == '3'
                      ? Colors.blue
                      : creditID == '4'
                          ? Colors.yellow
                          : creditID == '5'
                              ? Colors.blueAccent
                              : creditID == '6'
                                  ? Colors.purple
                                  : creditID == '7'
                                      ? Colors.black
                                      : creditID == '9'
                                          ? Colors.grey
                                          : creditID == "11"
                                              ? Colors.amber.shade800
                                              : Colors.brown;
      /*
credit to data
0 -> Absent
1 -> Leave Full Day
2 -> Leave Half Day
3 -> Attendance Full Day
4 -> Attendance Half Day
5 -> Work From Home
6 -> Short Leave
7 -> Attendance Submitted
8 -> ---------
9 -> Official Holiday
 */

      element["credit"] = creditID == '0'
          ? "Absent"
          : creditID == '1'
              ? "Full Day Leave"
              : creditID == '2'
                  ? "Half Day Leave"
                  : creditID == '3'
                      ? "Full Day Attendance"
                      : creditID == '4'
                          ? "Half Day Attendance"
                          : creditID == '5'
                              ? "Work From Home"
                              : creditID == '6'
                                  ? "Short Leave"
                                  : creditID == '7'
                                      ? "Attendance Submitted"
                                      : creditID == '9'
                                          ? "Official Holiday"
                                          : creditID == '11'
                                              ? 'Request Pending'
                                              : "";
      allLoadedDates[element["date"]] = element;
      if (element["credit_id"].toString() == "9") {
        String date = element["date"];
        // holidays[DateTime(
        //     int.parse(date.substring(0, 4)),
        //     int.parse(date.substring(5, 7)),
        //     int.parse(date.substring(8)))] = const [];
      }
    }
    // log(allLoadedDates.toString());
    setState(() {
      showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String selectedDate =
        "${DateFormat("y").format(userSelectedDate!)}-${DateFormat("MM").format(userSelectedDate!)}-${DateFormat("dd").format(userSelectedDate!)}";
    final bool checkInAvailable =
        (allLoadedDates[selectedDate] ?? {})["in_time"] != null &&
            (allLoadedDates[selectedDate] ?? {})["in_time"].toString() != " ";
    final bool checkOutAvailable =
        (allLoadedDates[selectedDate] ?? {})["out_time"] != null &&
            (allLoadedDates[selectedDate] ?? {})["out_time"].toString() != " ";
    final bool isOfficialHoliday =
        (allLoadedDates[selectedDate] ?? {})["credit_id"] == "9";
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer:
          CustomDrawer(currentScreen: AvailableDrawerScreens.attendanceHistory),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(context: context, builder: (_) => InfoWidget());
              },
              icon: const Icon(Icons.info))
        ],
        backgroundColor: Colors.blue,
        bottomOpacity: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: const Text(
          "Attendance History",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              focusedDay: focusday,
              firstDay: DateTime(2001),
              lastDay: DateTime(2100),
              onFormatChanged: (format) {
                calenderformat = format;
                setState(() {});
              },
              calendarFormat: calenderformat,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, events) {
                  if (date.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (date.difference(dateTimeToday!).inDays > 0) {
                    String month = date.month < 10 ? "0" : "";
                    month = month + "${date.month}";
                    String day = date.day < 10 ? "0" : "";
                    day = day + "${date.day}";
                    var item = allLoadedDates["${date.year}-$month-$day"];
                    if (item != null) {
                      if (item["credit_id"].toString() == "9") {
                        return Container(
                          margin: const EdgeInsets.all(2.0),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Text(
                            date.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    }
                  }
                  if (date.difference(dateTimeToday!).inDays <= 0) {
                    String month = date.month < 10 ? "0" : "";
                    month = month + "${date.month}";
                    String day = date.day < 10 ? "0" : "";
                    day = day + "${date.day}";
                    var item = allLoadedDates["${date.year}-$month-$day"];
                    if (item != null) {
                      if (item["credit_id"].toString() == "9") {
                        return Container(
                          margin: const EdgeInsets.all(2.0),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Text(
                            date.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return Container(
                          margin: const EdgeInsets.all(2.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (item["color"] as Color),
                          ),
                          child: Text(
                            date.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ));
                    }
                  }
                  return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Color(0xff072a99)),
                      ));
                },
                selectedBuilder: (context, date, events) {
                  var now = dateTimeToday;
                  if (date.difference(now!).inDays == 0) {
                    return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Color(0xff072a99), shape: BoxShape.circle),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        ));
                  }
                  if (date.difference(now).inDays > 0) {
                    return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xff072a99),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        ));
                  }
                  String month = date.month < 10 ? "0" : "";
                  month = month + "${date.month}";
                  String day = date.day < 10 ? "0" : "";
                  day = day + "${date.day}";
                  var item = allLoadedDates["${date.year}-$month-$day"];
                  if (item != null) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: (item["color"] as Color).withOpacity(0.8),
                          shape: BoxShape.circle),
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xff072a99), shape: BoxShape.circle),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
                todayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0x99072a99), shape: BoxShape.circle),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                canMarkersOverflow: true,
                holidayTextStyle: TextStyle(color: Colors.orange),
                weekendTextStyle:
                    TextStyle(color: Color.fromRGBO(183, 28, 28, 1)),
              ),
              onPageChanged: (date) {
                // if (date.year == DateTime.now().year &&
                //     date.month > DateTime.now().month) {
                //   log("else case");
                //   focusday = DateTime.now();
                //   setState(() {});
                //   getAttendanceHistory(date);
                // } else {
                //   log("if case");
                //   focusday = date;
                //   setState(() {});
                //   getAttendanceHistory(date);
                // }

                focusday = date;
                setState(() {});
                getAttendanceHistory(date);
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (
                selectedDate,
                _,
              ) {
                setState(() => userSelectedDate = selectedDate);
                if (loadedMonths.contains(
                    "${userSelectedDate!.month.toString()}-${userSelectedDate!.year.toString()}")) {
                  return;
                }
                getAttendanceHistory(userSelectedDate!);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade50),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        DateFormat("dd MMM, y").format(userSelectedDate!),
                        style: const TextStyle(
                          color: Color(0xff072a99),
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    showLoading
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: LoadingAnimationWidget.twistingDots(
                                leftDotColor: const Color(0xff072a99),
                                rightDotColor: Colors.blue,
                                size: 40,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              if (userSelectedDate!
                                          .difference(dateTimeToday!)
                                          .inDays >
                                      0 &&
                                  userSelectedDate!.weekday != DateTime.sunday)
                                const SizedBox(
                                  height: 15,
                                ),
                              Text(
                                (allLoadedDates[selectedDate] ??
                                                    {})["credit_id"]
                                                .toString() ==
                                            '9' &&
                                        userSelectedDate!
                                                .isAfter(dateTimeToday!)
                                                .toString() ==
                                            'true'
                                    ? "Official Holiday"
                                    : "",
                                style: const TextStyle(
                                    letterSpacing: 1.5,
                                    fontSize: 20,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              if (userSelectedDate!
                                          .difference(dateTimeToday!)
                                          .inDays <=
                                      0 &&
                                  (allLoadedDates[selectedDate] ??
                                          {})["credit"] !=
                                      null &&
                                  (allLoadedDates[selectedDate] ??
                                          {})["credit"] !=
                                      "")
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      (allLoadedDates[selectedDate] ??
                                                  {})["credit"]
                                              .toString() ??
                                          "",
                                      style: TextStyle(
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color:
                                              (allLoadedDates[selectedDate] ??
                                                  {})["color"]),
                                    ),
                                  ),
                                ),
                              if ((allLoadedDates[selectedDate] ??
                                          {})["credit_id"]
                                      .toString() !=
                                  "0")
                                if (!isOfficialHoliday)
                                  !checkInAvailable && !checkOutAvailable
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: Text(
                                                    userSelectedDate!.weekday ==
                                                            DateTime.sunday
                                                        ? "Sunday"
                                                        : "",
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            if (checkInAvailable &&
                                                goGreenModel!
                                                    .showattendancetime!)
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text(
                                                      "CHECK IN :",
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        (allLoadedDates[
                                                                selectedDate] ??
                                                            {})["in_time"],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (checkOutAvailable &&
                                                goGreenModel!
                                                    .showattendancetime!)
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text(
                                                      "CHECK OUT:",
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        (allLoadedDates[
                                                                selectedDate] ??
                                                            {})["out_time"],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Text(
                  "Attendance History",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff072a99)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Text(
                  "To understand the different colors used in the Attendance, please go through the data below",
                ),
              ),
              const InfoWidgetItems(
                  title: "Attendance Full Day", color: Colors.blue),
              const InfoWidgetItems(
                  title: "Attendance Half Day ", color: Colors.yellow),
              const InfoWidgetItems(
                  title: "Attendance Submitted", color: Colors.black),
              InfoWidgetItems(
                  title: "Request Pending", color: Colors.amber.shade800),
              const InfoWidgetItems(
                  title: "Leave Full Day", color: Colors.green),
              InfoWidgetItems(
                  title: "Leave Half Day", color: Colors.red.shade100),
              const InfoWidgetItems(title: "Short Leave", color: Colors.purple),
              InfoWidgetItems(title: "Absent", color: Colors.red.shade800),
              const InfoWidgetItems(
                  title: "Work From Home", color: Colors.blueAccent),
              const InfoWidgetItems(
                  title: "Official Holiday", color: Colors.grey),
              Center(
                child: TextButton(
                  onPressed: Navigator.of(context).pop,
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(const Color(0xff072a99))),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InfoWidgetItems extends StatelessWidget {
  const InfoWidgetItems({Key? key, @required this.title, @required this.color})
      : super(key: key);
  final String? title;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          Expanded(
              child: Text(
            title!,
            style: const TextStyle(fontSize: 16),
          ))
        ],
      ),
    );
  }
}
