// ignore_for_file: camel_case_types, avoid_positional_boolean_parameters

import 'dart:ffi' as ffi;

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

typedef llmodel_shutdown_gracefully_func = ffi.Void Function();
typedef LLModelShutdownGracefully = void Function();
