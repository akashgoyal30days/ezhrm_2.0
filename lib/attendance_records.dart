import 'package:flutter/material.dart';

class AttendanceRecordScreen extends StatelessWidget {
  const AttendanceRecordScreen(
      this.attendanceRecordList, this.attendanceRecordStatus,
      {Key? key, this.openedDirectly = false})
      : super(key: key);
  final bool openedDirectly;
  final List attendanceRecordList;
  final String attendanceRecordStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, !openedDirectly),
          icon: const Icon(Icons.clear),
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
        elevation: 0,
        title: const Text(
          "Today's Attendance Records",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 6,
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      attendanceRecordStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: ListView(
                  children: attendanceRecordList
                      .map<Widget>(
                        (item) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                item["ctime"],
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xff072a99),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Divider(),
                              )),
                              if (item['status'] == "0")
                                const Text(
                                  "Pending",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xff072a99),
                                      fontSize: 16),
                                ),
                              if (item['status'] == "1")
                                const Text(
                                  "Marked",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              )),
              Row(
                children: [
                  Expanded(
                    child: Hero(
                      tag: "The Button",
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Proceed",
                        ),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(15)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          backgroundColor: MaterialStateProperty.all(
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
      ),
    );
  }
}
