import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:faal/models/ganjoor/GanjoorPoemCompleteViewModel.dart';
import 'package:faal/models/recitation/PublicRecitationViewModel.dart';
import 'package:faal/services/ganjoor-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart';

void main() {
  runApp(FaalApp());
}

class FaalApp extends StatefulWidget {
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
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.green,
            fontFamily: 'Samim'),
        home: MyHomePage(),
        builder: (BuildContext context, Widget child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (BuildContext context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: child,
                );
              },
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  final GlobalKey<ScaffoldMessengerState> _key =
      GlobalKey<ScaffoldMessengerState>();
  bool _isLoading = false;
  GanjoorPoemCompleteViewModel _poem;
  PublicRecitationViewModel _recitation;
  AudioPlayer _player;
  int _curVerseOrder = 0;
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _player.createPositionStream().listen((event) {
      setCurVerse(event);
    });
  }

  @override
  void dispose() {
    _player.dispose();

    super.dispose();
  }

  Future _faal() async {
    setState(() {
      _isLoading = true;
    });
    var res = await GanjoorService().faal();
    if (res.item2.isNotEmpty) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text("خطا در دریافت نتیجه: " + res.item2),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {
      _isLoading = false;
      if (res.item2.isEmpty) {
        _poem = res.item1;
      }
    });
  }

  List<Widget> get _verseWigets {
    if (_poem == null) return [];
    return _poem.poem.verses
        .map((e) => Text(e.item2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'IranNastaliq',
                fontSize: 28,
                color: e.item1 == _curVerseOrder ? Colors.red : Colors.black)))
        .toList();
  }

  void setCurVerse(Duration position) {
    if (position == null || _recitation == null || _recitation.verses == null) {
      return;
    }
    var verse = _recitation.verses.lastWhere(
        (element) => element.audioStartMilliseconds <= position.inMilliseconds);
    if (verse == null) {
      return;
    }
    setState(() {
      _curVerseOrder = verse.verseOrder;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return ScaffoldMessenger(
        key: _key,
        child: LoadingOverlay(
            isLoading: _isLoading,
            child: Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text('فال حافظ'),
                actions: [
                  IconButton(
                    icon: Icon(_player.playing ? Icons.stop : Icons.play_arrow),
                    tooltip: 'بخوان',
                    onPressed: () async {
                      if (_poem == null) {
                        return;
                      }
                      if (_poem.recitations.length == 0) {
                        return;
                      }

                      if (_player.playing) {
                        await _player.stop();
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      _recitation = _poem.recitations[
                          Random().nextInt(_poem.recitations.length)];

                      if (_recitation.verses == null) {
                        var res =
                            await GanjoorService().getVerses(_recitation.id);
                        if (res.item2.isEmpty) {
                          _recitation.verses = res.item1;
                        }
                      }

                      await _player.setUrl(_recitation.mp3Url);
                      _player.play();

                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                  child: Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Column(
                  // Column is also a layout widget. It takes a list of children and
                  // arranges them vertically. By default, it sizes itself to fit its
                  // children horizontally, and tries to be as tall as its parent.
                  //
                  // Invoke "debug painting" (press "p" in the console, choose the
                  // "Toggle Debug Paint" action from the Flutter Inspector in Android
                  // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                  // to see the wireframe for each widget.
                  //
                  // Column has various properties to control how it sizes itself and
                  // how it positions its children. Here we use mainAxisAlignment to
                  // center the children vertically; the main axis here is the vertical
                  // axis because Columns are vertical (the cross axis would be
                  // horizontal).
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _verseWigets,
                ),
              )),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await _faal();
                },
                tooltip: 'فال نو',
                child: Icon(Icons.add),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            )));
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await _faal();
  }
}
