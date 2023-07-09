import 'package:flutter/material.dart';
import 'package:somenotes/constants/routes.dart';
import 'package:somenotes/services/auth/auth_exceptions.dart';
import 'package:somenotes/services/auth/auth_service.dart';
import '../utils/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  final String title = 'Login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
          'Login',
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
                      .login(email: email, password: password);
                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(homeRoute, (route) => false);
                  } else {
                    await AuthService.firebase().sendEmailVerification();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(verifyRoute, (route) => false);
                  }
                } on UserNotFoundAuthException {
                  await showErrorDialog(context, 'User not found');
                } on WrongPasswordAuthException {
                  await showErrorDialog(context, 'Wrong password');
                } on GenericAuthException {
                  await showErrorDialog(context, 'Something went wrong');
                } catch (e) {
                  await showErrorDialog(context, e.toString());
                }
              },
              child: const Text('Login')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not Registered? Register Here!'))
        ],
      ),
    );
  }
}
