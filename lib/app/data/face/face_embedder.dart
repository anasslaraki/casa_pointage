import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:onnxruntime/onnxruntime.dart';

import 'face_config.dart';
import 'face_math.dart';

/// Turns an aligned face into a template, with the model of [FaceConfig].
@lazySingleton
class FaceEmbedder {
  OrtSession? _session;
  Future<OrtSession>? _loading;

  Future<OrtSession> _load() async {
    OrtEnv.instance.init();
    final data = await rootBundle.load(FaceConfig.modelAsset);
    return OrtSession.fromBuffer(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      OrtSessionOptions(),
    );
  }

  /// Loads the model once; later calls reuse it.
  Future<OrtSession> _ready() async =>
      _session ??= await (_loading ??= _load());

  /// [chw] comes from `FaceAligner.align`. The template has length 1.
  Future<Float32List> embed(Float32List chw) async {
    final session = await _ready();
    const size = FaceConfig.inputSize;

    final input = OrtValueTensor.createTensorWithDataList(chw, [1, 3, size, size]);
    final options = OrtRunOptions();
    List<OrtValue?>? outputs;
    try {
      outputs = await session.runAsync(options, {session.inputNames.first: input});
      final raw = outputs?.first?.value;
      return FaceMath.normalize(_flatten(raw));
    } finally {
      input.release();
      options.release();
      outputs?.forEach((o) => o?.release());
    }
  }

  static List<double> _flatten(Object? value) {
    if (value is List) {
      return [for (final e in value) ..._flatten(e)];
    }
    if (value is num) return [value.toDouble()];
    return const [];
  }
}
