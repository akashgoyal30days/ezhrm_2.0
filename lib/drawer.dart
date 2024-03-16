import 'dart:io';
import 'package:ezhrm/Assigned_work.dart';
import 'package:ezhrm/Compoff.dart';
import 'package:ezhrm/about.dart';
import 'package:ezhrm/advance.dart';
import 'package:ezhrm/change_password_screen.dart';
import 'package:ezhrm/constants.dart';
import 'package:ezhrm/main.dart';
import 'package:ezhrm/meeting.dart';
import 'package:ezhrm/requestpastattendance.dart';
import 'package:ezhrm/upload_csr.dart';
import 'package:ezhrm/upload_documents.dart';
import 'package:ezhrm/feedback.dart';
import 'package:ezhrm/holiday.dart';
import 'package:ezhrm/leavequota.dart';
import 'package:ezhrm/leavestatus.dart';
import 'package:ezhrm/view_documents.dart';
import 'package:ezhrm/view_policies.dart';
import 'package:ezhrm/work_reporting.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ezhrm/loan.dart';
import 'package:ezhrm/reimbursment.dart';
import 'package:ezhrm/request_attendance_new.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/salary_slip.dart';
import 'package:ezhrm/uploadimg_new.dart';
import 'package:ezhrm/view_csr_actiivity.dart';
import 'package:ezhrm/view_todo_list.dart';
import 'package:ezhrm/workfromhome.dart';
import 'package:flutter/material.dart';
import 'applyleave.dart';
import 'attendance_history_new.dart';
import 'editprofile.dart';
import 'markattendance_new.dart';

