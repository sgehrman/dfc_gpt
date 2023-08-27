// ignore_for_file: camel_case_types, non_constant_identifier_names, prefer-correct-type-name

import 'dart:ffi' as ffi;

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

typedef llmodel_response_callback_func = ffi.Bool Function(
  ffi.Int32,
  ffi.Pointer<pffi.Utf8>,
);
typedef LLModelResponseCallback = bool Function(int, ffi.Pointer<pffi.Utf8>);

typedef llmodel_prompt_func = ffi.Void Function(
  ffi.Pointer,
  ffi.Pointer<pffi.Utf8>,
  ffi.Pointer<llmodel_prompt_context>,
);
typedef LLModelPrompt = void Function(
  ffi.Pointer,
  ffi.Pointer<pffi.Utf8>,
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

// =================================================

final class LLModelError extends ffi.Struct {
  external ffi.Pointer<pffi.Utf8> message;

  @ffi.Int32()
  external int code;
}

// =================================================

final class llmodel_prompt_context extends ffi.Struct {
  external ffi.Pointer<ffi.Float> logits;

  @ffi.Size()
  external int logits_size;

  external ffi.Pointer<ffi.Int32> tokens;

  @ffi.Size()
  external int tokens_size;

  @ffi.Int32()
  external int n_past;

  @ffi.Int32()
  external int n_ctx;

  @ffi.Int32()
  external int n_predict;

  @ffi.Int32()
  external int top_k;

  @ffi.Float()
  external double top_p;

  @ffi.Float()
  external double temp;

  @ffi.Int32()
  external int n_batch;

  @ffi.Float()
  external double repeat_penalty;

  @ffi.Int32()
  external int repeat_last_n;

  @ffi.Float()
  external double context_erase;
}
