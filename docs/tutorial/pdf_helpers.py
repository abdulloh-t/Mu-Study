"""Helpers for building PDF flowables."""

from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import (
    KeepTogether,
    ListFlowable,
    ListItem,
    Paragraph,
    Preformatted,
    Spacer,
    Table,
    TableStyle,
)

from pdf_styles import (
    ACCENT,
    BRAND,
    CALLOUT_BG,
    CHECK_BG,
    CODE_BG,
    TABLE_HEADER,
    TASK_BG,
    WARN_BG,
)


def p(styles, text, style="Body"):
    return Paragraph(text.replace("\n", "<br/>"), styles[style])


def h1(styles, text):
    return Paragraph(text, styles["H1"])


def h2(styles, text):
    return Paragraph(text, styles["H2"])


def h3(styles, text):
    return Paragraph(text, styles["H3"])


def bullets(styles, items):
    flow = []
    for item in items:
        flow.append(Paragraph(f"• {item}", styles["Bullet"]))
    return flow


def numbered(styles, items):
    flow = []
    for i, item in enumerate(items, 1):
        flow.append(Paragraph(f"{i}. {item}", styles["Bullet"]))
    return flow


def code_block(styles, path, code):
    parts = []
    if path:
        parts.append(Paragraph(path, styles["CodePath"]))
    # Preformatted keeps whitespace; wrap long lines lightly
    safe = code.replace("\t", "  ")
    parts.append(Preformatted(safe, styles["Code"], maxLineLength=95))
    return KeepTogether(parts)


def box(styles, title, body, bg, style_key):
    inner = [
        Paragraph(f"<b>{title}</b>", styles[style_key]),
        Paragraph(body.replace("\n", "<br/>"), styles[style_key]),
    ]
    t = Table([[inner]], colWidths=[6.5 * inch])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), bg),
                ("BOX", (0, 0), (-1, -1), 0.5, ACCENT),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 8),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]
        )
    )
    return KeepTogether([Spacer(1, 6), t, Spacer(1, 6)])


def callout(styles, title, body):
    return box(styles, title, body, CALLOUT_BG, "Callout")


def task(styles, title, body):
    return box(styles, f"TASK — {title}", body, TASK_BG, "Task")


def warn(styles, title, body):
    return box(styles, f"WARNING — {title}", body, WARN_BG, "Warn")


def checkpoint(styles, title, body):
    return box(styles, f"CHECKPOINT — {title}", body, CHECK_BG, "Callout")


def simple_table(styles, headers, rows, col_widths=None):
    data = [[Paragraph(h, styles["TableHeader"]) for h in headers]]
    for row in rows:
        data.append([Paragraph(str(c), styles["TableCell"]) for c in row])
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), TABLE_HEADER),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("BACKGROUND", (0, 1), (-1, -1), colors.white),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, CODE_BG]),
                ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#D6C9BC")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    return t
