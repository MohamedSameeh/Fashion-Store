import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/auth_repository.dart';
import '../../../data/store_repository.dart';
import 'auth_widgets.dart';

/// Signed out: sends a password reset email.
/// Signed in (opened from Profile > Change password): sets a new password.
class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final gmailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isEmailSend = false;
  bool _loading = false;
  bool _obscure = true;

  bool get _changeMode => Repo.auth.isSignedIn;

  @override
  void dispose() {
    gmailController.dispose();
    newPasswordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      if (_changeMode) {
        await Repo.auth.updatePassword(newPasswordController.text);
        if (!mounted) return;
        showAppSnack(context, 'Password updated');
        Navigator.pop(context);
      } else {
        await Repo.auth.sendPasswordReset(gmailController.text.trim());
        if (mounted) setState(() => isEmailSend = true);
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        await showMessageDialog(context,
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            message: e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_changeMode) {
      return AuthScaffold(
        showBack: true,
        title: 'Change password',
        subtitle: 'Choose a new password for your account.',
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: newPasswordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                    ),
                  ),
                  validator: (v) => (v ?? '').length < 6
                      ? 'Use at least 6 characters'
                      : null,
                ),
                const SizedBox(height: AppSpace.lg),
                TextFormField(
                  controller: confirmController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (v) => v != newPasswordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xxl),
          LoadingButton(
              label: 'Update password', loading: _loading, onPressed: _submit),
        ],
      );
    }

    return AuthScaffold(
      showBack: true,
      title: 'Forgot password',
      subtitle: isEmailSend
          ? 'If an account exists for ${gmailController.text.trim()}, a reset link is on its way.'
          : 'Enter your email and we will send you a link to reset your password.',
      children: [
        if (!isEmailSend) ...[
          Form(
            key: _formKey,
            child: TextFormField(
              controller: gmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) => EmailValidator.validate((v ?? '').trim())
                  ? null
                  : 'Enter a valid email',
            ),
          ),
          const SizedBox(height: AppSpace.xxl),
          LoadingButton(
              label: 'Send reset link', loading: _loading, onPressed: _submit),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            decoration: BoxDecoration(
              color: context.palette.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.mark_email_read_outlined,
                    color: context.palette.success),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text('Check your inbox and follow the link.',
                      style: context.text.bodyMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xxl),
          LoadingButton(
              label: 'Back to login',
              onPressed: () => Navigator.pop(context)),
        ],
      ],
    );
  }
}
