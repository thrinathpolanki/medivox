import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared layout for onboarding steps: title, step indicator, body, primary button.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.step,
    this.totalSteps = 8,
    this.scrollable = true,
    this.bottom,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String primaryLabel;
  final VoidCallback? onPrimary; // null => disabled
  final int? step;
  final int totalSteps;
  final bool scrollable;
  final Widget? bottom; // fixed area above the button (e.g. checkbox)
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        title: step == null
            ? null
            : Semantics(
                label: 'Step $step of $totalSteps',
                child: ExcludeSemantics(
                  child: Text('Step $step of $totalSteps',
                      style: theme.textTheme.titleSmall),
                ),
              ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: scrollable ? SingleChildScrollView(child: child) : child,
              ),
              if (bottom != null) bottom!,
              const SizedBox(height: 8),
              FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
              if (secondaryLabel != null) ...[
                const SizedBox(height: 4),
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
