class BotIsolateResponse {
  const BotIsolateResponse({
    required this.type,
    required this.data,
    this.fromUser = false,
  });

  final String type;
  final String data;
  final bool fromUser;
}

// --------------------------------

class BotRequest {
  const BotRequest({
    required this.modelPath,
    required this.question,
  });

  final String modelPath;
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
