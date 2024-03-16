import 'dart:io';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatefulWidget {
  const PdfView({Key? key}) : super(key: key);

  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView>
    with SingleTickerProviderStateMixin<PdfView> {
  var files;

//Declare Globaly
  String? directory;
  List file = [];
  @override
  void initState() {
    // TODO: implement initState
    _listofFiles();
    super.initState();
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }

  // Make New Function
  void _listofFiles() async {
    directory = (await _getDownloadDirectory())!.path;
    setState(() {
      file = Directory("$directory/Ezhrm/Salary Slips")
          .listSync(); //use your folder name insted of resume.
    });
  }

  // Build Part
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Downloaded Salary Slip',
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
        ),
        //bottomNavigationBar: const CustomBottomNavigationBar(),
        body: file == null
            ? const CircularProgressIndicator()
            : Column(
                children: <Widget>[
                  // your Content if there
                  Expanded(
                    child: ListView.builder(
                        itemCount: file.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                                elevation: 5,
                                child: ListTile(
                                  title: Text(file[index].path.split('/').last),
                                  leading: const Icon(Icons.picture_as_pdf),
                                  trailing: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.blue,
                                  ),
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ViewPDF(
                                        pathPDF: file[index].path.toString(),
                                        mytitle: file[index]
                                            .path
                                            .split('/')
                                            .last
                                            .toString(),
                                      );
                                      //open viewPDF page on click
                                    }));
                                  },
                                )),
                          );
                        }),
                  )
                ],
              ));
  }
}

class ViewPDF extends StatelessWidget {
  final String? pathPDF;
  final String? mytitle;
  const ViewPDF({Key? key, @required this.pathPDF, @required this.mytitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //view PDF
      appBar: AppBar(
        title: Text(
          mytitle!,
          style: const TextStyle(
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
      ),

      body: SfPdfViewer.network(pathPDF!),
    );
  }
}
