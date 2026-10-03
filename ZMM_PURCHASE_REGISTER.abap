*&---------------------------------------------------------------------*
*& Report ZMM_PURCHASE_REGISTER
*&---------------------------------------------------------------------*
*& Purchase Register - one line per Goods Receipt item (MvT 101 / 102)
*& - 102 (reversal) lines are shown with negative quantity / amount
*& - Amount in company code currency = MATDOC-DMBTR (inventory value)
*& - Supplier invoice number = RBKP-XBLNR (MIRO invoice of the GR)
*& - GL code = ACDOCA-RACCT of the GR accounting document
*& - Output with FM REUSE_ALV_GRID_DISPLAY
*&---------------------------------------------------------------------*
REPORT zmm_purchase_register.

TABLES: ekko, ekpo, matdoc.

*----------------------------------------------------------------------*
* Types
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_out,
         lifnr      TYPE ekko-lifnr,      " Supplier Code
         name1      TYPE lfa1-name1,      " Supplier Name
         land1      TYPE lfa1-land1,      " Supplier Country
         xblnr      TYPE rbkp-xblnr,      " Supplier Invoice Number
         zterm      TYPE ekko-zterm,      " Payment Terms
         cpudt      TYPE matdoc-cpudt,    " GRN Date
         budat      TYPE matdoc-budat,    " Posting Date
         bedat      TYPE ekko-bedat,      " PO Date
         mblnr      TYPE matdoc-mblnr,    " GR Number
         ebeln      TYPE ekko-ebeln,      " PO Number
         matnr      TYPE ekpo-matnr,      " Material Code
         maktx      TYPE makt-maktx,      " Material Description
         bukrs      TYPE ekko-bukrs,      " Company Code
         matkl      TYPE ekpo-matkl,      " Material Group
         menge      TYPE matdoc-menge,    " Quantity (received)
         meins      TYPE matdoc-meins,    " Unit
         netpr      TYPE ekpo-netpr,      " Unit Price
         waers      TYPE ekko-waers,      " Transaction Currency
         dmbtr      TYPE matdoc-dmbtr,    " Amount in Company Code Currency
         hwaer      TYPE matdoc-waers,    " Company Code Currency
         werks_name TYPE t001w-name1,     " Plant Name
         werks      TYPE ekpo-werks,      " Plant Code
         racct      TYPE acdoca-racct,    " GL Code
*        Technical fields (not displayed)
         ebelp      TYPE ekpo-ebelp,
         mjahr      TYPE matdoc-mjahr,
         zeile      TYPE matdoc-zeile,
         shkzg      TYPE matdoc-shkzg,
         lfbnr      TYPE matdoc-lfbnr,
         lfbja      TYPE matdoc-lfbja,
         lfpos      TYPE matdoc-lfpos,
         aworg      TYPE acdoca-aworg,
       END OF ty_out.

TYPES: BEGIN OF ty_invoice,
         ebeln TYPE rseg-ebeln,
         ebelp TYPE rseg-ebelp,
         lfbnr TYPE rseg-lfbnr,
         lfgja TYPE rseg-lfgja,
         lfpos TYPE rseg-lfpos,
         xblnr TYPE rbkp-xblnr,
       END OF ty_invoice.

TYPES: BEGIN OF ty_gl,
         awref TYPE acdoca-awref,
         aworg TYPE acdoca-aworg,
         ebeln TYPE acdoca-ebeln,
         ebelp TYPE acdoca-ebelp,
         racct TYPE acdoca-racct,
       END OF ty_gl.

*----------------------------------------------------------------------*
* Global data
*----------------------------------------------------------------------*
DATA: gt_out      TYPE STANDARD TABLE OF ty_out,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv.

*----------------------------------------------------------------------*
* Selection screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_ebeln FOR ekko-ebeln,      " Purchase Order
                  s_bukrs FOR ekko-bukrs,      " Company Code
                  s_date  FOR matdoc-budat,    " Date (GR Posting Date)
                  s_mblnr FOR matdoc-mblnr,    " Material Document
                  s_lifnr FOR ekko-lifnr,      " Supplier Code
                  s_matnr FOR ekpo-matnr.      " Material
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM get_data.

  IF gt_out IS INITIAL.
    MESSAGE 'No data found for the given selection' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM get_invoice_number.
  PERFORM get_gl_account.
  PERFORM build_fieldcat.
  PERFORM display_alv.

