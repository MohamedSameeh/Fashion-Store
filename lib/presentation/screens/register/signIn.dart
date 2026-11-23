import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/auth_repository.dart';
import '../../../data/demo/demo_data.dart';
import '../../../data/store_repository.dart';
import 'auth_widgets.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  late final emailController =
      TextEditingController(text: kDemoMode ? DemoData.profile.email : '');
  late final passController =
      TextEditingController(text: kDemoMode ? 'demo-pass' : '');
  bool visible = true;
  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _goHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('loginOrNot', true);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, 'homepage', (r) => false);
  }

  Future<void> _run(Future<bool> Function() action,
      {bool verification = false}) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final ok = await action();
      if (!mounted) return;
      if (ok) {
        await _goHome();
      } else if (verification) {
        await showMessageDialog(context,
            icon: Icons.mark_email_unread_outlined,
            title: 'Verify your email',
            message:
                'We sent you a verification link. Open it, then sign in again.');
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        await showMessageDialog(context,
            icon: Icons.error_outline_rounded,
            title: 'Could not sign in',
            message: e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void signIn() {
    if (!_formKey.currentState!.validate()) return;
    _run(
        () => Repo.auth.signInWithEmail(
            emailController.text.trim(), passController.text),
        verification: true);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Log in to continue shopping.',
      children: [
        if (kDemoMode)
          const DemoHint(
              'Demo mode: any email with a 6+ character password signs in as the sample customer.'),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
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
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: visible ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => visible = !visible),
                    icon: Icon(visible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Enter your password' : null,
                onFieldSubmitted: (_) => signIn(),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('forgot_password'),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        LoadingButton(label: 'Login', loading: _loading, onPressed: signIn),
        const OrDivider('or continue with'),
        Row(
          children: [
            SocialButton(
              label: 'Google',
              icon: Icons.account_circle_outlined,
              onPressed:
                  _loading ? null : () => _run(Repo.auth.signInWithGoogle),
            ),
            const SizedBox(width: AppSpace.md),
            SocialButton(
              label: 'Facebook',
              icon: Icons.people_alt_outlined,
              onPressed:
                  _loading ? null : () => _run(Repo.auth.signInWithFacebook),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?", style: context.text.bodyMedium),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('signUp'),
              child: const Text('Sign up'),
            ),
          ],
        ),
      ],
    );
  }
}
