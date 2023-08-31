import 'package:dfc_gpt/src/ai_lib/models/llmodel_prompt_config.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bot_config.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class BotConfig {
  BotConfig({
    required this.librarySearchPath,
    this.promptConfig,
    this.debug = false,
  });

  factory BotConfig.fromJson(Map<String, dynamic> json) =>
      _$BotConfigFromJson(json);

  final String librarySearchPath;
  final LLModelPromptConfig? promptConfig;
  final bool debug;

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() => _$BotConfigToJson(this);
}
