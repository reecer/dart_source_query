import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:source_query/src/responses/token_response.dart';

import 'responses/valve_response.dart';
import 'source_query_base.dart';

final DEFAULT_TOKEN = Uint8List.fromList([-1, -1, -1, -1]);
final MAX_TOKEN_RETRY = 5;

class ServerConn {
  final msgs = MsgQueue();
  final handlers = Completions();
  final UDP udp;

  final InternetAddress address;
  final int port;
  Uint8List _token = DEFAULT_TOKEN;

  ServerConn(this.address, this.port, this.udp);

  String get key => '${address}:${port}';

  Future<ValveResponse> send(MsgType msg) {
    _send(msg);

    switch (msg) {
      case MsgType.Info:
        return handlers.future<InfoResponse>();
        break;
      case MsgType.Rules:
        return handlers.future<RulesResponse>();
        break;
      case MsgType.Players:
        return handlers.future<PlayerResponse>();
        break;
    }
    return null;
  }

  void _send(MsgType msg) {
    print('Sending: ${msg}');

    var payload = _buildMsg(msg);
    msgs.enqueue(msg);
    udp.send(Datagram(payload, address, port));
  }

  void handleResponse(ValveResponse resp) {
    if (resp is TokenResponse) {
      _token = resp.token;
      msgs.sent.forEach((m) => _send(m));
      return;
    } else if (resp is InfoResponse) {
      msgs.sent.removeWhere((m) => m == MsgType.Info);
    } else if (resp is RulesResponse) {
      msgs.sent.removeWhere((m) => m == MsgType.Rules);
    } else if (resp is PlayerResponse) {
      msgs.sent.removeWhere((m) => m == MsgType.Players);
    }

    handlers.handle(resp);
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

class MsgQueue {
  final sent = <MsgType>{};

  void enqueue(MsgType msg) {
    sent.add(msg);
  }
}

class Completions {
  Completer<InfoResponse> _infoCompleter = Completer<InfoResponse>();
  Completer<RulesResponse> _rulesCompleter = Completer<RulesResponse>();
  Completer<PlayerResponse> _playerCompleter = Completer<PlayerResponse>();

  void handle(ValveResponse data) {
    if (data is InfoResponse) {
      _infoCompleter.complete(data);
      _infoCompleter = Completer<InfoResponse>();
    } else if (data is RulesResponse) {
      _rulesCompleter.complete(data);
      _rulesCompleter = Completer<RulesResponse>();
    } else if (data is PlayerResponse) {
      _playerCompleter.complete(data);
      _playerCompleter = Completer<PlayerResponse>();
    } else {
      print('Unknown valve response type: ${data}');
    }
  }

  Future<ValveResponse> future<T extends ValveResponse>() {
    if (T == InfoResponse) {
      return _infoCompleter.future;
    } else if (T == RulesResponse) {
      return _rulesCompleter.future;
    } else if (T == PlayerResponse) {
      return _playerCompleter.future;
    } else {
      print('Unknown valve send type: ${T}');
    }
    return null;
  }
}

class UDP {
  final int port;
  RawDatagramSocket _socket;
  Map<String, ServerConn> servers = {};

  UDP(this.port);

  Future startSocket() {
    return RawDatagramSocket.bind(InternetAddress.anyIPv4, port)
        .then((RawDatagramSocket socket) {
      _socket = socket;
      _socket.listen(_handleUDP);
    });

  }

  void stopSocket() {
    _socket.close();
  }

  void send(Datagram message, {retry = 0}) {
    var result = _socket.send(message.data, message.address, message.port);
    if (result < 1) {
      if (retry < 5) {
        send(message, retry: retry++);
        return;
      }
      throw "socket didn't send";
    }
  }

  ServerConn getConn(InternetAddress ip, int port) {
    var key = _key(ip, port);
    return servers.putIfAbsent(key, () => ServerConn(ip, port, this));
  }

  void _handleUDP(RawSocketEvent e) {
    var dg = _socket.receive();
    if (dg == null) {
      return;
    }
    var k = _key(dg.address, dg.port);
    if (!servers.containsKey(k)) {
      print('Recvd msg from unknown server: ${k}');
      return;
    }

    var result = ValveResponse.fromBuffer(dg.data);
    servers[k].handleResponse(result);
  }
}

String _key(ip, int port) {
  return '${ip}:${port}';
}
