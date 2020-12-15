import 'package:source_query/source_query.dart';
import 'package:source_query/src/responses/info_response.dart';
import 'package:source_query/src/responses/player_response.dart';

// var ip = '208.103.169.97', port = 28015;
// var ip = '37.230.228.177', port = 10000;
// var ip = '139.99.124.15', port = 28070;
var ip = '162.248.88.169', port = 28015;

void main() async {
  var sq = SourceQuery(ip, port);
  await sq.connect();

  var info = await sq.getInfo() as InfoResponse;
  print('Info: ${info.keywords}');

  // var rules = await sq.getRules();
  // print('Rules: ${rules}');

  var players = await sq.getPlayers() as PlayerResponse;
  print('Players: ${players.length}');
}
