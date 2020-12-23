import 'package:source_query/source_query.dart';

// var ip = '208.103.169.97', port = 28015;
// var ip = '37.230.228.177', port = 10000;
// var ip = '139.99.124.15', port = 28070;
var ip = '162.248.88.169', port = 28015;

void main() async {
  var sq = SourceQuery(8742);
  await sq.connect();

  var info = await sq.getInfo(ip, port);
  print('Info: ${info.keywords}');

  var rules = await sq.getRules(ip, port);
  print('Rules: ${rules}');

  var players = await sq.getPlayers(ip, port);
  print('Players: ${players.length}');
}
