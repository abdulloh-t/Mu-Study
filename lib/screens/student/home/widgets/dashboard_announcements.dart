import 'package:flutter/material.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/screens/student/home/widgets/expandable_announcement_card.dart';

class DashboardAnnouncements extends StatefulWidget {
  const DashboardAnnouncements({super.key, required this.announcements});

  final List<Announcement> announcements;

  static const _previewCount = 3;

  @override
  State<DashboardAnnouncements> createState() => _DashboardAnnouncementsState();
}

class _DashboardAnnouncementsState extends State<DashboardAnnouncements> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = [...widget.announcements]
      ..sort((a, b) {
        final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });
    final canExpand = sorted.length > DashboardAnnouncements._previewCount;
    final visible = _showAll || !canExpand
        ? sorted
        : sorted.take(DashboardAnnouncements._previewCount).toList();

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              for (final a in visible)
                ExpandableAnnouncementCard(announcement: a),
            ],
          ),
        ),
        if (canExpand)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = !_showAll),
              icon: Icon(
                _showAll
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 20,
              ),
              label: Text(
                _showAll
                    ? l10n.announcementsShowLess
                    : l10n.announcementsViewAll(sorted.length),
              ),
            ),
          ),
      ],
    );
  }
}
