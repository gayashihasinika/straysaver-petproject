import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ReportStrayDog extends StatefulWidget {
  @override
  _ReportStrayDogState createState() => _ReportStrayDogState();
}

class _ReportStrayDogState extends State<ReportStrayDog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedBehavior;
  List<XFile>? _images;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.locationWhenInUse.request();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationController.text = "${position.latitude}, ${position.longitude}";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error getting location: $e")));
    }
  }

  void _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final action = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 0), // Camera
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 1), // Gallery
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (action == null) return;

    if (action == 0) {
      // Open Camera
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _images = _images ?? [];
          _images!.add(photo);
        });
      }
    } else if (action == 1) {
      // Open Gallery
      final List<XFile>? pickedFiles = await picker.pickMultiImage();
      setState(() {
        _images = pickedFiles;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final String description = _descriptionController.text;
      final String location = _locationController.text;
      final String behavior = _selectedBehavior ?? 'Unknown';

      List<http.MultipartFile> imageFiles = [];
      if (_images != null && _images!.isNotEmpty) {
        for (var image in _images!) {
          imageFiles.add(await http.MultipartFile.fromPath('images', image.path));
        }
      }

      var request = http.MultipartRequest('POST', Uri.parse('https://yourapi.com/report'));
      request.fields['description'] = description;
      request.fields['location'] = location;
      request.fields['behavior'] = behavior;
      request.files.addAll(imageFiles);

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report submitted successfully!')));
          _formKey.currentState!.reset(); // Reset the form
          _images = null; // Clear selected images
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit report: ${response.statusCode}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Stray Dog'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/img.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Please provide detailed information about the stray dog.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16.0),
                Card(
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Dog's Description",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a description.' : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tip: Include details like size, color, breed (if known), visible injuries, and behavior (e.g., limping, scared).',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Card(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                        tooltip: 'Get Current Location',
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a location.' : null,
                  ),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: Text('Add Photos'),
                ),
                if (_images != null && _images!.isNotEmpty)
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _images!.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_images![index].path),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                SizedBox(height: 16.0),
                Text('Behavior'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Aggressive'),
                        leading: Radio<String>(
                          value: 'Aggressive',
                          groupValue: _selectedBehavior,
                          onChanged: (value) => setState(() => _selectedBehavior = value),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Friendly'),
                        leading: Radio<String>(
                          value: 'Friendly',
                          groupValue: _selectedBehavior,
                          onChanged: (value) => setState(() => _selectedBehavior = value),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Submit Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
