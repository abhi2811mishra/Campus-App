import 'package:campusapp/homepage/pages/add_event.dart';
import 'package:flutter/material.dart';


class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, String>> events = [];

  void addNewEvent(Map<String, String> newEvent) {
    setState(() {
      events.add(newEvent);
    });
  }

  void removeEvent(int index) {
    setState(() {
      events.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Events',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: events.isEmpty
          ? Center(child: Text('No events yet. Tap + to create one.'))
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                 margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                      child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                        event['title']!,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                       SizedBox(height: 6),
                       Text('${event['date']} • ${event['time']}'),
                        SizedBox(height: 6),
                           Row(
                         children: [
                           Icon(Icons.location_on, color: Colors.green, size: 18),
                           SizedBox(width: 4),
                           Expanded(
                              child: Text(
                              event['location']!,
                              style: TextStyle(color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,),
                             ),
                           ],
                        ),
              SizedBox(height: 6),
              Text(event['description']!),
                       ],
                     ),
                     ),
                               IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => removeEvent(index),
                                  ),
                                  ],
                              ),
                            ),
                        );

              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEventPage(onAddEvent: addNewEvent),
          ),
        ),
        child: Icon(Icons.add, color: Colors.white, size: 30),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
