import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

import '../enums/menu_action.dart';
import '../utilities/cupertino_dialog_box.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesView();
}

class _NotesView extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Main UI"),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showCupertinoDialog(context, "Sign Out", "Are you sure you want to sign out?", "Log out", "Cancel");

                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                    break;
                  default:
                }
              },
              itemBuilder: (context) {
                return const [PopupMenuItem<MenuAction>(value: MenuAction.logout, child: Text("Log Out"))];
              },
            )
          ],
        ),
        body: const Text("Hello World"));
  }
}
