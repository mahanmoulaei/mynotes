import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Sign Up'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Column(
        children: [
          TextField(controller: _email, enableSuggestions: false, autocorrect: false, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: "Enter your email here...")),
          TextField(controller: _password, obscureText: true, enableSuggestions: false, autocorrect: false, decoration: const InputDecoration(hintText: "Enter your password here...")),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              } on FirebaseAuthException catch (e) {
                final String? message = e.message;

                await showErrorDialog(context, "$message");
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              child: const Text("Already registered? Login"),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil("/login/", (context) => false);
              })
        ],
      ),
    );
  }
}
