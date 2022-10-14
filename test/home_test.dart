// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:rosie/src/app_config.dart';
import 'package:rosie/src/app_state.dart';
import 'package:rosie/src/home.dart';

Widget wrapHomeScreen([HomeScreen? homeScreen]) {
  return MaterialApp(
    home: ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: Provider<AppConfig>(
        create: (context) => AppConfig(<String, dynamic>{}),
        child: homeScreen ?? const HomeScreen(),
      ),
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  testWidgets('home loads', (WidgetTester tester) async {
    // Ensure that the home screen is wrapped with an AppConfig
    await tester.pumpWidget(wrapHomeScreen());
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
