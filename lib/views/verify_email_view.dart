import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Verify Email'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        body: Column(
          children: [
            const Text("We have sent you an email verification. Please open it to verify your account."),
            const Text("If you haven't received the verification email yet, press the button below:"),
            TextButton(
                child: const Text("Send email verification"),
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                })
          ],
        ));
  }
}
