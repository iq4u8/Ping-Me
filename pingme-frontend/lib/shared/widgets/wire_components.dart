import 'package:flutter/material.dart';
import '../../theme.dart';

class WireButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  final bool isPrimary;
  final IconData? icon;

  const WireButton({
    super.key,
    required this.text,
    required this.onClick,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Theme.of(context).colorScheme.primary : Colors.transparent,
          foregroundColor: isPrimary ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          side: isPrimary ? null : BorderSide(color: Theme.of(context).dividerColor),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isPrimary ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class WireInputField extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlaceholder;

  const WireInputField({
    super.key,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).dividerColor,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isPlaceholder ? Theme.of(context).dividerColor : Theme.of(context).colorScheme.onSurface,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ),
      ],
    );
  }
}
