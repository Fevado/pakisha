import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodDetailScreen extends StatelessWidget {
  final DocumentSnapshot foodPost;

  const FoodDetailScreen({super.key, required this.foodPost});

 @override
Widget build(BuildContext context) {
  final data = foodPost.data() as Map<String, dynamic>;

  final title = data['title'] ?? 'No Title';
  final description = data['description'] ?? 'No Description';
  final location = data['location'] ?? 'No Location';
  final donorEmail = data['donorEmail'] ?? 'Unknown';
  final isClaimed = data['isClaimed'] ?? false;
  final timestamp = data['timestamp'] != null
      ? (data['timestamp'] as Timestamp).toDate()
      : DateTime.now();

  final List<dynamic>? imageUrls = data['imageUrls'];

  return Scaffold(
    appBar: AppBar(
      title: const Text('Food Details'),
      backgroundColor: Colors.green[800],
    ),
    body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📍 Location: $location"),
                  Text("👤 Donor: $donorEmail"),
                  Text("🕒 Posted: ${timestamp.toLocal()}"),
                  const SizedBox(height: 10),
                  Text(
                    isClaimed ? "✅ Already Claimed" : "🟢 Available for Claim",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isClaimed ? Colors.green[700] : Colors.teal[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (imageUrls != null && imageUrls.isNotEmpty) ...[
            const Text(
              'Photos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: imageUrls.take(2).map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],

          if (!isClaimed)
            ElevatedButton(
              onPressed: () async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to claim food.")),
      );
      return;
    }

    final postRef = FirebaseFirestore.instance.collection('foodPosts').doc(foodPost.id);

    final postSnap = await postRef.get();
    if (postSnap.exists && !(postSnap.data()?['isClaimed'] ?? false)) {
      await postRef.update({
        'isClaimed': true,
        'claimedBy': user.uid,
        'claimedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You successfully claimed this food.")),
      );

      Navigator.pop(context); // Go back to homepage to reflect update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This food has already been claimed.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
},

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Claim This Food",
                style: TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    ),
  );
}
}


