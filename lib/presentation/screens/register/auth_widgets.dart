import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';

/// Shared layout for sign in / sign up / forgot password.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = false,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.xxl, AppSpace.lg, AppSpace.xxl, AppSpace.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(size: 20),
                  const SizedBox(height: AppSpace.xxxl),
                  Text(title, style: context.text.displaySmall),
                  const SizedBox(height: AppSpace.sm),
                  Text(subtitle,
                      style: context.text.bodyLarge!
                          .copyWith(color: context.palette.textMuted)),
                  const SizedBox(height: AppSpace.xxl + 4),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Neutral social sign-in button (no third-party logo artwork).
class SocialButton extends StatelessWidget {
  const SocialButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
        child: Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
              child: Text(label, style: context.text.bodySmall),
            ),
            const Expanded(child: Divider()),
          ],
        ),
      );
}

class DemoHint extends StatelessWidget {
  const DemoHint(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpace.lg),
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 18, color: context.colors.onPrimaryContainer),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(text,
                  style: context.text.bodySmall!
                      .copyWith(color: context.colors.onPrimaryContainer)),
            ),
          ],
        ),
      );
}

Future<void> showMessageDialog(BuildContext context,
    {required String title, required String message, IconData? icon}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: icon == null
          ? null
          : Icon(icon, color: context.colors.primary, size: 32),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    ),
  );
}
