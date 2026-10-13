import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';

class PaperAssets {
  static const _dir = 'assets/images/nature-paper';

  static const avatarSilhouette = '$_dir/avatar-silhouette.png';
  static const beigeLeaf = '$_dir/beige-leaf.png';
  static const bookshelfSingle = '$_dir/bookshelf-single-shelf.png';
  static const bookshelfDouble = '$_dir/bookshelf-two-shelves.png';
  static const brainVerified = '$_dir/brain-verified.png';
  static const browserDashboard = '$_dir/browser-dashboard.png';
  static const calendar = '$_dir/calendar.png';
  static const calendarWithClock = '$_dir/calendar-with-clock.png';
  static const cardboardStar = '$_dir/cardboard-star.png';
  static const chatBubbles = '$_dir/chat-bubbles.png';
  static const clipboardChecklist = '$_dir/clipboard-checklist.png';
  static const clipboardProfile = '$_dir/clipboard-profile.png';
  static const clipboardWithPencil = '$_dir/clipboard-with-pencil.png';
  static const closeButton = '$_dir/close-button.png';
  static const creamBird = '$_dir/cream-bird.png';
  static const creamPaperGreenTape = '$_dir/cream-paper-green-tape.png';
  static const divisionButton = '$_dir/division-button.png';
  static const documentLayout = '$_dir/document-layout.png';
  static const downloadInbox = '$_dir/download-inbox.png';
  static const dustyRoseFlower = '$_dir/dusty-rose-flower.png';
  static const envelopeSuccess = '$_dir/envelope-success.png';
  static const flatCloud = '$_dir/flat-cloud.png';
  static const grayCloud = '$_dir/gray-cloud.png';
  static const groupChat = '$_dir/group-chat.png';
  static const hangingGarland = '$_dir/hanging-garland.png';
  static const homeHouse = '$_dir/home-house.png';
  static const kraftPaperStrip = '$_dir/kraft-paper-strip.png';
  static const landscapeHills = '$_dir/landscape-hills-footer.png';
  static const linedPaperPencil = '$_dir/lined-paper-pencil.png';
  static const magnifyingGlass = '$_dir/magnifying-glass.png';
  static const manilaFolder = '$_dir/manila-folder.png';
  static const marketStall = '$_dir/market-stall.png';
  static const minusButton = '$_dir/minus-button.png';
  static const notificationBell = '$_dir/notification-bell-alert.png';
  static const openBook = '$_dir/open-book.png';
  static const paperFunnel = '$_dir/paper-funnel.png';
  static const puzzlePieces = '$_dir/puzzle-pieces.png';
  static const roundedTanStar = '$_dir/rounded-tan-star.png';
  static const sageScallopedFrame = '$_dir/sage-scalloped-frame.png';
  static const salmonFlower = '$_dir/salmon-flower.png';
  static const settingsGear = '$_dir/settings-gear.png';
  static const singleTree = '$_dir/single-tree.png';
  static const spiralNotebook = '$_dir/spiral-notebook.png';
  static const stickyNotesPair = '$_dir/sticky-notes-pair.png';
  static const stripedWashiTape = '$_dir/striped-washi-tape.png';
  static const tanNoteGreenTab = '$_dir/tan-note-green-tab.png';
  static const tanSeed = '$_dir/tan-seed.png';
  static const teacherChalkboard = '$_dir/teacher-chalkboard.png';
  static const tealBird = '$_dir/teal-bird.png';
  static const terracottaScallopedFrame =
      '$_dir/terracotta-scalloped-frame.png';
  static const texturedTanStar = '$_dir/textured-tan-star.png';
  static const tornPaperScrap = '$_dir/torn-paper-scrap.png';
  static const twoTrees = '$_dir/two-trees.png';
  static const wallClock = '$_dir/wall-clock.png';
  static const whiteCloud = '$_dir/white-cloud.png';
  static const whiteDaisy = '$_dir/white-daisy.png';
  static const yellowPencil = '$_dir/yellow-pencil.png';
}

bool isNaturePaper(BuildContext context) =>
    AppStyleTokens.maybeOf(context)?.isNaturePaper ?? false;

bool isSoftNeumorphism(BuildContext context) =>
    AppStyleTokens.maybeOf(context)?.isSoftNeumorphism ?? false;

bool isMonochromeWorkspace(BuildContext context) =>
    AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;

