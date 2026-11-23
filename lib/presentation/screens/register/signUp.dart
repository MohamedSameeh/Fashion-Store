import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/auth_repository.dart';
import '../../../data/store_repository.dart';
import 'auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool visible = true;
  bool _loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await Repo.auth.signUpWithEmail(nameController.text.trim(),
          emailController.text.trim(), passController.text);
      if (!mounted) return;
      await showMessageDialog(context,
          icon: Icons.mark_email_read_outlined,
          title: 'Account created',
          message: kDemoMode
              ? 'Demo mode: no account is stored. You can log in with any email.'
              : 'Check your email to verify the account, then log in.');
      if (mounted) Navigator.pushReplacementNamed(context, 'signIn');
    } on AuthFailure catch (e) {
      if (mounted) {
        await showMessageDialog(context,
            icon: Icons.error_outline_rounded,
            title: 'Could not sign up',
            message: e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _social(Future<bool> Function() action) async {
    setState(() => _loading = true);
    try {
      if (await action()) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loginOrNot', true);
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, 'homepage', (r) => false);
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        await showMessageDialog(context,
            icon: Icons.error_outline_rounded,
            title: 'Could not sign up',
            message: e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join to save favorites and track your orders.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => (v ?? '').trim().length < 2
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: AppSpace.lg),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: (v) => EmailValidator.validate((v ?? '').trim())
                    ? null
                    : 'Enter a valid email',
              ),
              const SizedBox(height: AppSpace.lg),
              TextFormField(
                controller: passController,
                obscureText: visible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: visible ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => visible = !visible),
                    icon: Icon(visible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
                validator: (v) => (v ?? '').length < 6
                    ? 'Use at least 6 characters'
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.xxl),
        LoadingButton(label: 'Sign up', loading: _loading, onPressed: signUp),
        const OrDivider('or sign up with'),
        Row(
          children: [
            SocialButton(
              label: 'Google',
              icon: Icons.account_circle_outlined,
              onPressed:
                  _loading ? null : () => _social(Repo.auth.signInWithGoogle),
            ),
            const SizedBox(width: AppSpace.md),
            SocialButton(
              label: 'Facebook',
              icon: Icons.people_alt_outlined,
              onPressed: _loading
                  ? null
                  : () => _social(Repo.auth.signInWithFacebook),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account?', style: context.text.bodyMedium),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('signIn'),
              child: const Text('Log in'),
            ),
          ],
        ),
      ],
    );
  }
}
