// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  File? _image;
  bool _loading = false;
  String _type = 'lost';

  String itemName = '';
  String description = '';
  String ownerName = '';
  String rollNumber = '';
  String contact = '';
  String email = '';

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      if (!await file.exists()) return null;
      final fileSize = await file.length();
      if (fileSize == 0 || fileSize > 32 * 1024 * 1024) return null;

      final id = Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('items/$id.jpg');
      final snapshot = await ref.putFile(file).timeout(
        Duration(minutes: 2),
        onTimeout: () {
          throw Exception("Upload timeout");
        },
      );

      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<String?> _uploadImageAlternative(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final id = Uuid().v4();
      final ref = FirebaseStorage.instance.ref('uploads/$id.jpg');
      final snapshot = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      }
      return null;
    } catch (e) {
      print("Alternative upload error: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      String? imageUrl;

      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
        if (imageUrl == null) {
          imageUrl = await _uploadImageAlternative(_image!);
        }

        if (imageUrl == null) {
          final proceed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Upload Failed'),
              content: Text('Image upload failed. Continue without image?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Continue')),
              ],
            ),
          );
          if (proceed != true) {
            setState(() => _loading = false);
            return;
          }
        }
      }

      final itemData = {
        'type': _type,
        'itemName': itemName,
        'description': description,
        'ownerName': ownerName,
        'rollNumber': rollNumber,
        'contact': contact,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      };
      if (imageUrl != null && imageUrl.isNotEmpty) {
        itemData['imageUrl'] = imageUrl;
      }

      await FirebaseFirestore.instance.collection('items').add(itemData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item added successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Lost/Found Item'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(labelText: 'Type'),
                  items: ['lost', 'found'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t.toUpperCase()));
                  }).toList(),
                  onChanged: (val) => setState(() => _type = val!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Item Name'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                  onSaved: (val) => itemName = val!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (val) => description = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Owner Name'),
                  onSaved: (val) => ownerName = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Roll Number'),
                  onSaved: (val) => rollNumber = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Contact'),
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => contact = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => email = val ?? '',
                ),
                SizedBox(height: 20),
                _image != null
                    ? Column(
                        children: [
                          Image.file(_image!, height: 150),
                          SizedBox(height: 10),
                          TextButton.icon(
                            icon: Icon(Icons.image),
                            label: Text('Change Image'),
                            onPressed: _pickImage,
                          ),
                        ],
                      )
                    : TextButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Select Image (optional)'),
                        onPressed: _pickImage,
                      ),
                SizedBox(height: 20),
                _loading
                    ? Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Uploading...'),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
