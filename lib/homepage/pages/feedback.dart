import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();

  final _rollNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _gmailController = TextEditingController();
  final _feedbackController = TextEditingController();

  String _selectedType = 'Teacher';
  bool _isSubmitting = false;
  int _starRating = 0;

  @override
  void dispose() {
    _rollNoController.dispose();
    _nameController.dispose();
    _gmailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // Validate all form fields first
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required details correctly.', Colors.red.shade700);
      return;
    }
    // Validate star rating
    if (_starRating == 0) {
      _showSnackBar('Please select a star rating for your feedback.', Colors.red.shade700);
      return;
    }

    setState(() => _isSubmitting = true);

    final feedbackData = {
      'type': _selectedType,
      'rollNo': _rollNoController.text.trim(),
      'name': _nameController.text.trim(),
      'gmail': _gmailController.text.trim(),
      'rating': _starRating,
      'content': _feedbackController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add(feedbackData);

      if (mounted) {
        _showSnackBar('Feedback for $_selectedType submitted successfully!', Colors.green.shade600);

        // Clear fields on successful submission
        _rollNoController.clear();
        _nameController.clear();
        _gmailController.clear();
        _feedbackController.clear();
        setState(() {
          _starRating = 0;
        });
      }
    } catch (e) {
      print('Error submitting feedback: $e'); // Log error for debugging
      if (mounted) {
        _showSnackBar('Failed to submit feedback. Please try again.', Colors.red.shade700);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Helper for consistent SnackBar messages
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildStar(int starIndex) {
    return GestureDetector( // Use GestureDetector for better tap area control
      onTap: () {
        setState(() {
          _starRating = starIndex;
        });
      },
      child: Icon(
        Icons.star_rounded, // Use rounded star for softer look
        color: starIndex <= _starRating ? Colors.amber.shade600 : Colors.grey.shade400, // Amber shade for selected, lighter grey for unselected
        size: 40, // Larger stars
      ),
    );
  }

  // Generic TextFormField builder for consistency
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Consistent vertical padding
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.deepPurple.shade700),
          fillColor: Colors.white, // White background for fields
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded borders
            borderSide: BorderSide.none, // No border by default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2), // Themed focus border
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: Colors.deepPurple, // Themed cursor
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Submit Feedback",
          style: TextStyle(
            fontSize: 26, // Larger title
            fontWeight: FontWeight.w800, // Heavier weight
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade700, // Darker, richer purple
        elevation: 4, // Add a subtle shadow
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50, // Very light purple
              Colors.deepPurple.shade100, // Slightly darker
              Colors.deepPurple.shade200, // Even slightly darker
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24), // Increased overall padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children
              children: [
                // Feedback Type Dropdown
                _buildTextFormField( // Reusing the text field styling for dropdown
                  controller: TextEditingController(text: _selectedType), // Dummy controller
                  labelText: "Feedback Type",
                  validator: (value) => null, // Dropdown always has a value
                  maxLines: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16, right: 16), // Adjust padding
                  child: DropdownButtonHideUnderline( // Hide default underline
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedType,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple.shade700),
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                      items: const [
                        DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                        DropdownMenuItem(value: 'Mess', child: Text('Mess')),
                        DropdownMenuItem(value: 'Canteen', child: Text('Canteen')), // Added canteen
                        DropdownMenuItem(value: 'Library', child: Text('Library')), // Added library
                        DropdownMenuItem(value: 'Other', child: Text('Other')), // Added other
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Roll Number
                _buildTextFormField(
                  controller: _rollNoController,
                  labelText: "Roll Number",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your roll number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number, // Numeric keyboard
                ),
                const SizedBox(height: 16),

                // Name
                _buildTextFormField(
                  controller: _nameController,
                  labelText: "Name",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gmail
                _buildTextFormField(
                  controller: _gmailController,
                  labelText: "Gmail",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your Gmail';
                    }
                    if (!RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(value.trim())) {
                      return 'Please enter a valid Gmail address (e.g., example@gmail.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Rating Section
                Text(
                  'Rate your experience:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => _buildStar(index + 1)),
                ),
                const SizedBox(height: 24),

                // Feedback Content
                _buildTextFormField(
                  controller: _feedbackController,
                  labelText: "Your Feedback",
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your feedback comments';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitFeedback, // Disable when submitting
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 28), // Rounded send icon
                  label: Text(
                    _isSubmitting ? "Submitting..." : "Submit Feedback",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade600, // Themed button color
                    foregroundColor: Colors.white, // Text/icon color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5, // Add shadow
                  ),
                ),
                const SizedBox(height: 20), // Space at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}