*&---------------------------------------------------------------------*
*& Form GET_DATA
*& Main data: GR items (MATDOC) + PO header/item + master data texts
*&---------------------------------------------------------------------*
FORM get_data.

  FIELD-SYMBOLS: <ls_out> TYPE ty_out.

  SELECT m~mblnr, m~mjahr, m~zeile, m~budat, m~cpudt,
         m~menge, m~meins, m~dmbtr, m~waers AS hwaer, m~shkzg,
         m~lfbnr, m~lfbja, m~lfpos,
         k~ebeln, k~lifnr, k~zterm, k~bedat, k~bukrs, k~waers,
         p~ebelp, p~matnr, p~matkl, p~netpr, p~werks,
         l~name1, l~land1,
         t~maktx,
         w~name1 AS werks_name
    FROM matdoc AS m
    INNER JOIN ekko AS k
      ON k~ebeln = m~ebeln
    INNER JOIN ekpo AS p
      ON  p~ebeln = m~ebeln
      AND p~ebelp = m~ebelp
    LEFT OUTER JOIN lfa1 AS l
      ON l~lifnr = k~lifnr
    LEFT OUTER JOIN makt AS t
      ON  t~matnr = p~matnr
      AND t~spras = 'E'                    " Material text always in English
    LEFT OUTER JOIN t001w AS w
      ON w~werks = p~werks
    WHERE m~record_type = 'MDOC'
      AND m~bwart       IN ('101', '102')
      AND m~xauto       = @space
      AND m~ebeln       IN @s_ebeln
      AND m~budat       IN @s_date
      AND m~mblnr       IN @s_mblnr
      AND k~bukrs       IN @s_bukrs
      AND k~lifnr       IN @s_lifnr
      AND p~matnr       IN @s_matnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_out.

  LOOP AT gt_out ASSIGNING <ls_out>.
*   Reversal (credit) lines are shown as negative values
    IF <ls_out>-shkzg = 'H'.
      <ls_out>-menge = <ls_out>-menge * -1.
      <ls_out>-dmbtr = <ls_out>-dmbtr * -1.
    ENDIF.

*   Reference year in ACDOCA-AWORG (used to read the GL account)
    <ls_out>-aworg = <ls_out>-mjahr.
  ENDLOOP.

  SORT gt_out BY ebeln ebelp budat mblnr zeile.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_INVOICE_NUMBER
*& Supplier invoice number (RBKP-XBLNR) of the MIRO invoice
*& that references the goods receipt
*&---------------------------------------------------------------------*
FORM get_invoice_number.

  DATA: lt_invoice TYPE STANDARD TABLE OF ty_invoice,
        ls_invoice TYPE ty_invoice,
        lv_lfbnr   TYPE rseg-lfbnr,
        lv_lfgja   TYPE rseg-lfgja,
        lv_lfpos   TYPE rseg-lfpos.

  FIELD-SYMBOLS: <ls_out> TYPE ty_out.

  SELECT r~ebeln, r~ebelp, r~lfbnr, r~lfgja, r~lfpos, k~xblnr
    FROM rseg AS r
    INNER JOIN rbkp AS k
      ON  k~belnr = r~belnr
      AND k~gjahr = r~gjahr
    FOR ALL ENTRIES IN @gt_out
    WHERE r~ebeln = @gt_out-ebeln
      AND r~ebelp = @gt_out-ebelp
      AND k~stblg = @space                 " Invoice not reversed
    INTO TABLE @lt_invoice.

  SORT lt_invoice BY ebeln ebelp lfbnr lfgja lfpos.

  LOOP AT gt_out ASSIGNING <ls_out>.
*   GR reference: for a 101 it is the GR itself,
*   for a 102 it is the original 101 that was reversed
    IF <ls_out>-lfbnr IS NOT INITIAL.
      lv_lfbnr = <ls_out>-lfbnr.
      lv_lfgja = <ls_out>-lfbja.
      lv_lfpos = <ls_out>-lfpos.
    ELSE.
      lv_lfbnr = <ls_out>-mblnr.
      lv_lfgja = <ls_out>-mjahr.
      lv_lfpos = <ls_out>-zeile.
    ENDIF.

    READ TABLE lt_invoice INTO ls_invoice
         WITH KEY ebeln = <ls_out>-ebeln
                  ebelp = <ls_out>-ebelp
                  lfbnr = lv_lfbnr
                  lfgja = lv_lfgja
                  lfpos = lv_lfpos
         BINARY SEARCH.
    IF sy-subrc = 0.
      <ls_out>-xblnr = ls_invoice-xblnr.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_GL_ACCOUNT
