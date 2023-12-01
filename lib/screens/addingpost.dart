import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facbookdemo/screens/comment.dart';
import 'package:facbookdemo/screens/feedscreen.dart';
import 'package:facbookdemo/screens/uploadpost.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> data;

  PostCard({required this.documentId, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(data['text']),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: () {
                  _likePost(documentId: documentId);
                },
              ),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadPostScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _likePost({required String documentId}) {
    FirebaseFirestore.instance.collection('posts').doc(documentId).update({
      'likes': FieldValue.increment(1),
    });
  }
}