String? paperAssetForIcon(IconData? icon) {
  if (icon == null) return null;
  if (icon == Icons.inbox_outlined || icon == Icons.inbox) {
    return PaperAssets.downloadInbox;
  }
  if (icon == Icons.grade_outlined ||
      icon == Icons.grade ||
      icon == Icons.star_outline ||
      icon == Icons.star ||
      icon == Icons.star_rounded) {
    return PaperAssets.cardboardStar;
  }
  if (icon == Icons.assignment_outlined ||
      icon == Icons.assignment ||
      icon == Icons.task_outlined ||
      icon == Icons.assignment_turned_in_outlined) {
    return PaperAssets.spiralNotebook;
  }
  if (icon == Icons.task_alt_rounded ||
      icon == Icons.edit_outlined ||
      icon == Icons.edit ||
      icon == Icons.add ||
      icon == Icons.add_rounded) {
    return PaperAssets.yellowPencil;
  }
  if (icon == Icons.inventory_2_rounded || icon == Icons.inventory_2_outlined) {
    return PaperAssets.manilaFolder;
  }
  if (icon == Icons.chat_bubble_outline_rounded ||
      icon == Icons.chat_outlined ||
      icon == Icons.chat ||
      icon == Icons.forum_outlined ||
      icon == Icons.chat_bubble_outline) {
    return PaperAssets.chatBubbles;
  }
  if (icon == Icons.campaign_rounded || icon == Icons.campaign_outlined) {
    return PaperAssets.envelopeSuccess;
  }
  if (icon == Icons.event_available_outlined ||
      icon == Icons.event_available_rounded ||
      icon == Icons.event_outlined) {
    return PaperAssets.clipboardChecklist;
  }
  if (icon == Icons.calendar_today_outlined ||
      icon == Icons.calendar_month_outlined ||
      icon == Icons.calendar_today) {
    return PaperAssets.calendar;
  }
  if (icon == Icons.people_outline ||
      icon == Icons.groups_outlined ||
      icon == Icons.groups ||
      icon == Icons.people_alt_outlined) {
    return PaperAssets.groupChat;
  }
  if (icon == Icons.notifications_outlined ||
      icon == Icons.notifications_none_rounded ||
      icon == Icons.notifications_active_outlined ||
      icon == Icons.notifications) {
    return PaperAssets.notificationBell;
  }
  if (icon == Icons.search || icon == Icons.search_rounded) {
    return PaperAssets.magnifyingGlass;
  }
  if (icon == Icons.menu_book ||
      icon == Icons.subject_outlined ||
      icon == Icons.language_rounded ||
      icon == Icons.language) {
    return PaperAssets.openBook;
  }
  if (icon == Icons.calculate || icon == Icons.calculate_outlined) {
    return PaperAssets.divisionButton;
  }
  if (icon == Icons.badge_outlined ||
      icon == Icons.person_outline ||
      icon == Icons.person ||
      icon == Icons.person_rounded ||
      icon == Icons.account_circle_outlined) {
    return PaperAssets.clipboardProfile;
  }
  if (icon == Icons.settings_outlined ||
      icon == Icons.settings ||
      icon == Icons.tune_rounded) {
    return PaperAssets.settingsGear;
  }
  if (icon == Icons.home_outlined || icon == Icons.home) {
    return PaperAssets.homeHouse;
  }
  if (icon == Icons.dashboard_outlined ||
      icon == Icons.dashboard ||
      icon == Icons.insights_outlined ||
      icon == Icons.analytics_outlined ||
      icon == Icons.analytics_rounded) {
    return PaperAssets.browserDashboard;
  }
  if (icon == Icons.warning_amber_rounded ||
      icon == Icons.cleaning_services_outlined ||
      icon == Icons.error_outline) {
    return PaperAssets.tornPaperScrap;
  }
  if (icon == Icons.schedule ||
      icon == Icons.access_time_rounded ||
      icon == Icons.timer_outlined) {
    return PaperAssets.wallClock;
  }
  if (icon == Icons.extension_outlined) return PaperAssets.puzzlePieces;
  if (icon == Icons.school || icon == Icons.school_outlined) {
    return PaperAssets.teacherChalkboard;
  }
  if (icon == Icons.self_improvement_outlined ||
      icon == Icons.self_improvement) {
    return PaperAssets.openBook;
  }
  if (icon == Icons.folder_outlined || icon == Icons.folder) {
    return PaperAssets.manilaFolder;
  }
  if (icon == Icons.psychology_outlined || icon == Icons.psychology) {
    return PaperAssets.brainVerified;
  }
  return null;
}

double paperControlRadius(BuildContext context) {
  if (isNaturePaper(context)) return 18;
  if (isMonochromeWorkspace(context)) return 6;
  return 14;
}

