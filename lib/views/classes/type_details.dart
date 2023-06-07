import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/classes/pdf_vew.dart';
import 'package:my_classroom/views/classes/students_assignments.dart';
import 'package:my_classroom/views/classes/students_quiz.dart';
import 'package:my_classroom/views/classes/submit_assignment.dart';
import 'package:my_classroom/views/classes/submit_quiz.dart';
import 'package:my_classroom/views/comments_page.dart';

class TypeDetails extends StatefulWidget {
  final String? classId;
  final String? role;
  final String? dueDate;
  final String? commentsId;
  final String? type;
  final String? title;
  final String? desc;
  final String? teacherFileUrl;
  final String? teacherFileName;
  final bool? isSubmittedAssignment;

  final bool? isSubisSubmittedQuiz;

  const TypeDetails(
      {super.key,
      this.classId,
      this.role,
      this.dueDate,
      this.commentsId,
      this.type,
      this.title,
      this.desc,
      this.teacherFileUrl,
      this.teacherFileName,
      this.isSubmittedAssignment,
      this.isSubisSubmittedQuiz});

  @override
  State<TypeDetails> createState() => _TypeDetailsState();
}

class _TypeDetailsState extends State<TypeDetails> {
  TextEditingController assignmentCommentController = TextEditingController();
  TextEditingController lectureCommentController = TextEditingController();
  TextEditingController quizCommentController = TextEditingController();
  TextEditingController announcementCommentController = TextEditingController();
  var currentUser;
  var assignmentMarks;
  var quizMarks;
  var studentAssignmentPdfUrl, studentAssignmentPdf;
  var studentQuizPdfUrl, studentQuizPdf;
  var yourWorkPdf;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid;
    widget.role == 'teacher' ? null : fetchStudentAssignmentPdf();
    widget.role == 'teacher' ? null : fetchStudentQuizPdf();

