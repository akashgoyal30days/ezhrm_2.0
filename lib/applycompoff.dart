import 'package:ezhrm/Compoff.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'constants.dart';
import 'drawer.dart';

class ApplyCompOff extends StatefulWidget {
  const ApplyCompOff({Key? key}) : super(key: key);

  @override
  _ApplyCompOffState createState() => _ApplyCompOffState();
}

class _ApplyCompOffState extends State<ApplyCompOff>
    with SingleTickerProviderStateMixin<ApplyCompOff> {
  bool visible = true;
  Map? data;
  Map? datanew;
  List? userData;
  List? userDatanew;
  String? _mylist;
  String? _mycredit;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  dynamic reasonController = TextEditingController();
  var difference = "";
  var newdata;
  int _value = 1;

  loadProgress() {
    if (visible == true) {
      setState(() {
        visible = false;
      });
    } else {
      setState(() {
        visible = true;
      });
    }
  }

  @override
  void initState() {
    getEmail();
    fetchList();
    fetchCredit();
    super.initState();
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

  Future fetchList() async {
    var uri = "$customurl/controller/process/app/leave.php";
    final response = await http.post(Uri.parse(uri), body: {
      'uid': SharedPreferencesInstance.getString('uid'),
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'fetch_quota'
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    data = json.decode(response.body);
    setState(() {
      visible = true;
      userData = data!["data"];
      visible = true;
    });
    if (debug == 'yes') {
      //debugPrint(userData.toString());
    }
  }

  Future fetchCredit() async {
    var urii = "$customurl/controller/process/app/leave.php";
    final responsenew = await http.post(Uri.parse(urii), body: {
      'uid': SharedPreferencesInstance.getString('uid'),
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'fetch_credit'
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    datanew = json.decode(responsenew.body);
    setState(() {
      visible = true;
      userDatanew = datanew!["data"];
      if (userDatanew == '') {
        setState(() {
          userDatanew = [];
        });
      }
      visible = true;
    });
    if (debug == 'yes') {
      //debugPrint(userDatanew.toString());
      //debugPrint(datanew.toString());
    }
  }

  String? resulted;
  DateTime selectedDate = DateTime.now();
  DateTime selectedDatenew = DateTime.now();
  var customFormat = DateFormat('yyyy-MM-dd');
  var customFormatnew = DateFormat('yyyy-MM-dd');
  Future<void> showPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0XFF072A99), // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Color(0XFF072A99),

                /// body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0XFF072A99), //text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (picked != selectedDate && picked != selectedDatenew) {
      setState(() {
        selectedDate = picked!;
        selectedDatenew = picked;
      });
    }
  }

  // String username = "";

  Future Leave() async {
    var urii = "$customurl/controller/process/app/leave.php";
    final responseneww = await http.post(Uri.parse(urii), body: {
      'uid': SharedPreferencesInstance.getString('uid'),
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'apply_leave',
      'date_from': customFormat.format(selectedDate),
      if (_mycredit == '2' || _mycredit == '6')
        'date_to': customFormat.format(selectedDate)
      else if (_mycredit == '1')
        'date_to': customFormatnew.format(selectedDatenew)
      else if (_mycredit == '5')
        'date_to': customFormatnew.format(selectedDatenew),
      'credit': _mycredit,
      'avail_leave': _mylist,
      'reason': reasonController.text
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    newdata = json.decode(responseneww.body);
    if (newdata.containsKey('status')) {
      setState(() {
        // message =  mydataatt['msg'];
        visible = false;
      });
      if (newdata['status'] == true) {
        setState(() {
          Fluttertoast.showToast(
              msg: "Successfully Applied",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          _mycredit = null;
          _mylist = null;
          reasonController.clear();
        });
      } else if (newdata['status'] == false) {
        setState(() {
          Fluttertoast.showToast(
              msg: "${newdata['error']}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          _mycredit = null;
          _mylist = null;
          reasonController.clear();
        });
      }
    }
    if (debug == 'yes') {
      //debugPrint(newdata.toString());
      //print('from- ${customFormat.format(selectedDate)}');
      //print('To- ${customFormatnew.format(selectedDatenew)}');
    }
  }

  Future Cmp() async {
    try {
      var urii = "$customurl/controller/process/app/comp_off.php";
      final responseneww = await http.post(Uri.parse(urii), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'apply_compoff',
        'date': customFormat.format(selectedDate),
        'compoff_type': '$_value',
        'reason': reasonController.text
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      newdata = json.decode(responseneww.body);
      if (newdata.containsKey('status')) {
        setState(() {
          visible = false;
        });
        if (newdata['status'] == true) {
          setState(() {
            Fluttertoast.showToast(
                msg: "Your Comp Off  Is Successfully Applied",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Compoff()));
            _mycredit = null;
            _mylist = null;
            reasonController.clear();
          });
        } else if (newdata['status'] == false) {
          setState(() {
            Fluttertoast.showToast(
                msg:
                    "Already Applied For This Date, Please Check And Try Again",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            _mycredit = null;
            _mylist = null;
            reasonController.clear();
          });
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Unable to complete your request, please retry after sometime",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(currentScreen: AvailableDrawerScreens.CompOff),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        bottomOpacity: 0,
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
        elevation: 0,
        title: const Text(
          "Apply Comp Off",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: userDatanew == null
          ? const Center(
              child: GFLoader(
              type: GFLoaderType.custom,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image(
                  image: AssetImage('assets/newlod.gif'),
                  height: 100,
                  width: 100,
                ),
              ),
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            margin: const EdgeInsets.all(8),
                            child: InkWell(
                              onTap: () => showPicker(context),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Select Date",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff072a99),
                                        )),
                                    TextButton(
                                        onPressed: () => showPicker(context),
                                        child: Text(DateFormat('dd MMM y')
                                            .format(selectedDate)),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.zero),
                                            textStyle:
                                                MaterialStateProperty.all(
                                                    const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                              const Color(0xff072a99),
                                            ))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 8),
                              child: Text("Select Type",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff072a99),
                                  ))),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Card(
                              child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none),
                                  ),
                                  value: _value,
                                  hint: const Text("Credit Type"),
                                  items: const [
                                    DropdownMenuItem(
                                      child: Text("Full Day"),
                                      value: 1,
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Half Day"),
                                      value: 2,
                                    )
                                  ],
                                  onChanged: (int? value) {
                                    setState(() {
                                      _value = value!;
                                      if (debug == 'yes') {
                                        //print(_value);
                                      }
                                    });
                                  }),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 8),
                              child: Text("Reason Here",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff072a99),
                                  ))),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: reasonController,
                              cursorColor: const Color(0x33072a99),
                              keyboardType: TextInputType.name,
                              onSubmitted: (_) {},
                              minLines: 10,
                              maxLines: 15,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(color: Color(0xff072a99)),
                              decoration: InputDecoration(
                                fillColor: const Color(0x33072a99),
                                filled: true,
                                hintText: "State your reason here",
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (reasonController.text != '') {
                                        Cmp();
                                      } else if (reasonController.text == '') {
                                        Fluttertoast.showToast(
                                            msg: "Please Fill All Fields",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 16.0);
                                      }
                                    },
                                    child: const Text("Apply Comp Off"),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(15)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        const Color(0xff072a99),
                                      ),
                                      elevation: MaterialStateProperty.all(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Compoff()));
                        },
                        child: const Text("Cancel"),
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            foregroundColor: MaterialStateProperty.all(
                              const Color(0xff072a99),
                            ))),
                  ],
                ),
              ),
            ),
    );
  }
}
