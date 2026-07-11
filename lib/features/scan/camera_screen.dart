import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/barcode_scanner.dart';
import '../../widgets/ui.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _initializing = true;
  bool _processing = false;
  bool _zoom2x = false;
  double _maxZoom = 1.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() { _error = 'No camera found on this device'; _initializing = false; });
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await ctrl.initialize();
      _maxZoom = await ctrl.getMaxZoomLevel();

      if (!mounted) { ctrl.dispose(); return; }
      setState(() { _controller = ctrl; _initializing = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Camera access denied'; _initializing = false; });
    }
  }

  Future<void> _toggleZoom() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    HapticFeedback.selectionClick();
    _zoom2x = !_zoom2x;
    final level = _zoom2x ? 2.0.clamp(1.0, _maxZoom) : 1.0;
    await ctrl.setZoomLevel(level);
    if (mounted) setState(() {});
  }

  Future<void> _capture() async {
    final ctrl = _controller;
    if (ctrl == null || _processing) return;
    HapticFeedback.mediumImpact();
    setState(() => _processing = true);

    try {
      final file = await ctrl.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      await _processAndNavigate(bytes);
    } catch (_) {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_processing) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1920);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _processing = true);
    await _processAndNavigate(bytes);
  }

  Future<void> _processAndNavigate(Uint8List bytes) async {
    String? barcode;
    try {
      barcode = await barcodeService.detectBarcode(bytes);
    } catch (_) {}

    if (mounted) {
      context.push('/scanning', extra: {'bytes': bytes.toList(), 'barcode': barcode});
    }
    if (mounted) setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFF2F4F7);

    return Scaffold(
      child: Container(
        color: const Color(0xFF000000),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              )
            else if (_initializing)
              const Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: white),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_rounded, size: 44, color: Color(0xFF5A6374)),
                    const Gap(14),
                    Text(_error!, style: kSans(15, color: white)),
                    const Gap(20),
                    AppButton(
                      label: 'Pick from gallery',
                      variant: AppButtonVariant.tonal,
                      expand: false,
                      height: 44,
                      onTap: _pickFromGallery,
                    ),
                  ],
                ),
              ),

            IgnorePointer(
              child: Center(
                child: CustomPaint(
                  size: const Size(270, 270),
                  painter: _BracketPainter(color: white.withValues(alpha: 0.85)),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Pressable(
                      onTap: () => context.pop(),
                      pressedScale: 0.9,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.close_rounded, color: white, size: 20),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0x66000000),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'SPECIMEN CAPTURE',
                        style: kMono(10, weight: FontWeight.w600, letterSpacing: 2, color: white),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            if (_processing)
              Container(
                color: const Color(0xAA000000),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5, color: white)),
                      Gap(16),
                      Text(
                        'READING SPECIMEN',
                        style: TextStyle(
                          fontSize: 11, letterSpacing: 2, color: white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xE6000000), Color(0x00000000)],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28, top: 70),
                    child: Column(
                      children: [
                        Text(
                          'Frame the item — labels help',
                          style: kSans(13, color: white.withValues(alpha: 0.75)),
                        ),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RoundControl(
                              onTap: _processing ? null : _pickFromGallery,
                              child: const Icon(Icons.photo_library_outlined, color: white, size: 21),
                            ),
                            const Gap(28),
                            Pressable(
                              onTap: _processing ? null : _capture,
                              pressedScale: 0.88,
                              child: Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kSignal, width: 3),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 58,
                                    height: 58,
                                    decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(28),
                            _RoundControl(
                              onTap: _processing ? null : _toggleZoom,
                              active: _zoom2x,
                              child: Text(
                                _zoom2x ? '2×' : '1×',
                                style: kMono(13, weight: FontWeight.w600, color: white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool active;

  const _RoundControl({required this.child, this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? const Color(0x55FFFFFF) : const Color(0x28FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 30.0;
    const r = 22.0;
    final w = size.width;
    final h = size.height;

    void corner(Offset origin, int dx, int dy) {
      final path = Path()
        ..moveTo(origin.dx + dx * len, origin.dy)
        ..lineTo(origin.dx + dx * r, origin.dy)
        ..arcToPoint(
          Offset(origin.dx, origin.dy + dy * r),
          radius: const Radius.circular(r),
          clockwise: (dx > 0) != (dy > 0),
        )
        ..lineTo(origin.dx, origin.dy + dy * len);
      canvas.drawPath(path, paint);
    }

    corner(const Offset(0, 0), 1, 1);
    corner(Offset(w, 0), -1, 1);
    corner(Offset(0, h), 1, -1);
    corner(Offset(w, h), -1, -1);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter old) => old.color != color;
}
