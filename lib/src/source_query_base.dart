import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'responses/token_response.dart';
import 'responses/valve_response.dart';
import 'udp.dart';

final DEFAULT_TOKEN = Uint8List.fromList([-1, -1, -1, -1]);
final MAX_TOKEN_RETRY = 5;

enum MsgType {
  Info, Rules, Players
}

class SourceQuery {
  final String ip;
  final int port;
  final _socket = UDP(1338);
  InternetAddress address;
  Uint8List _token = DEFAULT_TOKEN;

  SourceQuery(this.ip, this.port) {
    address = InternetAddress(ip);
  }

  Future<void> connect() {
    return _socket.startSocket();
  }

  Future<ValveResponse> getInfo() => _send(MsgType.Info);
  Future<ValveResponse> getRules() => _send(MsgType.Rules);
  Future<ValveResponse> getPlayers() => _send(MsgType.Players);

  Future<ValveResponse> _send(MsgType msg, {retry=0}) async {
    print('Sending: ${msg}');

    var payload = _buildMsg(msg);
    var resp = await _socket.send(Datagram(payload, address, port));

    if (resp is TokenResponse) {
      if (MAX_TOKEN_RETRY > 5) {
        throw 'Max token retry hit: ${MAX_TOKEN_RETRY}';
      }
      _token = resp.token;
      return _send(msg, retry: retry++);
    } else {
      return resp;
    }
  }

  Uint8List _buildMsg(MsgType msgType) {
    var msg = [];
    switch (msgType) {
      case MsgType.Info:
        msg = [0x54, ...'Source Engine Query'.codeUnits, 0];
        break;
      case MsgType.Players:
        msg = [0x55, ..._token];
        break;
      case MsgType.Rules:
        msg = [0x56, ..._token];
        break;
    }

    return Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, ...msg]);
  }
}