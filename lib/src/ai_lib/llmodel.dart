// ignore_for_file: use_setters_to_change_properties, avoid_positional_boolean_parameters

import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:dfc_gpt/src/ai_lib/llmodel_library.dart';
import 'package:dfc_gpt/src/ai_lib/llmodel_library_types.dart';
import 'package:dfc_gpt/src/ai_lib/llmodel_prompt_config.dart';
import 'package:ffi/ffi.dart';

class LLModel {
  LLModel({
    required this.modelPath,
    required this.librarySearchPath,
    required this.promptConfig,
    required this.responseCallback,
  });

  final String modelPath;
  final String librarySearchPath;
  final LLModelPromptConfig? promptConfig;
  final void Function(int tokenId, String response) responseCallback;

  bool _isLoaded = false;
  late final ffi.Pointer _model;
  late final ffi.Pointer<llmodel_prompt_context> _promptContext;

  Future<void> load() async {
    final config = promptConfig ?? LLModelPromptConfig();

    final ffi.Pointer<LLModelError> error = calloc<LLModelError>();

    try {
      _promptContext = calloc<llmodel_prompt_context>();
      _promptContext.ref
        ..logits = ffi.nullptr
        ..logits_size = 0
        ..tokens = ffi.nullptr
        ..tokens_size = 0
        ..n_past = config.nPast
        ..n_ctx = config.nCtx
        ..n_predict = config.nPredict
        ..top_k = config.topK
        ..top_p = config.topP
        ..temp = config.temp
        ..n_batch = config.nBatch
        ..repeat_penalty = config.repeatPenalty
        ..repeat_last_n = config.repeatLastN
        ..context_erase = config.contextErase;

      LLModelLibrary.initialize(
        librarySearchPath: librarySearchPath,
        reponseCallback: responseCallback,
      );

      LLModelLibrary.shared.setImplementationSearchPath(
        path: librarySearchPath,
      );

      if (!File(modelPath).existsSync()) {
        throw Exception('Model file does not exist: $modelPath');
      }

      _model = LLModelLibrary.shared.modelCreate2(
        modelPath: modelPath,
        buildVariant: 'auto',
        error: error,
      );

      if (_model.address == ffi.nullptr.address) {
        final String errorMsg = error.ref.message.toDartString();
        throw Exception('Could not load gpt4all backend: $errorMsg');
      }

      LLModelLibrary.shared.loadModel(
        model: _model,
        modelPath: modelPath,
      );

      if (LLModelLibrary.shared.isModelLoaded(model: _model)) {
        _isLoaded = true;
      } else {
        throw Exception('The model could not be loaded');
      }
    } finally {
      calloc.free(error);
    }
  }

  void generate({
    required String prompt,
  }) {
    LLModelLibrary.shared.prompt(
      model: _model,
      prompt: prompt,
      promptContext: _promptContext,
    );
  }

  void dispose() {
    if (_isLoaded) {
      LLModelLibrary.shared.modelDestroy(
        model: _model,
      );

      _isLoaded = false;
    }

    if (_promptContext != ffi.nullptr) {
      calloc.free(_promptContext);
    }
  }
}
