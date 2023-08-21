import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as pffi;

final class LLModelError extends ffi.Struct {
  external ffi.Pointer<pffi.Utf8> message;

  @ffi.Int32()
  external int code;
}
