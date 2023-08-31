import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotClientNotifier {
  factory BotClientNotifier() {
    return _instance ??= BotClientNotifier._();
  }

  BotClientNotifier._();

  static BotClientNotifier? _instance;
  final List<BotClient> _clients = [];

  void addListener(BotClient client) {
    _clients.add(client);
  }

  void removeListener(BotClient client) {
    _clients.remove(client);
  }

  // called from server
  void notifyClients(BotIsolateResponse response) {
    for (final client in _clients) {
      client.callback(response);
    }
  }
}
