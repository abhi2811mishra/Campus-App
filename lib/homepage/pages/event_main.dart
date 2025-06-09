import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_event.dart';
import 'package:intl/intl.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final CollectionReference eventsRef =
      FirebaseFirestore.instance.collection('events');

  Future<void> deleteEvent(String docId) async {
    await eventsRef.doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('College Events', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsRef.orderBy('date').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final events = snapshot.data!.docs;

          if (events.isEmpty) {
            return Center(child: Text('No events yet. Tap + to create one.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              final docId = events[index].id;
              final timestamp = event['date'] as Timestamp?;
              final dateStr = timestamp != null
                  ? DateFormat('MMM d, yyyy – hh:mm a')
                      .format(timestamp.toDate())
                  : 'No Date';

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
                            Text(event['title'] ?? '',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(dateStr),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(event['location'] ?? '',
                                      style:
                                          TextStyle(color: Colors.grey[800])),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(event['description'] ?? ''),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteEvent(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEventPage(),
          ),
        ),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

