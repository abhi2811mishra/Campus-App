import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusapp/homepage/pages/lost_found.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllItemsPage extends StatelessWidget {
  const AllItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Lost & Found Items'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Firestore error: ${snapshot.error}');
            return Center(child: Text('Error loading data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No items found.'));
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            padding: EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final data = items[index].data() as Map<String, dynamic>;

              final imageUrl = data['imageUrl'] ?? '';
              print("Loading image: ${data['imageUrl']}");

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.error, size: 40),
                              ),

                          )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['itemName'] ?? 'Unnamed',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(data['description'] ?? ''),
                            SizedBox(height: 8),
                            Text("Owner: ${data['ownerName'] ?? '-'}"),
                            Text("Roll No: ${data['rollNumber'] ?? '-'}"),
                            Text("Contact: ${data['contact'] ?? '-'}"),
                            Text("Email: ${data['email'] ?? '-'}"),
                            SizedBox(height: 5),
                            Chip(
                              label: Text(
                                data['type']?.toUpperCase() ?? 'UNKNOWN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              backgroundColor: data['type'] == 'lost'
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddItemScreen()),
          );
        },
      ),
    );
  }
}
