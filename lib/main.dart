import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shifty/injection.dart';
import 'package:shifty/presentation/core/app_widget.dart';

void main() {
  configureInjection(Environment.prod);
  runApp(AppWidget());
}
