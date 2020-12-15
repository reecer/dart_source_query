import 'dart:convert';
import 'dart:typed_data';

import 'rules_response.dart';
import 'info_response.dart';
import 'player_response.dart';
import 'token_response.dart';

class ValveResponse {
  int pos = 5;
  final ByteData blob;

  ValveResponse(this.blob);

  factory ValveResponse.fromBuffer(List<int> buffer) {
    var blob = Uint8List.fromList(buffer).buffer.asByteData();

    switch (buffer.elementAt(4)) {
      case 0x41:
        return TokenResponse.fromBlob(blob);
        break;
      case 0x49:
        return InfoResponse.fromBlob(blob);
        break;
      case 0x45:
        return RulesResponse.fromBlob(blob);
        break;
      case 0x44:
        return PlayerResponse.fromBlob(blob);
        break;
      default:
        print('Unknown msg type: ${buffer.elementAt(4)}');
    }
    return ValveResponse(blob);
  }

  int byte() {
    var val = blob.getUint8(pos);
    pos += 1;
    return val;
  }

  int short() {
    var val = blob.getInt16(pos, Endian.little);
    pos += 2;
    return val;
  }

  int long() {
    var val = blob.getInt32(pos);
    pos += 4;
    return val;
  }

  double float({little = false}) {
    var val = blob.getFloat32(pos, little ? Endian.little : Endian.big);
    pos += 4;
    return val;
  }

  int longlong() {
    var val = blob.getUint64(pos, Endian.little);
    pos += 8;
    return val;
  }

  String string() {
    var val = '';
    for (var i = pos; i < blob.lengthInBytes; i++) {
      var byte = blob.getUint8(i);
      if (byte == 0) {
        pos = i + 1;
        break;
      }

      val += String.fromCharCode(byte);
    }
    return utf8.decode(val.codeUnits);
  }
}
