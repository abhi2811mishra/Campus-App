import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  final Function(Map<String, String>) onAddEvent;

  AddEventPage({required this.onAddEvent});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String date = '';
  String time = '';
  String location = '';
  String description = '';

  void submitEvent() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.onAddEvent({
        'title': title,
        'date': date,
        'time': time,
        'location': location,
        'description': description,
      });

      Navigator.pop(context); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Event',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Event Title'),
                onSaved: (value) => title = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date (e.g. June 15, 2025)'),
                onSaved: (value) => date = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter date' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Time (e.g. 10:00 AM - 4:00 PM)'),
                onSaved: (value) => time = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter time' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (value) => location = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter location' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Submit Event',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

