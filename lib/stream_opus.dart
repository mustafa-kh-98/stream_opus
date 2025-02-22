library stream_opus;

import 'dart:ffi';
import 'dart:io';

import 'src/opus_dart_misc.dart';

export 'src/opus_dart_encoder.dart';
export 'src/opus_dart_misc.dart';
export 'src/opus_dart_streaming.dart';

void OPUSInit() {
  if (Platform.isAndroid) {
    initOpus(DynamicLibrary.open("libopus.so"));
  } else {
    initOpus(DynamicLibrary.process());
  }
}