    widget.type == 'Announcement' || widget.type == 'Lecture'
        ? null
        : widget.type == 'Assignment'
            ? fetchAssignmentMarks()
            : fetchQuizMarks();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back)),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                          value: 1, onTap: () async {}, child: Text('.')),
                    ];
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.type == 'Announcement' || widget.type == 'Lecture'
                      ? SizedBox()
                      : Text('Due ${widget.dueDate}'),
                  widget.type == 'Announcement' || widget.type == 'Lecture'
                      ? SizedBox()
                      : SizedBox(
                          height: 10,
                        ),
                  Text(
                    '${widget.type}',
                    style: TextStyle(color: constant().primary, fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.role == 'teacher'
                      ? SizedBox()
                      : widget.type == 'Announcement' ||
                              widget.type == 'Lecture'
                          ? SizedBox()
                          : widget.type == 'Assignment'
                              ? assignmentMarks == null
                                  ? Text('Assignment not checked')
                                  : Text(
                                      ' ${assignmentMarks} points',
                                    )
                              : assignmentMarks == null
                                  ? Text('Quiz not checked')
                                  : Text(
                                      '${quizMarks} points',
                                    ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      final route = MaterialPageRoute(
                        builder: (context) => CommentsPage(
                            classId: widget.classId,
                            commentsId: widget.commentsId),
                      );
                      Navigator.push(context, route);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.message),
                        SizedBox(
                          width: 10,
                        ),
                        Text('View comments')
                      ],
                    ),
                  ),
                  Divider(
                    color: constant().primary,
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('${widget.title}'),
                  SizedBox(
                    height: 10,
                  ),
                  widget.type == 'Quiz' ? SizedBox() : Text('${widget.desc}'),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Attachment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      final route = MaterialPageRoute(
                          builder: (context) =>
                              PdfViewerPage(pdfUrl: widget.teacherFileUrl));
                      Navigator.push(context, route);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf),
                        SizedBox(
                          width: 10,
                        ),
                        Text('${widget.teacherFileName}'.split('/').last)
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: constant().colorBlack),
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(child: Text('Save file offline')),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  widget.role == 'teacher'
                      ? SizedBox()
                      : widget.type == 'Announcement' ||
                              widget.type == 'Lecture'
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Your work'),
                                widget.type == 'Assignment'
                                    ? assignmentMarks == null
                                        ? Text('Assignment not checked')
                                        : Text('${assignmentMarks}/100')
                                    : assignmentMarks == null
                                        ? Text('Quiz not checked')
                                        : Text(
                                            '${quizMarks}/100',
                                          ),
                              ],
                            ),
                  widget.role == 'teacher'
                      ? SizedBox()
                      : widget.type == 'Announcement' ||
                              widget.type == 'Lecture'
                          ? SizedBox()
                          : SizedBox(
                              height: 10,
                            ),
                  widget.role == 'teacher'
                      ? SizedBox()
                      : widget.type == 'Announcement' ||
                              widget.type == 'Lecture'
                          ? SizedBox()
                          : GestureDetector(
                              onTap: () async {
                                if (yourWorkPdf != null) {
                                  final route = MaterialPageRoute(
                                      builder: (context) =>
                                          PdfViewerPage(pdfUrl: yourWorkPdf));
                                  Navigator.push(context, route);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: constant().colorBlack),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    widget.type == 'Assignment'
                                        ? studentAssignmentPdf != null
                                            ? Text('${studentAssignmentPdf}')
                                            : SizedBox()
                                        : SizedBox(),
                                    widget.type == 'Quiz'
                                        ? studentQuizPdf != null
                                            ? Text('${studentQuizPdf}')
                                            : SizedBox()
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            ),
                  widget.type == 'Quiz' || widget.type == 'Assignment'
                      ? SizedBox(
                          height: 30,
                        )
                      : SizedBox(),
                  widget.role == 'teacher'
                      ? widget.type == 'Quiz'
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () {
                                  final route = MaterialPageRoute(
                                      builder: (context) => CheckStudentQuiz(
                                          classId: widget.classId));
                                  Navigator.push(context, route);
                                },
                                child: Text('Check student quiz'),
                                style: ElevatedButton.styleFrom(
                                    primary: constant().colorBlack),
                              ),
                            )
                          : widget.type == 'Assignment'
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final route = MaterialPageRoute(
                                          builder: (context) =>
                                              CheckStudentAssignment(
                                                  classId: widget.classId));
                                      Navigator.push(context, route);
                                    },
                                    child: Text('Check student assignment'),
                                    style: ElevatedButton.styleFrom(
                                        primary: constant().colorBlack),
                                  ),
                                )
                              : SizedBox()
                      : SizedBox(),
                  widget.role == 'teacher'
                      ? SizedBox()
                      : widget.type == 'Assignment'
                          ? widget.isSubmittedAssignment == true
                              ? Text(
                                  'You submitted your assignment',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final route = MaterialPageRoute(
                                          builder: (context) =>
                                              SubmitAssignmentScreen(
                                                  assignmentId: widget.classId,
                                                  dueDate:
                                                      '${widget.dueDate}'));
                                      Navigator.push(context, route);
                                    },
                                    child: Text('Submit Assignment'),
                                    style: ElevatedButton.styleFrom(
                                        primary: constant().colorBlack),
                                  ),
                                )
                          : SizedBox(),
                  widget.role == 'teacher'
                      ? SizedBox()
                      : widget.type == 'Quiz'
                          ? widget.isSubisSubmittedQuiz == true
                              ? Text(
                                  'You submitted your quiz',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final route = MaterialPageRoute(
                                          builder: (context) =>
                                              SubmitQuizScreen(
                                                  assignmentId: widget.classId,
                                                  dueDate:
                                                      '${widget.dueDate}'));
                                      Navigator.push(context, route);
                                    },
                                    child: Text('Submit Quiz'),
                                    style: ElevatedButton.styleFrom(
                                        primary: constant().colorBlack),
                                  ),
                                )
                          : SizedBox(),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  fetchStudentAssignmentPdf() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('submittedAssignment')
        .doc(widget.classId)
        .collection('user')
        .doc(currentUser)
        .get();
    var data = querySnapshot.data();
    setState(() {
      studentAssignmentPdf = data == null
          ? 'You did not submitted your assignment yet'
          : data['studentFileName'];
      studentAssignmentPdfUrl = data == null ? null : data['assignmentPdf'];
      yourWorkPdf = studentAssignmentPdfUrl;
    });
  }

  fetchStudentQuizPdf() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('submittedQuiz')
        .doc(widget.classId)
        .collection('user')
        .doc(currentUser)
        .get();
    var data = querySnapshot.data();
    print(data);
    setState(() {
      studentQuizPdf = data == null
          ? 'You did not submitted your quiz yet'
          : data['studentQuizFileName'];
      studentQuizPdfUrl = data == null ? null : data['quizPdf'];
      yourWorkPdf = studentQuizPdfUrl;
    });
    print('class: ${data}');
  }

  fetchAssignmentMarks() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('submittedAssignmentMarks')
        .get();
    List data = [];
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((document) {
        data.add(document.data());
      });
      if (data[0]['userId'] == currentUser) {
        setState(() {
          assignmentMarks = data[0]['points'];
        });
      }
    }
  }

  fetchQuizMarks() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('submittedQuizMarks').get();
    List data = [];
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((document) {
        data.add(document.data());
      });
      if (data[0]['userId'] == currentUser) {
        setState(() {
          quizMarks = data[0]['points'];
        });
      }
    }
  }
}
