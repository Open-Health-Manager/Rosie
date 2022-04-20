// Mock authentication service (to be replaced with a real system once one exists)

import 'package:flutter/material.dart';
import 'open_health_manager/open_health_manager.dart';

class OpenHealthManagerAuth extends ChangeNotifier {
  OpenHealthManagerAuth(this.healthManager) : super();

  final OpenHealthManager healthManager;
  String? _email;

  bool get signedIn => _email != null;
  String? get email => _email;

  Future<bool> signIn(String email, String password) async {
    print("Signing in as $email");
    await healthManager.signIn(email, password);
    _email = email;
    notifyListeners();
    return true;
  }

  Future<bool> createAccount(String fullName, String email) async {
    await healthManager.createAccount(fullName, email);
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