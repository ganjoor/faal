class GanjoorPoem {
  final int id;
  final String title;
  final String fullUrl;
  String htmlText;

  GanjoorPoem({this.id, this.title, this.fullUrl, this.htmlText});

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

    return GanjoorPoem(
        id: json['id'],
        title: json['title'],
        fullUrl: json['fullUrl'],
        htmlText: poemText);
  }
}
