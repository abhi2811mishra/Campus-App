import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_event.dart'; // Make sure this path is correct
import 'package:intl/intl.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key}); // Added super.key

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final CollectionReference eventsRef =
      FirebaseFirestore.instance.collection('events');

  Future<void> deleteEvent(String docId) async {
    // Show a confirmation dialog before deleting
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Dismiss and return false
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Dismiss and return true
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700, // Red for destructive action
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false; // In case dialog is dismissed by tapping outside

    if (confirm) {
      try {
        await eventsRef.doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Event removed successfully!', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green.shade600, // Green for success
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete event: $e', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red.shade700, // Red for error
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'College Events',
          style: TextStyle(
            fontSize: 26, // Slightly larger title
            fontWeight: FontWeight.w800, // Heavier weight
            color: Colors.white,
            letterSpacing: 0.5, // Add a subtle letter spacing
          ),
        ),
        backgroundColor: Colors.deepPurple.shade700, // Darker, richer purple
        elevation: 4, // Add a subtle shadow to the app bar
        centerTitle: true, // Center the title
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50, // Very light purple at top
              Colors.white, // White in the middle
              Colors.deepPurple.shade100, // Light purple at bottom
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: eventsRef.orderBy('date').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple), // Themed indicator
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading events: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            final events = snapshot.data!.docs;

            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 80,
                      color: Colors.deepPurple.shade300,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No exciting events planned yet!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap the "+" button to add a new event.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Overall list padding
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index].data() as Map<String, dynamic>;
                final docId = events[index].id;
                final timestamp = event['date'] as Timestamp?;
                final dateStr = timestamp != null
                    ? DateFormat('MMM d, yyyy \n hh:mm a') // Newline for better date/time display
                        .format(timestamp.toDate())
                    : 'Date Not Set'; // Better placeholder

                return Card(
                  elevation: 5, // Increased elevation for a floating effect
                  margin: const EdgeInsets.symmetric(vertical: 10), // More vertical spacing between cards
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // More rounded corners
                  ),
                  child: InkWell( // Added InkWell for tap feedback
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      // Optional: Navigate to an event detail page here
                      // print('Tapped on event: ${event['title']}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Increased internal padding
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date/Time Column
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade100, // Light purple background
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('MMM').format(timestamp?.toDate() ?? DateTime.now()),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple.shade700),
                                ),
                                Text(
                                  DateFormat('dd').format(timestamp?.toDate() ?? DateTime.now()),
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple.shade900),
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(timestamp?.toDate() ?? DateTime.now()),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.deepPurple.shade700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15), // Spacing between date and event details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'] ?? 'No Title', // Better default text
                                  style: const TextStyle(
                                    fontSize: 20, // Larger title
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple, // Themed color
                                  ),
                                  maxLines: 2, // Allow title to wrap
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8), // More space
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.blue.shade700, size: 18), // Distinct color for icon
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        event['location'] ?? 'No Location',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey.shade800),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8), // More space
                                Text(
                                  event['description'] ?? 'No Description',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600), // Lighter for description
                                  maxLines: 3, // Allow description to wrap
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Delete button at the end
                          IconButton(
                            icon: Icon(Icons.delete_forever, color: Colors.red.shade600, size: 28), // Larger, more prominent delete icon
                            onPressed: () => deleteEvent(docId),
                            tooltip: 'Delete Event', // Add tooltip
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended( // Changed to extended for text
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEventPage(),
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // Text on FAB
        backgroundColor: Colors.deepPurple.shade600, // Themed FAB color
        elevation: 8, // More elevation for FAB
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // More rounded shape
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the FAB
    );
  }
}