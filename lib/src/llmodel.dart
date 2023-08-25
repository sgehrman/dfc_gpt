// ignore_for_file: use_setters_to_change_properties, avoid_positional_boolean_parameters

import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:dfc_gpt/src/llmodel_error.dart';
import 'package:dfc_gpt/src/llmodel_library.dart';
import 'package:dfc_gpt/src/llmodel_prompt_config.dart';
import 'package:dfc_gpt/src/llmodel_prompt_context.dart';
import 'package:ffi/ffi.dart';

class LLModel {
  LLModel({
    required this.responseCallback,
    required this.shutdownCallback,
  });

  final void Function() shutdownCallback;
  final void Function(int tokenId, String response) responseCallback;

  bool _isLoaded = false;

  late final LLModelLibrary _library;
  late final ffi.Pointer _model;

  late final ffi.Pointer<ffi.Pointer<ffi.Float>> _logits;
  late final ffi.Pointer<ffi.Pointer<ffi.Int32>> _tokens;
  late final ffi.Pointer<llmodel_prompt_context> _promptContext;

  Future<void> load({
    required final String modelPath,
    required final String librarySearchPath,
    LLModelPromptConfig? promptConfig,
  }) async {
    promptConfig ??= LLModelPromptConfig();

    final ffi.Pointer<LLModelError> error = calloc<LLModelError>();

    try {
      _logits = calloc<ffi.Pointer<ffi.Float>>();
      _tokens = calloc<ffi.Pointer<ffi.Int32>>();
      _promptContext = calloc<llmodel_prompt_context>();
      _promptContext.ref
        ..logits = _logits.value // generationConfig.logits
        ..logits_size = 0 // generationConfig.logits.length
        ..tokens = _tokens.value // generationConfig.tokens
        ..tokens_size = 0 // generationConfig.tokens.length
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

      _library = LLModelLibrary(
        // the dfc-gpt.so lib wraps the main libllmodel.so lib',
        pathToLibrary: '$librarySearchPath/dfc-gpt${_getFileSuffix()}',
        reponseCallback: responseCallback,
        shutdownCallback: shutdownCallback,
      );

      _library.setImplementationSearchPath(
        path: librarySearchPath,
      );

      if (!File(modelPath).existsSync()) {
        throw Exception('Model file does not exist: $modelPath');
      }

      _model = _library.modelCreate2(
        modelPath: modelPath,
        buildVariant: 'auto',
        error: error,
      );

      if (_model.address == ffi.nullptr.address) {
        final String errorMsg = error.ref.message.toDartString();
        throw Exception('Could not load gpt4all backend: $errorMsg');
      }

      _library.loadModel(
        model: _model,
        modelPath: modelPath,
      );

      if (_library.isModelLoaded(model: _model)) {
        _isLoaded = true;
      } else {
        throw Exception('The model could not be loaded');
      }
    } finally {
      calloc.free(error);
    }
  }

  String _getFileSuffix() {
    if (Platform.isWindows) {
      return '.dll';
    } else if (Platform.isMacOS) {
      return '.dylib';
    } else if (Platform.isLinux) {
      return '.so';
    } else {
      throw Exception('Unsupported device');
    }
  }

  void generate({
    required String prompt,
  }) {
    _library.prompt(
      model: _model,
      prompt: prompt,
      promptContext: _promptContext,
    );
  }

  void shutdownGracefully() {
    _library.shutdownGracefully();
  }

  void dispose() {
    if (_isLoaded) {
      _library.modelDestroy(
        model: _model,
      );

      _isLoaded = false;
    }

    calloc.free(_promptContext);
    calloc.free(_tokens);
    calloc.free(_logits);
  }
}
