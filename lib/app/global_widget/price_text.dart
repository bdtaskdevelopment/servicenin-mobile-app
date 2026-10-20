import 'package:flutter/material.dart';

/// Price in the admin panel's style: the payable price in emerald when
/// discounted (otherwise [baseColor]), with the list price struck through
/// in red beside it when a discount applies. Shared by Home Service and
/// Physiotherapy's catalog rows.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.prefix,
    this.baseColor = const Color(0xFF0E7C6B),
  });
  final int price;
  final int? originalPrice;
  final String? prefix;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null;
    return Text.rich(
      TextSpan(children: [
        if (prefix != null)
          TextSpan(
              text: '$prefix ',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
        TextSpan(
            text: '৳$price',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: hasDiscount ? const Color(0xFF047857) : baseColor)),
        if (hasDiscount) ...[
          const TextSpan(text: '  '),
          TextSpan(
              text: '৳$originalPrice',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFFEF4444))),
        ],
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
