import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facbookdemo/screens/uploadpost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facbookdemo/screens/uploadpost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
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

              return PostCard(documentId: document.id, data: data);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return UploadPostScreen();
          }));
        },
        child: Icon(Icons.add_comment),
      ),
    );
  }
}

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
          if (data['imageUrl'] != null)
            Image.network(
              data['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(data['text']),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      _likePost(documentId: documentId);
                    },
                  ),
                  Text(data['likes'].toString()),
                ],
              ),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(postId: documentId),
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
