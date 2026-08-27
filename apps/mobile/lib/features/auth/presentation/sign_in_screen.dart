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

/// Mavjud hisob bilan tizimga kirish ekrani.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const String title = 'Welcome back';
  static const String description = 'Sign in to continue your practice.';
  static const String ctaLabel = 'Sign in';
  static const String createAccountPrompt = 'New here? Create an account';

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(email: _email.text.trim(), password: _password.text);
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
                  : () => context.go(AppRoutes.createAccount),
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
                          Text(SignInScreen.title, style: text.headlineMedium),
                          const SizedBox(height: AppSpacing.sm),
                          Text(SignInScreen.description, style: text.bodyLarge),
                          const SizedBox(height: AppSpacing.xl),
                          if (_errorMessage != null) ...<Widget>[
                            AuthErrorBanner(message: _errorMessage!),
                            const SizedBox(height: AppSpacing.lg),
                          ],
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
                            textInputAction: TextInputAction.done,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            onSubmitted: _submit,
                            // Kirish paytida uzunlik tekshirilmaydi: eski
                            // parollar boshqa qoidalar bilan yaratilgan
                            // bo'lishi mumkin. Tekshiruvni backend bajaradi.
                            validator: (String? value) =>
                                (value == null || value.isEmpty)
                                ? 'Password is required.'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => context.go(AppRoutes.createAccount),
                            child: const Text(SignInScreen.createAccountPrompt),
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
                label: SignInScreen.ctaLabel,
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
