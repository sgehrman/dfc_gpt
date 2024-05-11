import 'package:json_annotation/json_annotation.dart';

part 'llmodel_prompt_config.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class LLModelPromptConfig {
  LLModelPromptConfig({
    this.logits = const [],
    this.tokens = const [],
    this.nPast = 0,
    this.nCtx = 1024, // 512 default, more than 2048 is bad
    this.nPredict = 4096, // default: 128, -1 = infinity
    this.topK = 40, // 40 is default
    this.topP = 0.4, // 0.9 is default
    this.minP = 0.05, // 0.05 is default
    this.temp = 0.7, // 0.8 is default
    this.nBatch = 128, // default: 512 prompt Batch Size
    this.repeatPenalty = 1.18, // 1.1 is default
    this.repeatLastN = 64, // repeat_penalty_tokens
    this.contextErase = 0.55,
  });

  factory LLModelPromptConfig.fromJson(Map<String, dynamic> json) =>
      _$LLModelPromptConfigFromJson(json);

  final List<double> logits;
  final List<int> tokens;

  final int nPast;
  final int nCtx; // 512 default, more than 2048 is bad
  final int nPredict; // default: 128, -1 = infinity
  final int topK;
  final double topP; // 0.9 is default
  final double minP; // 0.05 is default
  final double temp; // 0.8 is default
  final int nBatch; // default: 512 prompt Batch Size
  final double repeatPenalty; // 1.1 is default
  final int repeatLastN; // repeat_penalty_tokens
  final double contextErase;

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() => _$LLModelPromptConfigToJson(this);
}

// ===============================================================
// NOTES:
// shared_libs/gpt4all/gpt4all-backend/llama.cpp-230511/examples/main/README.md

// ** go defaults
// int nPast = 0;
// int nCtx = 1024;
// int nPredict = 50;
// int topK = 10;
// double topP = 0.9;
// double temp = 1;
// int nBatch = 1;
// double repeatPenalty = 1.2;
// int repeatLastN = 10;
// double contextErase = 0.5;

// ** original defaults
// int nPast = 0;
// int nCtx = 1024;
// int nPredict = 128;
// int topK = 40;
// double topP = 0.95;
// double temp = 0.28;
// int nBatch = 8;
// double repeatPenalty = 1.1;
// int repeatLastN = 10;
// double contextErase = 0.55;

// ** chat app defaults
