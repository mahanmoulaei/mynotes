import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Column(
        children: [
          TextField(controller: _email, enableSuggestions: false, autocorrect: false, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: "Enter your email here...")),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your password here..."),
          ),
          TextButton(
            child: const Text('Login'),
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

                final user = FirebaseAuth.instance.currentUser;
                final isEmailVerified = user?.emailVerified ?? false;

                if (isEmailVerified) {
                  Navigator.of(context).pushNamedAndRemoveUntil(notesviewRoute, (context) => false);
                } else if (user != null) {
                  Navigator.of(context).pushNamedAndRemoveUntil(verifyemailRoute, (context) => false);
                } else {}
              } on FirebaseAuthException catch (e) {
                final String? message = e.message;
                await showErrorDialog(context, "$message");
              }
            },
          ),
          TextButton(
              child: const Text("Not registered? Sign Up"),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (context) => false);
              }),
        ],
      ),
    );
  }
}
