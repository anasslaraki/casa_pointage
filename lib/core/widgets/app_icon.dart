import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The prototype's stroke icon set (24x24 grid), kept as-is for fidelity.
enum AppIcons {
  home('<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>'),
  users(
      '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c0-3.6 3-5.5 6.5-5.5s6.5 1.9 6.5 5.5"/><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8M18 14.8c2.2.6 3.5 2.3 3.5 5.2"/>'),
  user('<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.6-6 8-6s8 2 8 6"/>'),
  face(
      '<path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3"/><path d="M9 10v1M15 10v1M12 10v3h-1M9.5 16c1.5 1 3.5 1 5 0"/>'),
  scanFace(
      '<path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3"/><circle cx="12" cy="11" r="3.2"/><path d="M7.5 18c.9-1.7 2.5-2.6 4.5-2.6s3.6.9 4.5 2.6"/>'),
  calendar(
      '<rect x="3" y="4.5" width="18" height="16.5" rx="2.5"/><path d="M8 2.5v4M16 2.5v4M3 10h18"/>'),
  clock('<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>'),
  login(
      '<path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4M10 17l5-5-5-5M15 12H3"/>'),
  logout(
      '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>'),
  check('<path d="M20 6 9 17l-5-5"/>'),
  close('<path d="M18 6 6 18M6 6l12 12"/>'),
  chevronRight('<path d="m9 18 6-6-6-6"/>', mirrorInRtl: true),
  chevronLeft('<path d="m15 18-6-6 6-6"/>', mirrorInRtl: true),
  chevronDown('<path d="m6 9 6 6 6-6"/>'),
  alert(
      '<path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/>'),
  pin('<path d="M12 21s-7-6.2-7-12a7 7 0 0 1 14 0c0 5.8-7 12-7 12z"/><circle cx="12" cy="9" r="2.5"/>'),
  cloudOff(
      '<path d="M3 3l18 18M8.5 8.6A5 5 0 0 0 7 19h10.5M20.5 16.6A4 4 0 0 0 19.8 11 6 6 0 0 0 11 5.3"/>'),
  cloud('<path d="M17.5 19H7a5 5 0 1 1 1.2-9.9A6 6 0 0 1 19.8 11 4 4 0 0 1 17.5 19z"/>'),
  refresh('<path d="M21 12a9 9 0 1 1-2.6-6.4M21 3v6h-6"/>'),
  bed('<path d="M3 7v12M3 13h18v6M21 13a3 3 0 0 0-3-3h-7v3"/><circle cx="7" cy="10" r="2"/>'),
  hand(
      '<path d="M8 13V5.5a1.5 1.5 0 0 1 3 0V12M11 11V4.5a1.5 1.5 0 0 1 3 0V11M14 11V6.5a1.5 1.5 0 0 1 3 0V14a6 6 0 0 1-6 6h-1a6 6 0 0 1-5-2.7L3.6 14.5a1.5 1.5 0 0 1 2.5-1.6L8 15"/>'),
  camera(
      '<path d="M4 8h3l2-3h6l2 3h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/><circle cx="12" cy="13.5" r="3.5"/>'),
  flipCamera(
      '<path d="M4 8h3l2-3h6l2 3h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/><path d="M9 13.5a3 3 0 0 1 5.2-2M15 13.5a3 3 0 0 1-5.2 2M14.2 9.5v2h-2M9.8 17.5v-2h2"/>'),
  search('<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>'),
  lock('<rect x="4" y="11" width="16" height="10" rx="2.5"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>'),
  eye('<path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>'),
  eyeOff(
      '<path d="M3 3l18 18M10.6 5.1A10 10 0 0 1 12 5c6.4 0 10 7 10 7a17 17 0 0 1-3.2 4M6.6 6.6C3.8 8.4 2 12 2 12s3.6 7 10 7a9.7 9.7 0 0 0 5.4-1.6M9.9 9.9a3 3 0 0 0 4.2 4.2"/>'),
  globe(
      '<circle cx="12" cy="12" r="9.5"/><path d="M2.5 12h19M12 2.5c3 3.2 3 15.8 0 19M12 2.5c-3 3.2-3 15.8 0 19"/>'),
  help('<circle cx="12" cy="12" r="9.5"/><path d="M9.5 9a2.5 2.5 0 0 1 5 .5c0 1.7-2.5 2-2.5 3.5M12 17h.01"/>'),
  shield('<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="m9 12 2 2 4-4"/>'),
  history('<path d="M3 12a9 9 0 1 0 3-6.7L3 8M3 3v5h5M12 7v5l3 2"/>'),
  edit('<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="m13.5 6.5 4 4"/>'),
  wifi('<path d="M2 8.5a15 15 0 0 1 20 0M5.5 12a10 10 0 0 1 13 0M9 15.5a5 5 0 0 1 6 0M12 19h.01"/>');

  const AppIcons(this.path, {this.mirrorInRtl = false});

  final String path;

  /// Direction arrows flip in right-to-left layouts.
  final bool mirrorInRtl;
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.color,
    this.size = 22,
    this.strokeWidth = 2,
  });

  final AppIcons icon;
  final Color? color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Colors.black;
    final hex =
        (resolved.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');

    Widget child = SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="#$hex" stroke-width="$strokeWidth" stroke-linecap="round" '
      'stroke-linejoin="round">${icon.path}</svg>',
      width: size,
      height: size,
    );

    if (icon.mirrorInRtl && Directionality.of(context) == TextDirection.rtl) {
      child = Transform.flip(flipX: true, child: child);
    }
    return ExcludeSemantics(child: child);
  }
}
