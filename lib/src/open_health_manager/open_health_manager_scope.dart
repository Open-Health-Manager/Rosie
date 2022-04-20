import "package:flutter/material.dart";
import "open_health_manager.dart";

// This provides a scope for widgets to access OpenHealthManager singleton.
// The singleton shouldn't change, but provides information on how to access
// the manager.
class OpenHealthManagerScope extends InheritedWidget {
  const OpenHealthManagerScope({
    required this.manager,
    required Widget child,
    Key? key
  }) : super(key: key, child: child);

  final OpenHealthManager manager;

  static OpenHealthManager of(BuildContext context) => context
    .dependOnInheritedWidgetOfExactType<OpenHealthManagerScope>()!.manager;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    if (oldWidget is OpenHealthManagerScope) {
      return oldWidget.manager != manager;
    }
    // If we've fallen through, assume we need to update
    return true;
  }
}