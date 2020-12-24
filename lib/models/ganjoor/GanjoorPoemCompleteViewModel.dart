import 'package:faal/models/recitation/PublicRecitationViewModel.dart';
import 'package:tuple/tuple.dart';

class GanjoorPoemCompleteViewModel {
  final int id;
  final String title;
  final String fullTitle;
  final String urlSlug;
  final String fullUrl;
  final String plainText;
  final String htmlText;
  final List<PublicRecitationViewModel> recitations;
  final List<Tuple2<int, String>> verses;

  GanjoorPoemCompleteViewModel(
      {this.id,
      this.title,
      this.fullTitle,
      this.urlSlug,
      this.fullUrl,
      this.plainText,
      this.htmlText,
      this.recitations,
      this.verses});

  factory GanjoorPoemCompleteViewModel.fromJson(Map<String, dynamic> json) {
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

    List<Tuple2<int, String>> locVeres = [];
    int i = 1;
    for (String line in poemText.split('\r\n')) {
      locVeres.add(Tuple2<int, String>(i, '  ' + line + '  '));
      i++;
    }

    return GanjoorPoemCompleteViewModel(
        id: json['id'],
        title: json['title'],
        fullTitle: json['fullTitle'],
        urlSlug: json['urlSlug'],
        fullUrl: json['fullUrl'],
        plainText: json['plainText'],
        htmlText: json['htmlText'],
        recitations: (json['recitations'] as List)
            .map((i) => PublicRecitationViewModel.fromJson(i))
            .toList(),
        verses: locVeres);
  }
}
