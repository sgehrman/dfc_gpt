import 'dart:async';

import 'package:dfc_gpt/src/ai_bot/bot_client.dart';
import 'package:dfc_gpt/src/ai_bot/bot_isolate.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotServer {
  factory BotServer({
    required String librarySearchPath,
  }) {
    return _instance ??= BotServer._(
      librarySearchPath: librarySearchPath,
    );
  }

  BotServer._({
    required this.librarySearchPath,
  }) {
    _setup();
  }

  // ==================================================

  static void initialize({
    required String librarySearchPath,
  }) {
    if (_instance == null) {
      BotServer(librarySearchPath: librarySearchPath);
    }
  }

  static BotServer get shared {
    if (_instance == null) {
      throw StateError('Call initialize first');
    }

    return _instance!;
  }

  static BotServer? _instance;

  final String librarySearchPath;

  late BotIsolate _botIsolate;

  void addListener(BotClient client) {
    BotClientNotifier().addListener(client);
  }

  void removeListener(BotClient client) {
    BotClientNotifier().removeListener(client);
  }

  void _setup() {
    _botIsolate = BotIsolate(
      librarySearchPath: librarySearchPath,
      callback: (BotIsolateResponse response) {
        BotClientNotifier().notifyClients(response);
      },
    );
  }

  Future<void> askQuestion({
    required String modelPath,
    required String question,
  }) async {
    // send question asked from use first
    // that way your list of messages list for your typing and the bots
    BotClientNotifier().notifyClients(
      BotIsolateResponse(
        type: 'gpt-response',
        data: question,
        fromUser: true,
      ),
    );

    await _botIsolate.send(
      BotRequest(modelPath: modelPath, question: question),
    );
  }

  void shutdown() {
    _botIsolate.send(const BotShutdown());
  }
}

// ============================================================

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