BoxDecoration paperControlDecoration(
  BuildContext context, {
  Color? color,
  double? radius,
}) {
  final r = radius ?? paperControlRadius(context);
  final nature = isNaturePaper(context);
  return BoxDecoration(
    color: color ?? AppColors.controlSurface(context),
    borderRadius: BorderRadius.circular(r),
    border: Border.all(
      color: nature
          ? AppColors.inkAlpha(context, 0.12)
          : AppColors.inkAlpha(context, 0.08),
    ),
    boxShadow: nature && Theme.of(context).brightness == Brightness.light
        ? [
            BoxShadow(
              color: const Color(0xFF8A6A4A).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
        : null,
  );
}

class PaperDecor extends StatelessWidget {
  const PaperDecor(
    this.asset, {
    super.key,
    this.size,
    this.height,
    this.angle = 0,
    this.opacity = 1,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double? size;
  final double? height;
  final double angle;
  final double opacity;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (!isNaturePaper(context)) return const SizedBox.shrink();
    Widget img = Image.asset(
      asset,
      width: size,
      height: height ?? size,
      fit: fit,
      opacity: AlwaysStoppedAnimation(opacity),
      filterQuality: FilterQuality.medium,
    );
    if (angle != 0) img = Transform.rotate(angle: angle, child: img);
    return ExcludeSemantics(child: img);
  }
}

class PaperGlyph extends StatelessWidget {
  const PaperGlyph({
    super.key,
    required this.icon,
    this.asset,
    this.size = 22,
    this.color,
    this.opacity = 1,
    this.retintInDark = true,
  });

  final IconData icon;

  final String? asset;
  final double size;
  final Color? color;
  final double opacity;

  /// When false, keep original pack colors (e.g. shell bottom nav).
  final bool retintInDark;

  @override
  Widget build(BuildContext context) {
    final resolved = asset ?? paperAssetForIcon(icon);
    if (!isNaturePaper(context) || resolved == null) {
      return Icon(
        icon,
        size: size,
        color: opacity == 1 ? color : color?.withValues(alpha: opacity),
      );
    }

    Widget img = Image.asset(
      resolved,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    // Pack sprites are painted for cream paper; retint on night cards so
    // dark brown assets (stars, notebooks) stay readable.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark && retintInDark) {
      final provided = color;
      final tint =
          (provided != null && provided.computeLuminance() > 0.38)
          ? provided
          : NaturePaperColors.moonBeige;
      img = ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
        child: img,
      );
    }

    if (opacity < 1) {
      img = Opacity(opacity: opacity, child: img);
    }

    return ExcludeSemantics(child: img);
  }
}

class PaperEmptyIllustration extends StatelessWidget {
  const PaperEmptyIllustration({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 104,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: Transform.rotate(
              angle: -0.5,
              child: Image.asset(
                PaperAssets.beigeLeaf,
                width: 26,
                opacity: const AlwaysStoppedAnimation(0.8),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 0,
            child: Transform.rotate(
              angle: 0.35,
              child: Image.asset(
                PaperAssets.roundedTanStar,
                width: 20,
                opacity: const AlwaysStoppedAnimation(0.85),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: Image.asset(
              PaperAssets.whiteDaisy,
              width: 22,
              opacity: const AlwaysStoppedAnimation(0.9),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 0,
            child: Image.asset(
              PaperAssets.tanSeed,
              width: 14,
              opacity: const AlwaysStoppedAnimation(0.7),
            ),
          ),
          Image.asset(
            asset,
            width: 76,
            height: 76,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ],
      ),
    );
  }
}

class PaperTaped extends StatelessWidget {
  const PaperTaped({
    super.key,
    required this.child,
    this.angle = -0.07,
    this.tapeWidth = 88,
    this.alignment = 0,
  });

  final Widget child;
  final double angle;
  final double tapeWidth;

  final double alignment;

  @override
  Widget build(BuildContext context) {
    if (!isNaturePaper(context)) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment(alignment, 0),
            child: ExcludeSemantics(
              child: Transform.rotate(
                angle: angle,
                child: Image.asset(
                  PaperAssets.stripedWashiTape,
                  width: tapeWidth,
                  opacity: const AlwaysStoppedAnimation(0.92),
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PaperDivider extends StatelessWidget {
  const PaperDivider({super.key, this.width = 180});

  final double width;

  @override
  Widget build(BuildContext context) {
    if (!isNaturePaper(context)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: ExcludeSemantics(
          child: Image.asset(
            PaperAssets.kraftPaperStrip,
            width: width,
            height: 14,
            fit: BoxFit.fill,
            opacity: const AlwaysStoppedAnimation(0.75),
          ),
        ),
      ),
    );
  }
}

class PaperScallopedAvatar extends StatelessWidget {
  const PaperScallopedAvatar({
    super.key,
    required this.child,
    required this.avatarSize,
  });

  final Widget child;

  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    if (!isNaturePaper(context)) return child;
    final frameSize = avatarSize * 1.30;
    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: Image.asset(
              PaperAssets.sageScallopedFrame,
              width: frameSize,
              height: frameSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

String? paperStarForPercent(double? percent) {
  if (percent == null) return null;
  if (percent >= 85) return PaperAssets.cardboardStar;
  if (percent >= 70) return PaperAssets.texturedTanStar;
  return null;
}
