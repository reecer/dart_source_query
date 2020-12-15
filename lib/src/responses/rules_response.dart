import 'valve_response.dart';

class Rule {
  final String name;
  final String value;

  Rule(this.name, this.value);

  @override
  String toString() {
    return '${name}=${value}';
  }
}

class RulesResponse extends ValveResponse {
  final rules = <Rule>[];

  RulesResponse.fromBlob(blob) : super(blob) {
    var count = short();
    for (var i = 0; i < count; i++) {
      rules.add(rule());
    }
  }
  Rule rule() {
    return Rule(string(), string());
  }

  @override
  String toString() {
    return rules.join('\n') + '\n${rules.length} Rules';
  }
}
