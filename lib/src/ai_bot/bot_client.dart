import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_server.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';

class BotClient {
  BotClient({
    required String librarySearchPath,
    required this.callback,
    LLModelPromptConfig? promptConfig,
  }) {
    BotServer.initialize(
      librarySearchPath: librarySearchPath,
      promptConfig: promptConfig,
    );

    BotServer.shared.addListener(this);
  }

  final void Function(BotIsolateResponse response) callback;

  // must call dispose!
  void dispose() {
    BotServer.shared.removeListener(this);
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
