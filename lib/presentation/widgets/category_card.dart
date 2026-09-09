import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;
  final Color? accentColor;
  final Widget? trailing;
  final bool hasWarning;
  final String? warningMessage;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    required this.child,
    this.accentColor,
    this.trailing,
    this.hasWarning = false,
    this.warningMessage,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.primaryTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasWarning ? AppTheme.accentCoral.withValues(alpha: 0.6) : AppTheme.slate200,
          width: hasWarning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: hasWarning
                ? AppTheme.accentCoral.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with subtle gradient tint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.07),
                  Colors.white,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              border: Border(bottom: BorderSide(color: AppTheme.slate200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(fontSize: 12, color: AppTheme.slate400, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCoral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accentCoral.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.accentCoral),
                        const SizedBox(width: 4),
                        Text(
                          warningMessage ?? 'Review Needed',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentCoral),
                        ),
                      ],
                    ),
                  )
                else
                  ?trailing,
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
