import 'dart:typed_data';

import 'valve_response.dart';

class Player {
  int index;
  String name;
  int score;
  double duration;

  Player(this.index, this.name, this.score, this.duration);

  @override
  String toString() {
    return [index, name, score, duration].join('|');
  }
}

class PlayerResponse extends ValveResponse {
  final players = <Player>[];

  PlayerResponse.fromBlob(ByteData  blob) : super(blob) {
    while(pos < blob.lengthInBytes) {
      players.add(player());
    }
  }

  Player player() {
    return Player(byte(), string(), long(), float(little: true));
  }

  int get length {
    return players.length;
  }

  @override
  String toString() {
    return players.join(', ') + '\n${players.length} Players';
  }
}
