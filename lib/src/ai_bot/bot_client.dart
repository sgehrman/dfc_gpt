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

  static int get numClients => BotClientNotifier().numClients;

  // must call dispose!
  void dispose() {
    BotClientNotifier().removeListener(this);
  }

  // tearDown the whole gpt server and free up memory
  void tearDown() {
    BotServer.shared.tearDown();
  }

  void askQuestion({
    required GptModelFile modelFile,
    required String question,
  }) {
    BotServer.shared.askQuestion(modelFile: modelFile, question: question);
  }

  void shutdown() {
    // BotServer.shared.askQuestion(question: question);
  }
}
