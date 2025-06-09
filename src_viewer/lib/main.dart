import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src_viewer/screens/display.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'config.dart';
import 'dart:html' as html;

// Single global instance
late final FirebaseAnalytics analytics;

// Analytics event names
class AnalyticsEvents {
  static const String appOpen = 'app_open';
  static const String lessonView = 'lesson_view';
  static const String searchPerformed = 'search_performed';
  static const String filterApplied = 'filter_applied';
  static const String lessonApproved = 'lesson_approved';
  static const String errorOccurred = 'error_occurred';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Then initialize analytics
  analytics = FirebaseAnalytics.instance;
  await analytics.setAnalyticsCollectionEnabled(true);
  
  // Check for debug parameters
  final uri = Uri.parse(html.window.location.href);
  final queryParams = uri.queryParameters;
  
  if (Config.debugAnalytics || queryParams['firebase_analytics_debug'] == 'true') {
    // Enable debug mode in URL for web
    final newQueryParams = Map<String, String>.from(queryParams);
    newQueryParams['firebase_analytics_debug'] = 'true';
    final newUri = uri.replace(queryParameters: newQueryParams);
    html.window.history.pushState({}, '', newUri.toString());
    
    // Set debug mode explicitly
    await analytics.setAnalyticsCollectionEnabled(true);
    
    // Log a test event with a unique identifier
    await analytics.logEvent(
      name: 'debug_test_event',
      parameters: {
        'test_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'debug_mode': 'true',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    print('Analytics Debug Mode: Enabled');
    print('Debug URL: ${newUri.toString()}');
    print('Test event logged with ID: ${DateTime.now().millisecondsSinceEpoch}');
  }
  
  // Log initial app load with more detailed parameters
  await analytics.logEvent(
    name: 'app_open',
    parameters: {
      'source': 'main',
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'web',
      'debug_mode': queryParams['firebase_analytics_debug'] == 'true' ? 'true' : 'false',
      'app_version': '1.0.0',
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Social Responsible Computing',
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF228C4C)),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const DisplayPage());
  }
}
