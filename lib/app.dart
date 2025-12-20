import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';

import 'forms/homepage.dart';

class FaalApp extends StatefulWidget {
  const FaalApp({super.key});

  @override
  State<StatefulWidget> createState() => FaalAppState();
}

class FaalAppState extends State<FaalApp> {
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Remove `loading` div
      final loader = document.getElementsByClassName('loading');
      if (loader.isNotEmpty) {
        loader.first.remove();
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'فال حافظ',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          fontFamily: 'Samim',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.amber,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.amber,
          ),
        ),
        home: const HomePage(),
        builder: (BuildContext context, Widget? child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (BuildContext context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
            ),
          );
        });
  }
}
