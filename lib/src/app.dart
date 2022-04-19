import 'package:flutter/material.dart';
import 'auth.dart';
import 'rosie_theme.dart';
import 'home.dart';
import 'onboarding/onboarding.dart';

class RosieApp extends StatefulWidget {
  const RosieApp({Key? key}) : super(key: key);

  @override
  _RosieState createState() => _RosieState();
}

class _RosieState extends State<RosieApp> {
  final auth = OpenHealthManagerAuth();

  @override
  void initState() {
    auth.addListener(_handleAuthStateChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OpenHealthManagerAuthScope(
      notifier: auth,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: createRosieTheme(),
        darkTheme: createRosieTheme(brightness: Brightness.dark),
        home: auth.signedIn ? const HomeScreen() : const Onboarding(),
      )
    );
  }

  void _handleAuthStateChanged() {
    setState(() {
      // nothing to change ourselves, we received notification of a change
    });
  }

  @override
  void dispose() {
    auth.removeListener(_handleAuthStateChanged);
    super.dispose();
  }
}
