import 'dart:io';
import 'package:ezhrm/applyreimb.dart';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'constants.dart';
import 'drawer.dart';

class ApplyReim extends StatefulWidget {
  const ApplyReim({Key? key}) : super(key: key);

  @override
  _ApplyReimState createState() => _ApplyReimState();
}

class _ApplyReimState extends State<ApplyReim>
    with SingleTickerProviderStateMixin<ApplyReim> {
  bool visible = false;
  String? _value1;
  String? _value2;
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
  final int _value = 1;
  dynamic reasonController = TextEditingController();
  var newdata;
  String? img64;
  File? _image;
  File? imageResized;
  final picker = ImagePicker();
  dynamic amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    final bytes = File(pickedFile!.path).readAsBytesSync();
    img64 = base64Encode(bytes);
    if (debug == 'yes') {
      //print(img64.substring(0, img64.length));
    }
    setState(() {
      _image = File(pickedFile.path);
    });
    if (_image != null) {
      Fluttertoast.showToast(
          msg: "Image Selected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  Future getImagegallery() async {
    final pickedFilenew =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 30);
    final bytesnew = File(pickedFilenew!.path).readAsBytesSync();
    img64 = base64Encode(bytesnew);
    if (debug == 'yes') {
      //print(img64.substring(0, img64.length));
    }
    setState(() {
      _image = File(
        pickedFilenew.path,
      );
    });
  }

  final List<String> leaveList = <String>[
    "Company",
    "Client",
  ];
  final List<String> leaveListval = <String>[
    "1",
    "2",
  ];
  var internet = 'yes';

  @override
  void initState() {
    super.initState();
    // checkinternetconnection();
    _value1 = leaveListval[0];
    _value2 = leaveListval[1];
    getEmail();
    fetchList();
    // fetchCredit();
  }

   getEmail() {
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
    try {
      var uri = "$customurl/controller/process/app/extras.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_reimbursement'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data!["data"];
        visible = true;
        if (userData == null) {
          setState(() {
            userData = [];
          });
        }
      });
      if (debug == 'yes') {
        //debugPrint(userData.toString());
      }
    } catch (error) {
      //  userData = [];
      //print('i am here');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.reimbursment),
      appBar: AppBar(
        elevation: 0,
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
        title: const Text(
          "Reimbursement",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: userData == null
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
          : userData!.isEmpty
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'No Data found',
                      style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 16),
                    ),
                  ))
              : Container(
                  color: Colors.white,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white],
                      ),
                    ),
                    child: ListView.builder(
                        itemCount: userData == null ? 0 : userData!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.blue, Colors.indigo],
                                ),
                              ),
                              child: GestureDetector(
                                child: Row(
                                  children: [
                                    if (userData![index]["img_bill"] == '')
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.23,
                                        child: Image.asset(
                                          'assets/img.png',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                    else if (userData![index]["img_bill"] != '')
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.23,
                                        child: Image.network(
                                          '${userData![index]["img_bill"]}',
                                          width: 200,
                                          height: 100,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                " ₹ ${userData![index]["reimburse_amount"]}",
                                                style: const TextStyle(
                                                    fontSize: 25.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily: font1),
                                              ),
                                              const Spacer(),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  " ${userData![index]["apply_date"]}",
                                                  style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontFamily: font1),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          Text(
                                            '  Against - ${userData![index]['expense_against']}',
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: font1,
                                                letterSpacing: 1),
                                          ),
                                          const Divider(),
                                          if (userData![index]["status"] == '0')
                                            const Text(
                                              "  Pending",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: font1,
                                                  letterSpacing: 1),
                                            )
                                          else if (userData![index]["status"] ==
                                              '1')
                                            const Text(
                                              "  Approved",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: font1,
                                                  letterSpacing: 1),
                                            )
                                          else if (userData![index]["status"] ==
                                              '2')
                                            const Text(
                                              "  Rejected",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: font1,
                                                  letterSpacing: 1),
                                            )
                                          else if (userData![index]["status"] ==
                                              '3')
                                            const Text(
                                              "  Cancelled",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  letterSpacing: 1),
                                            ),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'Description- ${userData![index]['description']} ',
                                                      style: const TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.white,
                                                          fontFamily: font1),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {},
                              ),

                              /*FlipCard(
                      direction: FlipDirection.VERTICAL, // default
                      front: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.centerLeft,
                            colors: [Colors.blue, Colors.blue[900],],
                          ),
                        ),
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                              child: Text(
                                "${userData[index]["date"]}",style: TextStyle(fontSize: 15, color: Colors.white,fontWeight: FontWeight.w900),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                              child: SizedBox(width: 50,),
                            ),
                            if(userData[index]["status"]== '0')Text(
                              "Pending  ",style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.w900),
                            )
                            else if(userData[index]["status"]== '1')Text(
                              "Approved",style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.w900),
                            ) else if(userData[index]["status"]== '2')Text(
                              "Rejected ",style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.w900),
                            )
                            else if(userData[index]["status"]== '3')Text(
                                "Cancelled",style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.w900),
                              ),
                            //Spacer(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(55, 0, 5, 0),
                              child: Row(
                                children: [
                                  if(userData[index]['credit_id'] == '1')Text('Full Day',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),)
                                  else if(userData[index]['credit_id'] == '2')Text('Half Day',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      back: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.blue[600],],
                          ),
                        ),
                        height: 60,
                        child: Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(21.0),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(' Reason - ${userData[index]["reason"]}', style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w600),),
                                      Spacer(),

                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),*/
                            ),
                          );
                        }),
                  ),
                ),
      floatingActionButton: userData == null
          ? const SizedBox()
          : Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.indigo],
                ),
              ),
              width: 120,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReimBursement()));
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Apply New',
                      style: TextStyle(color: Colors.white, fontFamily: font1),
                    ),
                  ],
                ),
              ),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
