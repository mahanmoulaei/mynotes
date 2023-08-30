import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable // meaning the interal never going to change upon initialization. they cannot have any field that will change...
class AuthUser {
  final bool isEmailVerified;

  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(user.emailVerified);
  }
}
