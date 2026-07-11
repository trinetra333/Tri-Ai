// Web-safe stand-in for sd_isolate_processor_io.dart.
//
// Local/on-device Stable Diffusion image generation depends on dart:ffi,
// which doesn't exist on web. This stub keeps the exact same public API
// (constructor params, streams, generate()/dispose()) so chat_controller.dart
// and local_image_service.dart don't need any web-specific branching — a
// generate() call just resolves immediately with a clear error instead of
// silently hanging or crashing the build.

import 'dart:async';

import '../ffi/sd_ffi_bindings_stub.dart';

class ProgressUpdate {
  final int step;
  final int totalSteps;
  final double time;
  ProgressUpdate(this.step, this.totalSteps, this.time);
}

class LogMessage {
  final int level;
  final String message;
  LogMessage(this.level, this.message);
}

class GenerationResult {
  final dynamic rgbBytes;
  final int width;
  final int height;
  final String? error;
  GenerationResult(
      {this.rgbBytes, this.width = 0, this.height = 0, this.error});
}

class SdIsolateProcessor {
  final String modelPath;
  final int nThreads;
  final bool flashAttn;
  final bool vaeTiling;
  final String? taesdPath;
  final String? vaePath;
  final String? clipLPath;
  final Backend backend;
  final QuantizationType quantizationType;
  final bool offloadParamsToCpu;
  final bool enableMmap;
  final bool keepVaeOnCpu;
  final double maxVram;

  final _progressController = StreamController<ProgressUpdate>.broadcast();
  final _logController = StreamController<LogMessage>.broadcast();

  Stream<ProgressUpdate> get progressStream => _progressController.stream;
  Stream<LogMessage> get logStream => _logController.stream;

  Future<bool> get modelLoaded async => false;

  SdIsolateProcessor({
    required this.modelPath,
    this.nThreads = 0,
    this.flashAttn = false,
    this.vaeTiling = false,
    this.taesdPath,
    this.vaePath,
    this.clipLPath,
    this.backend = Backend.cpu,
    this.quantizationType = QuantizationType.f16,
    this.offloadParamsToCpu = false,
    this.enableMmap = false,
    this.keepVaeOnCpu = false,
    this.maxVram = 0.0,
  });

  Future<GenerationResult> generate({
    required String prompt,
    String negativePrompt = '',
    int width = 384,
    int height = 384,
    int steps = 4,
    int seed = -1,
    double cfgScale = 7.0,
    SampleMethod sampleMethod = SampleMethod.eulerA,
    Schedule schedule = Schedule.discrete,
    bool vaeTiling = false,
  }) async {
    return GenerationResult(
      error: 'Local image generation is not available on web.',
    );
  }

  Future<void> dispose() async {
    await _progressController.close();
    await _logController.close();
  }
}
