import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_client_notifier.dart';
import 'package:dfc_gpt/src/ai_bot/bot_server.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotClient {
  BotClient({
    required BotConfig config,
    required this.callback,
  }) {
    BotServer.initialize(
      config: config,
    );

    BotClientNotifier().addListener(this);
  }

  // BotClientNotifier calls this
  final void Function(BotIsolateResponse response) callback;

  // must call dispose!
  void dispose() {
    BotClientNotifier().removeListener(this);
  }

  void askQuestion({
    required String modelPath,
    required String question,
  }) {
    BotServer.shared.askQuestion(modelPath: modelPath, question: question);
  }

  void shutdown() {
    // BotServer.shared.askQuestion(question: question);
  }
}
