import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:my_classroom/views/homepage.dart';

class SubmitQuizScreen extends StatefulWidget {
  final String? dueDate;
  final String? assignmentId;

  SubmitQuizScreen({Key? key, this.dueDate, this.assignmentId})
      : super(key: key);

  @override
  State<SubmitQuizScreen> createState() => _SubmitQuizScreenState();
}

class _SubmitQuizScreenState extends State<SubmitQuizScreen> {
  File? _filePath;
  TextEditingController _messagaController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('Submit quiz'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Submit your quiz',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            SizedBox(
              height: 10,
            ),
            Text('Due date: ${widget.dueDate}'),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();

                if (result != null) {
                  String? filePath = result.files.single.path;
                  // Use the file path as needed
                  setState(() {
                    _filePath = File(filePath!);
                    print('filePath: $filePath');
                  });
                } else {
                  // User canceled the file picker
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: constant().colorBlack),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Upload Quiz'), Icon(Icons.add)],
                ),
              ),
            ),
            _filePath == null
                ? SizedBox()
                : SizedBox(
                    height: 16,
                  ),
            _filePath == null
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: constant().colorBlack),
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.file_copy),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Text(
                                '${_filePath.toString().split('/').last}')),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _filePath = null;
                              });
                            },
                            child: Icon(Icons.cancel))
                      ],
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _messagaController,
              // keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16.0, color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Type a message...',
                labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                filled: true,
                // fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(vertical: .0, horizontal: 12.0),
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      if (_filePath == null) {
                        return AlertDialog(
                          content: Container(
                            height: 60,
                            child: Column(
                              children: [
                                Icon(Icons.info),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Please upload quiz'),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text(
                              'Are you sure you want to submit your quiz?'),
                          actions: <Widget>[
                            ElevatedButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop(
                                    false); // Return false when "No" is pressed
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: constant().colorBlack),
                            ),
                            ElevatedButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.of(context).pop(
                                    true); // Return true when "Yes" is pressed
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: constant().colorBlack),
                            ),
                          ],
                        );
                      }
                    },
                  ).then((value) async {
                    if (value != null && value) {
                      String fileName = _filePath.toString().split('/').last;
                      firebase_storage.Reference storageRef = firebase_storage
                          .FirebaseStorage.instance
                          .ref()
                          .child('submittedAssignment')
                          .child(fileName);

                      await storageRef.putFile(File(_filePath!.path));

                      var downloadUrl = await storageRef.getDownloadURL();

                      var currentUser = FirebaseAuth.instance.currentUser!.uid;
                      var username =
                          FirebaseAuth.instance.currentUser!.displayName;
                      await FirebaseFirestore.instance
                          .collection('submittedQuiz')
                          .doc(widget.assignmentId)
                          .collection('user')
                          .doc(currentUser)
                          .set({
                        'userId': currentUser,
                        'displayName': username,
                        'message': _messagaController.text,
                        'studentQuizFileName': fileName,
                        'quizPdf': downloadUrl
                      });
                      await ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Quiz submitted successfully')));
                      print('User pressed Yes');
                      final route = MaterialPageRoute(
                        builder: (context) => HomePage(),
                      );
                      Navigator.push(context, route);
                    } else {
                      print('User pressed No or dialog dismissed');
                    }
                  });
                },
                child: Text('Submit Quiz'),
                style: ElevatedButton.styleFrom(primary: constant().colorBlack),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
