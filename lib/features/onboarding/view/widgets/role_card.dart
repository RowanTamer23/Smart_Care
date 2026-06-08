import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme.dart';

class RoleCard extends StatefulWidget {
  final bool isDoctorSelected;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final IconData backgroundIcon;
  final String title;
  final String description;
  final String ctaText;
  final Color ctaColor;
  final VoidCallback onTap;
  final bool hasBorder;

  const RoleCard({
    required this.isDoctorSelected,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.backgroundIcon,
    required this.title,
    required this.description,
    required this.ctaText,
    required this.ctaColor,
    required this.onTap,
    required this.hasBorder,
  });

  @override
  State<RoleCard> createState() => RoleCardState();
}

class RoleCardState extends State<RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.hasBorder
                  ? AppColors.border
                  : AppColors.accent.withOpacity(0.4),
              width: widget.hasBorder ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.hasBorder ? AppColors.primary : AppColors.accent)
                    .withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                  const Spacer(),
                  Icon(
                    widget.backgroundIcon,
                    size: 64,
                    color: AppColors.border,
                  ),
                ],
              ),
              Text(
                widget.title,
                style: darkHeadline.copyWith(
                    fontSize: 22, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(widget.description, style: lightTextBody),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    widget.ctaText,
                    style: tealBody.copyWith(color: widget.ctaColor),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: widget.ctaColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
