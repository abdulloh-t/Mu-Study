import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/providers/groups/group_providers.dart';

class GroupSelector extends ConsumerWidget {
  const GroupSelector({super.key, this.padding = const EdgeInsets.all(20)});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(myGroupsProvider);
    final activeId = ref.watch(activeGroupIdProvider);
    final list = groups.valueOrNull ?? const [];

    if (list.length < 2) return const SizedBox.shrink();

    final radius = paperControlRadius(context);

    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: paperControlDecoration(context),
        child: Row(
          children: [
            PaperGlyph(
              icon: Icons.groups_outlined,
              size: 18,
              color: AppColors.accent(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: activeId,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(radius),
                  dropdownColor: AppColors.controlSurface(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.ink(context),
                  ),
                  items: list
                      .map(
                        (g) => DropdownMenuItem(
                          value: g.id,
                          child: Text(g.title, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(selectedGroupIdProvider.notifier).state = value;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
