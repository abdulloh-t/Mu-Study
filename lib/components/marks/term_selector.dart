import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';

class TermSelector extends ConsumerWidget {
  const TermSelector({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(selectedMarkTermProvider);
    final optionsAsync = ref.watch(academicTermOptionsProvider);
    final radius = paperControlRadius(context);

    return optionsAsync.when(
      loading: () => Padding(
        padding: padding,
        child: const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (e, _) => Padding(
        padding: padding,
        child: Text(
          e.toString(),
          style: TextStyle(color: AppColors.errorRed, fontSize: 12),
        ),
      ),
      data: (options) {
        final selected = options.cast<AcademicTerm?>().firstWhere(
          (t) => t!.id == current.id,
          orElse: () => current,
        )!;

        return Padding(
          padding: padding,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: paperControlDecoration(context),
            child: Row(
              children: [
                PaperGlyph(
                  icon: Icons.calendar_month_outlined,
                  size: 18,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: options.any((t) => t.id == selected.id)
                          ? selected.id
                          : options.first.id,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(radius),
                      dropdownColor: AppColors.controlSurface(context),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink(context),
                      ),
                      items: options
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(
                                t.label(context.l10n),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        final next = options.firstWhere((t) => t.id == id);
                        ref
                            .read(selectedMarkTermProvider.notifier)
                            .select(next);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
