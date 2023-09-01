// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpt_model_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GptModelFile _$GptModelFileFromJson(Map<String, dynamic> json) => GptModelFile(
      path: json['path'] as String? ?? '',
      systemPrompt: json['systemPrompt'] as String? ?? '',
      promptTemplate: json['promptTemplate'] as String? ?? '',
    );

Map<String, dynamic> _$GptModelFileToJson(GptModelFile instance) =>
    <String, dynamic>{
      'path': instance.path,
      'promptTemplate': instance.promptTemplate,
      'systemPrompt': instance.systemPrompt,
    };
