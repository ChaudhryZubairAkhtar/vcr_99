import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/classes/classwork_page.dart';
import 'package:my_classroom/views/classes/people_page.dart';
import 'package:my_classroom/views/classes/stream_page.dart';

class ClassDetails extends StatefulWidget {
  final String? classId;
  final String? className;
  final String? role;

  const ClassDetails({super.key, this.classId, this.className, this.role});

  @override
  State<ClassDetails> createState() => _ClassDetailsState();
}

class _ClassDetailsState extends State<ClassDetails> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print(widget.classId);
    List widgetList = [
      StreamPage(classId: widget.classId, role: widget.role),
      ClassWorkPage(classId: widget.classId, role: widget.role),
      PeoplePage(classId: widget.classId, role: widget.role)
    ];
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('${widget.className}'),
      ),
      body: widgetList[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Stream',
                backgroundColor: constant().primary),
            BottomNavigationBarItem(
                icon: Icon(Icons.class_outlined),
                label: 'Classwork',
                backgroundColor: constant().primary),
            BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'People',
                backgroundColor: constant().primary),
          ]),
    ));
  }
}
