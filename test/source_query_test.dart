import 'dart:typed_data';

import 'package:source_query/src/responses/valve_response.dart';
import 'package:test/test.dart';



void main() {
  var resp = [255, 255, 255, 255, 73, 17, 82, 117, 115, 116, 111, 114, 105, 97, 46, 99, 111, 32, 45, 32, 85, 83, 32, 77, 97, 105, 110, 0, 80, 114, 111, 99, 101, 100, 117, 114, 97, 108, 32, 77, 97, 112, 0, 114, 117, 115, 116, 0, 82, 117, 115, 116, 0, 0, 0, 145, 169, 0, 100, 119, 0, 1, 50, 50, 55, 49, 0, 177, 111, 109, 6, 180, 113, 135, 188, 62, 64, 1, 109, 112, 52, 50, 53, 44, 99, 112, 51, 57, 54, 44, 112, 116, 114, 97, 107, 44, 113, 112, 48, 44, 118, 50, 50, 55, 49, 44, 104, 51, 57, 48, 97, 102, 100, 98, 100, 44, 115, 116, 111, 107, 44, 98, 111, 114, 110, 49, 54, 48, 55, 54, 51, 49, 49, 53, 50, 44, 103, 109, 114, 117, 115, 116, 44, 111, 120, 105, 100, 101, 0, 74, 218, 3, 0, 0, 0, 0, 0];
  // var msg = utf8.decode(resp, allowMalformed: false);
  // print(msg);

  group('Test info parser', () {
    setUp(() {
    });

    test('First Test', () {
      var result = ValveResponse.fromBuffer(resp);
      print(result);
      // expect(awesome.isAwesome, isTrue);
    });

    test('decode this', () {
      var id = [1, 64, 62, 188, 135, 113, 180, 6];
      var blob = ByteData.view(Uint8List.fromList(id).buffer);
      print(blob.getUint64(0, Endian.little));
    });
  });
}
