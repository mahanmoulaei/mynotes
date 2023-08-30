// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import '../services/auth/auth_exceptions.dart';
import '../utilities/cupertino_alert_dialog.dart';

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
                await AuthService.firebase().createUser(email: email, password: password);

                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyemailRoute);
              } on WeakPasswordAuthException {
                return showAlertDialog(context, "Register", "Weak Password", null);
              } on EmailAlreadyInUseAuthException {
                return showAlertDialog(context, "Register", "Email is already in use", null);
              } on InvalidEmailAuthException {
                return showAlertDialog(context, "Register", "Invalid email address", null);
              } on GenericAuthException {
                return showAlertDialog(context, "Register", "Failed to register", null);
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              child: const Text("Already registered? Login"),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (context) => false);
              })
        ],
      ),
    );
  }
}
