// ignore_for_file: camel_case_types, avoid_positional_boolean_parameters

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';

import 'package:dfc_gpt/src/ai_lib/llmodel_library_types.dart';
import 'package:dfc_gpt/src/ai_lib/models/bot_config.dart';
import 'package:ffi/ffi.dart' as pffi;
import 'package:path/path.dart' as p;

// =======================================================================

class LLModelLibrary {
  factory LLModelLibrary._priv({
    required BotConfig config,
    required Function(int param, String response) reponseCallback,
  }) {
    return _instance ??= LLModelLibrary._(
      config: config,
      reponseCallback: reponseCallback,
    );
  }

  LLModelLibrary._({
    required this.config,
    required this.reponseCallback,
  }) {
    _connectToDynamicLib();

    callbackStreamController = StreamController<List<int>>();

    final utf8Stream = callbackStreamController.stream.transform(utf8.decoder);

    utf8Stream.listen((event) {
      reponseCallback(0, event);
    });
  }

  // ==================================================

  static void initialize({
    required BotConfig config,
    required Function(int param, String response) reponseCallback,
  }) {
    if (_instance == null) {
      LLModelLibrary._priv(
        config: config,
        reponseCallback: reponseCallback,
      );
    }
  }

  static LLModelLibrary get shared {
    if (_instance == null) {
      throw StateError('Call initialize first');
    }

    return _instance!;
  }

  static LLModelLibrary? _instance;

  late StreamController<List<int>> callbackStreamController;
  Completer<bool>? _shutdownCompleter;

  final BotConfig config;
  final void Function(int param, String response) reponseCallback;
  late ffi.NativeCallable<
          ffi.Void Function(ffi.Pointer<pffi.Utf8>, ffi.Int32, ffi.Int32)>
      nativeCallable;

  late final ffi.DynamicLibrary _dynamicLibrary;

  // Dart methods binding to native methods
  late final LLModelIsModelLoaded _llModelIsModelLoaded;
  late final LLModelLoadModel _llModelLoadModel;
  late final LLModelModelCreate2 _llModelModelCreate2;
  late final LLModelModelDestroy _llModelModelDestroy;
  late final LLModelPrompt _llModelPrompt;
  late final LLModelSetImplementationSearchPath
      _llModelSetImplementationSearchPath;
  late final LLModelShutdownGracefully _llModelShutdownGracefully;

  void dispose() {
    callbackStreamController.close();

    // this keeps the isolate alive, must close
    nativeCallable.close();
    _dynamicLibrary.close();
  }

