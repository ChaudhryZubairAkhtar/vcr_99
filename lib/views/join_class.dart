import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:my_classroom/services/firebase_api.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/utils/utils.dart';
import 'package:my_classroom/views/class_details.dart';
import 'package:my_classroom/views/homepage.dart';

class JoinClass extends StatefulWidget {
  const JoinClass({super.key});

  @override
  State<JoinClass> createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _classId = TextEditingController();
  List? userData;
  bool isLoading = false;
  bool isJoining = false;
  var currentUser;
  List allClass = [];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await getUserData();
      setState(() {
        isJoining = true;
      });
      bool isSuccess = false;
      String? teacherName;
      String? className;
      String? classDesc;
      DateTime? createdAt;

      for (var i = 0; i < userData!.length; i++) {
        if (_classId.text == userData![i]['refClassId']) {
          isSuccess = true;
          teacherName = userData![i]['name'];
          className = userData![i]['className'];
          classDesc = userData![i]['classDesc'];
          createdAt = userData![i]['createdAt'].toDate();
        }
      }
      if (isSuccess == true) {
        await FirebaseApi.joinClass(
                _classId.text, teacherName!, className!, classDesc!, createdAt!)
            .then((success) {
          print('middle $isSuccess');
          utils().customSnackbar(context, 'You joined $className Class');
          if (success) {
            final route = MaterialPageRoute(
              builder: (context) => HomePage(),
            );
            Navigator.push(context, route);
          }
        });
      } else {
        utils().customSnackbar(context, 'No class exist with this id');
        setState(() {
          isJoining = false;
        });
        return;
      }
      setState(() {
        isJoining = false;
      });
      _classId.text = '';
    }
  }

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _classId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('Join class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _classId,
                decoration: InputDecoration(
                    labelText: 'Class Id', border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a class id';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: isJoining == true
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: constant().colorWhite,
                        ),
                      )
                    : Text(
                        'Join class',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                style: ElevatedButton.styleFrom(primary: constant().primary),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getUserData() async {
    setState(() {
      isLoading = true;
    });

    List uniqueDocuments = [];
    uniqueDocuments = await FirebaseApi().fetchUserData() as List;
    setState(() {
      userData = uniqueDocuments;
      isLoading = false;
    });
  }
}
