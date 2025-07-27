import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_detail_screen.dart'; 
class HomePage extends StatefulWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String firstName = '';

  @override
  void initState() {
    super.initState();
    fetchUserFirstName();
  }

  Future<void> fetchUserFirstName() async {
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        firstName = userDoc.data()?['firstName'] ?? 'User';
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> claimFood(String postId) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('foodPosts').doc(postId);

      final postSnap = await postRef.get();
      if (postSnap.exists && !(postSnap.data()?['isClaimed'] ?? false)) {
        await postRef.update({
          'isClaimed': true,
          'claimedBy': user!.uid,
          'claimedAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Food successfully claimed!")),
        );
        setState(() {}); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This food has already been claimed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error claiming food: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("PAKISHA Home"),
        backgroundColor: Colors.green[800],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[800]),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Pakisha Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Donor Dashboard"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/donor');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text("Recipient Dashboard"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/recipient');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome $firstName",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/post-food'),
                child: const Text("Post Food"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/map'),
                child: const Text("View Map"),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Available Food Posts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('foodPosts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "🍽️ No food posts yet. Be the first to donate!",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  final posts = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final data = post.data() as Map<String, dynamic>;
                      final isClaimed = data['isClaimed'] ?? false;

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
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              data['title'] ?? 'Untitled',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(data['description'] ?? ''),
                                const SizedBox(height: 4),
                                Text("📍 ${data['location'] ?? 'Unknown'}"),
                                Text("👤 ${data['donorEmail'] ?? 'Unknown'}"),
                                const SizedBox(height: 6),
                                Text(
                                  isClaimed ? "✅ Claimed" : "🟢 Available",
                                  style: TextStyle(
                                    color: isClaimed ? Colors.green[800] : Colors.teal[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: isClaimed
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => claimFood(post.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      minimumSize: const Size(70, 40),
                                    ),
                                    child: const Text("Claim"),
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
