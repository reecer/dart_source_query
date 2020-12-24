import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:source_query/source_query.dart';

import 'responses/valve_response.dart';
import 'udp.dart';

final DEFAULT_TOKEN = Uint8List.fromList([-1, -1, -1, -1]);
final MAX_TOKEN_RETRY = 5;

enum MsgType {
  Info, Rules, Players
}

class SourceQuery {
  final int port;
  UDP _udp;

  SourceQuery(this.port) {
    _udp = UDP(port);
  }

  Future<void> connect() {
    return _udp.startSocket();
  }

  void disconnect() {
    _udp.stopSocket();
  }

  Future<InfoResponse> getInfo(String ip, int port) => _send<InfoResponse>(MsgType.Info, ip, port);
  Future<RulesResponse> getRules(String ip, int port) => _send<RulesResponse>(MsgType.Rules, ip, port);
  Future<PlayerResponse> getPlayers(String ip, int port) => _send<PlayerResponse>(MsgType.Players, ip, port);

  Future<T> _send<T extends ValveResponse>(MsgType msg, String ip, int port) async {
    var conn = _udp.getConn(InternetAddress(ip), port);
    return conn.send(msg);
  }
}