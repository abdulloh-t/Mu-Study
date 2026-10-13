import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/progress/progress_report.dart';
import 'package:mu_study/core/progress/progress_report_pdf.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareProgressReport({
  required String studentId,
  required String groupId,
  required String studentName,
  required String groupTitle,
  required AcademicTerm term,
  required AppLocalizations l10n,
}) async {
  final report = await fetchProgressReport(
    studentId: studentId,
    groupId: groupId,
    studentName: studentName,
    groupTitle: groupTitle,
    term: term,
    l10n: l10n,
  );

  final pdfBytes = buildProgressReportPdf(report, l10n);
  final text = progressReportShareText(report, l10n);

  final safeStudent = studentName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  final fileName =
      'progress_${safeStudent.isEmpty ? studentId : safeStudent}_${term.id}.pdf';

  await SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: '${l10n.progressReportTitle} — $studentName',
      files: [
        XFile.fromData(pdfBytes, mimeType: 'application/pdf', name: fileName),
      ],
      fileNameOverrides: [fileName],
      downloadFallbackEnabled: true,
    ),
  );
}
