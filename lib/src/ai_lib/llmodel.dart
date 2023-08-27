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
    required this.responseCallback,
  });

  final String modelPath;
  final void Function(int tokenId, String response) responseCallback;

  bool _isLoaded = false;
  late final ffi.Pointer _model;
  late final ffi.Pointer<llmodel_prompt_context> _promptContext;

  Future<void> load({
    required final String librarySearchPath,
    LLModelPromptConfig? promptConfig,
  }) async {
    promptConfig ??= LLModelPromptConfig();

    final ffi.Pointer<LLModelError> error = calloc<LLModelError>();

    try {
      _promptContext = calloc<llmodel_prompt_context>();
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
        ..temp = promptConfig.temp
        ..n_batch = promptConfig.nBatch
        ..repeat_penalty = promptConfig.repeatPenalty
        ..repeat_last_n = promptConfig.repeatLastN
        ..context_erase = promptConfig.contextErase;

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
