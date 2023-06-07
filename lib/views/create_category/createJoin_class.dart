import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/create_class.dart';
import 'package:my_classroom/views/join_class.dart';

class CreateJoinClass extends StatefulWidget {
  const CreateJoinClass({super.key});

  @override
  State<CreateJoinClass> createState() => _CreateJoinClassState();
}

class _CreateJoinClassState extends State<CreateJoinClass> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('Create or Join class'),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.24,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Create new class or join claas',
              style: TextStyle(
                color: constant().colorBlack,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    final route = MaterialPageRoute(
                      builder: (context) => CreateClass(),
                    );
                    Navigator.push(context, route);
                  },
                  child: Card(
                    color: constant().colorBlack,
                    child: Container(
                        height: 90,
                        width: 90,
                        child: Center(
                            child: Text(
                          'Create class',
                          style: TextStyle(
                              color: constant().colorWhite,
                              fontWeight: FontWeight.bold),
                        ))),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final route = MaterialPageRoute(
                      builder: (context) => JoinClass(),
                    );
                    Navigator.push(context, route);
                  },
                  child: Card(
                    color: constant().colorBlack,
                    child: Container(
                        height: 90,
                        width: 90,
                        child: Center(
                            child: Text('Join class',
                                style: TextStyle(
                                    color: constant().colorWhite,
                                    fontWeight: FontWeight.bold)))),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
