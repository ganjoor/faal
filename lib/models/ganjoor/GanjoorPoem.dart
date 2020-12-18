import 'package:tuple/tuple.dart';

class GanjoorPoem {
  final int id;
  final String title;
  final String fullUrl;
  final List<Tuple2<int, String>> verses;

  GanjoorPoem({this.id, this.title, this.fullUrl, this.verses});

  factory GanjoorPoem.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    String poemText = json['htmlText'];
    poemText = poemText.replaceAll('<p>', '');
    poemText = poemText.replaceAll('<div class=\"b\">', '');
    poemText = poemText.replaceAll('<div class=\"b2\">', '');
    poemText = poemText.replaceAll('<div class=\"m1\">', '');
    poemText = poemText.replaceAll('<div class=\"m2\">', '');
    poemText = poemText.replaceAll('<div class=\"n\">', '');
    poemText = poemText.replaceAll('</p>', '');
    poemText = poemText.replaceAll('</div>', '');

    List<Tuple2<int, String>> locVeres = List<Tuple2<int, String>>();
    int i = 1;
    for (String line in poemText.split('\r\n')) {
      locVeres.add(Tuple2<int, String>(i, '  ' + line + '  '));
      i++;
    }

    return GanjoorPoem(
        id: json['id'],
        title: json['title'],
        fullUrl: json['fullUrl'],
        verses: locVeres);
  }
}