enum AvailableDrawerScreens {
  dashboard,
  checkforupdates,
  markAttendance,
  requestAttendance,
  request_past_attendance,
  attendanceHistory,
  leaveStatus,
  leaveQuota,
  holidayList,
  applyLeave,
  applyWFH,
  CompOff,
  salary,
  reimbursment,
  advanceSalary,
  loan,
  Csrviewactivity,
  csrpostactivity,
  TodoList,
  AssignedWork,
  WorkReporting,
  joinMeeting,
  uploadDocuments,
  viewDocuments,
  Policies,
  faceRecognitionImages,
  changePassword,
  feedback,
  aboutUs
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({this.currentScreen, Key? key, this.openUserProfileScreen})
      : super(key: key);
  final VoidCallback? openUserProfileScreen;
  final AvailableDrawerScreens? currentScreen;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void showUpdate() => showCupertinoDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              return false;
            },
            child: Theme(
              data: ThemeData.light(),
              child: CupertinoAlertDialog(
                title: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/ezlogo.png',
                      width: 200,
                      height: 100,
                    ),
                    const Text(
                      'EZHRM',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                content: Column(
                  children: const [
                    SizedBox(height: 20),
                    Text(
                      ' New Update available',
                      style: TextStyle(
                          fontFamily: font1,
                          fontWeight: FontWeight.w500,
                          fontSize: 25),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Column(
                    children: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Update Now'),
                        onPressed: () async {
                          if (Platform.isAndroid) {
                            launch(
                                "https://play.google.com/store/apps/details?id=com.in30days.ezhrm");
                          } else {
                            launch(
                                "https://apps.apple.com/us/app/ezhrm/id1551548072");
                          }
                        },
                      ),
                      const Divider(),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Not Now'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  navigator(context, Widget screen) {
    Navigator.pop(context);
    if (widget.currentScreen == AvailableDrawerScreens.dashboard) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => screen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
            child: SafeArea(
          child: Column(
            children: [
              widget.openUserProfileScreen == null
                  ? SizedBox()
                  : DashBoardProfileViewer(widget.openUserProfileScreen!),
              DashBoardItem(
                title: "Dashboard",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.dashboard,
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              DashBoardItem(
                title: "Mark Attendance",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.markAttendance,
                onTap: () async {
                  navigator(context, const MarkAttendanceScreen());
                },
              ),
              DashBoardItem(
                title: "Request Attendance",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.requestAttendance,
                onTap: () async {
                  navigator(context, const RequestAttendance());
                },
              ),
              DashBoardItem(
                title: "Req Past Attendance",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.request_past_attendance,
                onTap: () async {
                  navigator(context, const RequestPastAttendanceScreen());
                },
              ),
              DashBoardItem(
                title: "Attendance History",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.attendanceHistory,
                onTap: () async {
                  navigator(context, const AttendanceHistoryScreen());
                },
              ),
              DashBoardItem(
                title: "Apply Leave",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.applyLeave,
                onTap: () async {
                  navigator(context, const ApplyLeave());
                },
              ),
              DashBoardItem(
                title: "Leave Status",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.leaveStatus,
                onTap: () async {
                  navigator(context, const LeaveStatus());
                },
              ),
              DashBoardItem(
                title: "Leave Quota",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.leaveQuota,
                onTap: () async {
                  navigator(context, const LeaveQuota());
                },
              ),
              DashBoardItem(
                title: "Holiday List",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.holidayList,
                onTap: () async {
                  navigator(context, const MyHoliday());
                },
              ),

              DashBoardItem(
                title: "Work From Home",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.applyWFH,
                onTap: () async {
                  navigator(context, const WorkFromHome());
                },
              ),
              DashBoardItem(
                title: "Comp-Off",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.CompOff,
                onTap: () async {
                  navigator(context, const Compoff());
                },
              ),
              DashBoardItem(
                title: "Reimbursment",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.reimbursment,
                onTap: () async {
                  navigator(context, const ApplyReim());
                },
              ),
              DashBoardItem(
                title: "Advance Salary",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.advanceSalary,
                onTap: () async {
                  navigator(context, const Advance());
                },
              ),
              DashBoardItem(
                title: "Loan",
                isSelected: widget.currentScreen == AvailableDrawerScreens.loan,
                onTap: () async {
                  navigator(context, const Loan());
                },
              ),
              // DrawerDropDownButton(
              //   title: "Attendance",
              //   items: [

              //   ],
              // ),
              // DrawerDropDownButton(
              //   title: "Apply",
              //   items: [

              //   ],
              // ),
              DashBoardItem(
                title: "Salary Slip",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.salary,
                onTap: () async {
                  navigator(context, const SalarySlip());
                },
              ),
              // DashBoardItem(
              //   title: "Join Meeting",
              //   isSelected:
              //       widget.currentScreen == AvailableDrawerScreens.joinMeeting,
              //   onTap: () async {
              //     navigator(context, const MyMeetings());
              //   },
              // ),
              DashBoardItem(
                title: "Upload Documents",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.uploadDocuments,
                onTap: () async {
                  navigator(context, const DocuMents());
                },
              ),
              DashBoardItem(
                title: "View Documents",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.viewDocuments,
                onTap: () async {
                  navigator(context, const ViewDocuments());
                },
              ),
              DashBoardItem(
                title: "Policies",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.Policies,
                onTap: () async {
                  navigator(context, const ViewPolicies());
                },
              ),
              DashBoardItem(
                title: "Face Recognition Images",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.faceRecognitionImages,
                onTap: () async {
                  navigator(context, const UploadImg());
                },
              ),

              DrawerDropDownButton(
                title: "CSR",
                items: [
                  DashBoardItem(
                    title: "Post Activity",
                    isSelected: widget.currentScreen ==
                        AvailableDrawerScreens.csrpostactivity,
                    onTap: () async {
                      navigator(context, const CSRUploadActivity());
                    },
                  ),
                  DashBoardItem(
                    title: "View Activity",
                    isSelected: widget.currentScreen ==
                        AvailableDrawerScreens.Csrviewactivity,
                    onTap: () async {
                      navigator(context, const ViewCSRactivity());
                    },
                  ),
                ],
              ),
              DrawerDropDownButton(
                title: "Task Management",
                items: [
                  DashBoardItem(
                    title: "To do List",
                    isSelected:
                        widget.currentScreen == AvailableDrawerScreens.TodoList,
                    onTap: () async {
                      navigator(context, const ViewTodoList());
                    },
                  ),
                  DashBoardItem(
                    title: "Assigned Work",
                    isSelected: widget.currentScreen ==
                        AvailableDrawerScreens.AssignedWork,
                    onTap: () async {
                      navigator(context, const Assigned_work());
                    },
                  ),
                  DashBoardItem(
                    title: "Work Reporting",
                    isSelected: widget.currentScreen ==
                        AvailableDrawerScreens.WorkReporting,
                    onTap: () async {
                      navigator(context, const WorkReporting());
                    },
                  ),
                ],
              ),

              DashBoardItem(
                title: "Feedback",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.feedback,
                onTap: () async {
                  navigator(context, const FeedBack());
                },
              ),
              DashBoardItem(
                title: "Change Password",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.changePassword,
                onTap: () async {
                  navigator(context, const ChangePasswordScreen());
                },
              ),
              DashBoardItem(
                title: "Contact Us",
                isSelected:
                    widget.currentScreen == AvailableDrawerScreens.aboutUs,
                onTap: () async {
                  navigator(context, const About());
                },
              ),

              DashBoardItem(
                title: "Check for updates",
                isSelected: widget.currentScreen ==
                    AvailableDrawerScreens.checkforupdates,
                onTap: () async {
                  if (goGreenModel!.showUpdateAvailableDialog!) {
                    Navigator.pop(context);
                    showUpdate();
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        elevation: 5,
                        backgroundColor: Colors.red,
                        content: Text("No Update Available")));
                  }
                },
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class DashBoardItem extends StatelessWidget {
  const DashBoardItem(
      {Key? key, this.title, this.isSelected = false, this.onTap})
      : super(key: key);
  final String? title;
  final bool isSelected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelected ? Navigator.of(context).pop : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x55072a99) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8.0),
        padding:
            isSelected ? const EdgeInsets.all(10) : const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title!,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : null,
                  color: const Color(0xff072a99),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashBoardProfileViewer extends StatefulWidget {
  const DashBoardProfileViewer(this.openUserProfileScreen, {Key? key})
      : super(key: key);
  final VoidCallback openUserProfileScreen;
  @override
  State<DashBoardProfileViewer> createState() => _DashBoardProfileViewerState();
}

class _DashBoardProfileViewerState extends State<DashBoardProfileViewer> {
  @override
  Widget build(BuildContext context) {
    String userImageUrl = SharedPreferencesInstance.getString("Myimg");
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      child: Row(
        children: [
          userImageUrl != ""
              ? GestureDetector(
                  onTap: () async {
                    widget.openUserProfileScreen();
                    return Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65 * 0.3,
                    height: MediaQuery.of(context).size.width * 0.65 * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(userImageUrl), fit: BoxFit.fill),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () async => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfile(),
                      )),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65 * 0.2,
                    height: MediaQuery.of(context).size.width * 0.65 * 0.2,
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Color(0xff072a99),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                widget.openUserProfileScreen();
                return Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SharedPreferencesInstance.getString("Myname") ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    SharedPreferencesInstance.getString("Mydesig") ?? "",
                  ),
                  Text(
                    SharedPreferencesInstance.getString("Myemail") ?? "",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerDropDownButton extends StatefulWidget {
  const DrawerDropDownButton({
    Key? key,
    @required this.title,
    @required this.items,
  }) : super(key: key);
  final String? title;
  final List<DashBoardItem>? items;
  @override
  State<DrawerDropDownButton> createState() => _DrawerDropDownButtonState();
}

class _DrawerDropDownButtonState extends State<DrawerDropDownButton> {
  bool isOpen = false;
  @override
  void initState() {
    for (var i in widget.items!) {
      if (!i.isSelected) continue;
      isOpen = true;
      break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                      color: Color(0xff072a99),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: isOpen ? 3.1 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: Color(0x66072a99),
                  ),
                )
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
            firstChild: const SizedBox(),
            secondCurve: Curves.easeIn,
            secondChild: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4),
                      width: 3.2,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.items!),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState:
                isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250)),
      ],
    );
  }
}
