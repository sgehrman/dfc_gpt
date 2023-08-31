// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llmodel_prompt_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LLModelPromptConfig _$LLModelPromptConfigFromJson(Map<String, dynamic> json) =>
    LLModelPromptConfig(
      logits: (json['logits'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      tokens:
          (json['tokens'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      nPast: json['nPast'] as int? ?? 0,
      nCtx: json['nCtx'] as int? ?? 1024,
      nPredict: json['nPredict'] as int? ?? 4096,
      topK: json['topK'] as int? ?? 40,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.4,
      temp: (json['temp'] as num?)?.toDouble() ?? 0.7,
      nBatch: json['nBatch'] as int? ?? 128,
      repeatPenalty: (json['repeatPenalty'] as num?)?.toDouble() ?? 1.18,
      repeatLastN: json['repeatLastN'] as int? ?? 64,
      contextErase: (json['contextErase'] as num?)?.toDouble() ?? 0.55,
    );

Map<String, dynamic> _$LLModelPromptConfigToJson(
        LLModelPromptConfig instance) =>
    <String, dynamic>{
      'logits': instance.logits,
      'tokens': instance.tokens,
      'nPast': instance.nPast,
      'nCtx': instance.nCtx,
      'nPredict': instance.nPredict,
      'topK': instance.topK,
      'topP': instance.topP,
      'temp': instance.temp,
      'nBatch': instance.nBatch,
      'repeatPenalty': instance.repeatPenalty,
      'repeatLastN': instance.repeatLastN,
      'contextErase': instance.contextErase,
    };
