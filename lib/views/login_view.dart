import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:somenotes/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
export 'login_view.dart';

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
                await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform);
                final email = _emailController.text;
                final password = _passwordController.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);

                  print(userCredential);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Sorry, that password isn\'t correct.');
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('Login')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/register/', (route) => false);
              },
              child: const Text('Not Registered? Register Here!'))
        ],
      ),
    );
  }
}
