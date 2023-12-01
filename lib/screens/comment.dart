import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatelessWidget {
  final String postId;

  CommentsScreen({required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .where('postId', isEqualTo: postId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['text']),
                subtitle: Text(data['user']),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCommentDialog(context);
        },
        child: Icon(Icons.add_comment),
      ),
    );
  }

  void _showAddCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController commentController = TextEditingController();

        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(labelText: 'Comment'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('comments').add({
                  'postId': postId,
                  'user': FirebaseAuth.instance.currentUser!.uid,
                  'text': commentController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context); // Close the dialog
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
