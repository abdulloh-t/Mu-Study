"""Shared ReportLab styles for the MU Study reconstruction tutorial."""

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont


BRAND = colors.HexColor("#5C3D2E")
ACCENT = colors.HexColor("#C4A484")
CODE_BG = colors.HexColor("#F4F1EC")
CALLOUT_BG = colors.HexColor("#EEF6F0")
WARN_BG = colors.HexColor("#FFF4E5")
TASK_BG = colors.HexColor("#E8F0FE")
CHECK_BG = colors.HexColor("#F3E8FF")
TABLE_HEADER = colors.HexColor("#3E2C23")
MUTED = colors.HexColor("#6B5E55")


def build_styles():
    base = getSampleStyleSheet()
    styles = {
        "Title": ParagraphStyle(
            "TTitle",
            parent=base["Title"],
            fontSize=28,
            leading=34,
            textColor=BRAND,
            alignment=TA_CENTER,
            spaceAfter=12,
            fontName="Helvetica-Bold",
        ),
        "Subtitle": ParagraphStyle(
            "TSubtitle",
            parent=base["Normal"],
            fontSize=14,
            leading=18,
            textColor=MUTED,
            alignment=TA_CENTER,
            spaceAfter=8,
        ),
        "H1": ParagraphStyle(
            "TH1",
            parent=base["Heading1"],
            fontSize=18,
            leading=22,
            textColor=BRAND,
            spaceBefore=18,
            spaceAfter=10,
            fontName="Helvetica-Bold",
            keepWithNext=1,
        ),
        "H2": ParagraphStyle(
            "TH2",
            parent=base["Heading2"],
            fontSize=14,
            leading=18,
            textColor=colors.HexColor("#3E2C23"),
            spaceBefore=14,
            spaceAfter=8,
            fontName="Helvetica-Bold",
            keepWithNext=1,
        ),
        "H3": ParagraphStyle(
            "TH3",
            parent=base["Heading3"],
            fontSize=12,
            leading=15,
            textColor=colors.HexColor("#4A3728"),
            spaceBefore=10,
            spaceAfter=6,
            fontName="Helvetica-Bold",
            keepWithNext=1,
        ),
        "Body": ParagraphStyle(
            "TBody",
            parent=base["Normal"],
            fontSize=10,
            leading=14,
            alignment=TA_JUSTIFY,
            spaceAfter=8,
        ),
        "Bullet": ParagraphStyle(
            "TBullet",
            parent=base["Normal"],
            fontSize=10,
            leading=13,
            leftIndent=14,
            spaceAfter=3,
        ),
        "Code": ParagraphStyle(
            "TCode",
            parent=base["Code"],
            fontName="Courier",
            fontSize=7.5,
            leading=10,
            backColor=CODE_BG,
            leftIndent=4,
            rightIndent=4,
            spaceBefore=4,
            spaceAfter=8,
        ),
        "CodePath": ParagraphStyle(
            "TCodePath",
            parent=base["Normal"],
            fontName="Courier-Bold",
            fontSize=8,
            textColor=BRAND,
            spaceBefore=8,
            spaceAfter=2,
        ),
        "Callout": ParagraphStyle(
            "TCallout",
            parent=base["Normal"],
            fontSize=9.5,
            leading=13,
            textColor=colors.HexColor("#1B4332"),
        ),
        "Task": ParagraphStyle(
            "TTask",
            parent=base["Normal"],
            fontSize=9.5,
            leading=13,
            textColor=colors.HexColor("#1A365D"),
        ),
        "Warn": ParagraphStyle(
            "TWarn",
            parent=base["Normal"],
            fontSize=9.5,
            leading=13,
            textColor=colors.HexColor("#7C2D12"),
        ),
        "Caption": ParagraphStyle(
            "TCaption",
            parent=base["Normal"],
            fontSize=8,
            leading=10,
            textColor=MUTED,
            alignment=TA_CENTER,
            spaceAfter=10,
        ),
        "TOCEntry": ParagraphStyle(
            "TTOC",
            parent=base["Normal"],
            fontSize=10,
            leading=16,
            leftIndent=0,
        ),
        "Footer": ParagraphStyle(
            "TFooter",
            parent=base["Normal"],
            fontSize=8,
            textColor=MUTED,
            alignment=TA_CENTER,
        ),
        "Small": ParagraphStyle(
            "TSmall",
            parent=base["Normal"],
            fontSize=8.5,
            leading=11,
            textColor=MUTED,
            spaceAfter=6,
        ),
        "TableCell": ParagraphStyle(
            "TTableCell",
            parent=base["Normal"],
            fontSize=8,
            leading=10,
        ),
        "TableHeader": ParagraphStyle(
            "TTableHeader",
            parent=base["Normal"],
            fontSize=8,
            leading=10,
            textColor=colors.white,
            fontName="Helvetica-Bold",
        ),
    }
    return styles
