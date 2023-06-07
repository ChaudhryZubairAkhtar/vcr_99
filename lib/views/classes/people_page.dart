import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_classroom/utils/constants.dart';

class PeoplePage extends StatefulWidget {
  final String? classId;
  final String? role;

  const PeoplePage({super.key, this.classId, this.role});
  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  @override
  void initState() {
    // TODO: implement initState
    fetchJoinedClassUser();
  }

  @override
  Widget build(BuildContext context) {
    var userName = FirebaseAuth.instance.currentUser!.displayName;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder(
          stream: fetchJoinedClassUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docs = snapshot.data;
              return docs!.length == 0
                  ? Center(
                      child: Text(
                      'No students have joined this class',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ))
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Class Created at :',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      DateFormat("yyyy-MM-dd hh:mm:a")
                                          .format(
                                              docs![0]['createdAt'].toDate())
                                          .toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text(
                              'Teacher',
                              style: TextStyle(
                                  color: constant().primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                var data = docs![index];
                                return ListTile(
                                  title: Text(data['teacherName'].toString()),
                                  leading: CircleAvatar(
                                    child: Image(
                                        image: AssetImage(
                                            'assets/images/user.png')),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Students',
                                      style: TextStyle(
                                          color: constant().primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Text('${docs.length}',
                                      style: TextStyle(
                                          color: constant().primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ],
                              )),
                          ListView.builder(
                            itemCount: docs!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var data = docs[index];
                              return GestureDetector(
                                  onTap: () {
                                    // final route = MaterialPageRoute(
                                    //   builder: (context) => ClassDetails(
                                    //       classId: data['refClassId'],
                                    //       className: data['className'],
                                    //       role: data['role']),
                                    // );
                                    // Navigator.push(context, route);
                                  },
                                  child: ListTile(
                                    title: Text(data['displayName']),
                                    leading: CircleAvatar(
                                      child: Image(
                                          image: AssetImage(
                                              'assets/images/user.png')),
                                    ),
                                  ));
                            },
                          ),
                        ],
                      ),
                    );
            }
            return Text('No students have joined this class');
          },
        ),
      ),
    );
  }

  Stream<List> fetchJoinedClassUser() {
    return FirebaseFirestore.instance
        .collection('joinClassPeople')
        .doc(widget.classId)
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
