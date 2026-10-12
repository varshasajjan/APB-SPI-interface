Lint Report
  -----------------------------------------------------------------------------
  Report Summary
  -----------------------------------------------------------------------------
  Product Info
    Name    : VC Static Master Shell
    Version : X-2025.06 -- May 29, 2025

  Report Info
    Created : Oct 06, 2026  22:55:16

    TopLevelModule: APB_SPI_Top

  -----------------------------------------------------------------------------
  Management Summary
  -----------------------------------------------------------------------------
  Stage             Family                Fatals    Errors  Warnings     Infos
  -----             ------------------  --------  --------  --------  --------
  DESIGN_READ       DESIGN                     0         0         5         0
  DESIGN_READ       ErrorAnalyzeBBox           0         4         0         0
  LANGUAGE_CHECK    CODING                     0         0         0         1
  STRUCTURAL_CHECK  CODING                     0         0         0        15
  -----             ------------------  --------  --------  --------  --------
  Total                                        0         4         5        16


  -----------------------------------------------------------------------------
  Tree Summary
  -----------------------------------------------------------------------------
  Severity  Stage             Tag                  Count
  --------  -----             -------------------  -----
  error     DESIGN_READ       ErrorAnalyzeBBox         4
  warning   DESIGN_READ       DB_CANT_LOAD             1
  warning   DESIGN_READ       SM_URMI                  4
  info      LANGUAGE_CHECK    ReportPortInfo-ML        1
  info      STRUCTURAL_CHECK  RegInputOutput-ML       15
  --------  -----             -------------------  -----
  Total                                               25
  -----------------------------------------------------------------------------
  ReportPortInfo-ML  (1 info/0 waived)
  -----------------------------------------------------------------------------
  Tag           : ReportPortInfo-ML
  Description   : Port Information for top design unit has been generated. For details see report ReportPortInfo.rpt
  Violation     : Lint:16
  Goal          : lint_rtl
  FileName      : /home2/BPRN35/VarshiniGN/APB_SPI_2026/APB_SPI_project/APB_top/lint/vcst_rtdb/.internal/spyglass/vc_lint0/APB_SPI_Top/VC_GOAL0/spyglass_reports/morelint/ReportPortInfo
  LineNumber    : 1
  Statement     : #     Comment          : Report Top Level Module Port Info
