import 'dart:convert';
import 'dart:ffi';

import '../wrappers/opus_libinfo.dart' as opus_libinfo;
import '../wrappers/opus_encoder.dart' as opus_encoder;
import '../wrappers/opus_decoder.dart' as opus_decoder;
import 'init_ffi.dart';

const int maxDataBytes = 3 * 1275;

int maxSamplesPerPacket(int sampleRate, int channels) =>
    ((sampleRate * channels * 120) / 1000).ceil();

String getOpusVersion() {
  return _asString(opus.libinfo.opus_get_version_string());
}

String _asString(Pointer<Uint8> pointer) {
  int i = 0;
  while (pointer.elementAt(i).value != 0) {
    i++;
  }
  return utf8.decode(pointer.asTypedList(i));
}

class OpusException implements Exception {
  final int errorCode;

  const OpusException(this.errorCode);

  @override
  String toString() {
    String error = _asString(opus.libinfo.opus_strerror(errorCode));
    return 'OpusException $errorCode: $error';
  }
}

class OpusDestroyedError extends StateError {
  OpusDestroyedError.encoder()
      : super(
            'OpusDestroyedException: This OpusEncoder was already destroyed!');

  OpusDestroyedError.decoder()
      : super(
            'OpusDestroyedException: This OpusDecoder was already destroyed!');
}

late final ApiObject opus;

class ApiObject {
  final opus_libinfo.FunctionsAndGlobals libinfo;
  final opus_encoder.FunctionsAndGlobals encoder;
  final opus_decoder.FunctionsAndGlobals decoder;
  final Allocator allocator;

  ApiObject(DynamicLibrary opus,this.allocator)
      : libinfo = opus_libinfo.FunctionsAndGlobals(opus),
        encoder = opus_encoder.FunctionsAndGlobals(opus),
        decoder = opus_decoder.FunctionsAndGlobals(opus);
}

void initOpus(DynamicLibrary opusLib) {
  opus = createApiObject(opusLib);
}
