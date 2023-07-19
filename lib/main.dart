import 'package:flutter/material.dart';
import 'package:somenotes/constants/routes.dart';
import 'package:somenotes/services/auth/auth_service.dart';
import 'package:somenotes/views/login_view.dart';
import 'package:somenotes/views/notes/new_note_view.dart';
import 'package:somenotes/views/register_view.dart';
import 'package:somenotes/views/verify_email_view.dart';

import 'views/notes/notes_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      useMaterial3: true,
    ),
    home: const HomePage(),
    initialRoute: '/',
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      verifyRoute: (context) => const VerifyEmail(),
      homeRoute: (context) => const HomePage(),
      notesRoute: (context) => const NotesView(),
      newNoteRoute: (context) => const NewNoteView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmail();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