  // this is called from native cpp thread and arrives on the main dart thread
  static void dartCallback(
    ffi.Pointer<pffi.Utf8> message,
    int param,
    int typeId,
  ) {
    LLModelLibrary.shared._handleDartCallback(message, param, typeId);
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

  void _connectToDynamicLib() {
    final pathToLibrary = p.join(
      config.librarySearchPath,
      'libdfc-gpt${_getFileSuffix()}',
    );
    _dynamicLibrary = ffi.DynamicLibrary.open(pathToLibrary);

    _initializeMethodBindings();

    // ----------------------------------
    // initialize dart

    final initializeApi = _dynamicLibrary.lookupFunction<
        ffi.IntPtr Function(ffi.Pointer<ffi.Void>),
        int Function(ffi.Pointer<ffi.Void>)>('InitDartApiDL');

    initializeApi(ffi.NativeApi.initializeApiDLData);

    // ----------------------------------
    // setImplementationSearchPath

    _setImplementationSearchPath(
      path: config.librarySearchPath,
    );

    // ----------------------------------
    // set native callback for gpt4all lib
    // thread safe

    final registerCallback = _dynamicLibrary.lookupFunction<
        ffi.Void Function(
          ffi.Pointer<
                  ffi.NativeFunction<
                      ffi.Void Function(
                        ffi.Pointer<pffi.Utf8>,
                        ffi.Int32 param,
                        ffi.Int32 type,
                      )>>
              nativeFunction,
        ),
        void Function(
          ffi.Pointer<
                  ffi.NativeFunction<
                      ffi.Void Function(
                        ffi.Pointer<pffi.Utf8>,
                        ffi.Int32 param,
                        ffi.Int32 type,
                      )>>
              nativeFunction,
        )>('RegisterDartCallback');

    nativeCallable = ffi.NativeCallable<
        ffi.Void Function(
          ffi.Pointer<pffi.Utf8>,
          ffi.Int32,
          ffi.Int32,
        )>.listener(
      dartCallback,
    );

    registerCallback(nativeCallable.nativeFunction);
  }

  void _initializeMethodBindings() {
    _llModelIsModelLoaded = _dynamicLibrary
        .lookup<ffi.NativeFunction<llmodel_isModelLoaded_func>>(
          'dfc_llmodel_isModelLoaded',
        )
        .asFunction();

    _llModelLoadModel = _dynamicLibrary
        .lookup<ffi.NativeFunction<llmodel_loadModel_func>>(
          'dfc_llmodel_loadModel',
        )
        .asFunction();

    _llModelModelCreate2 = _dynamicLibrary
        .lookup<ffi.NativeFunction<llmodel_model_create2_func>>(
          'dfc_llmodel_model_create2',
        )
        .asFunction();

    _llModelModelDestroy = _dynamicLibrary
        .lookup<ffi.NativeFunction<llmodel_model_destroy_func>>(
          'dfc_llmodel_model_destroy',
        )
        .asFunction();

    _llModelPrompt = _dynamicLibrary
        .lookup<ffi.NativeFunction<llmodel_prompt_func>>('dfc_llmodel_prompt')
        .asFunction();

    _llModelSetImplementationSearchPath = _dynamicLibrary
        .lookup<
            ffi.NativeFunction<llmodel_set_implementation_search_path_func>>(
          'dfc_llmodel_set_implementation_search_path',
        )
        .asFunction();

    _llModelShutdownGracefully = _dynamicLibrary
        .lookup<ffi.NativeFunction<llmodel_shutdown_gracefully_func>>(
          'dfc_shutdown_gracefully',
        )
        .asFunction();
  }

  bool isModelLoaded({
    required ffi.Pointer model,
  }) {
    return _llModelIsModelLoaded(model);
  }

  bool loadModel({
    required ffi.Pointer model,
    required String modelPath,
  }) {
    return pffi.using((alloc) {
      return _llModelLoadModel(model, modelPath.toNativeUtf8(allocator: alloc));
    });
  }

  ffi.Pointer modelCreate2({
    required String modelPath,
    required String buildVariant,
    required ffi.Pointer<LLModelError> error,
  }) {
    return pffi.using((alloc) {
      return _llModelModelCreate2(
        modelPath.toNativeUtf8(allocator: alloc),
        buildVariant.toNativeUtf8(allocator: alloc),
        error,
      );
    });
  }

  Future<bool> shutdownGracefully() {
    _shutdownCompleter = Completer<bool>();

    _llModelShutdownGracefully();

    return _shutdownCompleter!.future;
  }

  void modelDestroy({
    required ffi.Pointer model,
  }) {
    _llModelModelDestroy(model);
  }

  void prompt({
    required ffi.Pointer model,
    required String prompt,
    required ffi.Pointer<llmodel_prompt_context> promptContext,
  }) {
    pffi.using((alloc) {
      _llModelPrompt(
        model,
        prompt.toNativeUtf8(allocator: alloc),
        promptContext,
      );
    });
  }

  void _setImplementationSearchPath({
    required String path,
  }) {
    pffi.using((alloc) {
      _llModelSetImplementationSearchPath(path.toNativeUtf8(allocator: alloc));
    });
  }

  // =================================================================
  // from callback

  void _handleDartCallback(
    ffi.Pointer<pffi.Utf8> message,
    int param,
    int typeId,
  ) {
    switch (typeId) {
      case 10: // prompt
        break;
      case 20: // response
        LLModelLibrary.shared._processDataFromCallback(
          param: param,
          message: message,
        );
        break;
      case 30: // recalculate
        LLModelLibrary.shared._processDataFromCallback(
          param: param,
          message: message,
        );
        break;
      case 40: // ShutdownTypeId
        LLModelLibrary.shared._shutdownFromCallback();

        if (config.debug) {
          _sendMessageOnCallback(
            '\n\nDEBUG: shutdown',
          );
        }
        break;

      case 50: // PromptDoneTypeId
        if (config.debug) {
          _sendMessageOnCallback(
            '\n\nDEBUG: prompt finished $param',
          );
        }
        break;
    }
  }

  void _processDataFromCallback({
    required int param,
    required ffi.Pointer<pffi.Utf8> message,
  }) {
    // NOTE: message.toDartString() doesn't work if the utf8 is broken between glyphs
    int len(Pointer<Uint8> codeUnits) {
      var index = 0;

      // index < 8192 is probably unnecessary, but might stop an endless loop
      while (index < 8192 && codeUnits[index] != 0) {
        index++;
      }

      return index;
    }

    final codeUnits = message.cast<Uint8>();
    callbackStreamController.add(codeUnits.asTypedList(len(codeUnits)));
  }

  void _sendMessageOnCallback(String message) {
    pffi.using((alloc) {
      _processDataFromCallback(
        param: 0,
        message: message.toNativeUtf8(allocator: alloc),
      );
    });
  }

  void _shutdownFromCallback() {
    if (_shutdownCompleter != null) {
      _shutdownCompleter!.complete(true);
    }
  }
}
