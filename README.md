# Opus Streaming Encode and Decode

A Flutter package for encoding and decoding real-time audio streams using OPUS. This package enables encoding and decoding audio streams efficiently for real-time applications.

## Features

- Encode PCM audio streams to OPUS format.
- Decode OPUS-encoded streams back to PCM.

## Installation

**Note:** This package uses `libopus` version 1.5.2 for Android and version 1.3.1 for iOS.

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  stream_opus:
    git: https://github.com/mustafa-kh-98/stream_opus.git
```

## Usage
## Initialization
Before using the encoder or decoder, initialize OPUS:

```dart
void main() {
  OPUSInit();
  runApp(MyApp());
}
```

### Encoding PCM to OPUS
```dart
final encoder = StreamOpusEncoder.bytes(
  floatInput: false,
  frameTime: FrameTime.ms20,
  sampleRate: 16000,
  channels: 1,
  application: Application.audio,
  copyOutput: true,
  fillUpLastFrame: true,
);

Stream<Uint8List> opusStream = pcmStream.transform(encoder);
```

### Decoding OPUS to PCM
```dart
final decoder = StreamOpusDecoder.bytes(
  floatOutput: false,
  sampleRate: 16000,
  channels: 1,
  copyOutput: true,
  forwardErrorCorrection: true,
);

Stream<Uint8List> pcmStream = opusStream.transform(decoder);
```

