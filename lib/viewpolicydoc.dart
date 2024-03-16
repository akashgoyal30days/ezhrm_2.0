import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class viewpolicydoc extends StatefulWidget {
  final filename;
  final filepath;
  final documentname;
  const viewpolicydoc(
      {Key? key,
      @required this.filepath,
      @required this.documentname,
      this.filename})
      : super(key: key);

  @override
  State<viewpolicydoc> createState() => _ViewdocPdfState();
}

class _ViewdocPdfState extends State<viewpolicydoc> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.filepath
                .toString()
                .substring(widget.filepath.toString().length - 1)
                .toString() ==
            'g'
        ? Scaffold(
            bottomNavigationBar: const bottombar_ios(),
            appBar: AppBar(
              title: Text(widget.filename.toString()),
              flexibleSpace: Container(
                decoration: BoxDecoration(
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
            body: ListView(
              children: [
                // Text(widget.filepath
                //     .toString()
                //     .substring(widget.filepath.toString().length - 1)
                //     .toString()),
                CachedNetworkImage(
                  placeholder: (context, url) => const LinearProgressIndicator(
                    color: Colors.blue,
                  ),
                  imageUrl: widget.filepath.toString(),
                  errorWidget: (context, url, error) => Column(
                    children: const [
                      Icon(
                        Icons.warning,
                        color: Colors.grey,
                        size: 50,
                      ),
                      Text("Image Not Available")
                    ],
                  ),
                )
              ],
            ))
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.filename.toString()),
            ),
            body: SfPdfViewer.network(widget.filepath.toString()));
  }
}
