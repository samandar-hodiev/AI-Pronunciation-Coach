import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/setup_header.dart';
import 'auth_validators.dart';
import 'controllers/auth_controller.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_text_field.dart';

/// Yangi hisob yaratish ekrani.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  static const String title = 'Create your account';
  static const String description =
      'Save your progress and pick up where you left off.';
  static const String ctaLabel = 'Create account';
  static const String signInPrompt = 'Already have an account? Sign in';

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Takroriy yuborishning oldini olamiz: tugma o'chirilgan bo'lsa ham
    // klaviaturadan "done" bosilishi mumkin.
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.account);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SetupHeader(
              onBack: _submitting
                  ? null
                  : () => context.go(AppRoutes.onboarding),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            CreateAccountScreen.title,
                            style: text.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            CreateAccountScreen.description,
                            style: text.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (_errorMessage != null) ...<Widget>[
                            AuthErrorBanner(message: _errorMessage!),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          AuthTextField(
                            label: 'Name',
                            controller: _name,
                            enabled: !_submitting,
                            keyboardType: TextInputType.name,
                            autofillHints: const <String>[AutofillHints.name],
                            validator: AuthValidators.name,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            label: 'Email',
                            controller: _email,
                            enabled: !_submitting,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const <String>[AutofillHints.email],
                            validator: AuthValidators.email,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            label: 'Password',
                            controller: _password,
                            enabled: !_submitting,
                            obscureText: true,
                            autofillHints: const <String>[
                              AutofillHints.newPassword,
                            ],
                            validator: AuthValidators.password,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            label: 'Confirm password',
                            controller: _confirmPassword,
                            enabled: !_submitting,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: _submit,
                            validator: (String? value) =>
                                AuthValidators.confirmPassword(
                                  value,
                                  _password.text,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => context.go(AppRoutes.signIn),
                            child: const Text(CreateAccountScreen.signInPrompt),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: PrimaryButton(
                label: CreateAccountScreen.ctaLabel,
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
