// ignore_for_file: depend_on_referenced_packages

import 'dart:io'; // For File class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key}); // Added const constructor

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker(); // Use _picker for consistency

  File? _image;
  bool _loading = false;
  String _type = 'lost'; // Default type
  String _submitButtonText = 'Submit Item'; // For dynamic button text

  // Form field variables
  String itemName = '';
  String description = '';
  String ownerName = '';
  String rollNumber = '';
  String contact = '';
  String email = '';

  // Helper for consistent SnackBar messages
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Image picking logic
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // Image upload to Firebase Storage
  Future<String?> _uploadImage(File file) async {
    try {
      if (!await file.exists()) {
        _showSnackBar('Selected image file does not exist.', backgroundColor: Colors.orange);
        return null;
      }
      final fileSize = await file.length();
      if (fileSize == 0) {
        _showSnackBar('Selected image file is empty.', backgroundColor: Colors.orange);
        return null;
      }
      if (fileSize > 10 * 1024 * 1024) { // Limit to 10MB to prevent very large uploads
        _showSnackBar('Image size exceeds 10MB limit. Please choose a smaller image.', backgroundColor: Colors.orange);
        return null;
      }

      final id = const Uuid().v4(); // Generate unique ID for image
      final ref = FirebaseStorage.instance.ref().child('lost_found_items/$id.jpg'); // Specific folder
      final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));

      // Listen for state changes to update progress (optional but good for large files)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          _submitButtonText = 'Uploading: ${(progress * 100).toStringAsFixed(0)}%';
        });
      });

      final snapshot = await uploadTask.whenComplete(() => {});

      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        _showSnackBar('Image upload failed. Please try again.', backgroundColor: Colors.red);
        return null;
      }
    } on FirebaseException catch (e) {
      print("Firebase Storage upload error: $e");
      _showSnackBar('Image upload error: ${e.message}', backgroundColor: Colors.red);
      return null;
    } catch (e) {
      print("General upload error: $e");
      _showSnackBar('An unexpected error occurred during image upload.', backgroundColor: Colors.red);
      return null;
    }
  }

  // Form submission logic
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please correct the errors in the form.', backgroundColor: Colors.red.shade700);
      return;
    }
    _formKey.currentState!.save(); // Save form field values

    setState(() {
      _loading = true;
      _submitButtonText = 'Submitting...';
    });

    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
      if (imageUrl == null) {
        // If image upload definitively failed after attempts, ask user whether to proceed
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Image Upload Failed', style: TextStyle(color: Colors.red)),
            content: const Text('The image could not be uploaded. Do you want to submit the item details without an image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Continue Anyway', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (proceed != true) {
          setState(() {
            _loading = false;
            _submitButtonText = 'Submit Item';
          });
          return; // Stop submission if user cancels
        }
      }
    }

    // Prepare data for Firestore
    final itemData = {
      'type': _type,
      'itemName': itemName,
      'description': description.isEmpty ? 'No description provided.' : description, // Default description
      'ownerName': ownerName.isEmpty ? 'Anonymous' : ownerName, // Default owner name
      'rollNumber': rollNumber.isEmpty ? 'N/A' : rollNumber, // Default roll number
      'contact': contact.isEmpty ? 'N/A' : contact, // Default contact
      'email': email.isEmpty ? 'N/A' : email, // Default email
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active', // 'active' or 'resolved'
    };
    if (imageUrl != null && imageUrl.isNotEmpty) {
      itemData['imageUrl'] = imageUrl; // Add image URL if available
    }

    try {
      await FirebaseFirestore.instance.collection('lostFoundItems').add(itemData); // Use a more descriptive collection name

      if (mounted) {
        _showSnackBar('Item reported successfully!', backgroundColor: Colors.green.shade600);
        Navigator.pop(context); // Go back after successful submission
      }
    } on FirebaseException catch (e) {
      print("Firestore submission error: $e");
      if (mounted) {
        _showSnackBar('Firestore error: ${e.message}', backgroundColor: Colors.red.shade700);
      }
    } catch (e) {
      print("General submission error: $e");
      if (mounted) {
        _showSnackBar('An unexpected error occurred during submission.', backgroundColor: Colors.red.shade700);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _submitButtonText = 'Submit Item';
        });
      }
    }
  }

  // Generic TextFormField builder for consistency
  Widget _buildTextFormField({
    required String labelText,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.green.shade700), // Themed label color
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green, width: 2), // Themed focus border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade900, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: Colors.green, // Themed cursor
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Item', // More concise title
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.green.shade700, // Richer green for app bar
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50, // Very light green
              Colors.green.shade100, // Slightly darker
              Colors.green.shade200, // Even slightly darker
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type Dropdown
                _buildTextFormField( // Visually integrate dropdown better
                  labelText: 'Report Type',
                  initialValue: _type.toUpperCase(), // Display current value
                  onSaved: (value) {}, // No save needed, handled by onChanged
                  maxLines: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16, right: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _type,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      dropdownColor: Colors.white, // Ensure dropdown background is white
                      onChanged: (val) {
                        setState(() => _type = val!);
                      },
                      items: ['lost', 'found'].map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.toUpperCase(), style: TextStyle(color: Colors.green.shade800)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Item Name
                _buildTextFormField(
                  labelText: 'Item Name',
                  validator: (val) => val!.isEmpty ? 'Item name is required' : null,
                  onSaved: (val) => itemName = val!,
                ),
                const SizedBox(height: 16),

                // Description
                _buildTextFormField(
                  labelText: 'Description (e.g., color, condition, where found/lost)',
                  onSaved: (val) => description = val ?? '',
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),

                // Owner Name (Optional but good to have)
                _buildTextFormField(
                  labelText: 'Your Name (Optional)',
                  onSaved: (val) => ownerName = val ?? '',
                ),
                const SizedBox(height: 16),

                // Roll Number (Optional but good to have)
                _buildTextFormField(
                  labelText: 'Your Roll Number (Optional)',
                  onSaved: (val) => rollNumber = val ?? '',
                  keyboardType: TextInputType.text, // Could be mixed if letters are in roll numbers
                ),
                const SizedBox(height: 16),

                // Contact (Optional but good to have)
                _buildTextFormField(
                  labelText: 'Your Contact Number (Optional)',
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => contact = val ?? '',
                  validator: (val) {
                    if (val != null && val.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(val)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email (Optional but good to have)
                _buildTextFormField(
                  labelText: 'Your Email (Optional)',
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => email = val ?? '',
                  validator: (val) {
                    if (val != null && val.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Image Picker Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200, width: 2),
                        ),
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Center(
                                child: Text(
                                  'No Image Selected',
                                  style: TextStyle(color: Colors.green.shade700, fontSize: 16),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.photo_library, color: Colors.white, size: 28),
                        label: const Text(
                          'Choose Image (Optional)',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _loading ? null : _submitForm, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700, // Darker green for emphasis
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: _loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            ),
                            const SizedBox(width: 12),
                            Text(_submitButtonText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : const Text(
                          'Submit Item',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}