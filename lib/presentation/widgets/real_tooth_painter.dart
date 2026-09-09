import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/tooth_procedure.dart';

enum ToothType { incisor, canine, premolar, molar }

enum OdontogramDisplayMode { anatomical, fiveSurface }

class ToothClassifier {
  static ToothType getType(String toothNumber) {
    if (toothNumber.length < 2) return ToothType.incisor;
    final lastDigit = toothNumber[1];
    switch (lastDigit) {
      case '1':
      case '2':
        return ToothType.incisor;
      case '3':
        return ToothType.canine;
      case '4':
      case '5':
        return ToothType.premolar;
      case '6':
      case '7':
      case '8':
      default:
        return ToothType.molar;
    }
  }

  static bool isUpper(String toothNumber) {
    if (toothNumber.isEmpty) return true;
    final first = toothNumber[0];
    return first == '1' || first == '2';
  }
}

/// CustomPainter that renders anatomically accurate dental morphology
/// with roots, crowns, enamel shine, and endodontic / restorative treatments.
class RealToothPainter extends CustomPainter {
  final String toothNumber;
  final ToothProcedure? procedure;
  final bool isSelected;
  final bool isHovered;
  final bool drawTextLabel;

  RealToothPainter({
    required this.toothNumber,
    this.procedure,
    this.isSelected = false,
    this.isHovered = false,
    this.drawTextLabel = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isUpper = ToothClassifier.isUpper(toothNumber);
    final type = ToothClassifier.getType(toothNumber);
    final w = size.width;
    final h = size.height;

    // Treatment identification
    final hasProc = procedure != null;
    final procName = procedure?.procedureName.toLowerCase() ?? '';
    final isRct =
        procName.contains('rct') ||
        procName.contains('root') ||
        procName.contains('endo');
    final isRestoration =
        procName.contains('filling') ||
        procName.contains('composite') ||
        procName.contains('amalgam') ||
        procName.contains('restoration') ||
        procName.contains('caries');
    final isPerio =
        procName.contains('scaling') ||
        procName.contains('cleaning') ||
        procName.contains('perio');
    final isExtracted =
        procName.contains('extract') || procName.contains('missing');

    // Color definitions
    final enamelBase = isSelected
        ? const Color(0xFFE0F2FE)
        : (hasProc
              ? (isRct
                    ? const Color(0xFFFFF1F2)
                    : isRestoration
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFECFEFF))
              : const Color(0xFFFFFFFF));
    final enamelEdge = isSelected
        ? AppTheme.primaryTeal
        : (hasProc
              ? (isRct
                    ? AppTheme.accentCoral
                    : isRestoration
                    ? AppTheme.accentAmber
                    : const Color(0xFF0891B2))
              : AppTheme.slate300);

    final rootBase = isSelected
        ? const Color(0xFFBAE6FD)
        : (hasProc
              ? (isRct ? const Color(0xFFFFE4E6) : const Color(0xFFFEF3C7))
              : const Color(0xFFF1F5F9));
    final rootEdge = isSelected
        ? AppTheme.primaryTeal
        : (hasProc
              ? (isRct
                    ? AppTheme.accentCoral.withValues(alpha: 0.8)
                    : AppTheme.accentAmber)
              : AppTheme.slate400);

    // Selected / Hover halo glow
    if (isSelected) {
      final glowPaint = Paint()
        ..color = AppTheme.primaryTeal.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 2, w - 4, h - 4),
          const Radius.circular(8),
        ),
        glowPaint,
      );
    }

    // Geometry layout:
    // For upper teeth: Root is on TOP (0 to 0.52 * h), Crown is on BOTTOM (0.48 * h to h)
    // For lower teeth: Crown is on TOP (0 to 0.52 * h), Root is on BOTTOM (0.48 * h to h)

    canvas.save();
    if (!isUpper) {
      // For lower teeth, invert vertically so crown is on top facing upper arch
      canvas.translate(0, h);
      canvas.scale(1.0, -1.0);
    }

    // Paint Root(s) first
    _drawRoots(canvas, w, h, type, rootBase, rootEdge, isRct);

    // Paint Crown
    _drawCrown(
      canvas,
      w,
      h,
      type,
      enamelBase,
      enamelEdge,
      isRestoration,
      isRct,
      isPerio,
    );

    canvas.restore();

    // If extracted, draw red clinical X
    if (isExtracted) {
      final xPaint = Paint()
        ..color = AppTheme.accentCoral
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(w * 0.2, h * 0.2),
        Offset(w * 0.8, h * 0.8),
        xPaint,
      );
      canvas.drawLine(
        Offset(w * 0.8, h * 0.2),
        Offset(w * 0.2, h * 0.8),
        xPaint,
      );
    }

    // Tooth Number Label at the center of crown (if enabled)
    if (drawTextLabel) {
      final textSpan = TextSpan(
        text: toothNumber,
        style: TextStyle(
          color: isSelected
              ? AppTheme.primaryDark
              : (hasProc ? AppTheme.slate900 : AppTheme.slate700),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final textY = isUpper
          ? (h * 0.68 - textPainter.height / 2)
          : (h * 0.32 - textPainter.height / 2);
      textPainter.paint(canvas, Offset((w - textPainter.width) / 2, textY));
    }
  }

  void _drawRoots(
    Canvas canvas,
    double w,
    double h,
    ToothType type,
    Color baseColor,
    Color edgeColor,
    bool isRct,
  ) {
    final rootPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = edgeColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rootTop = 4.0;
    final rootBottom = h * 0.52;

    final path = Path();

    switch (type) {
      case ToothType.molar:
        // Bifurcated dual root profile
        path.moveTo(w * 0.18, rootBottom);
        // Left root
        path.quadraticBezierTo(
          w * 0.12,
          rootTop + (rootBottom - rootTop) * 0.5,
          w * 0.28,
          rootTop,
        );
        path.quadraticBezierTo(
          w * 0.38,
          rootTop + (rootBottom - rootTop) * 0.4,
          w * 0.46,
          rootBottom * 0.75,
        );
        // Bifurcation notch
        path.lineTo(w * 0.54, rootBottom * 0.75);
        // Right root
        path.quadraticBezierTo(
          w * 0.62,
          rootTop + (rootBottom - rootTop) * 0.4,
          w * 0.72,
          rootTop,
        );
        path.quadraticBezierTo(
          w * 0.88,
          rootTop + (rootBottom - rootTop) * 0.5,
          w * 0.82,
          rootBottom,
        );
        path.close();
        break;

      case ToothType.premolar:
        // Moderately split / dual apex root
        path.moveTo(w * 0.24, rootBottom);
        path.quadraticBezierTo(w * 0.20, rootTop + 6, w * 0.38, rootTop);
        path.quadraticBezierTo(w * 0.50, rootTop + 8, w * 0.62, rootTop);
        path.quadraticBezierTo(w * 0.80, rootTop + 6, w * 0.76, rootBottom);
        path.close();
        break;

      case ToothType.canine:
        // Long, stout single conical root tapering to apex
        path.moveTo(w * 0.22, rootBottom);
        path.quadraticBezierTo(w * 0.26, rootTop + 8, w * 0.50, rootTop);
        path.quadraticBezierTo(w * 0.74, rootTop + 8, w * 0.78, rootBottom);
        path.close();
        break;

      case ToothType.incisor:
        // Slender conical single root
        path.moveTo(w * 0.26, rootBottom);
        path.quadraticBezierTo(w * 0.30, rootTop + 8, w * 0.50, rootTop);
        path.quadraticBezierTo(w * 0.70, rootTop + 8, w * 0.74, rootBottom);
        path.close();
        break;
    }

    canvas.drawPath(path, rootPaint);
    canvas.drawPath(path, edgePaint);

    // If RCT procedure, draw root canal filling lines (gutta-percha)
    if (isRct) {
      final rctPaint = Paint()
        ..color = AppTheme.accentCoral
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (type == ToothType.molar) {
        // Dual canal lines
        final leftCanal = Path()
          ..moveTo(w * 0.30, rootTop + 2)
          ..quadraticBezierTo(w * 0.25, rootBottom * 0.5, w * 0.32, rootBottom);
        final rightCanal = Path()
          ..moveTo(w * 0.70, rootTop + 2)
          ..quadraticBezierTo(w * 0.75, rootBottom * 0.5, w * 0.68, rootBottom);
        canvas.drawPath(leftCanal, rctPaint);
        canvas.drawPath(rightCanal, rctPaint);
      } else {
        // Single central canal line
        final canal = Path()
          ..moveTo(w * 0.50, rootTop + 2)
          ..lineTo(w * 0.50, rootBottom);
        canvas.drawPath(canal, rctPaint);
      }
    }
  }

  void _drawCrown(
    Canvas canvas,
    double w,
    double h,
    ToothType type,
    Color baseColor,
    Color edgeColor,
    bool isRestoration,
    bool isRct,
    bool isPerio,
  ) {
    final crownPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = edgeColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final crownTop = h * 0.48;
    final crownBottom = h - 3.0;

    final path = Path();

    switch (type) {
      case ToothType.molar:
        // Broad multi-cusped occlusal crown with developmental fissures
        path.moveTo(w * 0.12, crownTop);
        path.quadraticBezierTo(
          w * 0.08,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.14,
          crownBottom - 2,
        );
        // Cusps on occlusal edge
        path.quadraticBezierTo(
          w * 0.28,
          crownBottom,
          w * 0.36,
          crownBottom - 2,
        );
        path.quadraticBezierTo(
          w * 0.50,
          crownBottom + 1,
          w * 0.64,
          crownBottom - 2,
        );
        path.quadraticBezierTo(
          w * 0.72,
          crownBottom,
          w * 0.86,
          crownBottom - 2,
        );
        path.quadraticBezierTo(
          w * 0.92,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.88,
          crownTop,
        );
        // Cemento-enamel junction (CEJ)
        path.quadraticBezierTo(w * 0.50, crownTop + 3, w * 0.12, crownTop);
        path.close();
        break;

      case ToothType.premolar:
        // Bicuspid crown profile
        path.moveTo(w * 0.16, crownTop);
        path.quadraticBezierTo(
          w * 0.12,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.20,
          crownBottom - 2,
        );
        path.quadraticBezierTo(
          w * 0.35,
          crownBottom + 1,
          w * 0.50,
          crownBottom - 1,
        );
        path.quadraticBezierTo(
          w * 0.65,
          crownBottom + 1,
          w * 0.80,
          crownBottom - 2,
        );
        path.quadraticBezierTo(
          w * 0.88,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.84,
          crownTop,
        );
        path.quadraticBezierTo(w * 0.50, crownTop + 2.5, w * 0.16, crownTop);
        path.close();
        break;

      case ToothType.canine:
        // Pointed cusp diamond incisal crown
        path.moveTo(w * 0.18, crownTop);
        path.quadraticBezierTo(
          w * 0.14,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.26,
          crownBottom - 4,
        );
        path.lineTo(w * 0.50, crownBottom); // Pointed sharp cusp tip
        path.lineTo(w * 0.74, crownBottom - 4);
        path.quadraticBezierTo(
          w * 0.86,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.82,
          crownTop,
        );
        path.quadraticBezierTo(w * 0.50, crownTop + 2, w * 0.18, crownTop);
        path.close();
        break;

      case ToothType.incisor:
        // Straight incisal edge chisel crown
        path.moveTo(w * 0.20, crownTop);
        path.quadraticBezierTo(
          w * 0.16,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.20,
          crownBottom - 2,
        );
        path.quadraticBezierTo(w * 0.22, crownBottom, w * 0.28, crownBottom);
        path.lineTo(w * 0.72, crownBottom);
        path.quadraticBezierTo(
          w * 0.78,
          crownBottom,
          w * 0.80,
          crownBottom - 2,
        );
        path.quadraticBezierTo(
          w * 0.84,
          crownTop + (crownBottom - crownTop) * 0.5,
          w * 0.80,
          crownTop,
        );
        path.quadraticBezierTo(w * 0.50, crownTop + 2, w * 0.20, crownTop);
        path.close();
        break;
    }

    canvas.drawPath(path, crownPaint);
    canvas.drawPath(path, edgePaint);

    // Subtle enamel highlight reflection
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    final shinePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w * 0.24,
            crownTop + 4,
            w * 0.16,
            (crownBottom - crownTop) * 0.45,
          ),
          const Radius.circular(3),
        ),
      );
    canvas.drawPath(shinePath, shinePaint);

    // If Restoration / Filling, paint occlusal/coronal restorative inlay
    if (isRestoration) {
      final inlayPaint = Paint()
        ..color = AppTheme.accentAmber.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      final inlayEdge = Paint()
        ..color = const Color(0xFFB45309)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      final inlayRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          w * 0.32,
          crownBottom - (crownBottom - crownTop) * 0.38,
          w * 0.36,
          (crownBottom - crownTop) * 0.32,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(inlayRect, inlayPaint);
      canvas.drawRRect(inlayRect, inlayEdge);
    }

    // If Perio, paint cervical gingival band
    if (isPerio) {
      final perioPaint = Paint()
        ..color = const Color(0xFF06B6D4).withValues(alpha: 0.8)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(w * 0.15, crownTop + 1),
        Offset(w * 0.85, crownTop + 1),
        perioPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RealToothPainter oldDelegate) {
    return oldDelegate.toothNumber != toothNumber ||
        oldDelegate.procedure != procedure ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isHovered != isHovered;
  }
}

