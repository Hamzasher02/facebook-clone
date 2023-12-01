import 'package:facbookdemo/main.dart';
import 'package:facbookdemo/screens/auth/signup.dart';
import 'package:facbookdemo/screens/feedscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Facebook logo or app name
            Image.asset(
              'assets/f.png', // Replace with your Facebook logo asset
              height: 100,
              width: 100,
            ),
            SizedBox(height: 16.0),
            // Email TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Password TextField
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Login Button
            ElevatedButton(
              onPressed: () {
                _login();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Facebook's primary color
              ),
              child: Text('Log In'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SignupScreen();
                  }));
                },
                child: Text("don't have account"))
          ],
        ),
      ),
    );
  }

  void _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Successfully logged in, navigate to the feed page
      print('User logged in: ${userCredential.user!.email}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FeedScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // Handle invalid email or password
        print('Invalid email or password');
      } else {
        // Handle other errors
        print('Error: ${e.message}');
      }
    }
  }
}
