import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationCanvas extends StatelessWidget {
  final VoidCallback onClose; // Callback to close the canvas
  final VoidCallback onMarkAllAsRead; // Callback to mark all notifications as read

  const NotificationCanvas({
    super.key,
    required this.onClose,
    required this.onMarkAllAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('No user logged in.'));
    }

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 60, right: 10),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with "Mark all as read" and close button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: onMarkAllAsRead,
                            child: const Text(
                              "Mark all as read",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Notification list
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data?.data() == null) {
                        return const Center(child: Text('No notifications.'));
                      }

                      final List notifications = snapshot.data!.get('messages') ?? [];

                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final isRead = notification['read'] ?? false;

                          return ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: isRead ? Colors.grey : Colors.blue,
                            ),
                            title: Text(notification['title'] ?? 'No Title'),
                            subtitle: Text(notification['body'] ?? 'No Body'),
                            trailing: Text(
                              (notification['timestamp'] as Timestamp)
                                  .toDate()
                                  .toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}