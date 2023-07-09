import 'package:flutter/material.dart';
import 'package:somenotes/constants/routes.dart';
import 'package:somenotes/services/auth/auth_service.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Email',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 19, 41, 61),
      ),
      body: Column(children: [
        const Text(
            "We've sent you an email verification link, please check your email."),
        const Text(
            'If you have not received a verification email, press the button below.'),
        TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send verification email')),
        TextButton(
            onPressed: () async {
              await AuthService.firebase().logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Restart'))
      ]),
    );
  }
}
