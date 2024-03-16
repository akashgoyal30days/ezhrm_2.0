import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';

import 'drawer.dart';

const kHtml = """
<h1>Heading</h1>
<p>A paragraph with <strong>strong</strong> <em>emphasized</em> text.</p>
<ol>
  <li>List item number one</li>
  <li>
    Two
    <ul>
      <li>2.1 (nested)</li>
      <li>2.2</li>
    </ul>
  </li>
  <li>Three</li>
</ol>
<p>And YouTube video!</p>
<iframe src="https://www.youtube.com/embed/jNQXAC9IVRw" width="560" height="315"></iframe>
""";

class SalarySlip extends StatefulWidget {
  const SalarySlip({Key? key}) : super(key: key);

  @override
  _SalarySlipState createState() => _SalarySlipState();
}

class _SalarySlipState extends State<SalarySlip>
    with SingleTickerProviderStateMixin<SalarySlip> {
  bool visible = false;
  String? generatedPdfFilePath;
  //final pdf = Document();
  var currDt = DateTime.now();
  Map? data;
  Map? datanew;
  var userData;
  var userDatanew;
  var cdetails;
  var accdetails;
  List? earnings;
  var concatenate;
  List<dynamic>? newListlabel;
  List<dynamic>? newListamount;
  List<dynamic>? deductionlabel;
  List<dynamic>? deductionamount;
  List? deductions;
  var workeddays;
  var leave;
  var paiddays;
  var notpayable;
  var tovrt;
  String? _mylist;
  String? _mycredit;
  String? username;
  String? htmldata;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  var Name;
  var fathername;
  var sundayandholiday;
  var aadhar;
  var desig;
  var eid;
  List<dynamic>? list;
  var compname;
  String? compadd;
  var compdist;
  var compstate;
  var comppincode;
  var complogo;
  var tearnings;
  var tdeduct;
  var elist;
  String? val;
  var listlabel;
  var listamount = [];
  var netsalary;
  var reimbursement;
  var loanadj;
  var salaryadv;
  var adjustment;
  var advancesalary;
  var loandeducted;
  var loantaken;
  var loanoutstanding;
  var loanpaid;
  var bname;
  var accno;
  var panno;
  var esino;
  var pfno;
  var year;
  var month;
  String? screen;
  var newdata;
  var i;
  var y;
  var myearninglist;
  var myearningamount;
  var htmlContent;
  Future<Directory?> downloadsDirectory =
      DownloadsPathProvider.downloadsDirectory;

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }

  _requestPermissions() async {
    Map<Permission, PermissionStatus> permission = await [
      Permission.storage,
    ].request();

    if (permission[Permission.storage] != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  Future<void> generateDocument() async {
    htmlContent = """ $htmldata """;
//     htmlContent = """
//     <html>
//  <head>
//   <title> Slip-$Name</title>
//   <style>
//      *{ font-family:"serif"; }
//   body { padding:0px; margin:0px; font-family:serif; }
//   td, { padding:0px;  }
//   td { text-align:left;}
//     @media print {
//            #hide {
//         display: none;
//       }
//      }
//      .bdr{
//   border-bottom: 1px dashed #000;
//   }
//     </style>
//   </head>
//     <body>
//     <p style="text-align:center; font-size:larger; color:blue;">This is a system generated statement and requires no signature.</p>
//     <table style=" width:90%; outline-style:outset;  margin:20px auto; ">
//     <tr><td>
//    <table style="width:100%;   font-size: 15px; ">
//    <tr>
//        <td colspan="6" style="text-align: center; "><img style="max-height:100px;" src="$complogo" /></td>
//    </tr>
//    <tr height="8"></tr>
//         <tr>
//     <td colspan="6" class="bdr"  style="text-align:center;" >
//   $compname<br />$compadd,$compstate-$comppincode,<br />$compstate</td>

//     </tr>

//          <tr><td width="5%">Name</td> <td width="18%">: $Name</td>
//        <td width="10%">| Aadhar Number</td> <td width="10%">: $aadhar</td>
//        <td width="10%">| Leave</td> <td width="10%">: $leave</td>
//       </tr>
//     <tr><td width="5%">Employee ID </td><td width="18%">: $eid</td>
//         <td width="10%">| PAN Number.</td><td width="10%">:  $panno</td>
//         <td width="10%">| Sunday & Holiday</td> <td width="10%">: $sundayandholiday</td>
//       </tr>
//       <tr><td width="5%">Father Name</td> <td width="18%">: $fathername</td>
//        <td width="10%">| PF A/C No.</td> <td width="10%">: $pfno</td>
//        <td width="10%">| Days Worked</td> <td width="10%">: $workeddays</td>
//       </tr>
//         <tr><td class="bdr" width="5%">Designation </td> <td class="bdr" width="18%"> : $desig</td>
//              <td class="bdr" width="10%">| ESI Number</td> <td class="bdr" width="10%" >: $esino</td>
//              <td class="bdr" width="10%">| Paid Days</td> <td class="bdr" width="10%" >: $paiddays</td>
//                </tr>
//         </table>
//         </tr></td>
//         <tr><td>
//       <table style="width:100%;   font-size: 15px; ">
//         <tr>

//              <td>Payroll Month</td>
//     <td>Bank Name</td>
//     <td>Bank A/C No.</td>
//     <td>Take Home Pay </td>
//     <td>= </td>
//     <td>Earning </td>
//      <td>-</td>
//      <td>Deduction  </td>
//      <td>-</td>
//      <td>Adjustment</td>
//      <td>+</td>
//     <td>Reimbursements</td>
//     <td>+</td>
//     <td>Overtime</td>
//           </tr>

//           <tr>
//             <td class="bdr"> $month $year</td>
//         <td class="bdr">$bname </td>
//       <td class="bdr">$accno</td>
//       <td class="bdr"> $netsalary</td>
//       <td class="bdr">=</td>
//       <td class="bdr">$tearnings</td>
//       <td class="bdr">-</td>
//       <td class="bdr"> $tdeduct</td>
//       <td class="bdr">-</td>
//       <td class="bdr"> $adjustment</td>
//       <td class="bdr">+</td>
//       <td class="bdr">$reimbursement</td>
//       <td class="bdr">+</td>
//       <td class="bdr">$tovrt</td>

//             </tr>

//              <tr height="1"></tr>
//        </table></tr></td>
//         <tr><td>
//         <table style="width:100%;   font-size: 15px; ">
//    <tr>
//       <td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"> Earning     </td>
//       <td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"></td>
//        <td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;">| Deductions </td>
//         <td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"> </td>
//         <td colspan="2" style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;">| Loans Taken & Deducted</td>

//     </tr>
//    <tr>
//    <script>

//    </script>
//    <td style=" border-bottom: 1px dashed #000; font-size:15px;">
//       ${newListlabel.join('')}
//    </td>
//    <td style=" border-bottom: 1px dashed #000;">
//         ${newListamount.join('')}
//     </td>

//    <td style=" border-bottom: 1px dashed #000;">
//        ${deductionlabel.join('')}   </td>

//    <td style=" border-bottom: 1px dashed #000;">
//         ${deductionamount.join('')}       </td>
//         <td style=" border-bottom: 1px dashed #000;">
//             | Loan Taken <br />
//             | Emi Deducted<br />
//             | Loan Outstanding<br />
//             | Advance Salary<br />

//              </td>
//         <td style=" border-bottom: 1px dashed #000;">
//             :$loantaken<br />
//             :$loandeducted<br />
//             :$loanoutstanding<br />
//             :$advancesalary             </td>
//    </tr>
//      <tr>
//        <td class="bdr">Total</td>
//        <td class="bdr">: $tearnings</td>
//           <td class="bdr">| Total</td><td class="bdr"> : $tdeduct</td>
//        <td class="bdr">| </td><td class="bdr"></td>
//     </tr>
//     <tr height="8"></tr>

//    <tr>
//        <td colspan="4"></td>
//        <td colspan="2" style="border: 1px dashed #000; border-top: 1px dashed #000; text-align:center;">Take Home Pay &nbsp;&nbsp;&nbsp;Rs.$netsalary</td>

//    </tr>
//    <tr>
//        <td colspan="6"> Note:-</td>
//    </tr>
//    </table></tr></td>
//  </table>
//    </body>
//   </html>
//     """;

    final dir = await _getDownloadDirectory();
    await _requestPermissions();
    log("message");
    final Directory? _appDocDirFolder =
        Directory('${dir!.path}/Ezhrm/Salary Slips');
    if (await _appDocDirFolder!.exists()) {
      //print('exists');
      appDocDir = await _getDownloadDirectory();
      var targetPath = '${appDocDir!.path}/Ezhrm/Salary Slips';
      var targetFileName = "$_valuenew $_value";
      final dir = await getExternalStorageDirectory();
      final String path = "${dir!.path}/example.pdf";
      final file = File(path);
      var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          htmlContent, targetPath, targetFileName);
      generatedPdfFilePath = generatedPdfFile.path;
      Fluttertoast.showToast(
          msg: "Pdf Saved At \n ${appDocDir!.path}/Ezhrm/Salary Slips",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3000,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 12.0);
      return;
    } else {
      final Directory _appDocNewFolder =
          await _appDocDirFolder.create(recursive: true);
      appDocDir = await _getDownloadDirectory();
      var targetPath = '${appDocDir!.path}/Ezhrm/Salary Slips';
      var targetFileName = "$_valuenew $_value";
      final dir = await getExternalStorageDirectory();
      final String path = "${dir!.path}/example.pdf";
      final file = File(path);
      var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          htmlContent, targetPath, targetFileName);
      generatedPdfFilePath = generatedPdfFile.path;
      Fluttertoast.showToast(
          msg: "Pdf Saved At \n ${appDocDir!.path}/Ezhrm/Salary Slips",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3000,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 12.0);
    }
  }

  Directory? appDocDir;
  var internet = 'yes';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    getEmail();
    String monthNumber = (DateTime.now().month - 1).toString();
    _valuenew = monthNumber == "1"
        ? "Jan"
        : monthNumber == "2"
            ? "Feb"
            : monthNumber == "3"
                ? "Mar"
                : monthNumber == "4"
                    ? "Apr"
                    : monthNumber == "5"
                        ? "May"
                        : monthNumber == "6"
                            ? "Jun"
                            : monthNumber == "7"
                                ? "Jul"
                                : monthNumber == "8"
                                    ? "Aug"
                                    : monthNumber == "9"
                                        ? "Sep"
                                        : monthNumber == "10"
                                            ? "Oct"
                                            : monthNumber == "11"
                                                ? "Nov"
                                                : "Dec";
    _value = DateTime.now().year.toString();
    setState(() {
      userData = 'started';
    });
    // fetchCredit();
  }

  Future getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SharedPreferences preferencess = await SharedPreferences.getInstance();
    SharedPreferences preferencesimg = await SharedPreferences.getInstance();
    SharedPreferences preferencesimg2 = await SharedPreferences.getInstance();
    SharedPreferences preferencesuid = await SharedPreferences.getInstance();
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      username = preferencess.getString('username');
      ppic = preferencesimg.getString('profile');
      ppic2 = preferencesimg2.getString('profile2');
      uid = preferencesuid.getString('uid');
      cid = preferencecuid.getString('comp_id');
    });
  }

  Future fetchList() async {
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    SharedPreferences preferencesuid = await SharedPreferences.getInstance();
    try {
      var uri = "$customurl/controller/process/app/extras.php";
      var formdata = FormData.fromMap({
        'uid': preferencesuid.getString('uid'),
        'cid': preferencecuid.getString('comp_id'),
        'type': 'salary_slip2',
        'month': _valuenew,
        'year': _value
      });

      var dio = Dio();
      var response = await dio.request(
        uri,
        options: Options(
          method: 'POST',
        ),
        data: formdata,
      );

      log({
        'uid': preferencesuid.getString('uid'),
        'cid': preferencecuid.getString('comp_id'),
        'type': 'salary_slip2',
        'month': _valuenew,
        'year': _value
      }.toString());
      data = json.decode(response.data);
      log(response.statusCode.toString());
      log(data.toString());
      userData = data!["data"];
      htmldata = data!["data"];
      setState(() {});
      if (userData == null) {
        setState(() {
          screen = 'not found';
        });
      }
      loadLocalHTML();
      setState(() {
        visible = true;
        //user details
        // userDatanew = userData['user_details'];
        // Name = userDatanew[0]['u_full_name'];

        //print(userDatanew[0]['u_fname']);
        //print(userDatanew[0]['u_fname']);
        // if (userDatanew[0]['u_fname'] == null ||
        //     userDatanew[0]['u_fname'] == '') {
        //   //print("2if");
        //   setState(() {
        //     fathername = '';
        //   });
        // } else {
        //   //print("2else");
        //   setState(() {
        //     fathername = userDatanew[0]['u_fname'];
        //   });
        // }

        // desig = userDatanew[0]['u_designation'];
        // eid = userDatanew[0]['u_employee_id'];
        // year = userData['slip'][0]['year'];
        // month = userData['slip'][0]['month'];

        //print(desig);
        //print(eid);
        //print(year);
        //print(month);

        // account details

        // accdetails = userData['acc_details'];
        // //print(accdetails.toString());

        // if (accdetails.toString().isNotEmpty) {
        //   //print("aman");
        //   bname = accdetails[0]['bank_name'].toString();
        //   accno = accdetails[0]['bank_acc_no'].toString();
        //   panno = accdetails[0]['pan_no'].toString();
        //   esino = accdetails[0]['esi_no'].toString();
        //   pfno = accdetails[0]['pf_acc_no'].toString();
        //   aadhar = accdetails[0]['aadhar_no'];
        // } else {
        //   bname = "";
        //   accno = "";
        //   panno = "";
        //   esino = "";
        //   pfno = "";
        //   aadhar = "";
        // }

        //print("soni");

        // if(userDatanew[0]['aadhar_no'] == null || userDatanew[0]['aadhar_no'] == '' ){
        //   setState(() {
        //     aadhar = '';
        //   });
        // }else{
        //   setState(() {
        //
        //     aadhar = userDatanew[0]['aadhar_no'].toString();
        //   });
        // }

        //company details
        // cdetails = userData['company_details'];
        // compname = cdetails[0]['company_name'];
        // compstate = cdetails[0]['state'];
        // compdist = cdetails[0]['district'];
        // compadd = cdetails[0]['address'];
        // comppincode = cdetails[0]['pincode'];
        // complogo = cdetails[0]['file_name'];

        // //earnings
        // earnings = userData['slip'][0]['earnings'];
        // // elist = earnings[0]['label'];

        // //label and amount
        // newListlabel = [
        //   for (i = 0; i < earnings.length; i++) "${earnings[i]['label']} <br/>"
        // ];

        // newListamount = [
        //   for (i = 0; i < earnings.length; i++)
        //     ":${earnings[i]['amount']} <br/>"
        // ];
        //deductions
        // deductions = userData['slip'][0]['deductions'];

        // deductionlabel = [
        //   for (y = 0; y < deductions.length; y++)
        //     "|${deductions[y]['label']} <br/>"
        // ];
        // deductionamount = [
        //   for (y = 0; y < deductions.length; y++)
        //     ":${deductions[y]['amount']} <br/>"
        // ];
        // //over time
        // tovrt = userData['slip'][0]['extra_pay'].toString();

        // //not payable
        // notpayable = userData['slip'][0]['not_payable'].toString();
        // //worked days
        // workeddays = userData['slip'][0]['work_days'].toString();
        // //paid days
        // paiddays = userData['slip'][0]['paid_days'].toString();
        // //leaves
        // leave = userData['slip'][0]['leave_earn'].toString();
        // //adjustment
        // adjustment = int.parse(userData['slip'][0]['loan_adjust']) +
        //     int.parse(userData['slip'][0]['salary_advance']);

        // //total earn
        // tearnings = int.parse(userData['slip'][0]['total_earn']) +
        //     int.parse(userData['slip'][0]['incentive']);
        // //total deduct
        // tdeduct = userData['slip'][0]['total_deduct'].toString();
        // //reimbursement
        // reimbursement = userData['slip'][0]['reimbursement'].toString();
        // //netsalary
        // netsalary = userData['slip'][0]['net_salary'].toString();

        // //loan taken
        // loantaken = userData['slip'][0]['loan_advance'].toString();
        // //loan deducted
        // loandeducted = userData['slip'][0]['loan_adjust'].toString();
        // //loan outstanding
        // loanoutstanding = int.parse(userData['slip'][0]['loan_advance']) -
        //     int.parse(userData['slip'][0]['loan_paid']);
        // //advance salary
        // advancesalary = userData['slip'][0]['salary_advance'].toString();

        // //sunday and holiday
        // if (userData['slip'][0]['sunday'] == null ||
        //     userData['slip'][0]['sunday'] == '' ||
        //     userData['slip'][0]['holiday'] == null ||
        //     userData['slip'][0]['holiday'] == '') {
        //   sundayandholiday = '';
        // } else if (userData['slip'][0]['sunday'] == null ||
        //     userData['slip'][0]['sunday'] == '') {
        //   setState(() {
        //     sundayandholiday = userData['slip'][0]['holiday'].toString();
        //   });
        // } else if (userData['slip'][0]['holiday'] == null ||
        //     userData['slip'][0]['holiday'] == '') {
        //   setState(() {
        //     sundayandholiday = userData['slip'][0]['sunday'].toString();
        //   });
        // } else if (userData['slip'][0]['sunday'] != null ||
        //     userData['slip'][0]['sunday'] != '' ||
        //     userData['slip'][0]['holiday'] != null ||
        //     userData['slip'][0]['holiday'] != '') {
        //   setState(() {
        //     sundayandholiday = int.parse(userData['slip'][0]['sunday']) +
        //         int.parse(userData['slip'][0]['holiday']);
        //   });
        // }
        visible = true;
      });
      if (debug == 'yes') {
        //print("check here");
        //debugPrint(data.toString());
        //debugPrint(userData.toString());
        //debugPrint(userDatanew.toString());
        //debugPrint(Name.toString());
        //debugPrint(eid.toString());
        //debugPrint(desig.toString());
        //debugPrint(cdetails.toString());
        //debugPrint(complogo.toString());
        //debugPrint(earnings.toString());
        //debugPrint(deductions.toString());
        //debugPrint(notpayable.toString());
        //debugPrint(workeddays.toString());
        //debugPrint(paiddays.toString());
        //debugPrint(leave.toString());
        //debugPrint(accdetails.toString());
        //debugPrint(year.toString());
        //debugPrint(month.toString());
        //  //debugPrint(elist.toString());
        //print(newListlabel.toString());
        //print(newListamount.toString());
        //print(listlabel.toString());
        //print(myearninglist);
        //print(myearningamount);
        //print(concatenate);
        // //print();
        //array length//

        //debugPrint(data.length.toString());
        //debugPrint(userData.length.toString());
        //debugPrint(userDatanew.length.toString());
      }
    } catch (error) {
      //print(error);
      //print("aman error");
    }
  }

  WebViewController? webViewController;
  String htmlFilePath = 'assets/slip.html';

  // loadLocalHTML() async {
  //   webViewController.loadUrl(Uri.dataFromString(
  //           '<html>'
  //           '<head>'
  //           '<title> Salary Slip</title>'
  //           '<style>'
  //           '*{ font-family:"serif"; }'
  //           'body { padding:0px; margin:0px; font-family:serif; }'
  //           'td, { padding:0px;  }'
  //           'td { text-align:left;}'
  //           '@media print {'
  //           '#hide {'
  //           'display: none; '
  //           '}'
  //           '}'
  //           '.bdr{'
  //           'border-bottom: 1px dashed #000;'
  //           '}'
  //           ' </style>'
  //           '</head>'
  //           '<p style="text-align:center; font-size:larger; color:blue;">This is a system generated statement and requires no signature.</p>'
  //           '<table style=" width:100%; outline-style:outset;  margin:20px auto; ">'
  //           '<tr><td>'
  //           '<table style="width:100%;   font-size: 15px; "> '
  //           '<tr>'
  //           '<td colspan="12" style="text-align:center; "></td><img style="max-height:100px;" src="$complogo" /></td>'
  //           '</tr>'
  //           '<tr height="8"></tr>'
  //           '<tr>'
  //           '<td colspan="12" class="bdr"  style="text-align:center;" >'
  //           '$compname,<br/>${compadd?.replaceAll(' - ', '')},$compstate-$comppincode,<br/>'
  //           '$compstate'
  //           '</td>'
  //           '</tr>'
  //           '<tr><td width="5%">Name</td> <td width="18%">: $Name</td>'
  //           '<td width="10%">| Aadhar Number</td> <td width="10%">: $aadhar</td>'
  //           '<td width="10%">| Leave</td> <td width="10%">: $leave</td></tr>'
  //           '<tr><td width="5%">Employee ID </td> <td width="18%">: $eid</td>'
  //           '<td width="10%">| PAN Number</td> <td width="10%">:  $panno</td>'
  //           '<td width="10%">| Sunday & Holiday</td> <td width="10%">: $sundayandholiday</td></tr>'
  //           '<tr><td width="5%">Father Name </td><td width="18%">: $fathername</td>'
  //           '<td width="10%">| PF A/C No.</td><td width="10%">:  $pfno</td>'
  //           '<td width="10%">| Days Worked</td> <td width="10%">: $workeddays</td>'
  //           '</tr>'
  //           '<tr><td class="bdr" width="5%">Designation </td> <td class="bdr" width="18%"> : $desig</td>'
  //           '<td class="bdr" width="10%">| ESI Number</td> <td class="bdr" width="10%" >: $esino</td>'
  //           '<td class="bdr" width="10%">| Paid Days</td> <td class="bdr" width="10%" >: $paiddays</td>'
  //           '</tr>'
  //           '</tr></td>'
  //           '<table style="width:100%;   font-size: 15px; ">'
  //           '<tr>'
  //           '<td>Payroll Month</td>'
  //           '<td>Bank Name</td>'
  //           '<td>Bank A/C No.</td>'
  //           '<td>Take Home Pay </td>'
  //           '<td>= </td>'
  //           '<td>Earning </td>'
  //           '<td>-</td>'
  //           '<td>Deduction  </td>'
  //           '<td>-</td>'
  //           '<td>Adjustment</td>'
  //           '<td>+</td>'
  //           '<td>Reimbursements</td>'
  //           '<td>+</td>'
  //           '<td>Overtime</td>'
  //           '</tr>'
  //           '<tr>'
  //           '<td class="bdr"> $month $year</td>'
  //           '<td class="bdr">$bname </td>'
  //           '<td class="bdr">$accno</td>'
  //           '<td class="bdr"> $netsalary</td>'
  //           '<td class="bdr">=</td>'
  //           '<td class="bdr">$tearnings</td>'
  //           '<td class="bdr">-</td>'
  //           '<td class="bdr">$tdeduct</td>'
  //           '<td class="bdr">-</td>'
  //           '<td class="bdr"> $adjustment</td>'
  //           '<td class="bdr">+</td>'
  //           '<td class="bdr">$reimbursement</td>'
  //           '<td class="bdr">+</td>'
  //           '<td class="bdr">$tovrt</td>'
  //           '</tr>'
  //           '<tr height="1"></tr>'
  //           '</table></tr></td>'
  //           '<tr><td>'
  //           '<table style="width:100%;   font-size: 15px; ">'
  //           '<tr>'
  //           '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"> Earning     </td> '
  //           '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"></td>'
  //           '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;">| Deductions </td>'
  //           '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"> </td>'
  //           '<td colspan="2" style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;">| Loans Taken & Deducted</td>'
  //           '</tr>'
  //           '<tr>'
  //           '<td style=" border-bottom: 1px dashed #000; font-size:15px;"> '
  //           '${newListlabel?.join('')}'
  //           '</td>'
  //           '<td style=" border-bottom: 1px dashed #000;">'
  //           '${newListamount?.join((''))}'
  //           '</td>'
  //           '<td style=" border-bottom: 1px dashed #000;">'
  //           '${deductionlabel?.join('')}'
  //           '</td>'
  //           '<td style=" border-bottom: 1px dashed #000;">'
  //           '${deductionamount?.join((''))}'
  //           '</td>'
  //           '<td style=" border-bottom: 1px dashed #000;">'
  //           '| Loan Taken <br />'
  //           '| Emi Deducted<br />'
  //           '| Loan Outstanding<br />'
  //           '| Advance Salary<br />'
  //           '</td>'
  //           '<td style=" border-bottom: 1px dashed #000;">'
  //           ':$loantaken<br />'
  //           ':$loandeducted<br />'
  //           ':$loanoutstanding<br />'
  //           ':$advancesalary</td>'
  //           '</tr>'
  //           '<tr>'
  //           '<td class="bdr">Total</td>'
  //           '<td class="bdr">: $tearnings</td>'
  //           '<td class="bdr">| Total</td><td class="bdr"> : $tdeduct</td>'
  //           '<td class="bdr">| </td><td class="bdr"></td>'
  //           '</tr>'
  //           '<tr height="8"></tr>'
  //           '<tr>'
  //           '<td colspan="4"></td>'
  //           '<td colspan="2" style="border: 1px dashed #000; border-top: 1px dashed #000; text-align:center;">Take Home Pay &nbsp;&nbsp;&nbsp;Rs.$netsalary</td>'
  //           '</tr>'
  //           '<tr>'
  //           '<td colspan="6"> Note:-</td>'
  //           '</tr>'
  //           '</table></tr></td>'
  //           '</table></body></html>',
  //           mimeType: 'text/html')
  //       .toString());
  // }
  loadLocalHTML() async {
    webViewController = WebViewController()
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("https://")) {
              return NavigationDecision.navigate;
            } else {
              return NavigationDecision.prevent;
            }
          },
        ),
      );

    webViewController!.loadHtmlString(
      htmldata!,
      // '<html>'
      // '<head>'
      // '<title> Salary Slip</title>'
      // '<style>'
      // '*{ font-family:"serif"; }'
      // 'body { padding:0px; margin:0px; font-family:serif; }'
      // 'td, { padding:0px;  }'
      // 'td { text-align:left;}'
      // '@media print {'
      // '#hide {'
      // 'display: none; '
      // '}'
      // '}'
      // '.bdr{'
      // 'border-bottom: 1px dashed #000;'
      // '}'
      // ' </style>'
      // '</head>'
      // '<p style="text-align:center; font-size:larger; color:blue;">This is a system generated statement and requires no signature.</p>'
      // '<table style=" width:100%; outline-style:outset;  margin:20px auto; ">'
      // '<tr><td>'
      // '<table style="width:100%;   font-size: 15px; "> '
      // '<tr>'
      // '<td colspan="12" style="text-align:center; "></td><img style="max-height:100px;" src="$complogo" /></td>'
      // '</tr>'
      // '<tr height="8"></tr>'
      // '<tr>'
      // '<td colspan="12" class="bdr"  style="text-align:center;" >'
      // '$compname,<br/>${compadd?.replaceAll(' - ', '')},$compstate-$comppincode,<br/>'
      // '$compstate'
      // '</td>'
      // '</tr>'
      // '<tr><td width="5%">Name</td> <td width="18%">: $Name</td>'
      // '<td width="10%">| Aadhar Number</td> <td width="10%">: $aadhar</td>'
      // '<td width="10%">| Leave</td> <td width="10%">: $leave</td></tr>'
      // '<tr><td width="5%">Employee ID </td> <td width="18%">: $eid</td>'
      // '<td width="10%">| PAN Number</td> <td width="10%">:  $panno</td>'
      // '<td width="10%">| Sunday & Holiday</td> <td width="10%">: $sundayandholiday</td></tr>'
      // '<tr><td width="5%">Father Name </td><td width="18%">: $fathername</td>'
      // '<td width="10%">| PF A/C No.</td><td width="10%">:  $pfno</td>'
      // '<td width="10%">| Days Worked</td> <td width="10%">: $workeddays</td>'
      // '</tr>'
      // '<tr><td class="bdr" width="5%">Designation </td> <td class="bdr" width="18%"> : $desig</td>'
      // '<td class="bdr" width="10%">| ESI Number</td> <td class="bdr" width="10%" >: $esino</td>'
      // '<td class="bdr" width="10%">| Paid Days</td> <td class="bdr" width="10%" >: $paiddays</td>'
      // '</tr>'
      // '</tr></td>'
      // '<table style="width:100%;   font-size: 15px; ">'
      // '<tr>'
      // '<td>Payroll Month</td>'
      // '<td>Bank Name</td>'
      // '<td>Bank A/C No.</td>'
      // '<td>Take Home Pay </td>'
      // '<td>= </td>'
      // '<td>Earning </td>'
      // '<td>-</td>'
      // '<td>Deduction  </td>'
      // '<td>-</td>'
      // '<td>Adjustment</td>'
      // '<td>+</td>'
      // '<td>Reimbursements</td>'
      // '<td>+</td>'
      // '<td>Overtime</td>'
      // '</tr>'
      // '<tr>'
      // '<td class="bdr"> $month $year</td>'
      // '<td class="bdr">$bname </td>'
      // '<td class="bdr">$accno</td>'
      // '<td class="bdr"> $netsalary</td>'
      // '<td class="bdr">=</td>'
      // '<td class="bdr">$tearnings</td>'
      // '<td class="bdr">-</td>'
      // '<td class="bdr">$tdeduct</td>'
      // '<td class="bdr">-</td>'
      // '<td class="bdr"> $adjustment</td>'
      // '<td class="bdr">+</td>'
      // '<td class="bdr">$reimbursement</td>'
      // '<td class="bdr">+</td>'
      // '<td class="bdr">$tovrt</td>'
      // '</tr>'
      // '<tr height="1"></tr>'
      // '</table></tr></td>'
      // '<tr><td>'
      // '<table style="width:100%;   font-size: 15px; ">'
      // '<tr>'
      // '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"> Earning     </td> '
      // '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"></td>'
      // '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;">| Deductions </td>'
      // '<td style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;"> </td>'
      // '<td colspan="2" style=" border-bottom: 1px dashed #000; border-top: 1px dashed #000;">| Loans Taken & Deducted</td>'
      // '</tr>'
      // '<tr>'
      // '<td style=" border-bottom: 1px dashed #000; font-size:15px;"> '
      // '${newListlabel?.join('')}'
      // '</td>'
      // '<td style=" border-bottom: 1px dashed #000;">'
      // '${newListamount?.join((''))}'
      // '</td>'
      // '<td style=" border-bottom: 1px dashed #000;">'
      // '${deductionlabel?.join('')}'
      // '</td>'
      // '<td style=" border-bottom: 1px dashed #000;">'
      // '${deductionamount?.join((''))}'
      // '</td>'
      // '<td style=" border-bottom: 1px dashed #000;">'
      // '| Loan Taken <br />'
      // '| Emi Deducted<br />'
      // '| Loan Outstanding<br />'
      // '| Advance Salary<br />'
      // '</td>'
      // '<td style=" border-bottom: 1px dashed #000;">'
      // ':$loantaken<br />'
      // ':$loandeducted<br />'
      // ':$loanoutstanding<br />'
      // ':$advancesalary</td>'
      // '</tr>'
      // '<tr>'
      // '<td class="bdr">Total</td>'
      // '<td class="bdr">: $tearnings</td>'
      // '<td class="bdr">| Total</td><td class="bdr"> : $tdeduct</td>'
      // '<td class="bdr">| </td><td class="bdr"></td>'
      // '</tr>'
      // '<tr height="8"></tr>'
      // '<tr>'
      // '<td colspan="4"></td>'
      // '<td colspan="2" style="border: 1px dashed #000; border-top: 1px dashed #000; text-align:center;">Take Home Pay &nbsp;&nbsp;&nbsp;Rs.$netsalary</td>'
      // '</tr>'
      // '<tr>'
      // '<td colspan="6"> Note:-</td>'
      // '</tr>'
      // '</table></tr></td>'
      // '</table></body></html>',
    );
  }

  String _value = 'start';
  String _valuenew = 'start';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const bottombar_ios(),
        drawer:
            const CustomDrawer(currentScreen: AvailableDrawerScreens.salary),
        appBar: AppBar(
          title: const Text(
            'Salary Slip',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
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
          actions: [
            userData == null || userData == 'started'
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [Colors.green, Colors.blue],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          generateDocument();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Generate Pdf',
                              style: TextStyle(
                                  fontFamily: font1, color: Colors.white),
                            ),
                            Icon(
                              Icons.arrow_circle_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                        // color: Colors.white,
                      ),
                    ),
                  ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     decoration: const BoxDecoration(
            //       borderRadius: BorderRadius.all(Radius.circular(50)),
            //       gradient: LinearGradient(
            //         begin: Alignment.centerRight,
            //         end: Alignment.centerLeft,
            //         colors: [Colors.green, Colors.blue],
            //       ),
            //     ),
            //     child: TextButton(
            //       onPressed: () {
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (_) => ViewPDF(mytitle: "", pathPDF: "")));
            //       },
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: const [
            //           Text(
            //             'Saved',
            //             style:
            //                 TextStyle(fontFamily: font1, color: Colors.white),
            //           ),
            //           Icon(
            //             Icons.picture_as_pdf,
            //             color: Colors.white,
            //           )
            //         ],
            //       ),
            //       // color: Colors.white,
            //     ),
            //   ),
            // )
          ],
        ),
        backgroundColor: Colors.blue,
        body: Container(
            child: userData == 'started'
                ? Container(
                    child: const Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'To Generate Salary Slip, Please Select Month And Year',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    )),
                    color: Colors.white,
                  )
                : userData == null
                    ? Container(
                        color: Colors.white,
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: screen == 'not found'
                                    ? const Text(
                                        'No Salary Slip Found',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                        ),
                                      )
                                    : const Text(
                                        'Please Wait....',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 20,
                                        ),
                                      ))),
                      )
                    : WebViewWidget(controller: webViewController!)),
        floatingActionButton: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 5, 0, 5),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
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
                            dropdownColor: Colors.black,
                            icon: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ),
                            hint: const Text(
                              'Select Month',
                              style: TextStyle(
                                  fontFamily: font1, color: Colors.white),
                            ),
                            value: _valuenew,
                            items: const [
                              DropdownMenuItem(
                                child: Text(
                                  'Select Month',
                                  style: TextStyle(
                                      fontFamily: font1, color: Colors.white),
                                ),
                                value: 'start',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'uary',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Jan',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'February',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Feb',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'March',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Mar',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'April',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Apr',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'May',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'May',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'June',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Jun',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'July',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Jul',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'August',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Aug',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'September',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Sep',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'October',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Oct',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'November',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Nov',
                              ),
                              DropdownMenuItem(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    'December',
                                    style: TextStyle(
                                        fontFamily: font1, color: Colors.white),
                                  ),
                                ),
                                value: 'Dec',
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _valuenew = value!;
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
                  borderRadius: BorderRadius.all(Radius.circular(50)),
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
                          hint: const Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Text(
                              'Select Year',
                              style: TextStyle(
                                  fontFamily: font1, color: Colors.white),
                            ),
                          ),
                          value: _value,
                          items: [
                            const DropdownMenuItem(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: Text(
                                  'Select Year',
                                  style: TextStyle(
                                      fontFamily: font1, color: Colors.white),
                                ),
                              ),
                              value: 'start',
                            ),
                            DropdownMenuItem(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: Text(
                                  (currDt.year - 1).toString(),
                                  style: const TextStyle(
                                      fontFamily: font1, color: Colors.white),
                                ),
                              ),
                              value: (currDt.year - 1).toString(),
                            ),
                            DropdownMenuItem(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: Text(
                                  currDt.year.toString(),
                                  style: const TextStyle(
                                      fontFamily: font1, color: Colors.white),
                                ),
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
              _value == 'start' || _valuenew == 'start'
                  ? Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.grey, Colors.grey],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          //print("aman soni");
                        },
                        child: const Text(
                          'View',
                          style:
                              TextStyle(color: Colors.white, fontFamily: font1),
                        ),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.black],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          //  checkinternetconnection();

                          fetchList();
                          setState(() {
                            userData = null;
                          });
                        },
                        child: const Text(
                          'View',
                          style:
                              TextStyle(color: Colors.white, fontFamily: font1),
                        ),
                      ),
                    ),
            ],
          ),
        )
        // bottomNavigationBar: CustomBottomNavigationBar(),

        );
  }
}
