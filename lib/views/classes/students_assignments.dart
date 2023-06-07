import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/classes/pdf_vew.dart';

class CheckStudentAssignment extends StatefulWidget {
  final String? classId;
  const CheckStudentAssignment({super.key, this.classId});
  @override
  State<CheckStudentAssignment> createState() => _CheckStudentAssignmentState();
}

class _CheckStudentAssignmentState extends State<CheckStudentAssignment> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _commentController = [];

  @override
  void dispose() {
    for (final controller in _commentController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('Submitted Assignment'),
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('submittedAssignment')
                  .doc('${widget.classId}')
                  .collection('user')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }

                if (snapshot.hasData) {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: documents.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        var data = documents[index];
                        final controller = TextEditingController();
                        return Card(
                          margin: EdgeInsets.all(15),
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                      'Submitted by : ${data['displayName']}'),
                                  onTap: () {
                                    final route = MaterialPageRoute(
                                        builder: (context) => PdfViewerPage(
                                            pdfUrl: data['assignmentPdf']));
                                    Navigator.push(context, route);
                                  },
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: 'Give marks Out of 100',
                                    suffix: Text('/100'),
                                    labelStyle: TextStyle(
                                        fontSize: 16.0, color: Colors.grey),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: .0, horizontal: 12.0),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please give marks';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (controller.text.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection(
                                                'submittedAssignmentMarks')
                                            .doc(data['userId'])
                                            .set({
                                          'points': controller.text,
                                          'userId': data['userId'],
                                          'displayName': data['displayName']
                                        });

                                        controller.clear();
                                      }
                                    },
                                    child: Text('Submit'),
                                    style: ElevatedButton.styleFrom(
                                        primary: constant().colorBlack),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return Text('No data available');
              },
            )
          ],
        ),
      ),
    ));
  }
}
