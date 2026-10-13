import 'dart:typed_data';

import 'package:flutter/material.dart' show Rect, Offset;
import 'package:intl/intl.dart';
import 'package:mu_study/core/progress/progress_report.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/l10n/domain_labels.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Uint8List buildProgressReportPdf(ProgressReport report, AppLocalizations l10n) {
  final document = PdfDocument();
  final page = document.pages.add();
  final size = page.getClientSize();
  final g = page.graphics;

  final titleFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    18,
    style: PdfFontStyle.bold,
  );
  final headingFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    12,
    style: PdfFontStyle.bold,
  );
  final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
  final smallFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

  final ink = PdfColor(44, 36, 22);
  final muted = PdfColor(110, 100, 88);
  final accent = PdfColor(107, 79, 53);
  final line = PdfPen(PdfColor(220, 210, 195), width: 0.8);

  var y = 28.0;

  void drawText(
    String text,
    PdfFont font, {
    PdfColor? color,
    double? x,
    double? maxWidth,
  }) {
    g.drawString(
      text,
      font,
      brush: PdfSolidBrush(color ?? ink),
      bounds: Rect.fromLTWH(x ?? 28, y, maxWidth ?? (size.width - 56), 40),
    );
  }

  drawText('MU Study', titleFont, color: accent);
  y += 26;
  drawText(l10n.progressReportTitle, headingFont);
  y += 22;
  drawText('${report.studentName} · ${report.groupTitle}', bodyFont);
  y += 16;
  drawText(report.termLabel, bodyFont, color: muted);
  y += 14;
  g.drawLine(line, Offset(28, y), Offset(size.width - 28, y));
  y += 18;

  drawText(l10n.marksOverallAverage, headingFont);
  y += 18;
  final avg = report.average;
  final avgText = avg == null
      ? l10n.marksNoneYet
      : '${avg.toStringAsFixed(avg % 1 == 0 ? 0 : 1)}%  (${l10n.progressReportMarksCounted}: ${report.markCount})';
  drawText(avgText, bodyFont);
  y += 22;

  if (report.categoryAverages.isNotEmpty) {
    drawText(l10n.marksByCategory, headingFont);
    y += 16;
    for (final row in report.categoryAverages) {
      drawText(
        '${row.category.l10nLabel(l10n)}  —  ${row.average.toStringAsFixed(1)}%',
        bodyFont,
      );
      y += 14;
      if (y > size.height - 120) break;
    }
    y += 8;
  }

  drawText(l10n.progressReportAttendance, headingFont);
  y += 16;
  final att = report.attendance;
  if (att.total == 0) {
    drawText(l10n.progressReportNoAttendance, bodyFont, color: muted);
    y += 16;
  } else {
    drawText(
      '${l10n.progressReportAttendanceRate}: ${report.attendanceRate.toStringAsFixed(0)}%  (${att.total} ${l10n.progressReportSessions})',
      bodyFont,
    );
    y += 14;
    drawText(
      '${l10n.attendancePresentWord}: ${att.present}   '
      '${l10n.attendanceAbsentWord}: ${att.absent}   '
      '${l10n.attendanceLateWord}: ${att.late}   '
      '${l10n.attendanceExcusedWord}: ${att.excused}',
      bodyFont,
    );
    y += 20;
  }

  if (report.recentMarks.isNotEmpty && y < size.height - 100) {
    drawText(l10n.progressReportRecentMarks, headingFont);
    y += 16;
    for (final m in report.recentMarks) {
      if (y > size.height - 60) break;
      final date = DateFormat.yMMMd().format(m.markedOn);
      drawText(
        '$date  ·  ${m.title}  ·  ${m.percentage.toStringAsFixed(0)}%',
        smallFont,
        color: muted,
      );
      y += 12;
    }
  }

  final generated = DateFormat.yMMMd().add_jm().format(
    report.generatedAt ?? DateTime.now(),
  );
  g.drawString(
    l10n.progressReportGeneratedOn(generated),
    smallFont,
    brush: PdfSolidBrush(muted),
    bounds: Rect.fromLTWH(28, size.height - 36, size.width - 56, 20),
  );

  final bytes = Uint8List.fromList(document.saveSync());
  document.dispose();
  return bytes;
}
