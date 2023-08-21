// ignore_for_file: camel_case_types, avoid_positional_boolean_parameters

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:dfc_gpt/src/llmodel_error.dart';
import 'package:dfc_gpt/src/llmodel_prompt_context.dart';
import 'package:ffi/ffi.dart' as pffi;

typedef llmodel_isModelLoaded_func = ffi.Bool Function(ffi.Pointer);
typedef LLModelIsModelLoaded = bool Function(ffi.Pointer);

typedef llmodel_loadModel_func = ffi.Bool Function(
  ffi.Pointer,
  ffi.Pointer<pffi.Utf8>,
);
typedef LLModelLoadModel = bool Function(ffi.Pointer, ffi.Pointer<pffi.Utf8>);

typedef llmodel_model_create2_func = ffi.Pointer Function(
  ffi.Pointer<pffi.Utf8>,
  ffi.Pointer<pffi.Utf8>,
  ffi.Pointer<LLModelError>,
);
typedef LLModelModelCreate2 = ffi.Pointer Function(
  ffi.Pointer<pffi.Utf8>,
  ffi.Pointer<pffi.Utf8>,
  ffi.Pointer<LLModelError>,
);

typedef llmodel_model_destroy_func = ffi.Void Function(ffi.Pointer);
typedef LLModelModelDestroy = void Function(ffi.Pointer);

typedef llmodel_prompt_callback_func = ffi.Bool Function(ffi.Int32);
typedef LLModelPromptCallback = bool Function(int);

typedef llmodel_response_callback_func = ffi.Bool Function(
  ffi.Int32,
  ffi.Pointer<pffi.Utf8>,
);
typedef LLModelResponseCallback = bool Function(int, ffi.Pointer<pffi.Utf8>);

typedef llmodel_recalculate_callback_func = ffi.Bool Function(ffi.Bool);
typedef LLModelRecalculateCallback = bool Function(bool);

typedef llmodel_prompt_func = ffi.Void Function(
  ffi.Pointer,
  ffi.Pointer<pffi.Utf8>,
  ffi.Pointer<ffi.NativeFunction<llmodel_prompt_callback_func>>,
  ffi.Pointer<ffi.NativeFunction<llmodel_response_callback_func>>,
  ffi.Pointer<ffi.NativeFunction<llmodel_recalculate_callback_func>>,
  ffi.Pointer<llmodel_prompt_context>,
);
typedef LLModelPrompt = void Function(
  ffi.Pointer,
  ffi.Pointer<pffi.Utf8>,
  ffi.Pointer<ffi.NativeFunction<llmodel_prompt_callback_func>>,
  ffi.Pointer<ffi.NativeFunction<llmodel_response_callback_func>>,
  ffi.Pointer<ffi.NativeFunction<llmodel_recalculate_callback_func>>,
  ffi.Pointer<llmodel_prompt_context>,
);

typedef llmodel_set_implementation_search_path_func = ffi.Void Function(
  ffi.Pointer<pffi.Utf8>,
);
typedef LLModelSetImplementationSearchPath = void Function(
  ffi.Pointer<pffi.Utf8>,
);

void callbackSafe(ffi.Pointer<pffi.Utf8> a) {
  final duh = a.toDartString();

  LLModelLibrary.responseCallback(22, duh);
}

ffi.NativeCallable<ffi.Void Function(ffi.Pointer<pffi.Utf8>)> nc =
    ffi.NativeCallable<ffi.Void Function(ffi.Pointer<pffi.Utf8>)>.listener(
  callbackSafe,
);

class LLModelLibrary {
  LLModelLibrary({
    required String pathToLibrary,
  }) {
    _dynamicLibrary = ffi.DynamicLibrary.open(pathToLibrary);
    _initializeMethodBindings();

    final initializeApi = _dynamicLibrary.lookupFunction<
        ffi.IntPtr Function(ffi.Pointer<ffi.Void>),
        int Function(ffi.Pointer<ffi.Void>)>('InitDartApiDL');

    initializeApi(ffi.NativeApi.initializeApiDLData);

    final interactiveCppRequests = ReceivePort();
    final int nativePort = interactiveCppRequests.sendPort.nativePort;

    final registerCallback = _dynamicLibrary.lookupFunction<
        ffi.Void Function(
          ffi.Int64 sendPort,
          ffi.Pointer<
                  ffi.NativeFunction<ffi.Void Function(ffi.Pointer<pffi.Utf8>)>>
              functionPointer,
        ),
        void Function(
          int sendPort,
          ffi.Pointer<
                  ffi.NativeFunction<ffi.Void Function(ffi.Pointer<pffi.Utf8>)>>
              functionPointer,
        )>('RegisterMyCallback');

    registerCallback(nativePort, nc.nativeFunction);
  }

  static const bool except = false;

  static bool Function(int) promptCallback = (int tokenId) => true;
  static bool Function(int, String) responseCallback =
      (int tokenId, String response) {
    if (tokenId == -1) {
      stderr.write(response);
    } else {
      stdout.write(response);
    }

    return true;
  };

  static bool Function(bool) recalculateCallback =
      (bool isRecalculating) => isRecalculating;

  late final ffi.DynamicLibrary _dynamicLibrary;

  // Dart methods binding to native methods
  late final LLModelIsModelLoaded _llModelIsModelLoaded;
  late final LLModelLoadModel _llModelLoadModel;
  late final LLModelModelCreate2 _llModelModelCreate2;
  late final LLModelModelDestroy _llModelModelDestroy;
  late final LLModelPrompt _llModelPrompt;
  late final LLModelSetImplementationSearchPath
      _llModelSetImplementationSearchPath;

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
      ffi.Pointer.fromFunction<llmodel_prompt_callback_func>(
        _promptCallback,
        except,
      ),
      ffi.Pointer.fromFunction<llmodel_response_callback_func>(
        _responseCallback,
        except,
      ),
      ffi.Pointer.fromFunction<llmodel_recalculate_callback_func>(
        _recalculateCallback,
        except,
      ),
      promptContext,
    );
    // pffi.malloc.free(promptNative);
  }

  static bool _promptCallback(int tokenId) => promptCallback(tokenId);

  static bool _responseCallback(
    int tokenId,
    ffi.Pointer<pffi.Utf8> responsePart,
  ) {
    return responseCallback(tokenId, responsePart.toDartString());
  }

  static bool _recalculateCallback(bool isRecalculating) =>
      recalculateCallback(isRecalculating);

  void setImplementationSearchPath({
    required String path,
  }) {
    final ffi.Pointer<pffi.Utf8> pathNative = path.toNativeUtf8();
    _llModelSetImplementationSearchPath(path.toNativeUtf8());
    pffi.malloc.free(pathNative);
  }
}