*& GL account of the GR accounting document (ACDOCA, leading ledger).
*& The GR/IR clearing (WRX) and price difference (PRD) lines are skipped,
*& so we get the inventory (BSX) or the consumption account.
*&---------------------------------------------------------------------*
FORM get_gl_account.

  DATA: lt_gl TYPE STANDARD TABLE OF ty_gl,
        ls_gl TYPE ty_gl.

  FIELD-SYMBOLS: <ls_out> TYPE ty_out.

  SELECT awref, aworg, ebeln, ebelp, racct
    FROM acdoca
    FOR ALL ENTRIES IN @gt_out
    WHERE rldnr  = '0L'
      AND rbukrs = @gt_out-bukrs
      AND awtyp  = 'MKPF'
      AND awref  = @gt_out-mblnr
      AND aworg  = @gt_out-aworg
      AND ebeln  = @gt_out-ebeln
      AND ebelp  = @gt_out-ebelp
      AND ktosl  NOT IN ('WRX', 'PRD')
    INTO TABLE @lt_gl.

  SORT lt_gl BY awref aworg ebeln ebelp.

  LOOP AT gt_out ASSIGNING <ls_out>.
    READ TABLE lt_gl INTO ls_gl
         WITH KEY awref = <ls_out>-mblnr
                  aworg = <ls_out>-aworg
                  ebeln = <ls_out>-ebeln
                  ebelp = <ls_out>-ebelp
         BINARY SEARCH.
    IF sy-subrc = 0.
      <ls_out>-racct = ls_gl-racct.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM build_fieldcat.

  PERFORM add_field USING 'LIFNR'      'Supplier Code'          'EKKO'   'LIFNR'.
  PERFORM add_field USING 'NAME1'      'Supplier Name'          'LFA1'   'NAME1'.
  PERFORM add_field USING 'LAND1'      'Supplier Country'       'LFA1'   'LAND1'.
  PERFORM add_field USING 'XBLNR'      'Supplier Invoice No.'   'RBKP'   'XBLNR'.
  PERFORM add_field USING 'ZTERM'      'Payment Terms'          'EKKO'   'ZTERM'.
  PERFORM add_field USING 'CPUDT'      'GRN Date'               'MATDOC' 'CPUDT'.
  PERFORM add_field USING 'BUDAT'      'Posting Date'           'MATDOC' 'BUDAT'.
  PERFORM add_field USING 'BEDAT'      'PO Date'                'EKKO'   'BEDAT'.
  PERFORM add_field USING 'MBLNR'      'GR Number'              'MATDOC' 'MBLNR'.
  PERFORM add_field USING 'EBELN'      'PO Number'              'EKKO'   'EBELN'.
  PERFORM add_field USING 'MATNR'      'Material Code'          'EKPO'   'MATNR'.
  PERFORM add_field USING 'MAKTX'      'Material Description'   'MAKT'   'MAKTX'.
  PERFORM add_field USING 'BUKRS'      'Company Code'           'EKKO'   'BUKRS'.
  PERFORM add_field USING 'MATKL'      'Material Group'         'EKPO'   'MATKL'.
  PERFORM add_field USING 'MENGE'      'Quantity'               'MATDOC' 'MENGE'.
  PERFORM add_field USING 'MEINS'      'Unit'                   'MATDOC' 'MEINS'.
  PERFORM add_field USING 'NETPR'      'Unit Price'             'EKPO'   'NETPR'.
  PERFORM add_field USING 'WAERS'      'Transaction Currency'   'EKKO'   'WAERS'.
  PERFORM add_field USING 'DMBTR'      'Amount (CoCode Curr.)'  'MATDOC' 'DMBTR'.
  PERFORM add_field USING 'HWAER'      'CoCode Currency'        'MATDOC' 'WAERS'.
  PERFORM add_field USING 'WERKS_NAME' 'Plant Name'             'T001W'  'NAME1'.
  PERFORM add_field USING 'WERKS'      'Plant Code'             'EKPO'   'WERKS'.
  PERFORM add_field USING 'RACCT'      'GL Code'                'ACDOCA' 'RACCT'.

* Link quantity / amounts to their unit / currency fields
  FIELD-SYMBOLS: <ls_fcat> TYPE slis_fieldcat_alv.

  LOOP AT gt_fieldcat ASSIGNING <ls_fcat>.
    CASE <ls_fcat>-fieldname.
      WHEN 'MENGE'.
        <ls_fcat>-qfieldname = 'MEINS'.
      WHEN 'NETPR'.
        <ls_fcat>-cfieldname = 'WAERS'.
      WHEN 'DMBTR'.
        <ls_fcat>-cfieldname = 'HWAER'.
        <ls_fcat>-do_sum     = abap_true.   " Total per currency
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ADD_FIELD
*&---------------------------------------------------------------------*
FORM add_field USING pv_fieldname TYPE c
                     pv_text      TYPE c
                     pv_ref_tab   TYPE c
                     pv_ref_field TYPE c.

  DATA: ls_fcat TYPE slis_fieldcat_alv.

  ls_fcat-fieldname     = pv_fieldname.
  ls_fcat-tabname       = 'GT_OUT'.
  ls_fcat-ref_tabname   = pv_ref_tab.
  ls_fcat-ref_fieldname = pv_ref_field.
  ls_fcat-seltext_s     = pv_text.
  ls_fcat-seltext_m     = pv_text.
  ls_fcat-seltext_l     = pv_text.
  ls_fcat-reptext_ddic  = pv_text.
  ls_fcat-ddictxt       = 'L'.

  APPEND ls_fcat TO gt_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv.

  gs_layout-zebra             = abap_true.
  gs_layout-colwidth_optimize = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = 'Purchase Register'
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
      i_save             = 'A'
    TABLES
      t_outtab           = gt_out
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error while displaying the ALV' TYPE 'E'.
  ENDIF.

ENDFORM.
