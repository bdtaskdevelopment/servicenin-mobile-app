import 'dart:async';
import 'dart:io';
import 'package:internet_checker_plus/internet_checker_plus.dart';
import 'package:servicenin/app/core/helpers/app_helper.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:internet_checker_plus/internet_level.dart';

import 'app/app_binding.dart';
import 'app/my_app.dart';
// import 'firebase_options.dart';
import 'package:flutter_log_console/flutter_log_console.dart';
void main() async {

  // runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();
    AppDependencyInjection.init();

    
    await GetStorage.init();
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Missing or unreadable .env must not crash startup — fall back to
      // an empty env so dotenv.get(...) calls don't throw and the app can
      // still reach the splash screen.
      dotenv.loadFromString(envString: '', isOptional: true);
      FlutterConsole.log("dotenv load failed, using empty env: $e");
    }
    FlutterConsole.log("Hello Flutter");
    runApp(MyApp());
}
