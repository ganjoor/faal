import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ganjoor/ganjoor_poem_complete_view_model.dart';
import '../models/recitation/public_recitation_view_model.dart';
import '../services/ganjoor_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {
  final GlobalKey<ScaffoldMessengerState> _key =
      GlobalKey<ScaffoldMessengerState>();
  bool _isLoading = false;
  GanjoorPoemCompleteViewModel? _poem;
  PublicRecitationViewModel? _recitation;
  late AudioPlayer _player;
  int _curVerseOrder = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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

  Future _faal(bool autoPlay) async {
    if (_player.playing) {
      await _player.stop();
    }
    _curVerseOrder = 0;
    setState(() {
      _isLoading = true;
    });
    var res = await GanjoorService().faal();
    setState(() {
      _isLoading = false;
    });
    if (res.item2.isNotEmpty) {
      _key.currentState!.showSnackBar(SnackBar(
        content: Text('خطا در دریافت نتیجه: ${res.item2}'),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {
      if (res.item2.isEmpty) {
        _poem = res.item1;
      }
    });

    await _selectRandomRecitation(autoPlay);
  }

  List<Widget> get _verseWigets {
    if (_poem == null) return [];
    return _poem!.verses
        .map((e) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Visibility(
                  visible: e.item1 != _curVerseOrder,
                  child: Text(
                    e.item2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IranNastaliq',
                      fontSize: 28,
                    ),
                  )),
              Visibility(
                  visible: e.item1 == _curVerseOrder,
                  child: AnimatedTextKit(
                      repeatForever: false,
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          e.item2,
                          speed: const Duration(milliseconds: 100),
                          textStyle: const TextStyle(
                              fontSize: 36,
                              fontFamily: 'IranNastaliq',
                              color: Colors.brown),
                          textAlign: TextAlign.start,
                        )
                      ]))
            ]))
        .toList();
  }

  void setCurVerse(Duration? position) {
    if (position == null ||
        _recitation == null ||
        _recitation!.verses == null) {
      return;
    }
    var verse = _recitation == null || _recitation!.verses == null
        ? null
        : _recitation!.verses!.lastWhere((element) =>
            element!.audioStartMilliseconds <= position.inMilliseconds);
    if (verse == null) {
      return;
    }
    setState(() {
      _curVerseOrder = verse.verseOrder;
    });
  }

  Future _selectRandomRecitation(bool autoPlay) async {
    if (_poem == null) {
      return;
    }
    if (_poem!.recitations.isEmpty) {
      return;
    }

    if (_player.playing) {
      await _player.stop();
      return;
    }

    _curVerseOrder = 0;

    _recitation =
        _poem!.recitations[Random().nextInt(_poem!.recitations.length)];

    if (_recitation!.verses == null) {
      setState(() {
        _isLoading = true;
      });
      var res = await GanjoorService().getVerses(_recitation!.id);
      setState(() {
        _isLoading = false;
      });
      if (res.item2.isEmpty) {
        setState(() {
          _recitation!.verses = res.item1;
        });
      }
    }

    await _player.setUrl(_recitation!.mp3Url);
    if (autoPlay) {
      await _player.play();
    }
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
                title: Row(children: [
                  Image(
                    image: const AssetImage('web/icons/Icon-192.png'),
                    width: AppBar().preferredSize.height,
                    height: AppBar().preferredSize.height,
                    alignment: FractionalOffset.center,
                  ),
                  const Text('فال حافظ')
                ]),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () async {
                      if (_poem == null) {
                        return;
                      }
                      var url = 'https://ganjoor.net${_poem!.fullUrl}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw 'خطا در نمایش نشانی $url';
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(_player.playing
                        ? Icons.stop_circle
                        : Icons.play_circle_fill),
                    tooltip: 'توقف / پخش',
                    onPressed: () async {
                      if (_player.playing) {
                        await _player.stop();
                      } else {
                        await _player.play();
                      }
                    },
                  ),
                  PopupMenuButton<int>(
                    tooltip: 'تغییر خوانشگر',
                    onSelected: (int? id) async {
                      if (id == null) return;
                      if (_player.playing) {
                        await _player.stop();
                      }

                      if (_recitation!.verses == null) {
                        setState(() {
                          _isLoading = true;
                        });
                        var res =
                            await GanjoorService().getVerses(_recitation!.id);
                        setState(() {
                          _isLoading = false;
                        });
                        if (res.item2.isEmpty) {
                          _recitation!.verses = res.item1;
                        }
                      }

                      await _player.setUrl(_recitation!.mp3Url);

                      await _player.play();
                    },
                    child: ElevatedButton.icon(
                        icon: const Icon(Icons.person),
                        onPressed: null,
                        label: Text(_recitation == null
                            ? ''
                            : _recitation!.audioArtist)),
                    itemBuilder: (BuildContext context) {
                      if (_poem != null) {
                        return _poem!.recitations
                            .map((e) => PopupMenuItem<int>(
                                value: e!.id, child: Text(e.audioArtist)))
                            .toList();
                      }
                      return <PopupMenuEntry<int>>[];
                    },
                  )
                ],
              ),
              body: SingleChildScrollView(
                  child: DecoratedBox(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/paper.jpg'),
                            fit: BoxFit.cover),
                      ),
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
                      ))),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await _faal(true);
                },
                tooltip: 'فال نو',
                child: const Icon(Icons.refresh),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            )));
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await _faal(false);
  }
}
