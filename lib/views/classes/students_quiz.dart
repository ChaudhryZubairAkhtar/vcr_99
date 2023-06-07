import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/classes/pdf_vew.dart';

class CheckStudentQuiz extends StatefulWidget {
  final String? classId;
  const CheckStudentQuiz({super.key, this.classId});
  @override
  State<CheckStudentQuiz> createState() => _CheckStudentQuiz();
}

class _CheckStudentQuiz extends State<CheckStudentQuiz> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('Submitted Quiz'),
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('submittedQuiz')
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
                                    print('quiz click');
                                    final route = MaterialPageRoute(
                                        builder: (context) => PdfViewerPage(
                                            pdfUrl: data['quizPdf']));
                                    Navigator.push(context, route);
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                data['message'] == null
                                    ? SizedBox()
                                    : SizedBox(
                                        height: 10,
                                      ),
                                data['message'] == null
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          Text('Student message'),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text('${data['message']}',
                                              style: TextStyle(),
                                              textAlign: TextAlign.center),
                                        ],
                                      ),
                                data['message'] == null
                                    ? SizedBox()
                                    : SizedBox(
                                        height: 10,
                                      ),
                                TextFormField(
                                  controller: _commentController,
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
                                      if (_commentController.text.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('submittedQuizMarks')
                                            .doc(data['userId'])
                                            .set({
                                          'points': _commentController.text,
                                          'userId': data['userId'],
                                          'displayName': data['displayName']
                                        });

                                        _commentController.clear();
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
