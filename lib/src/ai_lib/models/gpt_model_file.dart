import 'package:json_annotation/json_annotation.dart';

part 'gpt_model_file.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class GptModelFile {
  GptModelFile({
    this.path = '',
    this.systemPrompt = '',
    this.promptTemplate = '',
  });

  factory GptModelFile.fromJson(Map<String, dynamic> json) =>
      _$GptModelFileFromJson(json);

  final String path;
  final String promptTemplate;
  final String systemPrompt;

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() => _$GptModelFileToJson(this);
}
