import 'package:flutter/material.dart';

import 'mock_backend/mock_trl_api.dart';
import 'state/app_controller.dart';
import 'ui/app.dart';

/// The only place that knows the back end is simulated: swap `MockTrlApi`
/// for an HTTP implementation of `TrlApi` when the real one exists.
void main() {
  final controller = AppController(MockTrlApi());
  runApp(TrlApp(controller: controller));
  controller.load();
}
