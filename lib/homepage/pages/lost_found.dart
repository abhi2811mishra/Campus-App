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
      final id = Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('item_images/$id.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
    }

    try {
      await FirebaseFirestore.instance.collection('items').add({
        'type': _type,
        'itemName': itemName,
        'description': description,
        'ownerName': ownerName,
        'rollNumber': rollNumber,
        'contact': contact,
        'email': email,
        'imageUrl': imageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item added.')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
                  onSaved: (val) => description = val!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Owner Name'),
                  onSaved: (val) => ownerName = val!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Roll Number'),
                  onSaved: (val) => rollNumber = val!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Contact'),
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => contact = val!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => email = val!,
                ),
                SizedBox(height: 20),
                _image != null
                    ? Image.file(_image!, height: 150)
                    : TextButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Select Image (optional)'),
                        onPressed: _pickImage,
                      ),
                SizedBox(height: 20),
                _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
