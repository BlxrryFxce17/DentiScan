import 'package:flutter/material.dart';
import '../../core/constants/dental_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/tooth_procedure.dart';
import 'real_tooth_painter.dart';

class OdontogramWidget extends StatefulWidget {
  final List<ToothProcedure> procedures;
  final Function(String toothNumber)? onToothSelected;
  final String? selectedToothNumber;

  const OdontogramWidget({
    super.key,
    required this.procedures,
    this.onToothSelected,
    this.selectedToothNumber,
  });

  @override
  State<OdontogramWidget> createState() => _OdontogramWidgetState();
}

class _OdontogramWidgetState extends State<OdontogramWidget> {
  String? _internalSelectedTooth;
  OdontogramDisplayMode _displayMode = OdontogramDisplayMode.anatomical;

  String? get _activeTooth => widget.selectedToothNumber ?? _internalSelectedTooth;

  @override
  Widget build(BuildContext context) {
    // FDI Tooth layout:
    // Upper: 18 -> 11 | 21 -> 28
    // Lower: 48 -> 41 | 31 -> 38
    final upperRight = ['18', '17', '16', '15', '14', '13', '12', '11'];
    final upperLeft = ['21', '22', '23', '24', '25', '26', '27', '28'];
    final lowerRight = ['48', '47', '46', '45', '44', '43', '42', '41'];
    final lowerLeft = ['31', '32', '33', '34', '35', '36', '37', '38'];

    final activeTooth = _activeTooth;
    final activeProc = activeTooth != null
        ? widget.procedures.where((p) => p.toothNumber == activeTooth).firstOrNull
        : null;
    final toothInfo = activeTooth != null ? DentalConstants.teeth[activeTooth] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header, View Mode Switcher & Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.grid_view_rounded, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Interactive Odontogram',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.slate900, letterSpacing: -0.2),
                      ),
                      Text(
                        'Anatomical Arch & FDI Charting',
                        style: TextStyle(fontSize: 10.5, color: AppTheme.slate400, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              // Toggle between Realistic Anatomical view and 5-Surface chart
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppTheme.slate100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(OdontogramDisplayMode.anatomical, 'Teeth', Icons.medical_services_rounded),
                    _buildModeButton(OdontogramDisplayMode.fiveSurface, 'Surfaces', Icons.pie_chart_outline_rounded),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend(),
              const Text(
                'FDI Two-Digit Notation',
                style: TextStyle(fontSize: 10, color: AppTheme.slate400, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Upper Arch Header with Quadrant Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Q1 • UPPER RIGHT (UR)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.slate400, letterSpacing: 0.5)),
              Text('MAXILLARY ARCH (UPPER)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.primaryTeal, letterSpacing: 0.8)),
              Text('Q2 • UPPER LEFT (UL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.slate400, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),

          // Upper Arch Teeth Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...upperRight.map((toothId) => _buildToothItem(toothId)),
                _buildMidlineDivider(),
                ...upperLeft.map((toothId) => _buildToothItem(toothId)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.slate200, height: 1),
          ),

          // Lower Arch Teeth Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...lowerRight.map((toothId) => _buildToothItem(toothId)),
                _buildMidlineDivider(),
                ...lowerLeft.map((toothId) => _buildToothItem(toothId)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Lower Arch Header with Quadrant Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Q4 • LOWER RIGHT (LR)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.slate400, letterSpacing: 0.5)),
              Text('MANDIBULAR ARCH (LOWER)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.primaryTeal, letterSpacing: 0.8)),
              Text('Q3 • LOWER LEFT (LL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.slate400, letterSpacing: 0.5)),
            ],
          ),

          // Interactive Selected Tooth Detail Preview Card
          if (activeTooth != null) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activeProc != null ? AppTheme.primaryTeal.withValues(alpha: 0.08) : AppTheme.slate50,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: activeProc != null ? AppTheme.primaryTeal.withValues(alpha: 0.4) : AppTheme.slate200,
                  width: activeProc != null ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeProc != null ? AppTheme.primaryTeal.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: activeProc != null
                            ? [AppTheme.primaryTeal, AppTheme.accentCyan]
                            : [AppTheme.slate700, AppTheme.slate800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#$activeTooth',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toothInfo?.name ?? 'Tooth #$activeTooth',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppTheme.slate900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (activeProc != null)
                          Text(
                            '${activeProc.procedureName} • Surface: ${activeProc.surface ?? "All"} • ₹${activeProc.estimatedCost?.toStringAsFixed(0) ?? "0"}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primaryDark),
                          )
                        else
                          const Text(
                            'Healthy • Intact tooth structure (No pathology recorded)',
                            style: TextStyle(fontSize: 11.5, color: AppTheme.slate400, fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                  if (activeProc != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentCoral.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Treated',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentCoral,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeButton(OdontogramDisplayMode mode, String label, IconData icon) {
    final isSelected = _displayMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _displayMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isSelected ? AppTheme.primaryTeal : AppTheme.slate400),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.slate600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMidlineDivider() {
    return Container(
      width: 2.5,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryTeal.withValues(alpha: 0.1),
            AppTheme.primaryTeal.withValues(alpha: 0.5),
            AppTheme.primaryTeal.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildToothItem(String toothNumber) {
    final proc = widget.procedures.where((p) => p.toothNumber == toothNumber).firstOrNull;
    final isSelected = _activeTooth == toothNumber;

    final toothWidth = 34.0;
    final toothHeight = _displayMode == OdontogramDisplayMode.anatomical ? 56.0 : 34.0;

    return Tooltip(
      message: DentalConstants.getToothDescription(toothNumber) + (proc != null ? '\n${proc.procedureName}' : ''),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _internalSelectedTooth = toothNumber;
          });
          widget.onToothSelected?.call(toothNumber);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: toothWidth,
          height: toothHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _displayMode == OdontogramDisplayMode.anatomical
                  ? CustomPaint(
                      painter: RealToothPainter(
                        toothNumber: toothNumber,
                        procedure: proc,
                        isSelected: isSelected,
                        drawTextLabel: false,
                      ),
                      size: Size(toothWidth, toothHeight),
                    )
                  : CustomPaint(
                      painter: FiveSurfaceToothPainter(
                        toothNumber: toothNumber,
                        procedure: proc,
                        isSelected: isSelected,
                        drawTextLabel: false,
                      ),
                      size: Size(toothWidth, toothHeight),
                    ),
              Positioned(
                top: _displayMode == OdontogramDisplayMode.fiveSurface
                    ? null
                    : (ToothClassifier.isUpper(toothNumber) ? toothHeight * 0.58 : toothHeight * 0.16),
                child: Text(
                  toothNumber,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? AppTheme.primaryDark
                        : (proc != null ? AppTheme.slate900 : AppTheme.slate700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendItem(AppTheme.accentCoral, 'Endo / RCT'),
        const SizedBox(width: 8),
        _legendItem(AppTheme.accentAmber, 'Restoration'),
        const SizedBox(width: 8),
        _legendItem(const Color(0xFF0891B2), 'Perio / Scaling'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.slate600)),
      ],
    );
  }
}
