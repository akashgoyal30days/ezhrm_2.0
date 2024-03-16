import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

import 'services/shared_preferences_singleton.dart';

class ShowAtt extends StatefulWidget {
  const ShowAtt({Key? key}) : super(key: key);

  @override
  _ShowAttState createState() => _ShowAttState();
}

class _ShowAttState extends State<ShowAtt>
    with SingleTickerProviderStateMixin<ShowAtt> {
  ScrollController? _scrollController;
  bool visible = false;
  Map? data;
  Map? datanew;
  List? userData;
  var userDatamy;
  List? userDatanew;
  String _value = 'start';
  String? _valuenew = 'start';
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  var newdata;

  final FocusNode myFocusNode = FocusNode();
  var currDt = DateTime.now();

  String? Month;
  String? monthint;
  String? yearint;

  show() {
    showDialog(
        context: context,
        builder: (_) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: SizedBox(
                    height: 230,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          child: Text(
                            'Colour Information',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                  ),
                                  Text('Absent (A)')
                                ],
                              ),
                              Row(
                                children: const [
                                  Text('Attendance Submitted (SUB)'),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.amber,
                                  ),
                                  Text('Short Leave (S.L.)')
                                ],
                              ),
                              Row(
                                children: const [
                                  Text('Official Holiday (H)'),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.indigo,
                                  ),
                                  Text('Late Present (L.P.)')
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Leave Half Day (L.H.)'),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.red[100],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.red[800],
                                  ),
                                  const Text('Leave Full Day (L)')
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Work From Home (W)'),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.blue[200],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.blue,
                                  ),
                                  Text('Attendance Full Day (P)')
                                ],
                              ),
                              Row(
                                children: const [
                                  Text('Present Half Day (P.H.)'),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.orange,
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ));
  }

  showdet(
      String date, String fulldate, String intime, String outtime, String rem) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
              child: ListBody(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 10),
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    width: 200.0,
                    height: 400.0,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 10),
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 100,
                                      decoration: TextDecoration.none),
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          fulldate,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              decoration: TextDecoration.none),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        intime == ''
                            ? const Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No in-time available for this date',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: font1,
                                        fontSize: 20,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        color: Colors.blue,
                                        height: 40,
                                        width: 100,
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'In Time',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                decoration:
                                                    TextDecoration.none),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        color: Colors.blue,
                                        height: 40,
                                        width: 150,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            intime,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                decoration:
                                                    TextDecoration.none),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                        intime == ''
                            ? const SizedBox()
                            : intime != '' && outtime == ''
                                ? const SizedBox()
                                : intime != '' && outtime != ''
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                color: Colors.blue,
                                                height: 40,
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Out Time',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        decoration:
                                                            TextDecoration
                                                                .none),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                color: Colors.blue,
                                                height: 40,
                                                width: 150,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    outtime,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        decoration:
                                                            TextDecoration
                                                                .none),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          rem,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              decoration: TextDecoration.none),
                        )
                      ],
                    )),
              )
            ],
          )),
        );
      },
      animationType: DialogTransitionType.size,
      curve: Curves.ease,
      duration: const Duration(seconds: 1),
    );
  }

  myyearint() {
    if (_value == 'start') {
      setState(() {
        yearint = currDt.year.toString();
      });
    } else {
      setState(() {
        yearint = _value;
      });
    }
  }

  mymonthint() {
    if (_valuenew == 'start') {
      setState(() {
        monthint = currDt.month.toString();
      });
    } else {
      setState(() {
        monthint = _valuenew;
      });
    }
  }

  mymonth() {
    if (monthint == '1') {
      setState(() {
        Month = 'January';
      });
    } else if (monthint == '2') {
      setState(() {
        Month = 'February';
      });
    } else if (monthint == '3') {
      setState(() {
        Month = 'March';
      });
    } else if (monthint == '4') {
      setState(() {
        Month = 'April';
      });
    } else if (monthint == '5') {
      setState(() {
        Month = 'May';
      });
    } else if (monthint == '6') {
      setState(() {
        Month = 'June';
      });
    } else if (monthint == '7') {
      setState(() {
        Month = 'July';
      });
    } else if (monthint == '8') {
      setState(() {
        Month = 'August';
      });
    } else if (monthint == '9') {
      setState(() {
        Month = 'September';
      });
    } else if (monthint == '10') {
      setState(() {
        Month = 'October';
      });
    } else if (monthint == '11') {
      setState(() {
        Month = 'November';
      });
    } else if (monthint == '12') {
      setState(() {
        Month = 'December';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _value = currDt.year.toString();
    _valuenew = DateFormat('M').format(currDt);
    _scrollController = ScrollController();

    try {
      getEmail();
      //  checkinternetconnection();
      fetchAtt();
      mymonthint();
      mymonth();
      myyearint();
    } catch (e) {
      //print(e);
    }
  }

  Future getEmail() async {
    setState(() {
      email = SharedPreferencesInstance.getString('email');
      username = SharedPreferencesInstance.getString('username');
      ppic = SharedPreferencesInstance.getString('profile');
      ppic2 = SharedPreferencesInstance.getString('profile2');
      uid = SharedPreferencesInstance.getString('uid');
      cid = SharedPreferencesInstance.getString('comp_id');
    });
  }

  List? myattendata1;
  List? myattendata;
  List? myholidaydata;
  var myleavedata;
  var holidaydate;
  var mholiday;
  var mholidaysplited;
  var i;
  var dated;
  DateTime? converteddate;
  var format;
  DateTime? myd;
  String? formattedTime;

  var outputformat = DateFormat('dd/MM/yyyy');
  Future fetchAtt() async {
    try {
      var urii = "$customurl/controller/process/app/attendance.php";
      final responsenew = await http.post(Uri.parse(urii), body: {
        'type': 'fetch',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid'),
        if (_valuenew == 'start')
          'month': currDt.month.toString()
        else
          'month': _valuenew,
        if (_value == 'start')
          'year': currDt.year.toString()
        else
          'year': _value,
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var mydataatt = json.decode(responsenew.body);
      log(responsenew.body);
      setState(() {
        visible = true;
        userDatamy = mydataatt["data"];
        myattendata = userDatamy['attendance'];
        myattendata!.removeAt(0);
        visible = true;
      });
    } catch (error) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  Container taskList(String title, IconData iconImg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: <Widget>[
          Icon(
            iconImg,
            color: iconColor,
            size: 15,
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: (const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ))),
              ],
            ),
          )
        ],
      ),
    );
  }

  TextStyle dayStyle(FontWeight fontWeight) {
    return TextStyle(color: const Color(0xff30384c), fontWeight: fontWeight);
  }

  var internet = 'yes';

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
//  final String formatted = formatter.format(now);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Attendance History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: font1,
          ),
        ),
        actions: [IconButton(onPressed: show, icon: const Icon(Icons.info))],
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
      body: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade600,
                  Colors.indigo,
                ],
              ),
            ),
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.blue, Colors.indigo],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            child: DropdownButton(
                                icon: const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownColor: Colors.black,
                                value: _valuenew,
                                items: [
                                  DropdownMenuItem(
                                    child: Text(
                                      DateFormat("MMMM").format(DateTime.now()),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    value: 'start',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'January',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '1',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'February',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '2',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'March',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '3',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'April',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '4',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'May',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '5',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'June',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '6',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'July',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '7',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'August',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '8',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'September',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '9',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'October',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '10',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'November',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '11',
                                  ),
                                  const DropdownMenuItem(
                                    child: Text(
                                      'December',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                          color: Colors.white),
                                    ),
                                    value: '12',
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _valuenew = value;
                                    if (debug == 'yes') {
                                      //print(_valuenew);
                                    }
                                  });
                                }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue, Colors.indigo],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          child: DropdownButton(
                              icon: const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ),
                              dropdownColor: Colors.black,
                              value: _value,
                              items: [
                                const DropdownMenuItem(
                                  child: Text(
                                    'Select Year',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: font1,
                                        color: Colors.white),
                                  ),
                                  value: 'start',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    (currDt.year - 1).toString(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: font1,
                                        color: Colors.white),
                                  ),
                                  value: (currDt.year - 1).toString(),
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    currDt.year.toString(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: font1,
                                        color: Colors.white),
                                  ),
                                  value: currDt.year.toString(),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _value = value!;
                                  if (debug == 'yes') {
                                    //print(_value);
                                  }
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_value == 'start' || _valuenew == 'start') {
                        return;
                      }
                      fetchAtt();
                      mymonthint();
                      mymonth();
                      myyearint();
                      setState(() {
                        userData = null;
                      });
                    },
                    child: const Text("Change"),
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.blue,
                      ),
                      elevation: MaterialStateProperty.all(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          myattendata == null
              ? Expanded(
                  child: Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Colors.indigo,
                      rightDotColor: Colors.blue,
                      size: 60,
                    ),
                  ),
                )
              : Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(children: [
                        for (int index = 0;
                            index < myattendata!.length;
                            index = index + 4)
                          Expanded(
                            child: Row(children: [
                              Expanded(
                                child: !(index < myattendata!.length)
                                    ? const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            3, 3, 3, 3),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myattendata![index]
                                                    ['credit_id'] ==
                                                "10") {
                                            } else {
                                              showdet(
                                                '${myattendata![index]['date'][8] + myattendata![index]['date'][9]}',
                                                outputformat.format(
                                                    DateTime.parse(
                                                        myattendata![index]
                                                            ['date'])),
                                                myattendata![index]['in_time'] !=
                                                            null ||
                                                        myattendata![index]
                                                                ['in_time'] !=
                                                            ''
                                                    ? '${myattendata![index]['in_time']}'
                                                    : '',
                                                myattendata![index]
                                                                ['out_time'] !=
                                                            null ||
                                                        myattendata![index]
                                                                ['out_time'] !=
                                                            ''
                                                    ? '${myattendata![index]['out_time']}'
                                                    : '',
                                                myattendata![index]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? 'Absent'
                                                    : myattendata![index]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? 'Leave Full Day'
                                                        : myattendata![index][
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? 'Leave Half Day'
                                                            : myattendata![index]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? 'Attendance Full Day'
                                                                : myattendata![index]
                                                                            [
                                                                            'credit_id'] ==
                                                                        '4'
                                                                    ? 'Present Half Day'
                                                                    : myattendata![index]['credit_id'] ==
                                                                            '5'
                                                                        ? 'Work From Home'
                                                                        : myattendata![index]['credit_id'] ==
                                                                                '6'
                                                                            ? 'Short Leave'
                                                                            : myattendata![index]['credit_id'] == '7'
                                                                                ? 'Attendance Submitted'
                                                                                : myattendata![index]['credit_id'] == '9'
                                                                                    ? 'Official Holiday'
                                                                                    : "",
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(


                                                  color: myattendata![index]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Colors.red
                                                      : myattendata![index][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Colors.red.shade800
                                                          : myattendata![index][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Colors.red.shade100
                                                              : myattendata![index][
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Colors.blue
                                                                  : myattendata![index][
                                                                              'credit_id'] ==
                                                                          '4'
                                                                      ? Colors
                                                                          .orange
                                                                      : myattendata![index]['credit_id'] ==
                                                                              '5'
                                                                          ? Colors
                                                                              .blue.shade200
                                                                          : myattendata![index]['credit_id'] == '6'
                                                                              ? Colors.amber
                                                                              : myattendata![index]['credit_id'] == '7'
                                                                                  ? Colors.black
                                                                                  : myattendata![index]['credit_id'] == '8'
                                                                                      ? const Color.fromARGB(255, 43, 43, 42)
                                                                                      : myattendata![index]['credit_id'] == '9'
                                                                                          ? Colors.red
                                                                                          : myattendata![index]['credit_id'] == 10
                                                                                              ? Colors.blue
                                                                                              : Colors.blue,
                                                ),
                                                color: myattendata![index]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? Colors.red
                                                    : myattendata![index]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? Colors.red.shade800
                                                        : myattendata!
                                                        [index][
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? Colors.red.shade100
                                                            : myattendata![index]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? Colors.blue
                                                                : myattendata![index]
                                                                            [
                                                                            'credit_id'] ==
                                                                        '4'
                                                                    ? Colors
                                                                        .orange
                                                                    : myattendata![index]['credit_id'] ==
                                                                            '5'
                                                                        ? Colors
                                                                            .blue.shade200
                                                                        : myattendata![index]['credit_id'] == '6'
                                                                            ? Colors.amber
                                                                            : myattendata![index]['credit_id'] == '7'
                                                                                ? Colors.black
                                                                                : myattendata![index]['credit_id'] == '8'
                                                                                    ? Colors.red
                                                                                    : myattendata![index]['credit_id'] == '9'
                                                                                        ? Colors.red
                                                                                        : myattendata![index]['credit_id'] == '10'
                                                                                            ? Colors.white
                                                                                            : Colors.grey.shade300,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  myattendata![index]
                                                              ['credit_id'] ==
                                                          10
                                                      ? Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        )
                                                      : Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        ),
                                                  myattendata![index]
                                                              ['credit_id'] ==
                                                          10
                                                      ? Text(
                                                          myattendata![index]
                                                                  ['date'][8] +
                                                              myattendata![index]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17),
                                                        )
                                                      : Text(
                                                          myattendata![index]
                                                                  ['date'][8] +
                                                              myattendata![index]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                  myattendata![index]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Text(
                                                          "(A)",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  25),
                                                        )
                                                      : myattendata![index][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Text(
                                                              "(L)",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      25),
                                                            )
                                                          : myattendata![index][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Text(
                                                                  "(L.H.)",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              25),
                                                                )
                                                              : myattendata![index]
                                                                          [
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Text(
                                                                      "(P)",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 25),
                                                                    )
                                                                  : myattendata![index]
                                                                              [
                                                                              'credit_id'] ==
                                                                          '4'
                                                                      ? Text(
                                                                          "(P.H.)",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: MediaQuery.of(context).size.width / 25),
                                                                        )
                                                                      : myattendata![index]['credit_id'] ==
                                                                              '5'
                                                                          ? Text(
                                                                              "(W)",
                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                            )
                                                                          : myattendata![index]['credit_id'] == '6'
                                                                              ? Text(
                                                                                  "(S.L.)",
                                                                                  style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                )
                                                                              : myattendata![index]['credit_id'] == '7'
                                                                                  ? Text(
                                                                                      "(SUB)",
                                                                                      style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                    )
                                                                                  : myattendata![index]['credit_id'] == '8'
                                                                                      ? Text(
                                                                                          "",
                                                                                          style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                        )
                                                                                      : myattendata![index]['credit_id'] == '9'
                                                                                          ? Text(
                                                                                              "(H)",
                                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                            )
                                                                                          : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: !(index + 1 < myattendata!.length)
                                    ? const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            3, 3, 3, 3),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myattendata![index + 1]
                                                    ['credit_id'] ==
                                                "10") {
                                            } else {
                                              showdet(
                                                '${myattendata![index + 1]['date'][8] + myattendata![index + 1]['date'][9]}',
                                                outputformat.format(
                                                    DateTime.parse(
                                                        myattendata![index + 1]
                                                            ['date'])),
                                                myattendata![index + 1]
                                                                ['in_time'] !=
                                                            null ||
                                                        myattendata![index + 1]
                                                                ['in_time'] !=
                                                            ''
                                                    ? '${myattendata![index + 1]['in_time']}'
                                                    : '',
                                                myattendata![index + 1]
                                                                ['out_time'] !=
                                                            null ||
                                                        myattendata![index + 1]
                                                                ['out_time'] !=
                                                            ''
                                                    ? '${myattendata![index + 1]['out_time']}'
                                                    : '',
                                                myattendata![index + 1]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? 'Absent'
                                                    : myattendata![index + 1]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? 'Leave Full Day'
                                                        : myattendata![index + 1]
                                                                    [
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? 'Leave Half Day'
                                                            : myattendata![index + 1]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? 'Attendance Full Day'
                                                                : myattendata![index + 1]
                                                                            [
                                                                            'credit_id'] ==
                                                                        '4'
                                                                    ? 'Present Half Day'
                                                                    : myattendata![index + 1]['credit_id'] ==
                                                                            '5'
                                                                        ? 'Work From Home'
                                                                        : myattendata![index + 1]['credit_id'] == '6'
                                                                            ? 'Short Leave'
                                                                            : myattendata![index + 1]['credit_id'] == '7'
                                                                                ? 'Attendance Submitted'
                                                                                : myattendata![index + 1]['credit_id'] == '9'
                                                                                    ? 'Official Holiday'
                                                                                    :"",
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: myattendata![index + 1]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Colors.red
                                                      : myattendata![index + 1][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Colors.red.shade800
                                                          : myattendata![index + 1][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Colors.red.shade100
                                                              : myattendata![index + 1]
                                                                          [
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Colors.blue
                                                                  : myattendata![index + 1]['credit_id'] ==
                                                                          '4'
                                                                      ? Colors
                                                                          .orange
                                                                      : myattendata![index + 1]['credit_id'] ==
                                                                              '5'
                                                                          ? Colors.blue.shade200
                                                                          : myattendata![index + 1]['credit_id'] == '6'
                                                                              ? Colors.amber
                                                                              : myattendata![index + 1]['credit_id'] == '7'
                                                                                  ? Colors.black
                                                                                  : myattendata![index + 1]['credit_id'] == '8'
                                                                                      ? Colors.red
                                                                                      : myattendata![index + 1]['credit_id'] == '9'
                                                                                          ? Colors.red
                                                                                          : myattendata![index + 1]['credit_id'] == 10
                                                                                              ? Colors.blue
                                                                                              : Colors.blue,
                                                ),
                                                color: myattendata![index + 1]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? Colors.red
                                                    : myattendata![index + 1]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? Colors.red
                                                        : myattendata![index + 1][
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? Colors.red[100]
                                                            : myattendata![index + 1]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? Colors.blue
                                                                : myattendata![index + 1]['credit_id'] ==
                                                                        '4'
                                                                    ? Colors
                                                                        .orange
                                                                    : myattendata![index + 1]['credit_id'] ==
                                                                            '5'
                                                                        ? Colors
                                                                            .blue.shade200
                                                                        : myattendata![index + 1]['credit_id'] == '6'
                                                                            ? Colors.amber
                                                                            : myattendata![index + 1]['credit_id'] == '7'
                                                                                ? Colors.black
                                                                                : myattendata![index + 1]['credit_id'] == '8'
                                                                                    ? Colors.red
                                                                                    : myattendata![index + 1]['credit_id'] == '9'
                                                                                        ? Colors.red
                                                                                        : myattendata![index + 1]['credit_id'] == '10'
                                                                                            ? Colors.white
                                                                                            : Colors.grey.shade300
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  myattendata![index + 1]
                                                              ['credit_id'] ==
                                                          10
                                                      ? Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index +
                                                                              1]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        )
                                                      : Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index +
                                                                              1]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        ),
                                                  myattendata![index + 1]
                                                              ['credit_id'] ==
                                                          10
                                                      ? Text(
                                                          myattendata![index + 1]
                                                                  ['date'][8] +
                                                              myattendata![
                                                                      index + 1]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17),
                                                        )
                                                      : Text(
                                                          myattendata![index + 1]
                                                                  ['date'][8] +
                                                              myattendata![
                                                                      index + 1]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                  myattendata![index + 1]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Text(
                                                          "(A)",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  25),
                                                        )
                                                      : myattendata![index + 1][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Text(
                                                              "(L)",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      25),
                                                            )
                                                          : myattendata![index + 1][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Text(
                                                                  "(L.H.)",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              25),
                                                                )
                                                              : myattendata![index +
                                                                              1]
                                                                          [
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Text(
                                                                      "(P)",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 25),
                                                                    )
                                                                  : myattendata![index + 1]
                                                                              ['credit_id'] ==
                                                                          '4'
                                                                      ? Text(
                                                                          "(P.H.)",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: MediaQuery.of(context).size.width / 25),
                                                                        )
                                                                      : myattendata![index + 1]['credit_id'] == '5'
                                                                          ? Text(
                                                                              "(W)",
                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                            )
                                                                          : myattendata![index + 1]['credit_id'] == '6'
                                                                              ? Text(
                                                                                  "(S.L.)",
                                                                                  style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                )
                                                                              : myattendata![index + 1]['credit_id'] == '7'
                                                                                  ? Text(
                                                                                      "(SUB)",
                                                                                      style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                    )
                                                                                  : myattendata![index + 1]['credit_id'] == '8'
                                                                                      ? Text(
                                                                                          "",
                                                                                          style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                        )
                                                                                      : myattendata![index + 1]['credit_id'] == '9'
                                                                                          ? Text(
                                                                                              "(H)",
                                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                            )
                                                                                          : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: !(index + 2 < myattendata!.length)
                                    ? const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            3, 3, 3, 3),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myattendata![index + 2]
                                                    ['credit_id'] ==
                                                "10") {
                                            } else {
                                              showdet(
                                                '${myattendata![index + 2]['date'][8] + myattendata![index + 2]['date'][9]}',
                                                outputformat.format(
                                                    DateTime.parse(
                                                        myattendata![index + 2]
                                                            ['date'])),
                                                myattendata![index + 2]
                                                                ['in_time'] !=
                                                            null ||
                                                        myattendata![index + 2]
                                                                ['in_time'] !=
                                                            ''
                                                    ? '${myattendata![index + 2]['in_time']}'
                                                    : '',
                                                myattendata![index + 2]
                                                                ['out_time'] !=
                                                            null ||
                                                        myattendata![index + 2]
                                                                ['out_time'] !=
                                                            ''
                                                    ? '${myattendata![index + 2]['out_time']}'
                                                    : '',
                                                myattendata![index + 2]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? 'Absent'
                                                    : myattendata![index + 2]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? 'Leave Full Day'
                                                        : myattendata![index + 2]
                                                                    [
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? 'Leave Half Day'
                                                            : myattendata![index + 2]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? 'Attendance Full Day'
                                                                : myattendata![index + 2]
                                                                            [
                                                                            'credit_id'] ==
                                                                        '4'
                                                                    ? 'Present Half Day'
                                                                    : myattendata![index + 2]['credit_id'] ==
                                                                            '5'
                                                                        ? 'Work From Home'
                                                                        : myattendata![index + 2]['credit_id'] == '6'
                                                                            ? 'Short Leave'
                                                                            : myattendata![index + 2]['credit_id'] == '7'
                                                                                ? 'Attendance Submitted'
                                                                                : myattendata![index + 2]['credit_id'] == '9'
                                                                                    ? 'Official Holiday'
                                                                                    : "",
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            child: Container(
                                              padding:
                                                 EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: myattendata![index + 2]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Colors.red
                                                      : myattendata![index + 2][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Colors.red.shade800
                                                          : myattendata![index + 2][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Colors.red.shade100
                                                              : myattendata![index + 2]
                                                                          [
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Colors.blue
                                                                  : myattendata![index + 2]['credit_id'] ==
                                                                          '4'
                                                                      ? Colors
                                                                          .orange
                                                                      : myattendata![index + 2]['credit_id'] ==
                                                                              '5'
                                                                          ? Colors.blue.shade200
                                                                          : myattendata![index + 2]['credit_id'] == '6'
                                                                              ? Colors.amber
                                                                              : myattendata![index + 2]['credit_id'] == '7'
                                                                                  ? Colors.black
                                                                                  : myattendata![index + 2]['credit_id'] == '8'
                                                                                      ? Colors.red
                                                                                      : myattendata![index + 2]['credit_id'] == '9'
                                                                                          ? Colors.red
                                                                                          : myattendata![index + 2]['credit_id'] == 10
                                                                                              ? Colors.blue
                                                                                              : Colors.blue,
                                                ),
                                                color: myattendata![index + 2]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? Colors.red
                                                    : myattendata![index + 2]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? Colors.red[800]
                                                        : myattendata![index + 2][
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? Colors.red[100]
                                                            : myattendata![index + 2]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? Colors.blue
                                                                : myattendata![index + 2]['credit_id'] ==
                                                                        '4'
                                                                    ? Colors
                                                                        .orange
                                                                    : myattendata![index + 2]['credit_id'] ==
                                                                            '5'
                                                                        ? Colors
                                                                            .blue[200]
                                                                        : myattendata![index + 2]['credit_id'] == '6'
                                                                            ? Colors.amber
                                                                            : myattendata![index + 2]['credit_id'] == '7'
                                                                                ? Colors.black
                                                                                : myattendata![index + 2]['credit_id'] == '8'
                                                                                    ? Colors.red
                                                                                    : myattendata![index + 2]['credit_id'] == '9'
                                                                                        ? Colors.red
                                                                                        : myattendata![index + 2]['credit_id'] == '10'
                                                                                            ? Colors.white
                                                                                            : Colors.grey[300],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  myattendata![index + 2]
                                                              ['credit_id'] ==
                                                          10
                                                      ? Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index +
                                                                              2]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        )
                                                      : Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index +
                                                                              2]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        ),
                                                  myattendata![index + 2]
                                                              ['credit_id'] ==
                                                          10
                                                      ? Text(
                                                          myattendata![index + 2]
                                                                  ['date'][8] +
                                                              myattendata![
                                                                      index + 2]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17),
                                                        )
                                                      : Text(
                                                          myattendata![index + 2]
                                                                  ['date'][8] +
                                                              myattendata![
                                                                      index + 2]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                  myattendata![index + 2]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Text(
                                                          "(A)",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  25),
                                                        )
                                                      : myattendata![index + 2][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Text(
                                                              "(L)",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      25),
                                                            )
                                                          : myattendata![index + 2][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Text(
                                                                  "(L.H.)",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              25),
                                                                )
                                                              : myattendata![index +
                                                                              2]
                                                                          [
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Text(
                                                                      "(P)",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 25),
                                                                    )
                                                                  : myattendata![index + 2]
                                                                              ['credit_id'] ==
                                                                          '4'
                                                                      ? Text(
                                                                          "(P.H.)",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: MediaQuery.of(context).size.width / 25),
                                                                        )
                                                                      : myattendata![index + 2]['credit_id'] == '5'
                                                                          ? Text(
                                                                              "(W)",
                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                            )
                                                                          : myattendata![index + 2]['credit_id'] == '6'
                                                                              ? Text(
                                                                                  "(S.L.)",
                                                                                  style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                )
                                                                              : myattendata![index + 2]['credit_id'] == '7'
                                                                                  ? Text(
                                                                                      "(SUB)",
                                                                                      style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                    )
                                                                                  : myattendata![index + 2]['credit_id'] == '8'
                                                                                      ? Text(
                                                                                          "",
                                                                                          style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                        )
                                                                                      : myattendata![index + 2]['credit_id'] == '9'
                                                                                          ? Text(
                                                                                              "(H)",
                                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                            )
                                                                                          : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: !(index + 3 < myattendata!.length)
                                    ? const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            3, 3, 3, 3),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myattendata![index + 3]
                                                    ['credit_id'] ==
                                                "10") {
                                            } else {
                                              showdet(
                                                '${myattendata![index + 3]['date'][8] + myattendata![index + 3]['date'][9]}',
                                                outputformat.format(
                                                    DateTime.parse(
                                                        myattendata![index + 3]
                                                            ['date'])),
                                                myattendata![index + 3]
                                                                ['in_time'] !=
                                                            null ||
                                                        myattendata![index + 3]
                                                                ['in_time'] !=
                                                            ''
                                                    ? '${myattendata![index + 3]['in_time']}'
                                                    : '',
                                                myattendata![index + 3]
                                                                ['out_time'] !=
                                                            null ||
                                                        myattendata![index + 3]
                                                                ['out_time'] !=
                                                            ''
                                                    ? '${myattendata![index + 3]['out_time']}'
                                                    : '',
                                                myattendata![index + 3]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? 'Absent'
                                                    : myattendata![index + 3]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? 'Leave Full Day'
                                                        : myattendata![index + 3]
                                                                    [
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? 'Leave Half Day'
                                                            : myattendata![index + 3]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? 'Attendance Full Day'
                                                                : myattendata![index + 3]
                                                                            [
                                                                            'credit_id'] ==
                                                                        '4'
                                                                    ? 'Present Half Day'
                                                                    : myattendata![index + 3]['credit_id'] ==
                                                                            '5'
                                                                        ? 'Work From Home'
                                                                        : myattendata![index + 3]['credit_id'] == '6'
                                                                            ? 'Short Leave'
                                                                            : myattendata![index + 3]['credit_id'] == '7'
                                                                                ? 'Attendance Submitted'
                                                                                : myattendata![index + 3]['credit_id'] == '9'
                                                                                    ? 'Official Holiday'
                                                                                    : "",
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: myattendata![index + 3]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Colors.red
                                                      : myattendata![index + 3][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Colors.red.shade800
                                                          : myattendata![index + 3][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Colors.red.shade100
                                                              : myattendata![index + 3]
                                                                          [
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Colors.blue
                                                                  : myattendata![index + 3]['credit_id'] ==
                                                                          '4'
                                                                      ? Colors
                                                                          .orange
                                                                      : myattendata![index + 3]['credit_id'] ==
                                                                              '5'
                                                                          ? Colors.blue.shade200
                                                                          : myattendata![index + 3]['credit_id'] == '6'
                                                                              ? Colors.amber
                                                                              : myattendata![index + 3]['credit_id'] == '7'
                                                                                  ? Colors.black
                                                                                  : myattendata![index + 3]['credit_id'] == '8'
                                                                                      ? Colors.red
                                                                                      : myattendata![index + 3]['credit_id'] == '9'
                                                                                          ? Colors.red
                                                                                          : myattendata![index + 3]['credit_id'] == 10
                                                                                              ? Colors.blue
                                                                                              : Colors.blue,
                                                ),
                                                color: myattendata![index + 3]
                                                            ['credit_id'] ==
                                                        '0'
                                                    ? Colors.red
                                                    : myattendata![index + 3]
                                                                ['credit_id'] ==
                                                            '1'
                                                        ? Colors.red[800]
                                                        : myattendata![index + 3][
                                                                    'credit_id'] ==
                                                                '2'
                                                            ? Colors.red[100]
                                                            : myattendata![index + 3]
                                                                        [
                                                                        'credit_id'] ==
                                                                    '3'
                                                                ? Colors.blue
                                                                : myattendata![index + 3]['credit_id'] ==
                                                                        '4'
                                                                    ? Colors
                                                                        .orange
                                                                    : myattendata![index + 3]['credit_id'] ==
                                                                            '5'
                                                                        ? Colors
                                                                            .blue[200]
                                                                        : myattendata![index + 3]['credit_id'] == '6'
                                                                            ? Colors.amber
                                                                            : myattendata![index + 3]['credit_id'] == '7'
                                                                                ? Colors.black
                                                                                : myattendata![index + 3]['credit_id'] == '8'
                                                                                    ? Colors.red
                                                                                    : myattendata![index + 3]['credit_id'] == '9'
                                                                                        ? Colors.red
                                                                                        : myattendata![index + 3]['credit_id'] == '10'
                                                                                            ? Colors.white
                                                                                            : Colors.grey[300],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  myattendata![index + 3]
                                                              ['credit_id'] ==
                                                          "10"
                                                      ? Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index +
                                                                              3]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        )
                                                      : Text(
                                                          DateFormat('EE').format(
                                                              DateTime.parse(
                                                                  myattendata![
                                                                          index +
                                                                              3]
                                                                      [
                                                                      'date'])),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  28),
                                                        ),
                                                  myattendata![index + 3]
                                                              ['credit_id'] ==
                                                          10
                                                      ? Text(
                                                          myattendata![index + 3]
                                                                  ['date'][8] +
                                                              myattendata![
                                                                      index + 3]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17),
                                                        )
                                                      : Text(
                                                          myattendata![index + 3]
                                                                  ['date'][8] +
                                                              myattendata![
                                                                      index + 3]
                                                                  ['date'][9],
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  17,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                  myattendata![index + 3]
                                                              ['credit_id'] ==
                                                          '0'
                                                      ? Text(
                                                          "(A)",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  25),
                                                        )
                                                      : myattendata![index + 3][
                                                                  'credit_id'] ==
                                                              '1'
                                                          ? Text(
                                                              "(L)",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      25),
                                                            )
                                                          : myattendata![index + 3][
                                                                      'credit_id'] ==
                                                                  '2'
                                                              ? Text(
                                                                  "(L.H.)",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              25),
                                                                )
                                                              : myattendata![index +
                                                                              3]
                                                                          [
                                                                          'credit_id'] ==
                                                                      '3'
                                                                  ? Text(
                                                                      "(P)",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 25),
                                                                    )
                                                                  : myattendata![index + 3]
                                                                              ['credit_id'] ==
                                                                          '4'
                                                                      ? Text(
                                                                          "(P.H.)",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: MediaQuery.of(context).size.width / 25),
                                                                        )
                                                                      : myattendata![index + 3]['credit_id'] == '5'
                                                                          ? Text(
                                                                              "(W)",
                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                            )
                                                                          : myattendata![index + 3]['credit_id'] == '6'
                                                                              ? Text(
                                                                                  "(S.L.)",
                                                                                  style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                )
                                                                              : myattendata![index + 3]['credit_id'] == '7'
                                                                                  ? Text(
                                                                                      "(SUB)",
                                                                                      style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                    )
                                                                                  : myattendata![index + 3]['credit_id'] == '8'
                                                                                      ? Text(
                                                                                          "",
                                                                                          style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                        )
                                                                                      : myattendata![index + 3]['credit_id'] == '9'
                                                                                          ? Text(
                                                                                              "(H)",
                                                                                              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 25),
                                                                                            )
                                                                                          : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              )
                            ]),
                          )
                      ]),
                    ),
                  ),
                ),
        ],
      ),

      // //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
