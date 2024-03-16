import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'services/shared_preferences_singleton.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class LeaveList extends StatefulWidget {
  const LeaveList({Key? key}) : super(key: key);

  @override
  _LeaveListState createState() => _LeaveListState();
}

class _LeaveListState extends State<LeaveList>
    with SingleTickerProviderStateMixin<LeaveList> {
  bool visible = false;
  Map? data;
  Map? updata;
  List? userData;
  List? userDatanew;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;

  @override
  void initState() {
    super.initState();
    getEmail();
    fetchList();
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

  Future Updt(String status, String rid, String type) async {
    if (debug == 'yes') {
      //print('$rid');
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.fixed,
      elevation: 0,
      duration: const Duration(hours: 1),
      backgroundColor: Colors.black.withOpacity(0.5),
      content: Center(
          child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.5,
          ),
          const Text(
            'Please Wait!! Processing',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(120, 10, 120, 0),
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        ],
      )),
    ));
    try {
      var uri = "$customurl/controller/process/app/leave.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': type,
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid'),
        'status': status,
        'req_id': rid
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      updata = json.decode(response.body);
      setState(() {
        visible = true;
        userDatanew = updata!["data"];
        //da = data["data"]["status"];
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(updata.toString());
      }
      if (data!['status'] == true && type == 'ignore_req') {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            userData = null;
            fetchList();
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.fixed,
          elevation: 0,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blue.shade50.withOpacity(0.5),
          content: Center(
              child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
              ),
              const Icon(
                Icons.upload_outlined,
                size: 60,
                color: Colors.blue,
              ),
              const Text(
                'Successfully Forwarded',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3),
              ),
            ],
          )),
        ));
      } else if (data!['status'] == true &&
          type == 'req_update' &&
          status == '2') {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            userData = null;
            fetchList();
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.fixed,
          elevation: 0,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.withOpacity(0.5),
          content: Center(
              child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
              ),
              const Icon(
                Icons.close,
                size: 60,
                color: Colors.red,
              ),
              const Text(
                'Successfully Rejected',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3),
              ),
            ],
          )),
        ));
      } else if (data!['status'] == true &&
          type == 'req_update' &&
          status == '1') {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            userData = null;
            fetchList();
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.fixed,
          elevation: 0,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.withOpacity(0.5),
          content: Center(
              child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
              ),
              const Icon(
                Icons.check,
                size: 60,
                color: Colors.blue,
              ),
              const Text(
                'Successfully Approved',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3),
              ),
            ],
          )),
        ));
      }
    } catch (error) {}
  }

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/leave.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'pend_request_my',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid')
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data!["data"];
        //da = data["data"]["status"];
        visible = true;

        if (userData!.isEmpty) {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return Theme(
                data: ThemeData.dark(),
                child: CupertinoAlertDialog(
                  title: Column(
                    children: const [
                      Icon(
                        Icons.warning,
                        color: Colors.yellow,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'No leaves to review',
                        style: TextStyle(),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      });
      if (debug == 'yes') {
        //debugPrint(data.toString());
      }
    } catch (error) {}
  }

  void showimg(String urlimgg) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.light(),
          child: CupertinoAlertDialog(
            title: CachedNetworkImage(
                // radius: 28.35,
                height: 450,
                width: MediaQuery.of(context).size.width / 3,
                imageUrl: urlimgg,
                fit: BoxFit.fill,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/img.png')),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  DateTime? _lastPressedAt;
  show(String totaldays, String from, String to, String reason, String credit,
      String tquota, String avquota) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            color: Colors.white,
            height: MediaQuery.of(context).copyWith().size.height / 2.5,
            child: ListView(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Divider(),
                    Container(
                        child: Text(
                      'Total Days Leave - $totaldays',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                    const Divider(),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width / 2.5,
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Spacer(),
                              Center(
                                  child: Text(
                                'From',
                                style: TextStyle(color: Colors.white),
                              )),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width / 2.5,
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Spacer(),
                              Center(
                                  child: Text(
                                'To',
                                style: TextStyle(color: Colors.white),
                              )),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 2.5,
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                          child: Row(
                            children: [
                              const Spacer(),
                              Center(
                                  child: Text(
                                from,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 2.5,
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Spacer(),
                              Center(
                                  child: Text(
                                to,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Credit - $credit',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Description - $reason',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(18, 8, 18, 8),
                                  child: Text(
                                    'Total Quota',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    tquota,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: Text(
                                    'Available Quota',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    avquota,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bottomNavigationBar: const CustomBottomNavigationBar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
        title: const Text(
          "Team's Leave List",
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
          : Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      SizedBox(
                        width: 70,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                          child: Text(
                            'Name',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Emp Id',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Leave Type',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Action',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Details',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: ListView.builder(
                      itemCount: userData == null ? 0 : userData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          color: Colors.transparent,
                          child: Card(
                            elevation: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(7, 0, 0, 0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 8, 8, 8),
                                      child: Text(
                                        '${userData![index]['u_full_name']}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(7, 0, 0, 0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 8, 8, 8),
                                      child: Text(
                                        '${userData![index]['u_employee_id']}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                      child: Text(
                                        '${userData![index]['type']}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              showCupertinoDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Theme(
                                                    data: ThemeData.dark(),
                                                    child: CupertinoAlertDialog(
                                                      title: Column(
                                                        children: const [
                                                          Text('Approve?'),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                      content: const Text(
                                                          'Are You Sure You Want To Approve This Leave?'),
                                                      actions: <Widget>[
                                                        CupertinoDialogAction(
                                                          isDefaultAction: true,
                                                          child:
                                                              const Text('Yes'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Updt(
                                                                '1',
                                                                userData![index]
                                                                    ['id'],
                                                                'req_update');
                                                          },
                                                        ),
                                                        CupertinoDialogAction(
                                                          isDefaultAction:
                                                              false,
                                                          child:
                                                              const Text('No'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: const Icon(
                                              Icons.check,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                            width: 18,
                                            child: FloatingActionButton(
                                              onPressed: () {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Theme(
                                                      data: ThemeData.dark(),
                                                      child:
                                                          CupertinoAlertDialog(
                                                        title: Column(
                                                          children: const [
                                                            Text('Reject?'),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                        content: const Text(
                                                            'Are You Sure You Want To Reject This Leave?'),
                                                        actions: <Widget>[
                                                          CupertinoDialogAction(
                                                            isDefaultAction:
                                                                true,
                                                            child: const Text(
                                                                'Yes'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Updt(
                                                                  '2',
                                                                  userData![
                                                                          index]
                                                                      ['id'],
                                                                  'req_update');
                                                            },
                                                          ),
                                                          CupertinoDialogAction(
                                                            isDefaultAction:
                                                                false,
                                                            child: const Text(
                                                                'No'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              backgroundColor: Colors.red,
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                              ),
                                            )),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                            width: 18,
                                            child: FloatingActionButton(
                                              onPressed: () {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Theme(
                                                      data: ThemeData.dark(),
                                                      child:
                                                          CupertinoAlertDialog(
                                                        title: Column(
                                                          children: const [
                                                            Text(
                                                                'Carry Forward?'),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                        content: const Text(
                                                            'Are You Sure You Want To Forward This Leave To Higher Authority?'),
                                                        actions: <Widget>[
                                                          CupertinoDialogAction(
                                                            isDefaultAction:
                                                                true,
                                                            child: const Text(
                                                                'Yes'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Updt(
                                                                  '3',
                                                                  userData![
                                                                          index]
                                                                      ['id'],
                                                                  'ignore_req');
                                                            },
                                                          ),
                                                          CupertinoDialogAction(
                                                            isDefaultAction:
                                                                false,
                                                            child: const Text(
                                                                'No'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              backgroundColor: Colors.black,
                                              child: const Icon(
                                                Icons.upload_outlined,
                                                size: 18,
                                              ),
                                            )),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 2, 10),
                                    child: IconButton(
                                      icon: const Icon(CupertinoIcons.eye),
                                      onPressed: () {
                                        show(
                                            '${userData![index]['days']}',
                                            '${userData![index]['date_from']}',
                                            '${userData![index]['date_to']}',
                                            '${userData![index]['reason']}',
                                            '${userData![index]['credit']}',
                                            '${userData![index]['total_quota']}',
                                            '${userData![index]['avail_quota']}');
                                      },
                                    )),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
    );
  }
}
