// ignore_for_file: use_setters_to_change_properties, avoid_positional_boolean_parameters

import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:dfc_gpt/src/ai_lib/llmodel_library.dart';
import 'package:dfc_gpt/src/ai_lib/llmodel_library_types.dart';
import 'package:dfc_gpt/src/ai_lib/models/bot_config.dart';
import 'package:dfc_gpt/src/ai_lib/models/gpt_model_file.dart';
import 'package:dfc_gpt/src/ai_lib/models/llmodel_prompt_config.dart';
import 'package:ffi/ffi.dart' as pffi;
import 'package:ffi/ffi.dart';

class LLModel {
  LLModel({
    required this.modelFile,
    required this.config,
    required this.responseCallback,
  });

  final GptModelFile modelFile;
  final BotConfig config;
  final void Function(int tokenId, String response) responseCallback;

  bool _isLoaded = false;
  late final ffi.Pointer _model;
  late final ffi.Pointer<llmodel_prompt_context> _promptContext;

  Future<void> load() async {
    final error = calloc<ffi.Pointer<pffi.Utf8>>();

    try {
      _promptContext = calloc<llmodel_prompt_context>();
      _resetPromptContext();

      LLModelLibrary.initialize(
        config: config,
        reponseCallback: responseCallback,
      );

      if (!File(modelFile.path).existsSync()) {
        throw Exception('Model file does not exist: ${modelFile.path}');
      }

      _model = LLModelLibrary.shared.modelCreate2(
        modelPath: modelFile.path,
        buildVariant: 'auto',
        error: error,
      );

      if (_model.address == ffi.nullptr.address) {
        final errorMsg = error.value.toDartString();
        throw Exception('Could not load gpt4all backend: $errorMsg');
      }

      LLModelLibrary.shared.loadModel(model: _model, modelPath: modelFile.path);

      if (LLModelLibrary.shared.isModelLoaded(model: _model)) {
        _isLoaded = true;
      } else {
        throw Exception('The model could not be loaded');
      }
    } finally {
      calloc.free(error);
    }
  }

  void generate({required String prompt}) {
    _logContext();
    // sometimes models get stuck? a reset helps, but some models give a BOS?
    // first token must be BOS?
    // https://github.com/nomic-ai/gpt4all/pull/1023
    // _resetPromptContext();

    var promptTemplate = modelFile.promptTemplate;
    if (promptTemplate.isEmpty) {
      promptTemplate = '### Human: \n%1\n### Assistant:\n';
    }

    LLModelLibrary.shared.prompt(
      model: _model,
      prompt: prompt,
      promptTemplate: promptTemplate,
      promptContext: _promptContext,
    );
  }

  void dispose() {
    if (_isLoaded) {
      LLModelLibrary.shared.modelDestroy(model: _model);

      _isLoaded = false;
    }

    if (_promptContext != ffi.nullptr) {
      calloc.free(_promptContext);
    }
  }

  // =================================================================
  // private

  void _resetPromptContext() {
    final promptConfig = config.promptConfig ?? LLModelPromptConfig();

    _promptContext.ref
      ..logits = ffi.nullptr
      ..logits_size = 0
      ..tokens = ffi.nullptr
      ..tokens_size = 0
      ..n_past = promptConfig.nPast
      ..n_ctx = promptConfig.nCtx
      ..n_predict = promptConfig.nPredict
      ..top_k = promptConfig.topK
      ..top_p = promptConfig.topP
      ..min_p = promptConfig.minP
      ..temp = promptConfig.temp
      ..n_batch = promptConfig.nBatch
      ..repeat_penalty = promptConfig.repeatPenalty
      ..repeat_last_n = promptConfig.repeatLastN
      ..context_erase = promptConfig.contextErase;
  }

  void _logContext({bool enabled = false}) {
    if (enabled) {
      print('// ----------------------------------------');
      print('// promptContext');
      print('logits: ${_promptContext.ref.logits}');
      print('logits_size: ${_promptContext.ref.logits_size}');
      print('context_erase: ${_promptContext.ref.context_erase}');
      print('n_batch: ${_promptContext.ref.n_batch}');
      print('n_ctx: ${_promptContext.ref.n_ctx}');
      print('n_past: ${_promptContext.ref.n_past}');
      print('n_predict: ${_promptContext.ref.n_predict}');
      print('repeat_last_n: ${_promptContext.ref.repeat_last_n}');
      print('repeat_penalty: ${_promptContext.ref.repeat_penalty}');
      print('temp: ${_promptContext.ref.temp}');
      print('tokens: ${_promptContext.ref.tokens}');
      print('tokens_size: ${_promptContext.ref.tokens_size}');
      print('top_k: ${_promptContext.ref.top_k}');
      print('top_p: ${_promptContext.ref.top_p}');
      print('min_p: ${_promptContext.ref.min_p}');
    }
  }
}
