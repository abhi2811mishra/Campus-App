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
    if (!_formKey.currentState!.validate()) return;
    if (_starRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback for $_selectedType submitted!')),
      );

      // Clear all inputs after successful submission
      _rollNoController.clear();
      _nameController.clear();
      _gmailController.clear();
      _feedbackController.clear();
      setState(() {
        _starRating = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStar(int starIndex) {
    return IconButton(
      onPressed: () {
        setState(() {
          _starRating = starIndex;
        });
      },
      icon: Icon(
        Icons.star,
        color: starIndex <= _starRating ? Colors.amber : Colors.grey,
        size: 32,
      ),
      splashRadius: 24,
      tooltip: '$starIndex star${starIndex > 1 ? "s" : ""}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: "Feedback Type",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                    DropdownMenuItem(value: 'Mess', child: Text('Mess')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _rollNoController,
                  decoration: const InputDecoration(
                    labelText: "Roll Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your roll number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _gmailController,
                  decoration: const InputDecoration(
                    labelText: "Gmail",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your Gmail';
                    }
                    if (!RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(value.trim())) {
                      return 'Please enter a valid Gmail address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Star Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => _buildStar(index + 1)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Your Feedback",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some feedback';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _submitFeedback,
                        icon: const Icon(Icons.send),
                        label: const Text("Submit"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
