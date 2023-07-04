import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const Text('Please verify your email'),
        TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser?.sendEmailVerification();
            },
            child: Text('Send verification email')),
      ]),
    );
  }
}
