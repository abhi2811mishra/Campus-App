import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusapp/homepage/pages/lost_found.dart'; // Assuming this path is correct for AddItemScreen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class AllItemsPage extends StatelessWidget {
  const AllItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lost & Found Items', // More concise and direct title
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.teal.shade700, // Darker, richer teal
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
              Colors.teal.shade50, // Very light teal
              Colors.teal.shade100, // Slightly darker
              Colors.teal.shade200, // Even slightly darker
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('lostFoundItems') // Use the updated collection name
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Firestore error: ${snapshot.error}'); // Log error for debugging
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 60),
                      const SizedBox(height: 10),
                      Text(
                        'Oops! Something went wrong.\nPlease try again later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.red.shade800),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal), // Themed indicator
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, color: Colors.grey.shade400, size: 80),
                    const SizedBox(height: 10),
                    Text(
                      'No lost or found items reported yet!',
                      style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to report an item.',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            final items = snapshot.data!.docs;

            return ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(16), // More padding around the list
              itemBuilder: (context, index) {
                final data = items[index].data() as Map<String, dynamic>;

                final String imageUrl = data['imageUrl'] ?? '';
                final String itemName = data['itemName'] ?? 'Unnamed Item';
                final String description = data['description'] ?? 'No description provided.';
                final String ownerName = data['ownerName'] ?? 'Anonymous';
                final String rollNumber = data['rollNumber'] ?? 'N/A';
                final String contact = data['contact'] ?? 'N/A';
                final String email = data['email'] ?? 'N/A';
                final String type = data['type'] ?? 'unknown';
                final Timestamp? timestamp = data['timestamp'] as Timestamp?;

                String formattedDate = 'Unknown Date';
                if (timestamp != null) {
                  final dateTime = timestamp.toDate();
                  formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
                }

                // Determine colors based on type
                Color typeChipColor = type == 'lost' ? Colors.red.shade100 : Colors.green.shade100;
                Color typeTextColor = type == 'lost' ? Colors.red.shade800 : Colors.green.shade800;
                IconData typeIcon = type == 'lost' ? Icons.search : Icons.check_circle_outline; // Different icons for lost/found

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10), // Increased vertical margin
                  elevation: 6, // Slightly higher elevation for more pop
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // More rounded corners
                    side: BorderSide(color: Colors.teal.shade300, width: 0.5), // Subtle border
                  ),
                  child: InkWell( // Make the card tappable for future details page
                    onTap: () {
                      // TODO: Implement navigation to a detailed item view if needed
                      print('Tapped on ${itemName}');
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // More internal padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item Image
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200, // Placeholder background
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade300),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey.shade400,
                                          ),
                                        )
                                      : Icon(
                                          Icons.camera_alt_outlined, // Icon for no image
                                          size: 50,
                                          color: Colors.grey.shade400,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16), // Increased spacing

                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade800,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      description,
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(typeIcon, size: 20, color: typeTextColor),
                                        const SizedBox(width: 5),
                                        Chip(
                                          label: Text(
                                            type.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: typeTextColor,
                                            ),
                                          ),
                                          backgroundColor: typeChipColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Reported: $formattedDate',
                                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 0.8, color: Colors.teal), // Separator
                          // Contact Details Section
                          Text(
                            'Contact Information:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                          ),
                          const SizedBox(height: 8),
                          _buildContactRow(Icons.person_outline, 'Name', ownerName),
                          _buildContactRow(Icons.credit_card, 'Roll No.', rollNumber), // More relevant icon
                          _buildContactRow(Icons.phone, 'Contact', contact),
                          _buildContactRow(Icons.email, 'Email', email),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
        label: const Text(
          'Report New Item',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        backgroundColor: Colors.teal.shade600, // Themed FAB color
        elevation: 8, // More prominent shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Rounded shape
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the FAB
    );
  }

  // Helper widget to build contact info rows
  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.teal.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.teal.shade800),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
