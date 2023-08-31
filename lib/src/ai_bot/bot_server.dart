import 'dart:async';

import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_client_notifier.dart';
import 'package:dfc_gpt/src/ai_bot/bot_isolate.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotServer {
  factory BotServer({
    required BotConfig config,
  }) {
    return _instance ??= BotServer._(
      config: config,
    );
  }

  BotServer._({
    required this.config,
  }) {
    _setup();
  }

  static void initialize({
    required BotConfig config,
  }) {
    // initialize _instance
    BotServer(
      config: config,
    );
  }

  static BotServer get shared {
    if (_instance == null) {
      throw StateError('Call initialize first');
    }

    return _instance!;
  }

  static BotServer? _instance;
  final BotConfig config;
  late BotIsolate _botIsolate;

  void _setup() {
    _botIsolate = BotIsolate(
      config: config,
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
