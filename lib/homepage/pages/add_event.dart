import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Make sure you have this import for DateFormat

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key}); // Added super.key

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String location = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSubmitting = false; // To show loading state on button

  Future<void> pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(), // Use existing date if available
      firstDate: DateTime.now().subtract(const Duration(days: 0)), // Can't select past dates
      lastDate: DateTime(2050), // Extended last date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple, // DatePicker header color
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple), // Selected date color
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(), // Use existing time if available
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple, // TimePicker header color
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple), // Selected time color
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all required fields.', Colors.red);
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      _showSnackBar('Please select both date and time.', Colors.red);
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    // Combine selectedDate and selectedTime
    final fullDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'date': fullDateTime, // Store as Timestamp
        'location': location,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackBar('Event added successfully!', Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding event: $e'); // Good for debugging
      if (mounted) {
        _showSnackBar('Failed to add event. Please try again.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Makes it float above content
        margin: const EdgeInsets.all(16), // Padding from edges
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
        duration: const Duration(seconds: 3), // Show for 3 seconds
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.deepPurple.shade700),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // No border by default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
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
        maxLines: maxLines,
        keyboardType: keyboardType,
        cursorColor: Colors.deepPurple, // Cursor color
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String titleText,
    required String valueText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2, // Subtle elevation
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( // For ripple effect
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  titleText,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Event',
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
          child: ListView(
            padding: const EdgeInsets.all(24), // Increased overall padding
            children: [
              // Title Field
              _buildTextFormField(
                labelText: 'Event Title',
                onSaved: (value) => title = value ?? '',
                validator: (value) => value!.isEmpty ? 'Please enter event title' : null,
              ),
              const SizedBox(height: 12),

              // Date Picker
              _buildDatePickerTile(
                titleText: 'Event Date',
                valueText: selectedDate == null
                    ? 'Not Selected'
                    : DateFormat('MMM d, yyyy').format(selectedDate!),
                icon: Icons.calendar_today,
                onTap: pickDate,
              ),
              const SizedBox(height: 12),

              // Time Picker
              _buildDatePickerTile(
                titleText: 'Event Time',
                valueText: selectedTime == null
                    ? 'Not Selected'
                    : selectedTime!.format(context),
                icon: Icons.access_time,
                onTap: pickTime,
              ),
              const SizedBox(height: 12),

              // Location Field
              _buildTextFormField(
                labelText: 'Location',
                onSaved: (value) => location = value ?? '',
                validator: (value) => value!.isEmpty ? 'Please enter event location' : null,
              ),
              const SizedBox(height: 12),

              // Description Field
              _buildTextFormField(
                labelText: 'Description',
                onSaved: (value) => description = value ?? '',
                validator: (value) => value!.isEmpty ? 'Please enter event description' : null,
                maxLines: 5, // Allow more lines for description
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 30), // More space before the button

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : submitEvent, // Disable when submitting
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600, // Themed button color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 16), // Generous padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  elevation: 5, // Add shadow
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Add Event'),
              ),
              const SizedBox(height: 10), // Space after button
            ],
          ),
        ),
      ),
    );
  }
}
