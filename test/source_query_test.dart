import 'dart:async';
import 'dart:math';

import 'package:source_query/source_query.dart';
import 'package:source_query/src/responses/valve_response.dart';
import 'package:test/test.dart';


void main() {
  group('SourceQuery', () {
    var ip = '162.248.88.169', port = 28015;
    var rand = Random();
    SourceQuery sq;

    setUp(() async {
      var randPort = 1023 + rand.nextInt(10000);
      sq = SourceQuery(randPort);
      await sq.connect();
    });

    tearDown(() {
      sq.disconnect();
    });

    test('getInfo', () async {
      var info = await sq.getInfo(ip, port);
      expect(info, isA<InfoResponse>());
      print(info.name);
    });

    test('getRules', () async {
      var rules = await sq.getRules(ip, port);
      expect(rules, isA<RulesResponse>());
      print((rules).rules.length);
    });

    test('getPlayers', () async {
      var players = await sq.getPlayers(ip, port);
      expect(players, isA<PlayerResponse>());
      print((players).length);
    });

    test('parallel fetching', () async {
      var f1 = sq.getInfo(ip, port),
          f2 = sq.getPlayers(ip, port),
          f3 = sq.getRules(ip, port);

      var results = await Future.wait([f1, f2, f3]).timeout(Duration(seconds: 10));
      var info = results[0];
      var players = results[1];
      var rules = results[2];

      expect(info, isA<InfoResponse>());
      expect(rules, isA<RulesResponse>());
      expect(players, isA<PlayerResponse>());
    });

  });
  group('Valve response parsing', () {
    var resp = [255, 255, 255, 255, 73, 17, 82, 117, 115, 116, 111, 114, 105, 97, 46, 99, 111, 32, 45, 32, 85, 83, 32, 77, 97, 105, 110, 0, 80, 114, 111, 99, 101, 100, 117, 114, 97, 108, 32, 77, 97, 112, 0, 114, 117, 115, 116, 0, 82, 117, 115, 116, 0, 0, 0, 145, 169, 0, 100, 119, 0, 1, 50, 50, 55, 49, 0, 177, 111, 109, 6, 180, 113, 135, 188, 62, 64, 1, 109, 112, 52, 50, 53, 44, 99, 112, 51, 57, 54, 44, 112, 116, 114, 97, 107, 44, 113, 112, 48, 44, 118, 50, 50, 55, 49, 44, 104, 51, 57, 48, 97, 102, 100, 98, 100, 44, 115, 116, 111, 107, 44, 98, 111, 114, 110, 49, 54, 48, 55, 54, 51, 49, 49, 53, 50, 44, 103, 109, 114, 117, 115, 116, 44, 111, 120, 105, 100, 101, 0, 74, 218, 3, 0, 0, 0, 0, 0];

    test('Decodes response', () {
      var result = ValveResponse.fromBuffer(resp);
      expect(result, isA<InfoResponse>());
      expect((result as InfoResponse).keywords, 'mp425,cp396,ptrak,qp0,v2271,h390afdbd,stok,born1607631152,gmrust,oxide');
    });
  });
}
