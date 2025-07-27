import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_detail_screen.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  Future<String?> _getCurrentUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // ensure latest info
    return user?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Your Food Posts'),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: FutureBuilder<String?>(
        future: _getCurrentUserEmail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserEmail = snapshot.data;

          if (currentUserEmail == null) {
            return const Center(child: Text('User not logged in'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('foodPosts')
                .where('donorEmail', isEqualTo: currentUserEmail)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('You have not posted any food yet.'),
                );
              }

              final posts = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final data = post.data() as Map<String, dynamic>;

                  final title = data['title'] ?? '';
                  final description = data['description'] ?? '';
                  final isClaimed = data['isClaimed'] ?? false;
                  final claimedBy = data.containsKey('claimedBy')
                      ? data['claimedBy']
                      : 'N/A';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailScreen(foodPost: post),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(description),
                            const SizedBox(height: 12),
                            Text(
                              isClaimed
                                  ? '✅ Claimed by: $claimedBy'
                                  : '❗ Not yet claimed',
                              style: TextStyle(
                                color: isClaimed ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
