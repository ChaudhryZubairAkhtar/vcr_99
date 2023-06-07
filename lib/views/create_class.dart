import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:my_classroom/services/firebase_api.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:my_classroom/views/homepage.dart';

class CreateClass extends StatefulWidget {
  const CreateClass({super.key});

  @override
  State<CreateClass> createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      bool success = await FirebaseApi.createClass(
          _classNameController.text, _descriptionController.text);

      _classNameController.text = '';
      _descriptionController.text = '';
      setState(() {
        isLoading = false;
      });
      if (success) {
        final route = MaterialPageRoute(
          builder: (context) => HomePage(),
        );
        Navigator.push(context, route);
      }
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constant().primary,
        title: Text('Create class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _classNameController,
                decoration: InputDecoration(
                    labelText: 'Class Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a class name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                maxLines: 5,
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                child: isLoading == true
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: constant().colorWhite,
                        ),
                      )
                    : Text(
                        'Create class',
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
    ;
  }
}
