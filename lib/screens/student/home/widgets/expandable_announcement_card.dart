import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';

class ExpandableAnnouncementCard extends StatefulWidget {
  const ExpandableAnnouncementCard({super.key, required this.announcement});

  final Announcement announcement;

  @override
  State<ExpandableAnnouncementCard> createState() =>
      _ExpandableAnnouncementCardState();
}

class _ExpandableAnnouncementCardState
    extends State<ExpandableAnnouncementCard> {
  static const _collapsedLines = 3;

  bool _expanded = false;

  TextStyle get _bodyStyle => TextStyle(
    fontSize: 14,
    color: AppColors.inkAlpha(context, 0.6),
    height: 1.4,
  );

  bool _exceedsCollapsedLines(double maxWidth, TextDirection direction) {
    final text = widget.announcement.description.trim();
    if (text.isEmpty) return false;
    final painter = TextPainter(
      text: TextSpan(text: text, style: _bodyStyle),
      maxLines: _collapsedLines,
      textDirection: direction,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.announcement;
    final description = a.description.trim();

    return PaperTaped(
      alignment: -0.55,
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.softSurface(context),
                  child: Icon(
                    Icons.person,
                    size: 12,
                    color: AppColors.accent(context),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.commonTeacher,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkAlpha(context, 0.7),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.MMMd().format(a.createdAt ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.inkAlpha(context, 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              a.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              LayoutBuilder(
                builder: (context, constraints) {
                  final canExpand = _exceedsCollapsedLines(
                    constraints.maxWidth,
                    Directionality.of(context),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: Text(
                          description,
                          maxLines: _expanded ? null : _collapsedLines,
                          overflow: _expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: _bodyStyle,
                        ),
                      ),
                      if (canExpand) ...[
                        SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => setState(() => _expanded = !_expanded),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _expanded
                                    ? context.l10n.announcementsShowLess
                                    : context.l10n.announcementsReadMore,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent(context),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                _expanded
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                size: 18,
                                color: AppColors.accent(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
