import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  static Future createClass(String className, String classDesc) async {
    var currentUser = await FirebaseAuth.instance.currentUser!.uid;
    var currentUserName = await FirebaseAuth.instance.currentUser!.displayName;

    final refClass = FirebaseFirestore.instance.collection('class').doc();

    final json = {
      'name': currentUserName,
      'classId': currentUser,
      'refClassId': refClass.id,
      'className': className,
      'classDesc': classDesc,
      'role': 'teacher',
      'createdAt': DateTime.now()
    };
    await refClass.set(json);
    return true;
  }

  static Future joinClass(String refClassId, String teacherName,
      String className, String classDesc, DateTime createdAt) async {
    var currentUser = await FirebaseAuth.instance.currentUser!;
    final refClass = FirebaseFirestore.instance
        .collection('joinClassUsers')
        .doc('${currentUser.uid}')
        .collection('data')
        .doc(refClassId);
    final json = {
      'classId': currentUser.uid,
      'refClassId': refClass.id,
      'teacherName': teacherName,
      'className': className,
      'classDesc': classDesc,
      'email': currentUser.displayName,
      'role': 'student',
      'createdAt': createdAt
    };
    await refClass.set(json);

    final refClassUser = FirebaseFirestore.instance
        .collection('joinClassPeople')
        .doc(refClassId)
        .collection('users')
        .doc();
    final jsonUser = {
      'classId': currentUser.uid,
      'refClassId': refClass.id,
      'teacherName': teacherName,
      'displayName': currentUser.displayName,
      'role': 'student',
      'createdAt': createdAt
    };
    await refClassUser.set(jsonUser);

    return true;
  }

  Future<List> fetchUserData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('class').get();
    List data = [];
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((document) {
        data.add(document.data());
      });
    }
    print('data : $data');
    return data;
  }

  static Future createAssignment(
      String? classId,
      String assignmentTitle,
      String assignmentDesc,
      String? type,
      String date,
      String time,
      String path,
      String? fileName,
      String? url) async {
    final mainRefClass = FirebaseFirestore.instance.collection('allType').doc();
    if (type == 'Assignment') {
      var currentUser = await FirebaseAuth.instance.currentUser!.uid;
      final refClass = FirebaseFirestore.instance
          .collection('assignmentAndQuiz')
          .doc(classId);

      final json = {
        'assignmentAndQuizId': classId,
        'assignmentAndQuizRefId': refClass.id,
        'assignmentAndQuizTitle': assignmentTitle,
        'assignmentAndQuizDesc': assignmentDesc,
        'type': type,
        'date': date,
        'time': time.toString(),
        'fileUrl': path,
        'teacherFileName': fileName
      };
      await refClass.set(json);

      final json1 = {
        'mainId': classId,
        'refMainId': refClass.id,
        'mainTitle': assignmentTitle,
        'mainDesc': assignmentDesc,
        'type': type,
        'date': date,
        'time': time.toString(),
        'fileUrl': path,
        'teacherFileName': fileName
      };
      await mainRefClass.set(json1);
      return true;
    } else if (type == 'Announcement') {
      var currentUser = await FirebaseAuth.instance.currentUser!.uid;
      final refClass =
          FirebaseFirestore.instance.collection('announcement').doc();

      final json = {
        'announcementId': classId,
        'refAnnouncementId': refClass.id,
        'announcementTitle': assignmentTitle,
        'announcementDesc': assignmentDesc,
        'type': type,
        // 'date': date,
        // 'time': time.toString()
        'fileUrl': path, 'teacherFileName': fileName
      };
      await refClass.set(json);
      final json1 = {
        'mainId': classId,
        'refMainId': refClass.id,
        'mainTitle': assignmentTitle,
        'mainDesc': assignmentDesc,
        'type': type,
        // 'date': date,
        // 'time': time.toString(),
        'fileUrl': path, 'teacherFileName': fileName
      };
      await mainRefClass.set(json1);
      return true;
    } else if (type == 'Quiz') {
      var currentUser = await FirebaseAuth.instance.currentUser!.uid;
      final refClass =
          FirebaseFirestore.instance.collection('assignmentAndQuiz').doc();

      final json = {
        'assignmentAndQuizId': classId,
        'assignmentAndQuizRefId': refClass.id,
        'assignmentAndQuizTitle': assignmentTitle,
        'quizLink': url,
        'type': type,
        'date': date,
        'time': time.toString(),
        'fileUrl': path,
        'teacherFileName': fileName
      };

      final json1 = {
        'mainId': classId,
        'refMainId': refClass.id,
        'mainTitle': assignmentTitle,
        'mainLink': url,
        'type': type,
        'date': date,
        'time': time.toString(),
        'fileUrl': path,
        'teacherFileName': fileName
      };
      await refClass.set(json);
      await mainRefClass.set(json1);
      return true;
    } else if (type == 'Lecture') {
      var currentUser = await FirebaseAuth.instance.currentUser!.uid;
      final refClass = FirebaseFirestore.instance.collection('lecture').doc();

      final json = {
        'lectureId': classId,
        'reflectureId': refClass.id,
        'lectureTitle': assignmentTitle,
        'lectureDesc': assignmentDesc,
        'type': type,
        // 'date': date,
        // 'time': time.toString()
        'fileUrl': path, 'teacherFileName': fileName
      };
      await refClass.set(json);
      final json1 = {
        'mainId': classId,
        'refMainId': refClass.id,
        'mainTitle': assignmentTitle,
        'mainDesc': assignmentDesc,
        'type': type,
        // 'date': date,
        // 'time': time.toString(),
        'fileUrl': path, 'teacherFileName': fileName
      };
      await mainRefClass.set(json1);
      return true;
    }
  }
}
