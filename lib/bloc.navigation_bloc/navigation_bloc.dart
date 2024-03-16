// import 'package:bloc/bloc.dart';
// import '/Chngpwd.dart';
// import '/ReqAtt.dart';
// import '/Compoff.dart';
// import '/ViewPdf.dart';
// import '/about.dart';
// import '/advance.dart';
// import '/applyadvsalary.dart';
// import '/applycompoff.dart';
// import '/applyleave.dart';
// import '/applyloan.dart';
// import '/applyreimb.dart';
// import '/applywfh.dart';
// import '/markwithdate.dart';
// import '/notification.dart';
// import '/reqattendancewithdate.dart';
// import '/workfromhome.dart';
// import '/documents.dart';
// import '/editprofile.dart';
// import '/feedback.dart';
// import '/markattendance.dart';
// import '/holiday.dart';
// import '/home.dart';
// import '/leavequota.dart';
// import '/leavestatus.dart';
// import '/loan.dart';
// import '/meeting.dart';
// import '/myprofile.dart';
// import '/reimbursment.dart';
// import '/showatt.dart';
// import '/sslip.dart';
// import '/tattlist.dart';
// import '/teamleavelist.dart';
// import '/temareimlist.dart';
// import '/uploadimg_new.dart';


// enum NavigationEvents {
//   HomePageClickedEvent,
//   MyLeaveClickedEvent,
//   MyLeaveStatusClickedEvent,
//   MyProfileClickedEvent,
//   MyAttendanceClickedEvent,
//   MyReqAttendanceClickedEvent,
//   MyAttendanceViewClickedEvent,
//   MyLeaveApplyViewClickedEvent,
//   MyWfhClickedEvent,
//   MyProfileEditClickedEvent,
//   MyCompClickedEvent,
//   MyHolidayClickedEvent,
//   MyReimClickedEvent,
//   MyApplyReimClickedEvent,
//   DocumentsClickedEvent,
//   FetRecClickedEvent,
//   UldImgClickedEvent,
//   FeedbackClickedEvent,
//   SslipClickedEvent,
//   JoinMeetClickedEvent,
//   ChangePassClickedEvent,
//   TeamReimList,
//   TeamLeaveList,
//   TeamAttendanceList,
//   LoanStatus,
//   ApplyLoan,
//   CompOffApply,
//   Workfromhomeapply,
//   AdvanceSalary,
//   Applyadv,
//   Notification,
//   Markwithdate,
//   Reqwithdate,
//   about,
//   viewpdf,
//   TakeImg
// }

// abstract class NavigationStates {}

// class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
//   NavigationBloc(NavigationStates initialState) : super(initialState);

//   NavigationStates get initialState => const HomePage();

//   @override
//   Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
//     switch (event) {
//       case NavigationEvents.HomePageClickedEvent:
//         yield const HomePage();
//         break;
//       case NavigationEvents.MyLeaveClickedEvent:
//         yield LeaveQuota();
//         break;
//       case NavigationEvents.MyLeaveStatusClickedEvent:
//         yield LeaveStatus();
//         break;
//       case NavigationEvents.MyProfileClickedEvent:
//         yield const MyProfile();
//         break;
//       case NavigationEvents.MyAttendanceClickedEvent:
//         yield const MyAttendance();
//         break;
//       case NavigationEvents.MyReqAttendanceClickedEvent:
//         yield ReqAttendance();
//         break;
//       case NavigationEvents.MyAttendanceViewClickedEvent:
//         yield const ShowAtt();
//         break;
//       case NavigationEvents.MyLeaveApplyViewClickedEvent:
//         yield const ApplyLeave();
//         break;
//       case NavigationEvents.MyWfhClickedEvent:
//         yield ApplyWfh();
//         break;
//       case NavigationEvents.MyProfileEditClickedEvent:
//         yield const EditProfile();
//         break;
//       case NavigationEvents.MyCompClickedEvent:
//         yield const ApplyCmp();
//         break;
//       case NavigationEvents.MyHolidayClickedEvent:
//         yield const MyHoliday();
//         break;
//       case NavigationEvents.MyReimClickedEvent:
//         yield ApplyReim();
//         break;
//       case NavigationEvents.MyApplyReimClickedEvent:
//         yield const ReimBursement();
//         break;
//       case NavigationEvents.DocumentsClickedEvent:
//         yield const DocuMents();
//         break;
//       case NavigationEvents.UldImgClickedEvent:
//         yield UploadImg();
//         break;
//       case NavigationEvents.FeedbackClickedEvent:
//         yield const FeedBack();
//         break;
//       case NavigationEvents.SslipClickedEvent:
//         yield SalarySlip();
//         break;
//       case NavigationEvents.JoinMeetClickedEvent:
//         yield MyMeetings();
//         break;
//       case NavigationEvents.ChangePassClickedEvent:
//         yield const Cpwd();
//         break;
//       case NavigationEvents.TeamReimList:
//         yield TrList();
//         break;
//       case NavigationEvents.TeamLeaveList:
//         yield LeaveList();
//         break;
//       case NavigationEvents.TeamAttendanceList:
//         yield TeamAttList();
//         break;
//       case NavigationEvents.LoanStatus:
//         yield Loan();
//         break;
//       case NavigationEvents.ApplyLoan:
//         yield const ApplyLoan();
//         break;
//       case NavigationEvents.CompOffApply:
//         yield const ApplyCompOff();
//         break;
//       case NavigationEvents.Workfromhomeapply:
//         yield const ApplyWrkfrmhome();
//         break;
//       case NavigationEvents.AdvanceSalary:
//         yield const Advance();
//         break;
//       case NavigationEvents.Applyadv:
//         yield const Applyadvsalary();
//         break;
//       case NavigationEvents.Notification:
//         yield Notif();
//         break;
//       case NavigationEvents.Markwithdate:
//         yield MyAttendancedate();
//         break;
//       case NavigationEvents.Reqwithdate:
//         yield const MyReqAttendancedate();
//         break;
//       case NavigationEvents.about:
//         yield const About();
//         break;
//       case NavigationEvents.viewpdf:
//         yield PdfView();
//         break;
//       default:
//         yield const HomePage();
//         break;
//     }
//   }
// }
