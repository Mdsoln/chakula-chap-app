import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bounceAnim = Tween<double>(begin: 1, end: 0.93).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _bounceController.forward(),
      onTapUp: (_) => _bounceController.reverse(),
      onTapCancel: () => _bounceController.reverse(),
      child: ScaleTransition(
        scale: _bounceAnim,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.navyAccent, width: 0.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImage(),
              _buildDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        Container(
          height: 110,
          color: AppColors.navyMedium,
          width: double.infinity,
          child: Center(
            child: Text(
              widget.item.emoji,
              style: const TextStyle(fontSize: 52),
            ),
          ),
        ),
        if (widget.item.tag != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.goldBright,
                borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                widget.item.tag!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.navyDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        if (!widget.item.isAvailable)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Text(
                  'Unavailable',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.item.name,
            style: AppTextStyles.labelLarge.copyWith(height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            // No Flexible — Text handles overflow via maxLines + ellipsis
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 12, color: AppColors.goldBright),
              const SizedBox(width: 3),
              Text(widget.item.rating.toString(), style: AppTextStyles.bodySmall),
              const SizedBox(width: 6),
              const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text('${widget.item.prepTimeMinutes}m', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tsh ${widget.item.price.toInt()}',
                style: AppTextStyles.price.copyWith(fontSize: 14),
              ),
              GestureDetector(
                onTap: widget.item.isAvailable ? widget.onAddToCart : null,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: widget.item.isAvailable ? AppColors.goldGradient : null,
                    color: widget.item.isAvailable ? null : AppColors.navyAccent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: widget.item.isAvailable
                        ? [BoxShadow(
                      color: AppColors.goldBright.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )]
                        : null,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: widget.item.isAvailable
                        ? AppColors.navyDeep
                        : AppColors.textDisabled,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}