/// CustomPainter that renders the standard clinical 5-Surface FDI Dental Chart
/// (Occlusal, Mesial, Distal, Buccal, Lingual)
class FiveSurfaceToothPainter extends CustomPainter {
  final String toothNumber;
  final ToothProcedure? procedure;
  final bool isSelected;
  final bool drawTextLabel;

  FiveSurfaceToothPainter({
    required this.toothNumber,
    this.procedure,
    this.isSelected = false,
    this.drawTextLabel = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hasProc = procedure != null;
    final procName = procedure?.procedureName.toLowerCase() ?? '';
    final isRct =
        procName.contains('rct') ||
        procName.contains('root') ||
        procName.contains('endo');
    final isRestoration =
        procName.contains('filling') ||
        procName.contains('composite') ||
        procName.contains('amalgam') ||
        procName.contains('restoration') ||
        procName.contains('caries');

    final surfaceStr = procedure?.surface?.toLowerCase() ?? '';

    // Color definitions
    final defaultBg = isSelected
        ? const Color(0xFFE0F2FE)
        : const Color(0xFFFFFFFF);
    final borderCol = isSelected ? AppTheme.primaryTeal : AppTheme.slate300;
    final fillCol = isRct
        ? AppTheme.accentCoral
        : (isRestoration ? AppTheme.accentAmber : const Color(0xFF0891B2));

    final basePaint = Paint()
      ..color = defaultBg
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = borderCol
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final r = w / 2;
    final center = Offset(r, h / 2);
    final innerR = r * 0.45;

    // Draw outer boundary
    canvas.drawCircle(center, r - 2, basePaint);

    // 5 Surfaces:
    // Center circle = Occlusal
    // Top = Buccal
    // Bottom = Lingual
    // Left = Mesial
    // Right = Distal
    final bool oFilled =
        hasProc && (surfaceStr.contains('o') || surfaceStr.isEmpty || isRct);
    final bool bFilled = hasProc && surfaceStr.contains('b');
    final bool lFilled = hasProc && surfaceStr.contains('l');
    final bool mFilled = hasProc && surfaceStr.contains('m');
    final bool dFilled = hasProc && surfaceStr.contains('d');

    final surfPaint = Paint()
      ..color = fillCol.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // Buccal (top arc)
    if (bFilled) {
      final bPath = Path()
        ..moveTo(center.dx - innerR * 0.707, center.dy - innerR * 0.707)
        ..lineTo(center.dx - (r - 2) * 0.707, center.dy - (r - 2) * 0.707)
        ..arcToPoint(
          Offset(center.dx + (r - 2) * 0.707, center.dy - (r - 2) * 0.707),
          radius: Radius.circular(r - 2),
        )
        ..lineTo(center.dx + innerR * 0.707, center.dy - innerR * 0.707)
        ..arcToPoint(
          Offset(center.dx - innerR * 0.707, center.dy - innerR * 0.707),
          radius: Radius.circular(innerR),
          clockwise: false,
        )
        ..close();
      canvas.drawPath(bPath, surfPaint);
    }

    // Lingual (bottom arc)
    if (lFilled) {
      final lPath = Path()
        ..moveTo(center.dx - innerR * 0.707, center.dy + innerR * 0.707)
        ..lineTo(center.dx - (r - 2) * 0.707, center.dy + (r - 2) * 0.707)
        ..arcToPoint(
          Offset(center.dx + (r - 2) * 0.707, center.dy + (r - 2) * 0.707),
          radius: Radius.circular(r - 2),
          clockwise: false,
        )
        ..lineTo(center.dx + innerR * 0.707, center.dy + innerR * 0.707)
        ..arcToPoint(
          Offset(center.dx - innerR * 0.707, center.dy + innerR * 0.707),
          radius: Radius.circular(innerR),
        )
        ..close();
      canvas.drawPath(lPath, surfPaint);
    }

    // Mesial (left arc)
    if (mFilled) {
      final mPath = Path()
        ..moveTo(center.dx - (r - 2) * 0.707, center.dy - (r - 2) * 0.707)
        ..arcToPoint(
          Offset(center.dx - (r - 2) * 0.707, center.dy + (r - 2) * 0.707),
          radius: Radius.circular(r - 2),
          clockwise: false,
        )
        ..lineTo(center.dx - innerR * 0.707, center.dy + innerR * 0.707)
        ..arcToPoint(
          Offset(center.dx - innerR * 0.707, center.dy - innerR * 0.707),
          radius: Radius.circular(innerR),
        )
        ..close();
      canvas.drawPath(mPath, surfPaint);
    }

    // Distal (right arc)
    if (dFilled) {
      final dPath = Path()
        ..moveTo(center.dx + (r - 2) * 0.707, center.dy - (r - 2) * 0.707)
        ..arcToPoint(
          Offset(center.dx + (r - 2) * 0.707, center.dy + (r - 2) * 0.707),
          radius: Radius.circular(r - 2),
        )
        ..lineTo(center.dx + innerR * 0.707, center.dy + innerR * 0.707)
        ..arcToPoint(
          Offset(center.dx + innerR * 0.707, center.dy - innerR * 0.707),
          radius: Radius.circular(innerR),
          clockwise: false,
        )
        ..close();
      canvas.drawPath(dPath, surfPaint);
    }

    // Occlusal center
    final occlusalPaint = Paint()
      ..color = oFilled ? fillCol.withValues(alpha: 0.75) : defaultBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerR, occlusalPaint);
    canvas.drawCircle(center, innerR, linePaint);

    // Cross dividing lines to outer circle
    canvas.drawLine(
      Offset(center.dx - innerR * 0.707, center.dy - innerR * 0.707),
      Offset(center.dx - (r - 2) * 0.707, center.dy - (r - 2) * 0.707),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx + innerR * 0.707, center.dy - innerR * 0.707),
      Offset(center.dx + (r - 2) * 0.707, center.dy - (r - 2) * 0.707),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - innerR * 0.707, center.dy + innerR * 0.707),
      Offset(center.dx - (r - 2) * 0.707, center.dy + (r - 2) * 0.707),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx + innerR * 0.707, center.dy + innerR * 0.707),
      Offset(center.dx + (r - 2) * 0.707, center.dy + (r - 2) * 0.707),
      linePaint,
    );

    canvas.drawCircle(center, r - 2, linePaint);

    // Number label (if enabled)
    if (drawTextLabel) {
      final textSpan = TextSpan(
        text: toothNumber,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryDark : AppTheme.slate800,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FiveSurfaceToothPainter oldDelegate) {
    return oldDelegate.toothNumber != toothNumber ||
        oldDelegate.procedure != procedure ||
        oldDelegate.isSelected != isSelected;
  }
}
