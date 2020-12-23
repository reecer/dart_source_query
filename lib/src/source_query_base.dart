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
  final _socket = UDP(1338);

  SourceQuery(this.port);

  Future<void> connect() {
    return _socket.startSocket();
  }

  Future<InfoResponse> getInfo(String ip, int port) => _send<InfoResponse>(MsgType.Info, ip, port);
  Future<RulesResponse> getRules(String ip, int port) => _send<RulesResponse>(MsgType.Rules, ip, port);
  Future<PlayerResponse> getPlayers(String ip, int port) => _send<PlayerResponse>(MsgType.Players, ip, port);

  Future<T> _send<T extends ValveResponse>(MsgType msg, String ip, int port) async {
    print('Sending: ${msg}');

    var addr = InternetAddress(ip);
    var conn = _socket.getConn(addr, port);
    return conn.send(msg);
  }
}