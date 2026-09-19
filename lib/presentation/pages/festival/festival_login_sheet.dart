import 'package:flutter/material.dart';
import 'package:flutter_core_project/common/helpers/is_dark_mode.dart';
import 'package:flutter_core_project/core/configs/theme/app_colors.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/injection_container.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_core_project/services/localization_service.dart';

Future<bool> showFestivalLoginSheet(
  BuildContext context, {
  FestivalAuthService? authService,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FestivalLoginSheet(
      authService: authService ?? sl<FestivalAuthService>(),
    ),
  );
  return result ?? false;
}

class _FestivalLoginSheet extends StatefulWidget {
  final FestivalAuthService authService;

  const _FestivalLoginSheet({required this.authService});

  @override
  State<_FestivalLoginSheet> createState() => _FestivalLoginSheetState();
}

class _FestivalLoginSheetState extends State<_FestivalLoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on FestivalApiException {
      if (mounted) {
        setState(() => _error = context.tr('festival_login_failed'));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.tr('festival_error_generic'));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: context.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.festival_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('festival_login_title'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('festival_login_description'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  key: const ValueKey('festival_username'),
                  controller: _usernameController,
                  enabled: !_submitting,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  decoration: InputDecoration(
                    labelText: context.tr('festival_username'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: context.isDarkMode
                        ? const Color(0xFF1C1B1B)
                        : AppColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: context.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? context.tr('festival_username_required')
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('festival_password'),
                  controller: _passwordController,
                  enabled: !_submitting,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submitting ? null : _submit(),
                  decoration: InputDecoration(
                    labelText: context.tr('festival_password'),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    filled: true,
                    fillColor: context.isDarkMode
                        ? const Color(0xFF1C1B1B)
                        : AppColors.lightBackground,
                    suffixIcon: IconButton(
                      tooltip: context.tr(
                        _obscurePassword
                            ? 'festival_show_password'
                            : 'festival_hide_password',
                      ),
                      onPressed: _submitting
                          ? null
                          : () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: context.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? context.tr('festival_password_required')
                      : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  key: const ValueKey('festival_login_submit'),
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(context.tr('festival_login_action')),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('festival_separate_account_note'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
