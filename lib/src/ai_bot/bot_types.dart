import 'package:dfc_gpt/src/ai_lib/models/gpt_model_file.dart';

class BotIsolateResponse {
  const BotIsolateResponse({
    required this.type,
    required this.data,
    required this.fromUser,
  });

  final String type;
  final String data;
  final bool fromUser;
}

// --------------------------------

class BotRequest {
  const BotRequest({
    required this.modelFile,
    required this.question,
  });

  final GptModelFile modelFile;
  final String question;
}

// --------------------------------

class BotResponse {
  const BotResponse({
    required this.output,
  });

  final String output;
}

// --------------------------------

class BotShutdown {
  const BotShutdown();
}

// --------------------------------

class BotIsolateFinished {
  const BotIsolateFinished();
}
