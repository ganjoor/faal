import 'dart:convert';

import 'package:faal/services/gservice-address.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class GanjoorService {
  Future<Tuple2<dynamic, String>> faal() async {
    try {
      var apiRoot = GServiceAddress.Url;
      http.Response response =
          await http.get('$apiRoot/api/ganjoor/hafez/faal', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        return Tuple2<dynamic, String>(
            json.decode(response.body)['poem']['plainText'], '');
      } else {
        return Tuple2<dynamic, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<dynamic, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }
}
