import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/material.dart';

class LogFiles extends StatefulWidget {
  const LogFiles({Key? key}) : super(key: key);

  @override
  State<LogFiles> createState() => _State();
}

class _State extends State<LogFiles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log's"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await SharedPreferencesInstance.instance!
                  .setStringList("logfiles", []);
              setState(() {});
            },
          )
        ],
      ),
      body: ListView(
        children: SharedPreferencesInstance.getLogs
            .map<Widget>((e) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e.toString()),
                    ),
                    elevation: 10,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
