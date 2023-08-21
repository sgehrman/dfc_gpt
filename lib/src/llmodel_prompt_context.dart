// ignore_for_file: camel_case_types, non_constant_identifier_names, prefer-correct-type-name

import 'dart:ffi' as ffi;

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
