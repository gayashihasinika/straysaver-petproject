import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LostDogReport extends StatefulWidget {
  @override
  _LostDogReportState createState() => _LostDogReportState();
}

class _LostDogReportState extends State<LostDogReport> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dogNameController = TextEditingController();
  final TextEditingController _dogAgeController = TextEditingController();
  final TextEditingController _dogDescriptionController = TextEditingController();
  final TextEditingController _lastSeenDateController = TextEditingController();
  final TextEditingController _lastSeenTimeController = TextEditingController();
  String _lastSeenLocation = '';
  String? _status = "Lost";
  File? _image;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lastSeenLocation = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No image selected')));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _lastSeenDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _lastSeenTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report Submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Dog Report'),
      ),
      body: Container(
        color: Colors.orangeAccent[100], // Set your background color here
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _dogNameController,
                            decoration: InputDecoration(labelText: 'Dog Name'),
                            validator: (value) => value!.isEmpty ? 'Please enter the dog\'s name.' : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _dogAgeController,
                            decoration: InputDecoration(labelText: 'Dog Age'),
                            validator: (value) => value!.isEmpty ? 'Please enter the dog\'s age.' : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _dogDescriptionController,
                            decoration: InputDecoration(labelText: 'Dog Description'),
                            validator: (value) => value!.isEmpty ? 'Please enter a description.' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: TextEditingController(text: _lastSeenLocation),
                            decoration: InputDecoration(labelText: 'Last Seen Location'),
                            onChanged: (value) {
                              setState(() {
                                _lastSeenLocation = value;
                              });
                            },
                            validator: (value) => value!.isEmpty ? 'Please enter a location.' : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _lastSeenDateController,
                            decoration: InputDecoration(labelText: 'Last Seen Date'),
                            readOnly: true,
                            onTap: _selectDate,
                            validator: (value) => value!.isEmpty ? 'Please select a date.' : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _lastSeenTimeController,
                            decoration: InputDecoration(labelText: 'Last Seen Time'),
                            readOnly: true,
                            onTap: _selectTime,
                            validator: (value) => value!.isEmpty ? 'Please select a time.' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: InputDecoration(labelText: 'Status'),
                            onChanged: (String? newValue) {
                              setState(() {
                                _status = newValue;
                              });
                            },
                            items: <String>['Lost', 'Found', 'Reunited']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: Text('Upload Photo'),
                          ),
                          if (_image != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Image.file(
                                _image!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      child: Text('Submit Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
