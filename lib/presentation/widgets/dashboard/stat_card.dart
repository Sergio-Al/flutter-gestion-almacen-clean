import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String? value;
  final double? percentChange;
  final bool isPositive;
  final IconData? icon;
  final Color? iconColor;
  final bool isLoading;
  final bool hasError;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.percentChange,
    this.isPositive = true,
    this.icon,
    this.iconColor,
    this.isLoading = false,
    this.hasError = false,
  }) : super(key: key);

  const StatCard.loading({
    Key? key,
    required this.title,
    this.value,
    this.percentChange,
    this.isPositive = true,
    this.icon,
    this.iconColor,
  })  : isLoading = true,
        hasError = false,
        super(key: key);

  const StatCard.error({
    Key? key,
    required this.title,
    this.value,
    this.percentChange,
    this.isPositive = true,
    this.icon,
    this.iconColor,
  })  : isLoading = false,
        hasError = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (hasError)
            const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
              ],
            ),
          if (!isLoading && !hasError && percentChange != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${percentChange!.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
