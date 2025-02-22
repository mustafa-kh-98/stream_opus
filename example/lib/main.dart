import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stream_opus/stream_opus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_client/web_socket_client.dart';

void main() {
  OPUSInit();
  runApp(
    const MaterialApp(
      home: OpusStreamingDecodeAndEncode(),
    ),
  );
}

class OpusStreamingDecodeAndEncode extends StatefulWidget {
  const OpusStreamingDecodeAndEncode({super.key});

  @override
  State<OpusStreamingDecodeAndEncode> createState() =>
      _OpusStreamingDecodeAndEncodeState();
}

class _OpusStreamingDecodeAndEncodeState
    extends State<OpusStreamingDecodeAndEncode> {
  int wavHeaderSize = 44;
  bool _isRecording = false;
  Stream<Uint8List>? stream;
  List<Uint8List> output = [];
  String conState = "";
  final AudioRecorder _audioRecorder = AudioRecorder();
  WebSocket? _socket;
  final String _socketURL = "SOCKET URL";

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  initSocket() {
    _socket = WebSocket(
      Uri.parse(_socketURL),
    );
    _socket!.connection.listen(
      (sC) {
        setState(() {
          conState = sC.toString();
        });
        log(sC.toString(), name: "ConnectionState");
      },
    );
    _socket!.messages.listen(
      (sC) {
        log(sC.toString(), name: "ConnectionEvent");
      },
    );
  }

  // this will stream record and decode each chunk to pous then decode it
  // and set all chunks to output
  // **NOTE** if you want to just encode you don not need to add decoder

  Future<bool> _startListening() async {
    if (_isRecording) return false;
    setState(() {
      _isRecording = true;
    });
    try {
      output.add(Uint8List(wavHeaderSize));
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        sampleRate: 16000,
      );
      final encoder = StreamOpusEncoder.bytes(
        floatInput: false,
        frameTime: FrameTime.ms20,
        sampleRate: 16000,
        channels: 1,
        application: Application.audio,
        copyOutput: true,
        fillUpLastFrame: true,
      );
      final decoder = StreamOpusDecoder.bytes(
        floatOutput: false,
        sampleRate: 16000,
        channels: 1,
        copyOutput: true,
        forwardErrorCorrection: true,
      );
      stream = await _audioRecorder.startStream(config);
      stream!
          .transform(encoder)
          .cast<Uint8List?>()
          .transform(decoder)
          .cast<Uint8List>()
          .listen(
        (chunk) {
          output.add(chunk);
        },
      );
    } catch (e) {
      log("get an error", error: e);
      return false;
    }
    return true;
  }

  void _startRecording() async {
    await _startListening();
  }

  void _stopRecording() async {
    setState(() {
      _isRecording = false;
      _audioRecorder.stop();
    });
    _saveAndShare();
  }

  _saveAndShare() {
    int length = output.fold(
      0,
      (int l, Uint8List element) => l + element.length,
    );
    Uint8List header = wavHeader(
      channels: 1,
      sampleRate: 16000,
      fileSize: length,
    );
    output[0] = header;
    Uint8List flat = Uint8List(length);
    int index = 0;
    for (Uint8List element in output) {
      flat.setAll(index, element);
      index += element.length;
    }
    save(flat);
  }

  void save(Uint8List data) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/recorded_audio.wav';

      File file = File(filePath);
      await file.writeAsBytes(data, flush: true);
      log("File saved at: $filePath");
      XFile xfile = XFile(file.path);

      await Share.shareXFiles([xfile]);
    } catch (e) {
      log("Error saving or playing file:", error: e);
    }
  }

  /// add head for wave file
  Uint8List wavHeader(
      {required int sampleRate, required int channels, required int fileSize}) {
    const int sampleBits = 16; //We know this since we used opus
    const Endian endian = Endian.little;
    final int frameSize = ((sampleBits + 7) ~/ 8) * channels;
    ByteData data = ByteData(wavHeaderSize);
    data.setUint32(4, fileSize - 4, endian);
    data.setUint32(16, 16, endian);
    data.setUint16(20, 1, endian);
    data.setUint16(22, channels, endian);
    data.setUint32(24, sampleRate, endian);
    data.setUint32(28, sampleRate * frameSize, endian);
    data.setUint16(30, frameSize, endian);
    data.setUint16(34, sampleBits, endian);
    data.setUint32(40, fileSize - 44, endian);
    Uint8List bytes = data.buffer.asUint8List();
    bytes.setAll(0, ascii.encode('RIFF'));
    bytes.setAll(8, ascii.encode('WAVE'));
    bytes.setAll(12, ascii.encode('fmt '));
    bytes.setAll(36, ascii.encode('data'));
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-time Audio Streaming with Opus')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRecording
                    ? "Recording and streaming audio..."
                    : "Press Start to stream audio",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                conState.replaceAll("Instance of ", "Status of socket is => "),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Text(_isRecording ? "Stop" : "Start"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
