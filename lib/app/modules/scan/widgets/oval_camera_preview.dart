import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:casa_pointage/core/widgets/app_icon.dart';

/// Called with each camera frame (NV21) and the camera it comes from.
typedef FrameCallback = void Function(CameraImage image, CameraDescription camera);

/// Live camera inside an oval. Falls back to a silhouette when no camera is
/// available or the permission is denied, so the flow can still be tested.
/// When [onFrame] is set, the frames are streamed to it for face analysis.
class OvalCameraPreview extends StatefulWidget {
  const OvalCameraPreview({
    super.key,
    required this.lens,
    required this.width,
    required this.height,
    this.onFrame,
  });

  final CameraLensDirection lens;
  final double width;
  final double height;
  final FrameCallback? onFrame;

  @override
  State<OvalCameraPreview> createState() => _OvalCameraPreviewState();
}

class _OvalCameraPreviewState extends State<OvalCameraPreview> {
  CameraController? _camera;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(OvalCameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lens != widget.lens) _start();
  }

  Future<void> _stop(CameraController? camera) async {
    if (camera == null) return;
    try {
      if (camera.value.isStreamingImages) await camera.stopImageStream();
    } on CameraException {
      // Already stopped.
    }
    await camera.dispose();
  }

  Future<void> _start() async {
    final generation = ++_generation;
    final previous = _camera;
    setState(() => _camera = null);
    await _stop(previous);

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final description = cameras.firstWhere(
        (c) => c.lensDirection == widget.lens,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();

      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }
      if (widget.onFrame != null) {
        await controller.startImageStream(
          (image) => widget.onFrame?.call(image, description),
        );
      }
      setState(() => _camera = controller);
    } on CameraException {
      // Permission denied or camera busy: keep the placeholder.
    }
  }

  @override
  void dispose() {
    _generation++;
    _stop(_camera);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    final ready = camera != null && camera.value.isInitialized;

    return ClipOval(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ColoredBox(
          color: const Color(0xFF1A211C),
          child: ready
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    // The sensor reports landscape sizes; the preview is
                    // shown in portrait.
                    width: camera.value.previewSize!.height,
                    height: camera.value.previewSize!.width,
                    child: CameraPreview(camera),
                  ),
                )
              : Center(
                  child: AppIcon(
                    AppIcons.user,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: widget.width * 0.48,
                    strokeWidth: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}
