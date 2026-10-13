import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mu_study/components/brand/app_logo.dart';
import 'package:mu_study/components/buttons/primary_button.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/constants/env.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = context.l10n;
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = l10n.loginMissingFields);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(_usernameController.text.trim(), _passwordController.text);
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      context.go('/boot');
    } on AuthException catch (_) {
      setState(() {
        _error = l10n.loginIncorrect;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _error = _messageForPostgrest(e, l10n.loginConfigError);
      });
    } catch (e) {
      setState(() {
        _error = kDebugMode ? 'Sign in error: $e' : l10n.loginFailed;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _messageForPostgrest(PostgrestException e, String configError) {
    final msg = e.message.toLowerCase();
    if (msg.contains('jwt') ||
        msg.contains('api key') ||
        msg.contains('invalid') && msg.contains('key')) {
      return configError;
    }
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.softWash(context, lightAlpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.accent(context).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const _LoginNatureScenery(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: AppLogoImage(size: 88)),
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          l10n.appName,
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(letterSpacing: -1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          l10n.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.inkAlpha(context, 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        l10n.loginUsername.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: '@username',
                          prefixIcon: Icon(Icons.alternate_email, size: 20),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.loginPassword.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                        obscureText: true,
                        onSubmitted: (_) => _login(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.errorRed.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.errorRed,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!Env.isConfigured) ...[
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.loginConfigMissing,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.mutedGold,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      PrimaryButton(
                        label: l10n.loginSignIn,
                        loading: _loading,
                        onPressed: _login,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginNatureScenery extends StatefulWidget {
  const _LoginNatureScenery();

  @override
  State<_LoginNatureScenery> createState() => _LoginNatureSceneryState();
}

class _LoginCloud {
  const _LoginCloud({
    required this.asset,
    required this.top,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });

  final String asset;
  final double top;
  final double size;
  final double speed;
  final double phase;
  final double opacity;
}

class _LoginNatureSceneryState extends State<_LoginNatureScenery>
    with SingleTickerProviderStateMixin {
  static const _clouds = [
    _LoginCloud(
      asset: PaperAssets.whiteCloud,
      top: 72,
      size: 64,
      speed: 1.15,
      phase: 0.05,
      opacity: 0.72,
    ),
    _LoginCloud(
      asset: PaperAssets.flatCloud,
      top: 130,
      size: 48,
      speed: 0.75,
      phase: 0.42,
      opacity: 0.48,
    ),
    _LoginCloud(
      asset: PaperAssets.grayCloud,
      top: 168,
      size: 40,
      speed: 1.35,
      phase: 0.7,
      opacity: 0.32,
    ),
    _LoginCloud(
      asset: PaperAssets.whiteCloud,
      top: 210,
      size: 36,
      speed: 0.95,
      phase: 0.22,
      opacity: 0.4,
    ),
    _LoginCloud(
      asset: PaperAssets.flatCloud,
      top: 54,
      size: 30,
      speed: 1.55,
      phase: 0.88,
      opacity: 0.28,
    ),
  ];

  AnimationController? _ctrl;

  void _syncController(bool nature) {
    if (nature && _ctrl == null) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      )..repeat();
    } else if (!nature && _ctrl != null) {
      _ctrl!.dispose();
      _ctrl = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController(isNaturePaper(context));
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    _ctrl = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nature = isNaturePaper(context);
    _syncController(nature);
    final ctrl = _ctrl;
    if (!nature || ctrl == null) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (context, _) {
          final t = ctrl.value;
          final angle = t * 2 * math.pi;
          final tealX = 28 + math.sin(angle * 0.5) * 18;
          final tealY = 110 + math.sin(angle) * 12;
          final tealTilt = -0.08 + math.sin(angle) * 0.08;
          final creamX = 40 + math.sin(angle * 0.4 + 1.8) * 14;
          final creamY = 82 + math.sin(angle + 1.2) * 10;
          final creamTilt = 0.1 + math.sin(angle + 1.2) * 0.07;

          return Stack(
            children: [
              for (final c in _clouds)
                Positioned(
                  left:
                      width -
                      (((t * c.speed + c.phase) % 1.0) * (width + c.size + 40)),
                  top: c.top,
                  child: Image.asset(
                    c.asset,
                    width: c.size,
                    height: c.size,
                    opacity: AlwaysStoppedAnimation(c.opacity),
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              Positioned(
                left: tealX,
                top: tealY,
                child: Transform.rotate(
                  angle: tealTilt,
                  child: Image.asset(
                    PaperAssets.tealBird,
                    width: 40,
                    height: 40,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Positioned(
                right: creamX,
                top: creamY,
                child: Transform.rotate(
                  angle: creamTilt,
                  child: Image.asset(
                    PaperAssets.creamBird,
                    width: 32,
                    height: 32,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 8,
                child: Image.asset(
                  PaperAssets.singleTree,
                  height: 96,
                  opacity: const AlwaysStoppedAnimation(0.75),
                  filterQuality: FilterQuality.medium,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Image.asset(
                  PaperAssets.twoTrees,
                  height: 110,
                  opacity: const AlwaysStoppedAnimation(0.75),
                  filterQuality: FilterQuality.medium,
                ),
              ),
              Positioned(
                bottom: 96,
                right: 52,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Image.asset(
                    PaperAssets.whiteDaisy,
                    width: 24,
                    height: 24,
                    opacity: const AlwaysStoppedAnimation(0.85),
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
