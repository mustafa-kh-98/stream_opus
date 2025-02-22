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