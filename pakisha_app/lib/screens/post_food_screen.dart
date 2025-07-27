import 'dart:io' as io show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class PostFoodScreen extends StatefulWidget {
  const PostFoodScreen({super.key});

  @override
  State<PostFoodScreen> createState() => _PostFoodScreenState();
}

class _PostFoodScreenState extends State<PostFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;

  // Web and mobile image selections
  List<({Uint8List bytes, String name})> _webImages = [];
  List<io.File> _mobileImages = [];

  Future<void> _pickImages() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _webImages = result.files
              .take(2)
              .map((f) => (bytes: f.bytes!, name: f.name))
              .toList();
        });
      }
    } else {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 70);
      if (picked.isNotEmpty) {
        setState(() {
          _mobileImages = picked.take(2).map((x) => io.File(x.path)).toList();
        });
      }
    }
  }

  Future<List<String>> _uploadImages(String postId) async {
    List<String> imageUrls = [];

    if (kIsWeb) {
      for (int i = 0; i < _webImages.length; i++) {
        final img = _webImages[i];
        final ref = FirebaseStorage.instance
            .ref()
            .child('foodPosts/$postId/image_$i.jpg');
        final uploadTask = ref.putData(
          img.bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await (await uploadTask).ref.getDownloadURL();
        imageUrls.add(url);
      }
    } else {
      for (int i = 0; i < _mobileImages.length; i++) {
        final file = _mobileImages[i];
        final ref = FirebaseStorage.instance
            .ref()
            .child('foodPosts/$postId/image_$i.jpg');
        final uploadTask = ref.putFile(file);
        final url = await (await uploadTask).ref.getDownloadURL();
        imageUrls.add(url);
      }
    }

    return imageUrls;
  }

  Future<void> _submitFoodPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final postRef = FirebaseFirestore.instance.collection('foodPosts').doc();

      final foodPost = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'donorEmail': user.email,
        'isClaimed': false,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await postRef.set(foodPost);

      final hasImages = kIsWeb ? _webImages.isNotEmpty : _mobileImages.isNotEmpty;
      if (hasImages) {
        final imageUrls = await _uploadImages(postRef.id);
        print('Uploaded image URLs: $imageUrls');
        await postRef.update({'imageUrls': imageUrls});
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food posted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Post Food'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Food Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text("Select up to 2 Images (Optional)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
              if (kIsWeb && _webImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _webImages
                      .map((img) => Image.memory(img.bytes,
                          height: 100, width: 100, fit: BoxFit.cover))
                      .toList(),
                ),
              if (!kIsWeb && _mobileImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _mobileImages
                      .map((file) => Image.file(file,
                          height: 100, width: 100, fit: BoxFit.cover))
                      .toList(),
                ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitFoodPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}



