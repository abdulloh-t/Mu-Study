import 'package:flutter/material.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Future<void> openPdfViewer(BuildContext context, String url, {String? title}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // The shell's nav bar floats above its own body, so a sheet opened on the
    // shell navigator would come up underneath it.
    useRootNavigator: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      maxChildSize: 0.98,
      minChildSize: 0.5,
      builder: (_, controller) => Column(
        children: [
          ListTile(
            title: Text(title ?? ctx.l10n.pdfDefaultTitle),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
          Expanded(
            child: SfPdfViewer.network(
              url,
              scrollDirection: PdfScrollDirection.vertical,
            ),
          ),
        ],
      ),
    ),
  );
}
