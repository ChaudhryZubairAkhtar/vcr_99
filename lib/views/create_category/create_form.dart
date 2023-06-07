import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_classroom/services/firebase_api.dart';
import 'package:my_classroom/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:my_classroom/views/class_details.dart';
import 'package:my_classroom/views/homepage.dart';
import 'package:url_launcher/url_launcher.dart';

class MyForm extends StatefulWidget {
  final String? classId;

  const MyForm({
    super.key,
    this.classId,
  });
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  String? _selectedItem;
  String? _title;
  String? _description;
  File? _filePath;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  bool isLoading = false;
  String? url = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Create Form'), backgroundColor: constant().primary),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: constant().colorBlack),
                      borderRadius: BorderRadius.circular(5)),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedItem,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue;
                      });
                    },
                    underline: SizedBox(),
                    items: <String>[
                      'Assignment',
                      'Announcement',
                      'Quiz',
                      'Lecture',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text('Select an option'),
                  ),
                ),
                SizedBox(height: 10.0),
                _selectedItem == 'Quiz'
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              url =
                                  'https://docs.google.com/forms/u/0/d/1awFSLQ9jwwijQ6Uswi977f2CWzOTFnja-6pMtEsiZiQ/edit';
                            });
                            openBrowserUrl(
                              url: url!,
                              inApp: true,
                            );
                          },
                          child: Text('Set Quiz'),
                          style: ElevatedButton.styleFrom(
                            primary: constant().colorBlack,
                          ),
                        ))
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                _selectedItem == 'Quiz'
                    ? TextFormField(
                        controller: _urlController,
                        maxLines: 1,
                        decoration: InputDecoration(
                            labelText: 'Url link',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please tpye a url link';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                      )
                    : TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                      ),
                SizedBox(height: 16.0),
                _selectedItem == 'Assignment' || _selectedItem == 'Quiz'
                    ? GestureDetector(
                        onTap: showDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: constant().colorBlack),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Add due date'),
                              Icon(Icons.calendar_month)
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                _selectedItem == 'Assignment' || _selectedItem == 'Quiz'
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: constant().colorBlack),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${DateFormat("yyyy-MM-dd").format(_selectedDate)}'),
                            Text('${time.format(context)}'),
                          ],
                        ),
                      )
                    : SizedBox(),
                _selectedItem == 'Assignment' || _selectedItem == 'Quiz'
                    ? SizedBox(
                        height: 16,
                      )
                    : SizedBox(),
                GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      String? filePath = result.files.single.path;
                      // Use the file path as needed
                      setState(() {
                        _filePath = File(filePath!);
                        print('filePath: $filePath');
                      });
                    } else {
                      // User canceled the file picker
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: constant().colorBlack),
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Add Attachment'), Icon(Icons.add)],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                _filePath == null
                    ? SizedBox()
                    : Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: constant().colorBlack),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.file_copy),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                                    '${_filePath.toString().split('/').last}')),
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _filePath = null;
                                  });
                                },
                                child: Icon(Icons.cancel))
                          ],
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    child: isLoading == true
                        ? CircularProgressIndicator(
                            color: constant().primary,
                          )
                        : Text('Add'),
                    onPressed: () {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: constant().colorBlack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showDate() async {
    DateTime? newDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate!,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (newDate == null) return;
    setState(() {
      _selectedDate = newDate;
    });

    TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: time,
        builder: (context, child) => Theme(
            data: ThemeData().copyWith(
                colorScheme: ColorScheme.dark(primary: Colors.white),
                dialogBackgroundColor: Colors.black),
            child: child!));
    if (newTime == null) return;
    setState(() {
      time = newTime;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        bool isLoading = true;
      });
      String downloadUrl;
      String fileName = _filePath.toString().split('/').last;
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('files')
          .child(fileName);

      await storageRef.putFile(File(_filePath!.path));

      downloadUrl = await storageRef.getDownloadURL();

      bool success = await FirebaseApi.createAssignment(
          widget.classId,
          _titleController.text,
          _descriptionController.text,
          _selectedItem,
          DateFormat("yyyy-MM-dd").format(_selectedDate).toString(),
          time.format(context).toString(),
          downloadUrl,
          fileName,
          url);
      setState(() {
        bool isLoading = false;
      });
      _titleController.clear();
      _descriptionController.clear();
      final route = MaterialPageRoute(
        builder: (context) => HomePage(),
      );
      Navigator.push(context, route);
    }
  }

  Future openBrowserUrl({required String url, required bool inApp}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
