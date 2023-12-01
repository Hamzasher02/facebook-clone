import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPostScreen extends StatefulWidget {
  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final TextEditingController _postController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _uploadPost() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (_image != null) {
      // Upload image to Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('post_images/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() => null);

      String imageUrl = await storageReference.getDownloadURL();

      // Add post with image URL to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'text': _postController.text,
        'user': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'likes': 0,
      });
    } else {
      // Add post without image to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'text': _postController.text,
        'user': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
      });
    }

    Navigator.pop(context); // Close the upload post screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: _image == null
                  ? Container(
                      color: Colors.grey,
                      height: 200,
                      width: double.infinity,
                      child: Icon(Icons.add_a_photo, size: 50),
                    )
                  : Image.file(_image!, height: 200, width: double.infinity),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                labelText: 'Write your post',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _uploadPost();
              },
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
