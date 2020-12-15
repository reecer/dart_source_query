import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'responses/valve_response.dart';


class UDP {
  final int port;
  RawDatagramSocket _socket;
  StreamSubscription<RawSocketEvent> _socketSub;

  ValveResponse response;
  var messages = Queue<ValveResponse>();

  UDP(this.port);

  Future startSocket() {
    return RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then(
      (RawDatagramSocket socket) {
        _socket = socket;
      }
    );
  }

  Future<ValveResponse> send(Datagram requestToSend) {
    // All sends expect a response
    var completer = Completer<ValveResponse>();
    var recv = (e) {
      var dg = _socket.receive();
      if (dg != null) {
        var result = ValveResponse.fromBuffer(dg.data);
        completer.complete(result);
        _socketSub.onData(null);
      }
    };

    // Setup response capturing
    if (_socketSub == null) {
      _socketSub = _socket.listen(recv);
    } else {
      _socketSub.onData(recv);
    }

    // Send the packet
    var result = _socket.send(requestToSend.data, requestToSend.address, requestToSend.port);
    if (result == 0) {
      throw "socket didn't send";
    }

    return completer.future;
  }
}