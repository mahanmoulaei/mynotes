import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/auth_exceptions.dart';
import '../utilities/cupertino_alert_dialog.dart';

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
                await AuthService.firebase().logIn(email: email, password: password);

                final user = AuthService.firebase().currentUser;

                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(notesviewRoute, (_) => false);
                } else {
                  Navigator.of(context).pushNamed(verifyemailRoute);
                }
              } on UserNotFoundAuthException {
                return showAlertDialog(context, "Login", "User not found!", null);
              } on WrongPasswordAuthException {
                return showAlertDialog(context, "Login", "Wrong credentials!", null);
              } on GenericAuthException {
                return showAlertDialog(context, "Login", "Authentication error!", null);
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
