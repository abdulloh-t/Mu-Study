import 'dart:typed_data';
import 'dart:ui';

import 'package:mu_study/core/admin/credential_slip.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

const _slipsPerPage = 3;

/// A4 page with up to 3 unique cut-apart login cards. Never repeats a person
/// to fill empty slots.
Uint8List buildCredentialSlipsPdf(
  List<CredentialSlip> slips,
  AppLocalizations l10n,
) {
  final unique = uniqueCredentialSlips(slips);
  if (unique.isEmpty) {
    throw ArgumentError(l10n.adminCredentialNeedUsers);
  }

  final document = PdfDocument();
  document.pageSettings.size = PdfPageSize.a4;
  document.pageSettings.margins.all = 28;

  final muFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    18,
    style: PdfFontStyle.bold,
  );
  final studyFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    18,
    style: PdfFontStyle.bold,
  );
  final disclaimerFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    8,
    style: PdfFontStyle.italic,
  );
  final labelFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    11,
    style: PdfFontStyle.bold,
  );
  final valueFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

  final muInk = PdfColor(45, 36, 22);
  final gold = PdfColor(197, 160, 89);
  final valueInk = PdfColor(20, 20, 20);
  final muted = PdfColor(120, 120, 120);
  final border = PdfColor(210, 210, 210);
  final fill = PdfColor(255, 255, 255);
  final linePen = PdfPen(PdfColor(230, 230, 230), width: 0.8);

  for (var i = 0; i < unique.length; i += _slipsPerPage) {
    final page = document.pages.add();
    final size = page.getClientSize();
    final g = page.graphics;
    const gap = 18.0;
    final slipHeight = (size.height - gap * (_slipsPerPage - 1)) / _slipsPerPage;
    final batch = unique.skip(i).take(_slipsPerPage).toList();

    for (var s = 0; s < batch.length; s++) {
      final top = s * (slipHeight + gap);
      final bounds = Rect.fromLTWH(0, top, size.width, slipHeight);
      _drawSlip(
        g,
        bounds: bounds,
        slip: batch[s],
        l10n: l10n,
        muFont: muFont,
        studyFont: studyFont,
        disclaimerFont: disclaimerFont,
        labelFont: labelFont,
        valueFont: valueFont,
        muInk: muInk,
        gold: gold,
        valueInk: valueInk,
        muted: muted,
        border: border,
        fill: fill,
        linePen: linePen,
      );
    }
  }

  final bytes = Uint8List.fromList(document.saveSync());
  document.dispose();
  return bytes;
}

void _drawSlip(
  PdfGraphics g, {
  required Rect bounds,
  required CredentialSlip slip,
  required AppLocalizations l10n,
  required PdfFont muFont,
  required PdfFont studyFont,
  required PdfFont disclaimerFont,
  required PdfFont labelFont,
  required PdfFont valueFont,
  required PdfColor muInk,
  required PdfColor gold,
  required PdfColor valueInk,
  required PdfColor muted,
  required PdfColor border,
  required PdfColor fill,
  required PdfPen linePen,
}) {
  const radius = 10.0;
  final card = _roundedRect(bounds, radius);
  g.drawPath(card, brush: PdfSolidBrush(fill), pen: PdfPen(border, width: 1));

  const barWidth = 7.0;
  g.drawRectangle(
    brush: PdfSolidBrush(gold),
    bounds: Rect.fromLTWH(
      bounds.left,
      bounds.top + radius,
      barWidth,
      bounds.height - radius * 2,
    ),
  );

  final left = bounds.left + 28;
  final width = bounds.width - 48;
  var y = bounds.top + 22;

  g.drawString(
    'MU',
    muFont,
    brush: PdfSolidBrush(muInk),
    bounds: Rect.fromLTWH(left, y, 40, 24),
  );
  g.drawString(
    'Study',
    studyFont,
    brush: PdfSolidBrush(gold),
    bounds: Rect.fromLTWH(left + 34, y, 80, 24),
  );
  y += 28;

  g.drawLine(
    linePen,
    Offset(left, y),
    Offset(bounds.right - 20, y),
  );
  y += 10;

  g.drawString(
    l10n.adminCredentialConfidential,
    disclaimerFont,
    brush: PdfSolidBrush(muted),
    bounds: Rect.fromLTWH(left, y, width, 28),
  );
  y += 36;

  void row(String label, String value) {
    g.drawString(
      '$label:',
      labelFont,
      brush: PdfSolidBrush(muInk),
      bounds: Rect.fromLTWH(left, y, 100, 16),
    );
    g.drawString(
      value,
      valueFont,
      brush: PdfSolidBrush(valueInk),
      bounds: Rect.fromLTWH(left + 108, y, width - 108, 16),
    );
    y += 22;
  }

  row(l10n.loginUsername, slip.username);
  row(l10n.adminFullName, slip.fullName);
  row(l10n.adminPassword, slip.password);
}

PdfPath _roundedRect(Rect r, double radius) {
  final path = PdfPath();
  final d = radius * 2;
  path.addArc(Rect.fromLTWH(r.left, r.top, d, d), 180, 90);
  path.addArc(Rect.fromLTWH(r.right - d, r.top, d, d), 270, 90);
  path.addArc(Rect.fromLTWH(r.right - d, r.bottom - d, d, d), 0, 90);
  path.addArc(Rect.fromLTWH(r.left, r.bottom - d, d, d), 90, 90);
  path.closeFigure();
  return path;
}
