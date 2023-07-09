// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:somenotes/constants/routes.dart';
import 'package:somenotes/services/auth/auth_exceptions.dart';
import 'package:somenotes/services/auth/auth_service.dart';

import 'package:somenotes/utils/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 19, 41, 61),
      ),
      body: Column(
        children: [
          TextField(
              controller: _emailController,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
              )),
          TextField(
              controller: _passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Password',
              )),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().initialize();
                final email = _emailController.text;
                final password = _passwordController.text;
                try {
                  await AuthService.firebase()
                      .createUser(email: email, password: password);
                  await AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyRoute);
                } on WeakPasswordAuthException {
                  await showErrorDialog(context, 'Password is too weak.');
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(context, 'email already in use.');
                } on InvalidEmailAuthException {
                  await showErrorDialog(context, 'not a valid email.');
                } on GenericAuthException {
                  await showErrorDialog(context, 'Something went wrong');
                } catch (e) {
                  await showErrorDialog(context, e.toString());
                }
              },
              child: const Text('Register')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Already Registered? Login Here'))
        ],
      ),
    );
  }
}
