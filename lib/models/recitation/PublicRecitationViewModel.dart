import 'package:faal/models/recitation/recitation-verse-sync.dart';

class PublicRecitationViewModel {
  final int id;
  final int poemId;
  final String poemFullTitle;
  final String poemFullUrl;
  final String audioTitle;
  final String audioArtist;
  final String audioArtistUrl;
  final String audioSrc;
  final String audioSrcUrl;
  final String legacyAudioGuid;
  final String mp3FileCheckSum;
  final int mp3SizeInBytes;
  final String publishDate;
  final String fileLastUpdated;
  final String mp3Url;
  final String xmlText;
  final String plainText;
  final String htmlText;
  List<RecitationVerseSync> verses;
  bool isExpanded = false;

  PublicRecitationViewModel(
      {this.id,
      this.poemId,
      this.poemFullTitle,
      this.poemFullUrl,
      this.audioTitle,
      this.audioArtist,
      this.audioArtistUrl,
      this.audioSrc,
      this.audioSrcUrl,
      this.legacyAudioGuid,
      this.mp3FileCheckSum,
      this.mp3SizeInBytes,
      this.publishDate,
      this.fileLastUpdated,
      this.mp3Url,
      this.xmlText,
      this.plainText,
      this.htmlText});

  factory PublicRecitationViewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return PublicRecitationViewModel(
        id: json['id'],
        poemId: json['id'],
        poemFullTitle: json['poemFullTitle'],
        poemFullUrl: json['poemFullUrl'],
        audioTitle: json['audioTitle'],
        audioArtist: json['audioArtist'],
        audioArtistUrl: json['audioArtistUrl'],
        audioSrc: json['audioSrc'],
        audioSrcUrl: json['audioSrcUrl'],
        legacyAudioGuid: json['legacyAudioGuid'],
        mp3FileCheckSum: json['mp3FileCheckSum'],
        mp3SizeInBytes: json['mp3SizeInBytes'],
        publishDate: json['publishDate'],
        fileLastUpdated: json['fileLastUpdated'],
        mp3Url: json['mp3Url'],
        xmlText: json['xmlText'],
        plainText: json['plainText'],
        htmlText: json['htmlText']);
  }
}
