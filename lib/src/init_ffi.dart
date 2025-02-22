import 'dart:ffi';
import 'opus_dart_misc.dart' show ApiObject;
import 'package:ffi/ffi.dart' as ffipackage;

ApiObject createApiObject(DynamicLibrary library) {
  return ApiObject(library as dynamic, ffipackage.malloc as dynamic);
}
