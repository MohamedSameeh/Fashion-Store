import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models.dart';
import '../../../data/store_repository.dart';

class UpdateUserInformationPage extends StatefulWidget {
  const UpdateUserInformationPage({super.key});

  @override
  State<UpdateUserInformationPage> createState() =>
      _UpdateUserInformationPageState();
}

class _UpdateUserInformationPageState
    extends State<UpdateUserInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final UserProfile? user = await Repo.store
          .watchProfile()
          .first
          .timeout(const Duration(seconds: 12));
      nameController.text = user?.name ?? '';
      emailController.text = user?.email ?? '';
      phoneController.text = user?.phone ?? '';
    } catch (_) {
      _error = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _updateUserInformation() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Repo.store.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );
      if (!mounted) return;
      showAppSnack(context, 'Profile updated');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        showAppSnack(context, 'Could not update your profile. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update My Info')),
      body: _error
          ? ErrorState(
              message: 'Error loading user data', onRetry: _fetchUserData)
          : _loading
              ? const ListSkeleton(count: 3, height: 58)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpace.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
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
                          validator: (v) =>
                              EmailValidator.validate((v ?? '').trim())
                                  ? null
                                  : 'Enter a valid email',
                        ),
                        const SizedBox(height: AppSpace.lg),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpace.xxl),
                        LoadingButton(
                          label: 'Save changes',
                          loading: _saving,
                          onPressed: _updateUserInformation,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
