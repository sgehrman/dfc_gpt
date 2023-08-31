import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotClientNotifier {
  factory BotClientNotifier() {
    return _instance ??= BotClientNotifier._();
  }

  BotClientNotifier._();

  static BotClientNotifier? _instance;
  final List<BotClient> _clients = [];

  // this is used so we only shutdown if one client
  // if there are two windows open, we don't shutdown
  int get numClients => _clients.length;

  void addListener(BotClient client) {
    _clients.add(client);
  }

  void removeListener(BotClient client) {
    print('SNG removed client: $numClients');
    _clients.remove(client);
  }

  // called from server
  void notifyClients(BotIsolateResponse response) {
    for (final client in _clients) {
      client.callback(response);
    }
  }
}
