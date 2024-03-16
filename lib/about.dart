import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/log_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'main.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About>
    with SingleTickerProviderStateMixin<About> {
  var currDt = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  _launchURL(lurl) async {
    var url = lurl;
    if (await canLaunch(url)) {
    } else {
      throw 'Could not launch $url';
    }
  }

  DateTime lastButtonClick = DateTime.now();
  int buttonClickCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/30days.png', scale: 1.5),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!goGreenModel!.debugEnable!) return;
                        if (buttonClickCount == 5) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LogFiles()));
                          buttonClickCount = 0;
                          return;
                        }
                        if (buttonClickCount == 0 ||
                            DateTime.now()
                                    .difference(lastButtonClick)
                                    .inMilliseconds <
                                600) {
                          buttonClickCount++;
                          lastButtonClick = DateTime.now();
                          return;
                        }
                        print("came out with buttonClickCount");

                        buttonClickCount = 0;
                      },
                      child: SizedBox(
                        child: Image.asset(
                          'assets/ezlogo.png',
                          scale: 6,
                        ),
                      ),
                    ),
                    const Text(
                      'A Complete HR Management Software',
                      style: TextStyle(
                        color: Color(0xff072a99),
                      ),
                    ),
                    Text(
                      'App Version : v$version',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 25,
                        fontFamily: font1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Spread the word',
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 23,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            launch(
                                "https://wa.me/?text=Hi%2C\n\n+I+am+using+EZHRM+for+managing+all+the+Employees+of+my+company.+Would+like+to+recommend+taking+a+free+trial+for+your+company+too.+\n\nwww.ezhrm.in&rlz=1C1CHBF_enIN919IN919&oq=Hi%2C+I+am+using+EZHRM+for+managing+all+Employees+of+my+company.+Would+like+to+recommend+taking+a+free+trial+for+your+company+too.+www.ezhrm.in");
                          },
                          child: const Align(
                            alignment: Alignment.center,
                            child: FaIcon(
                              FontAwesomeIcons.whatsappSquare,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Let's get connected",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await launch(
                                  "https://www.youtube.com/channel/UCy-rTHg2QlS1UyrP6OXejGg");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.youtube,
                              color: Colors.red,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await launch("https://www.facebook.com/ezhrm");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.facebook,
                              color: Colors.indigo,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await launch(
                                  "https://www.linkedin.com/in/ezhrm-hr-and-payroll-management-software-2864291a3/");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.linkedin,
                              color: Colors.blue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await launch("https://wa.me/917056321321");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.whatsappSquare,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          await launch("tel:+917056321321");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.phone,
                              color: Colors.indigo,
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '+91 7056321321',
                              style: TextStyle(
                                  color: Color(0xff072a99),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '© ${currDt.year.toString()} EZHRM',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 25,
                fontFamily: font1,
                color: Colors.grey,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            ' Made In India ',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 25,
                fontFamily: font1,
                color: Colors.grey,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
