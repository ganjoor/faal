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
        verses: (json['verses'] as List)
            .map((e) => Tuple2<int, String>(e['vOrder'], e['text']))
            .toList());
  }
}
