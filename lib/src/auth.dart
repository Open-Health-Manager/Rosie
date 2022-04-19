// Mock authentication service (to be replaced with a real system once one exists)

import 'package:flutter/material.dart';

class OpenHealthManagerAuth extends ChangeNotifier {
  String? _email;

  bool get signedIn => _email != null;
  String? get email => _email;

  Future<bool> signIn(String email, String password) async {
    print("Signing in as $email");
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _email = email;
    notifyListeners();
    return true;
  }

  Future<bool> createAccount(String fullName, String email) async {
    print("Creating an account for $fullName with email $email");
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _email = email;
    notifyListeners();
    return true;
  }
}

// This provides a scope for widgets to access the account data and therefore be able to load additional data about a
// given user.
class OpenHealthManagerAuthScope extends InheritedNotifier<OpenHealthManagerAuth> {
  const OpenHealthManagerAuthScope({
    required OpenHealthManagerAuth notifier,
    required Widget child,
    Key? key
  }) : super(key: key, notifier: notifier, child: child);

  static OpenHealthManagerAuth of(BuildContext context) => context
    .dependOnInheritedWidgetOfExactType<OpenHealthManagerAuthScope>()!.notifier!;
}