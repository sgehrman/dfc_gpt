import 'dart:async';

import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_client_notifier.dart';
import 'package:dfc_gpt/src/ai_bot/bot_isolate.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotServer {
  factory BotServer({required BotConfig config}) {
    return _instance ??= BotServer._(config: config);
  }

  BotServer._({required this.config}) {
    _botIsolate = BotIsolate(
      config: config,
      callback: (response) {
        BotClientNotifier().notifyClients(response);
      },
    );
  }

  static BotServer? _instance;
  final BotConfig config;
  BotIsolate? _botIsolate;

  static void initialize({required BotConfig config}) {
    // initialize _instance
    BotServer(config: config);
  }

  static BotServer get shared {
    if (_instance == null) {
      throw StateError('Call initialize first');
    }

    return _instance!;
  }

  void tearDown() {
    _botIsolate?.dispose();

    // set shared instance to null
    _instance = null;
  }

  Future<void> askQuestion({
    required GptModelFile modelFile,
    required String question,
  }) async {
    // send question asked from use first
    // that way your list of messages list for your typing and the bots
    BotClientNotifier().notifyClients(
      BotIsolateResponse(type: 'gpt-response', data: question, fromUser: true),
    );

    await _botIsolate?.send(
      BotRequest(modelFile: modelFile, question: question),
    );
  }
}
