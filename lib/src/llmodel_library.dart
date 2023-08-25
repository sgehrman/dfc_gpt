// ignore_for_file: camel_case_types, avoid_positional_boolean_parameters

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:ffi';

import 'package:dfc_gpt/src/llmodel_error.dart';
import 'package:dfc_gpt/src/llmodel_library_types.dart';
import 'package:dfc_gpt/src/llmodel_prompt_context.dart';
import 'package:ffi/ffi.dart' as pffi;

// this is called from native cpp thread and arrives on the main dart thread
void dartCallback(ffi.Pointer<pffi.Utf8> message, int tokenId, int typeId) {
  switch (typeId) {
    case 10: // prompt
      // print(message.toDartString());
      break;
    case 20: // response
      libraryInstance?.processDataFromCallback(
        tokenId: tokenId,
        message: message,
      );
      break;
    case 30: // recalculate
      libraryInstance?.processDataFromCallback(
        tokenId: tokenId,
        message: message,
      );

      break;
    case 40: // ShutdownTypeId
      // called after a shutdown_gracefully call
      // tell lib to now dispose the model

      libraryInstance?.shutdown();

      break;
  }
}

final nativeCallable = ffi.NativeCallable<
    ffi.Void Function(ffi.Pointer<pffi.Utf8>, ffi.Int32, ffi.Int32)>.listener(
  dartCallback,
);

// =======================================================================

// global for callback
LLModelLibrary? libraryInstance;

// =======================================================================

class LLModelLibrary {
  LLModelLibrary({
    required this.pathToLibrary,
    required this.reponseCallback,
    required this.shutdownCallback,
  }) {
    // a global singleton.  should only be called once per isolate
    if (libraryInstance != null) {
      print(
        'libraryInstance should not be set twice, new request should be in a new isolate.',
      );
    }
    libraryInstance = this;

    _load();

    callbackStreamController = StreamController<List<int>>();

    final utf8Stream = callbackStreamController.stream.transform(utf8.decoder);

    utf8Stream.listen((event) {
      reponseCallback(0, event);
    });
  }

  late StreamController<List<int>> callbackStreamController;

  final String pathToLibrary;
  final void Function() shutdownCallback;
  final void Function(int tokenId, String response) reponseCallback;

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
  }

  void _load() {
    _dynamicLibrary = ffi.DynamicLibrary.open(pathToLibrary);
    _initializeMethodBindings();

    final initializeApi = _dynamicLibrary.lookupFunction<
        ffi.IntPtr Function(ffi.Pointer<ffi.Void>),
        int Function(ffi.Pointer<ffi.Void>)>('InitDartApiDL');

    initializeApi(ffi.NativeApi.initializeApiDLData);

    final registerCallback = _dynamicLibrary.lookupFunction<
        ffi.Void Function(
          ffi.Pointer<
                  ffi.NativeFunction<
                      ffi.Void Function(
                        ffi.Pointer<pffi.Utf8>,
                        ffi.Int32 tokenId,
                        ffi.Int32 type,
                      )>>
              nativeFunction,
        ),
        void Function(
          ffi.Pointer<
                  ffi.NativeFunction<
                      ffi.Void Function(
                        ffi.Pointer<pffi.Utf8>,
                        ffi.Int32 tokenId,
                        ffi.Int32 type,
                      )>>
              nativeFunction,
        )>('RegisterDartCallback');

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
    final ffi.Pointer<pffi.Utf8> modelPathNative = modelPath.toNativeUtf8();
    final bool result = _llModelLoadModel(model, modelPathNative);
    pffi.malloc.free(modelPathNative);

    return result;
  }

  ffi.Pointer modelCreate2({
    required String modelPath,
    required String buildVariant,
    required ffi.Pointer<LLModelError> error,
  }) {
    final ffi.Pointer<pffi.Utf8> modelPathNative = modelPath.toNativeUtf8();

    final ffi.Pointer<pffi.Utf8> buildVariantNative =
        buildVariant.toNativeUtf8();

    final ffi.Pointer result = _llModelModelCreate2(
      modelPath.toNativeUtf8(),
      buildVariant.toNativeUtf8(),
      error,
    );

    pffi.malloc.free(modelPathNative);
    pffi.malloc.free(buildVariantNative);

    return result;
  }

  void shutdownGracefully() {
    _llModelShutdownGracefully();
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
    final ffi.Pointer<pffi.Utf8> promptNative = prompt.toNativeUtf8();
    _llModelPrompt(
      model,
      promptNative,
      promptContext,
    );
    // pffi.malloc.free(promptNative);
  }

  void setImplementationSearchPath({
    required String path,
  }) {
    final ffi.Pointer<pffi.Utf8> pathNative = path.toNativeUtf8();
    _llModelSetImplementationSearchPath(path.toNativeUtf8());
    pffi.malloc.free(pathNative);
  }

  // =================================================================
  // from callback

  void processDataFromCallback({
    required int tokenId,
    required ffi.Pointer<pffi.Utf8> message,
  }) {
    // utf failing. wizardlm superhot, type hello
    // file.openRead().transform(utf8.decoder)
    // https://api.dart.dev/stable/3.1.0/dart-async/Stream/map.html

    // file.openRead().transform(utf8.decoder)

    int len(Pointer<Uint8> codeUnits) {
      var length = 0;

      while (codeUnits[length] != 0) {
        length++;
      }

      return length;
    }

    final codeUnits = message.cast<Uint8>();
    callbackStreamController.add(codeUnits.asTypedList(len(codeUnits)));
  }

  void shutdown() {
    shutdownCallback();
  }
}
