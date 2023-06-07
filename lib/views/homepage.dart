import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:my_classroom/services/firebase_api.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/class_details.dart';
import 'package:my_classroom/views/create_category/createJoin_class.dart';
import 'package:my_classroom/views/create_class.dart';
import 'package:my_classroom/views/join_class.dart';
import 'package:my_classroom/views/signin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List? uniqueId;
  bool isCreated = false;
  bool isJoined = true;
  var currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid;
    fetchCreatedClass();
    fetchJoinedClass();
    // fetchUniqueId(currentUser);
  }

  List? userData;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('HomePage'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  final route = MaterialPageRoute(
                    builder: (context) => SigninPage(),
                  );
                  Navigator.push(context, route);
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.logout)))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Created Classes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            isCreated == true
                ? Center(
                    child: CircularProgressIndicator(
                      color: constant().primary,
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: fetchCreatedClass(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: documents.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final document = documents[index];
                              if (document['classId'] == currentUser) {
                                return GestureDetector(
                                  onTap: () {
                                    final route = MaterialPageRoute(
                                      builder: (context) => ClassDetails(
                                          classId: document['refClassId'],
                                          className: document['className'],
                                          role: document['role']),
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                'Role: ${document['role']}',
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
                                                'Classname: ${document['className']}',
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
                                                  'Class descrition: ${document['classDesc']}',
                                                  style: TextStyle(
                                                    color:
                                                        constant().colorWhite,
                                                  )),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            PopupMenuButton(
                                              itemBuilder: (context) {
                                                return [
                                                  PopupMenuItem(
                                                      value: 1,
                                                      onTap: () async {
                                                        await Clipboard.setData(
                                                                ClipboardData(
                                                                    text: document[
                                                                        'refClassId']))
                                                            .then((value) => ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Class id copied to clipboard"))));
                                                        // copied successfully
                                                      },
                                                      child:
                                                          Text('Get class id')),
                                                ];
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Joined Classes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // isJoined == true
            //     ? Center(
            //         child: CircularProgressIndicator(
            //           color: constant().primary,
            //         ),
            //       )
            //     :
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder(
                stream: fetchJoinedClass(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var docs = snapshot.data;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: docs!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var data = docs[index];
                          print('data:${data}');
                          if (data['classId'] == currentUser) {
                            return GestureDetector(
                              onTap: () {
                                final route = MaterialPageRoute(
                                  builder: (context) => ClassDetails(
                                      classId: data['refClassId'],
                                      className: data['className'],
                                      role: data['role']),
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            'Role: ${data['role']}',
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
                                            'Classname: ${data['className']}',
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
                                              'Class descrition: ${data['classDesc']}',
                                              style: TextStyle(
                                                color: constant().colorWhite,
                                              )),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }
                  return Text('No class created by this user');
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: constant().primary,
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => CreateJoinClass(),
            );
            Navigator.push(context, route);
          },
          child: Icon(
            Icons.add,
          )),
    ));
  }

  Stream<QuerySnapshot> fetchCreatedClass() {
    return FirebaseFirestore.instance.collection('class').snapshots();
  }

  // Stream<List> fetchStreamData() => FirebaseFirestore.instance
  //     .collection('class')
  //     .snapshots()
  //     .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  // Future<List<DocumentSnapshot>> fetchUniqueId(String currentUser) async {
  //   List<DocumentSnapshot> uniqueDocuments = [];
  //   QuerySnapshot querySnapshot =
  //       await FirebaseFirestore.instance.collection('class').get();
  //   querySnapshot.docs.forEach((documentSnapshot) {
  //     // Check if the document already exists in the list
  //     bool exists = uniqueDocuments.any((doc) => doc.id == documentSnapshot.id);
  //     if (!exists) {
  //       uniqueDocuments.add(documentSnapshot);
  //     }
  //   });
  //   setState(() {
  //     uniqueId = uniqueDocuments;
  //     isCreated = false;
  //     isJoined = false;
  //   });
  //   return uniqueDocuments;
  // }

  Stream<List> fetchJoinedClass() {
    return FirebaseFirestore.instance
        .collection('joinClassUsers')
        .doc('${currentUser}')
        .collection('data')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // getUserData() async {
  //   setState(() {
  //     isCreated = true;
  //   });

  //   List uniqueDocuments = [];
  //   uniqueDocuments = await FirebaseApi().fetchUserData() as List;
  //   setState(() {
  //     userData = uniqueDocuments;
  //     isCreated = false;
  //     print('userData:${userData}');
  //   });
  // }
}
