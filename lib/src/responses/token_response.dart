import 'dart:typed_data';

import 'valve_response.dart';

class TokenResponse extends ValveResponse {
  Uint8List token;

  TokenResponse.fromBlob(blob) : super(blob) {
    token = _int();
  }

  Uint8List _int() {
    var val = blob.buffer.asUint8List(pos, 4);
    pos += 4;
    return val;
  }

  @override
  String toString() {
    return '${token}';
  }
}
