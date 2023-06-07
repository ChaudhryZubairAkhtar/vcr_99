import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:my_classroom/utils/constants.dart';

class CommentsPage extends StatefulWidget {
  final String? classId;
  final String? commentsId;

  const CommentsPage({super.key, this.classId, this.commentsId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  var displayName = FirebaseAuth.instance.currentUser!.displayName;
  TextEditingController assignmentCommentController = TextEditingController();
  TextEditingController lectureCommentController = TextEditingController();
  TextEditingController quizCommentController = TextEditingController();
  TextEditingController announcementCommentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    print('classid ${widget.classId}');
    print('commentsId ${widget.commentsId}');
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text(
          'Class comments',
          // style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('commentsRoom')
                    .doc(widget.classId)
                    .collection('type')
                    .doc(widget.commentsId)
                    .collection('comments')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    print('wqas :${snapshot.data!.docs}');
                    var comments = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        var comment = comments[index];
                        var time = DateFormat('hh:mm:a')
                            .format(comment['createdAt'].toDate());
                        print('comment $comment');
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              CircleAvatar(
                                child: Image(
                                    image:
                                        AssetImage('assets/images/user.png')),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${comment['name']}'),
                                  Text('${comment['message']}'),
                                ],
                              ),
                              Spacer(),
                              Text('$time'),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return SizedBox();
                }),
          )),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Color.fromARGB(255, 239, 239, 239),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: assignmentCommentController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Comment here...',
                        border: InputBorder.none),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                    onTap: () async {
                      if (assignmentCommentController.text.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('commentsRoom')
                            .doc(widget.classId)
                            .collection('type')
                            .doc(widget.commentsId)
                            .collection('comments')
                            .doc()
                            .set({
                          'message': assignmentCommentController.text,
                          'name': displayName,
                          'createdAt': DateTime.now()
                        });
                        assignmentCommentController.clear();
                      }
                    },
                    child: Icon(Icons.send)),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
