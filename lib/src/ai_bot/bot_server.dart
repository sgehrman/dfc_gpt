import 'dart:async';

import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_client_notifier.dart';
import 'package:dfc_gpt/src/ai_bot/bot_isolate.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotServer {
  factory BotServer({
    required String librarySearchPath,
    required LLModelPromptConfig? promptConfig,
  }) {
    return _instance ??= BotServer._(
      librarySearchPath: librarySearchPath,
      promptConfig: promptConfig,
    );
  }

  BotServer._({
    required this.librarySearchPath,
    required this.promptConfig,
  }) {
    _setup();
  }

  static void initialize({
    required String librarySearchPath,
    required LLModelPromptConfig? promptConfig,
  }) {
    // initialize _instance
    BotServer(
      librarySearchPath: librarySearchPath,
      promptConfig: promptConfig,
    );
  }

  static BotServer get shared {
    if (_instance == null) {
      throw StateError('Call initialize first');
    }

    return _instance!;
  }

  static BotServer? _instance;
  final String librarySearchPath;
  final LLModelPromptConfig? promptConfig;
  late BotIsolate _botIsolate;

  void _setup() {
    _botIsolate = BotIsolate(
      librarySearchPath: librarySearchPath,
      promptConfig: promptConfig,
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
