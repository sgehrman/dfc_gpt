// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BotConfig _$BotConfigFromJson(Map<String, dynamic> json) => BotConfig(
      librarySearchPath: json['librarySearchPath'] as String,
      promptConfig: json['promptConfig'] == null
          ? null
          : LLModelPromptConfig.fromJson(
              json['promptConfig'] as Map<String, dynamic>),
      debug: json['debug'] as bool? ?? false,
    );

Map<String, dynamic> _$BotConfigToJson(BotConfig instance) => <String, dynamic>{
      'librarySearchPath': instance.librarySearchPath,
      'promptConfig': instance.promptConfig?.toJson(),
      'debug': instance.debug,
    };
