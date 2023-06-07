import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  final dynamic pdfUrl;
  const PdfViewerPage({super.key, this.pdfUrl});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool isLoading = true;
  var _localfile;
  @override
  void initState() {
    super.initState();
    loadPdf().then((value) {
      setState(() {
        _localfile = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pdf view'),
        ),
        body: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : Container(
                width: MediaQuery.of(context).size.width,
                child: PDFView(
                  fitPolicy: FitPolicy.BOTH,
                  nightMode: false,
                  autoSpacing: false,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  pageSnap: true,
                  fitEachPage: true,
                  filePath: _localfile!,
                  pageFling: false,
                  onError: (error) {
                    print(error.toString());
                  },
                ),
              ));
  }

  Future<String> loadPdf() async {
    var response = await http.get(Uri.parse(widget.pdfUrl));
    var dir = await getTemporaryDirectory();
    File file = new File(dir.path + '/data.pdf');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }
}
