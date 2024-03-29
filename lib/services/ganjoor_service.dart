import 'dart:convert';

import 'package:faal/models/ganjoor/ganjoor_poem_complete_view_model.dart';
import 'package:faal/models/recitation/recitation_verse_sync.dart';
import 'package:faal/services/gservice_address.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class GanjoorService {
  Future<Tuple2<GanjoorPoemCompleteViewModel?, String>> faal() async {
    try {
      var apiRoot = GServiceAddress.url;
      http.Response response = await http
          .get(Uri.parse('$apiRoot/api/ganjoor/hafez/faal'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        return Tuple2<GanjoorPoemCompleteViewModel?, String>(
            GanjoorPoemCompleteViewModel.fromJson(json.decode(response.body)),
            '');
      } else {
        return Tuple2<GanjoorPoemCompleteViewModel?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<GanjoorPoemCompleteViewModel?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  Future<Tuple2<List<RecitationVerseSync?>?, String>> getVerses(int id) async {
    try {
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.get(
          Uri.parse('$apiRoot/api/audio/verses/$id'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'});

      List<RecitationVerseSync?> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(RecitationVerseSync.fromJson(item));
        }
        return Tuple2<List<RecitationVerseSync?>?, String>(ret, '');
      } else {
        return Tuple2<List<RecitationVerseSync?>?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<List<RecitationVerseSync?>?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }
}
