import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/classes/students_assignments.dart';
import 'package:my_classroom/views/classes/students_quiz.dart';
import 'package:my_classroom/views/classes/submit_assignment.dart';
import 'package:my_classroom/views/classes/submit_quiz.dart';
import 'package:my_classroom/views/classes/type_details.dart';
import 'package:my_classroom/views/create_category/create_form.dart';

class StreamPage extends StatefulWidget {
  final String? classId;
  final String? role;
  const StreamPage({super.key, this.classId, this.role});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  var loggedUserEmail = FirebaseAuth.instance.currentUser!.email;
  bool isSubmittedAssignment = false;
  bool isSubmittedQuiz = false;
  bool isLoading = true;
  TextEditingController assignmentCommentController = TextEditingController();
  TextEditingController lectureCommentController = TextEditingController();
  TextEditingController quizCommentController = TextEditingController();
  TextEditingController announcementCommentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchAllTypes();
    fetchSubmittedAssignment();
    fetchSubmittedQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body:
          //  isLoading == true
          //     ? Center(child: Center(child: Text('Loading...')))
          //     :
          Column(
        children: [
          Expanded(
            // height: MediaQuery.of(context).size.height * 0.8,
            child: StreamBuilder<QuerySnapshot>(
              stream: fetchAllTypes(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: documents.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      if (document['mainId'] == widget.classId) {
                        if (document['type'] == 'Assignment') {
                          return GestureDetector(
                            onTap: () {
                              final route = MaterialPageRoute(
                                builder: (context) => TypeDetails(
                                    commentsId: document['refMainId'],
                                    classId: widget.classId,
                                    role: widget.role,
                                    dueDate:
                                        '${document['date']}, ${document['time']}',
                                    type: document['type'],
                                    title: document['mainTitle'],
                                    desc: document['mainDesc'],
                                    teacherFileUrl: document['fileUrl'],
                                    teacherFileName: document['teacherFileName']
                                        .toString()
                                        .split('/')
                                        .last,
                                    isSubmittedAssignment:
                                        isSubmittedAssignment),
                              );
                              Navigator.push(context, route);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: constant().primary,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      'New Assignment: ${document['type']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Text(
                                      'Title: ${document['mainTitle']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Text(
                                      'Description: ${document['mainDesc']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Container(
                                  //   child: Text(
                                  //     'Due date:  ${document['date']}  ${document['time']}',
                                  //     style: TextStyle(
                                  //       color: constant().colorWhite,
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     GestureDetector(
                                  //         onTap: () async {
                                  //           await Clipboard.setData(
                                  //                   ClipboardData(
                                  //                       text: document[
                                  //                           'fileUrl']))
                                  //               .then((value) => ScaffoldMessenger
                                  //                       .of(context)
                                  //                   .showSnackBar(SnackBar(
                                  //                       content: Text(
                                  //                           "Url copied to clipboard"))));
                                  //           // copied successfully
                                  //         },
                                  //         child: Icon(Icons.copy)),
                                  //     SizedBox(
                                  //       width: 10,
                                  //     ),
                                  //     Text(
                                  //       'File Copy Url',
                                  //     )
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Text(
                                  //         'fileUrl: ${document['fileUrl']}',
                                  //         style: TextStyle(
                                  //           color: constant().colorWhite,
                                  //         ),
                                  //         overflow: TextOverflow.ellipsis,
                                  //         softWrap: false,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),

                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (document['type'] == 'Announcement') {
                          return GestureDetector(
                            onTap: () {
                              final route = MaterialPageRoute(
                                builder: (context) => TypeDetails(
                                    role: widget.role,
                                    // dueDate:
                                    //     '${document['date']}, ${document['time']}',
                                    commentsId: document['refMainId'],
                                    classId: widget.classId,
                                    type: document['type'],
                                    title: document['mainTitle'],
                                    desc: document['mainDesc'],
                                    teacherFileUrl: document['fileUrl'],
                                    teacherFileName: document['teacherFileName']
                                        .toString()
                                        .split('/')
                                        .last),
                              );
                              Navigator.push(context, route);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: constant().primary,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      'New Announcement: ${document['type']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Text(
                                      'Title: ${document['mainTitle']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Text(
                                      'Description: ${document['mainDesc']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     GestureDetector(
                                  //         onTap: () async {
                                  //           await Clipboard.setData(
                                  //                   ClipboardData(
                                  //                       text: document[
                                  //                           'fileUrl']))
                                  //               .then((value) => ScaffoldMessenger
                                  //                       .of(context)
                                  //                   .showSnackBar(SnackBar(
                                  //                       content: Text(
                                  //                           "Url copied to clipboard"))));
                                  //           // copied successfully
                                  //         },
                                  //         child: Icon(Icons.copy)),
                                  //     SizedBox(
                                  //       width: 10,
                                  //     ),
                                  //     Text(
                                  //       'File Copy Url',
                                  //     )
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Text(
                                  //         'fileUrl: ${document['fileUrl']}',
                                  //         style: TextStyle(
                                  //           color: constant().colorWhite,
                                  //         ),
                                  //         overflow: TextOverflow.ellipsis,
                                  //         softWrap: false,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                ],
                              ),
                            ),
                          );
                        } else if (document['type'] == 'Quiz') {
                          return GestureDetector(
                            onTap: () {
                              final route = MaterialPageRoute(
                                builder: (context) => TypeDetails(
                                    commentsId: document['refMainId'],
                                    classId: widget.classId,
                                    role: widget.role,
                                    dueDate:
                                        '${document['date']}, ${document['time']}',
                                    type: document['type'],
                                    title: document['mainTitle'],
                                    teacherFileUrl: document['fileUrl'],
                                    teacherFileName: document['teacherFileName']
                                        .toString()
                                        .split('/')
                                        .last,
                                    isSubisSubmittedQuiz: isSubmittedQuiz),
                              );
                              Navigator.push(context, route);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: constant().primary,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      'New Quiz: ${document['type']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Title: ${document['mainTitle']}',
                                    style: TextStyle(
                                      color: constant().colorWhite,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     GestureDetector(
                                  //         onTap: () async {
                                  //           await Clipboard.setData(
                                  //                   ClipboardData(
                                  //                       text: document[
                                  //                           'mainLink']))
                                  //               .then((value) => ScaffoldMessenger
                                  //                       .of(context)
                                  //                   .showSnackBar(SnackBar(
                                  //                       content: Text(
                                  //                           "Url copied to clipboard"))));
                                  //           // copied successfully
                                  //         },
                                  //         child: Icon(Icons.copy)),
                                  //     SizedBox(
                                  //       width: 10,
                                  //     ),
                                  //     Text(
                                  //       'Copy Url',
                                  //     )
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Text(
                                  //         'Url: ${document['mainLink']}',
                                  //         style: TextStyle(
                                  //           color: constant().colorWhite,
                                  //         ),
                                  //         overflow: TextOverflow.ellipsis,
                                  //         softWrap: false,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     GestureDetector(
                                  //         onTap: () async {
                                  //           await Clipboard.setData(
                                  //                   ClipboardData(
                                  //                       text: document[
                                  //                           'fileUrl']))
                                  //               .then((value) => ScaffoldMessenger
                                  //                       .of(context)
                                  //                   .showSnackBar(SnackBar(
                                  //                       content: Text(
                                  //                           "Url copied to clipboard"))));
                                  //           // copied successfully
                                  //         },
                                  //         child: Icon(Icons.copy)),
                                  //     SizedBox(
                                  //       width: 10,
                                  //     ),
                                  //     Text(
                                  //       'File Copy Url',
                                  //     )
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Text(
                                  //         'fileUrl: ${document['fileUrl']}',
                                  //         style: TextStyle(
                                  //           color: constant().colorWhite,
                                  //         ),
                                  //         overflow: TextOverflow.ellipsis,
                                  //         softWrap: false,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  // widget.role == 'teacher'
                                  //     ? SizedBox()
                                  //     : isSubmittedQuiz == true
                                  //         ? Text(
                                  //             'You submitted your quiz',
                                  //             style: TextStyle(
                                  //                 fontSize: 16,
                                  //                 fontWeight: FontWeight.bold),
                                  //           )
                                  //         : Container(
                                  //             width: MediaQuery.of(context)
                                  //                 .size
                                  //                 .width,
                                  //             child: ElevatedButton(
                                  //               onPressed: () {
                                  //                 final route = MaterialPageRoute(
                                  //                     builder: (context) =>
                                  //                         SubmitQuizScreen(
                                  //                             assignmentId:
                                  //                                 widget
                                  //                                     .classId,
                                  //                             dueDate:
                                  //                                 '${document['date']}  ${document['time']}'));
                                  //                 Navigator.push(
                                  //                     context, route);
                                  //               },
                                  //               child: Text('Submit Quiz'),
                                  //               style: ElevatedButton.styleFrom(
                                  //                   primary:
                                  //                       constant().colorBlack),
                                  //             ),
                                  //           ),
                                ],
                              ),
                            ),
                          );
                        } else if (document['type'] == 'Lecture') {
                          return GestureDetector(
                            onTap: () {
                              final route = MaterialPageRoute(
                                builder: (context) => TypeDetails(
                                    role: widget.role,
                                    // dueDate:
                                    //     '${document['date']}, ${document['time']}',
                                    commentsId: document['refMainId'],
                                    classId: widget.classId,
                                    type: document['type'],
                                    title: document['mainTitle'],
                                    desc: document['mainDesc'],
                                    teacherFileUrl: document['fileUrl'],
                                    teacherFileName: document['teacherFileName']
                                        .toString()
                                        .split('/')
                                        .last),
                              );
                              Navigator.push(context, route);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: constant().primary,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      'New Lecture: ${document['type']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Text(
                                      'Title: ${document['mainTitle']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Text(
                                      'Description: ${document['mainDesc']}',
                                      style: TextStyle(
                                        color: constant().colorWhite,
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     GestureDetector(
                                  //         onTap: () async {
                                  //           await Clipboard.setData(
                                  //                   ClipboardData(
                                  //                       text: document[
                                  //                           'fileUrl']))
                                  //               .then((value) => ScaffoldMessenger
                                  //                       .of(context)
                                  //                   .showSnackBar(SnackBar(
                                  //                       content: Text(
                                  //                           "Url copied to clipboard"))));
                                  //           // copied successfully
                                  //         },
                                  //         child: Icon(Icons.copy)),
                                  //     SizedBox(
                                  //       width: 10,
                                  //     ),
                                  //     Text(
                                  //       'File Copy Url',
                                  //     )
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 5,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Text(
                                  //         'fileUrl: ${document['fileUrl']}',
                                  //         style: TextStyle(
                                  //           color: constant().colorWhite,
                                  //         ),
                                  //         overflow: TextOverflow.ellipsis,
                                  //         softWrap: false,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        return SizedBox();
                      }
                    },
                  );
                }
                return Text('No Classes found');
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.role == 'teacher'
          ? FloatingActionButton(
              backgroundColor: constant().primary,
              onPressed: () {
                final route = MaterialPageRoute(
                  builder: (context) => MyForm(classId: widget.classId),
                );
                Navigator.push(context, route);
              },
              child: Icon(
                Icons.add,
              ))
          : SizedBox(),
    ));
  }

  Stream<QuerySnapshot> fetchAllTypes() {
    return FirebaseFirestore.instance.collection('allType').snapshots();
  }

  void fetchSubmittedAssignment() async {
    var currentUser = FirebaseAuth.instance.currentUser!.uid;
    var refAssignment = await FirebaseFirestore.instance
        .collection('submittedAssignment')
        .doc(widget.classId)
        .collection('user')
        .doc(currentUser)
        .get();

    if (refAssignment.exists) {
      if (refAssignment['userId'] == currentUser) {
        if (mounted) {
          setState(() {
            isSubmittedAssignment = true;
            isLoading = false;
          });
        }
      }
    }
  }

  void fetchSubmittedQuiz() async {
    var currentUser = FirebaseAuth.instance.currentUser!.uid;
    var refAssignment = await FirebaseFirestore.instance
        .collection('submittedQuiz')
        .doc(widget.classId)
        .collection('user')
        .doc(currentUser)
        .get();

    if (refAssignment.exists) {
      if (refAssignment['userId'] == currentUser) {
        setState(() {
          isSubmittedQuiz = true;
          isLoading = false;
        });
      }
    }
  }
}
