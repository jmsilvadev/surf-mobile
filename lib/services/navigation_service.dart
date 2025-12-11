import 'package:flutter/widgets.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void navigateToRegistration() {
  final ctx = appNavigatorKey.currentState;
  if (ctx == null) return;
  ctx.pushReplacementNamed('/registration');
}
