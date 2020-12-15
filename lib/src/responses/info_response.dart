import 'valve_response.dart';

class InfoResponse extends ValveResponse {
  int protocol;
  String name;
  String map;
  String folder;
  String game;
  int id;
  int players;
  int maxPlayers;
  int bots;
  int serverType;
  int env;
  int visibility;
  int vac;
  String version;
  int flags;
  int port;
  int steamId;
  int spectatePort;
  String spectateName;
  String keywords;
  int gameId;

  InfoResponse.fromBlob(blob) : super(blob) {
    protocol = byte();
    name = string();
    map = string();
    folder = string();
    game = string();
    id = short();
    players = byte();
    maxPlayers = byte();
    bots = byte();
    serverType = byte();
    env = byte();
    visibility = byte();
    vac = byte();
    version = string();
    flags = byte();

    if (flags > 0) {
      if (flags & 0x80 != 0) {
        port = short();
      }
      if (flags & 0x10 != 0) {
        steamId = longlong();
      }
      if (flags & 0x40 != 0) {
        spectatePort = short();
        spectateName = string();
      }
      if (flags & 0x20 != 0) {
        keywords = string();
      }
      if (flags & 0x01 != 0) {
        gameId = longlong();
      }
    }
  }

  @override
  String toString() {
    return [protocol,name,map,folder,game,id,players,maxPlayers,bots,serverType,env,visibility,vac,version,flags,port,steamId,spectatePort,spectateName,keywords,gameId]
        .reduce((value, element) => '${value}\n${element}');
  }
}
