*&---------------------------------------------------------------------*
*& Report  Z_SD_R_ZSDR003_MARKET_REPORT
************************************************************
* PROGRAM DETAILS
* Program Name: Z_SD_R_ZSDR025_ARTICLE_SALES
* Title: Article Sales report ( Copy of ZSDR003)
* Original Author: CSC_ABAP
* Date Written: 02/09/2012
* Type: Report Program
* Design Spec ID:
* Brief Purpose: Article Sales Reprot
*
* SYSTEM DETAILS
* SAP Release (for original code): SAP ECC 6.0
* E2E Process: SD
* Module: SD

* DESCRIPTION / PROCESSING DETAILS
* Market Report
************************************************************
* CHANGE HISTORY
* Date        Developer       SAP Release  Change Number
************************************************************
*&---------------------------------------------------------------------*

REPORT zsd_r_zsdr025_article_sales2 .
TABLES : vbrk,
         tvko,
         marc,
         tvtw,
         tspa,
         kna1,
         t023,
         p0001,
         wrf_brands_t,
         t024d,
         tvkgr,
         tvbur,
         mara,
         twew,
         tvkwz,
         t077d,
         knvv,
         tvv1t, " Added by Pravin Bagul on 19.11.2014
         tvv2t, " Added by Pravin Bagul on 19.11.2014
         tvv3t, " Added by Pravin Bagul on 19.11.2014
         marm. " Added by Pravin Bagul on 05.01.2015

*ALV data declarations

*Start of changes by csc_abap on 26.9.13 for Inc 7000002684
DATA : lt_t6wfgt TYPE TABLE OF t6wfgt,
       lw_t6wfgt LIKE LINE OF lt_t6wfgt.
*End of changes by csc_abap on 26.9.13 for Inc 7000002684

DATA : gv_curr   TYPE tcurr-tcurr,
       lv_exrate TYPE vbrk-netwr.

DATA: it_fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid,
      gc_msgtype_e TYPE symsgty VALUE 'E'.

TYPES : BEGIN OF lty_vbrk,           "insert csc_ryugandh one sep 18
          vbeln    TYPE vbrk-vbeln,
          fkart    TYPE vbrk-fkart,
          waerk    TYPE vbrk-waerk,
          vkorg    TYPE vbrk-vkorg,
          fkdat    TYPE vbrk-fkdat,
          kunag    TYPE kunag,
          vtweg    TYPE vbrk-vtweg,
          spart    TYPE vbrk-spart,
          kurrf    TYPE vbrk-kurrf,
          fksto    TYPE vbrk-fksto,
          bstnk_vf TYPE vbrk-bstnk_vf,   "Marwan 20012106
          kunrg    TYPE vbrk-kunrg, "Desoky
        END OF lty_vbrk.

TYPES : BEGIN OF lty_vbrp,
          vbeln      TYPE vbrp-vbeln,
          posnr      TYPE vbrp-posnr,
          netwr      TYPE vbrp-netwr,
          aubel      TYPE vbrp-aubel, "Added by Assadulla Khan
          matnr      TYPE vbrp-matnr,
          pstyv      TYPE vbrp-pstyv,
          fkimg      TYPE vbrp-fkimg,
          vrkme      TYPE vbrp-vrkme,
          werks      TYPE vbrp-werks,
          wavwr      TYPE vbrp-wavwr,
          vkgrp      TYPE vbrp-vkgrp,
          vkbur      TYPE vbrp-vkbur,
          vkorg_auft TYPE vkorg_auft,
          vtweg_auft TYPE vtweg_auft,
          meins      TYPE vbrp-meins, " Added by Pravin Bagul on 25.11.2014
          vgbel      TYPE vbrp-vgbel, " PGI Date: delivery reference
        END OF lty_vbrp.

" PGI Date
TYPES : BEGIN OF lty_likp,
          vbeln     TYPE likp-vbeln,
          wadat_ist TYPE likp-wadat_ist,
        END OF lty_likp.

************* Added & Commented by Pravin Bagul on 26.10.2015 ****

*TYPES : BEGIN OF ty_t001w,
*        werks TYPE t001w-werks,
*        name1 TYPE t001w-name1,
*        END OF ty_t001w.

*******************************************************

TYPES : BEGIN OF lty_mara,
          matnr    TYPE mara-matnr,
          matkl    TYPE mara-matkl,
          brand_id TYPE mara-brand_id,
          extwg    TYPE mara-extwg,
          meins    TYPE mara-meins, "Inserted by Kishore
          fashgrd  TYPE mara-fashgrd, " Added by csc_abap on 26.9.13 for Inc 7000002684
        END OF lty_mara.

TYPES : BEGIN OF lty_t024d,
          werks TYPE t024d-werks,
          dispo TYPE t024d-dispo,
          dsnam TYPE t024d-dsnam,
        END OF lty_t024d,

        BEGIN OF lty_tvko,
          vkorg TYPE tvko-vkorg,
        END OF lty_tvko.

TYPES : BEGIN OF lty_marc,
          matnr TYPE marc-matnr,
          werks TYPE marc-werks,
          ekgrp TYPE marc-ekgrp,
          dispo TYPE marc-dispo,
        END OF lty_marc.

TYPES : BEGIN OF lty_t023t,
          matkl TYPE t023t-matkl,
          wgbez TYPE t023t-wgbez,
        END OF lty_t023t.

TYPES : BEGIN OF lty_makt,
          matnr TYPE makt-matnr,
          maktx TYPE makt-maktx,
          spras TYPE makt-spras, "ECDK910782(+)
        END OF lty_makt.

TYPES : BEGIN OF lty_kna1,
          kunnr TYPE kna1-kunnr,
          land1 TYPE kna1-land1,
          name1 TYPE kna1-name1,
          ktokd TYPE kna1-ktokd,
          namep TYPE kna1-name1,  "Desoky
        END OF lty_kna1.

TYPES : BEGIN OF lty_knvv,
          kunnr TYPE knvv-kunnr,
          vkorg TYPE knvv-vkorg,
          vtweg TYPE knvv-vtweg,
          spart TYPE knvv-spart,
          kdgrp TYPE knvv-kdgrp,
          vkgrp TYPE knvv-vkgrp,
          vkbur TYPE knvv-vkbur,
          kvgr1 TYPE knvv-kvgr1, "Added by Pravin Bagul on 13.11.2014
          kvgr2 TYPE knvv-kvgr2, "Added by Pravin Bagul on 13.11.2014
          kvgr3 TYPE knvv-kvgr3, "Added by Pravin Bagul on 13.11.2014
          kvgr4 TYPE knvv-kvgr4, "Added by Pravin Bagul on 13.11.2014
          kvgr5 TYPE knvv-kvgr5, "Added by Pravin Bagul on 13.11.2014
        END OF lty_knvv.

TYPES : BEGIN OF lty_pa0002,
          pernr TYPE pa0002-pernr,
          vorna TYPE pa0002-vorna,
          nachn TYPE pa0002-nachn,
        END OF lty_pa0002,

        BEGIN OF lty_waerk,
          waerk TYPE vbrk-waerk,
        END OF lty_waerk.

TYPES : BEGIN OF lty_vbpa,
          vbeln TYPE vbpa-vbeln,
          pernr TYPE vbpa-pernr,
        END OF lty_vbpa,

        BEGIN OF lty_mvke,
          matnr TYPE mvke-matnr,
          vkorg TYPE mvke-vkorg,
          vtweg TYPE mvke-vtweg,
          vrkme TYPE mvke-vrkme,
*           bezei1       TYPE tvm1t-bezei,
          mvgr1 TYPE mvke-mvgr1,
*         bezei2       TYPE tvm2t-bezei,
          mvgr2 TYPE mvke-mvgr2,
*         bezei3       TYPE tvm3t-bezei,
          mvgr3 TYPE mvke-mvgr3,
*         bezei4       TYPE tvm4t-bezei,
          mvgr4 TYPE mvke-mvgr4,
*         bezei5       TYPE tvm5t-bezei,
          mvgr5 TYPE mvke-mvgr5,
        END OF lty_mvke,

        BEGIN OF lty_marm,
          matnr TYPE marm-matnr,
          meinh TYPE marm-meinh,
          umrez TYPE marm-umrez,
          umren TYPE marm-umren,
        END OF lty_marm.

TYPES : BEGIN OF lty_vbak,
          vbeln TYPE vbak-vbeln,
          audat TYPE vbak-audat,   "Added by Assadulla Khan on 16.03.2014
          bstnk TYPE vbak-bstnk,
        END OF lty_vbak.

TYPES : BEGIN OF ty_main,
          vbeln        TYPE vbrk-vbeln,                         " Billing Doc
          fkdat        TYPE vbrk-fkdat,
          vkorg        TYPE vbrk-vkorg,                         " Sales Org
          vtext        TYPE tvkot-vtext,                        " Sales Org Text
          vtweg        TYPE tvtw-vtweg,                         " Distribution Channel
          order_no     TYPE vbak-vbeln, "added by Assadulla Khan " Order Number
          order_date   TYPE vbak-audat, "added by Assadulla Khan " Order Date
          vtext_dc     TYPE tvtwt-vtext,                        " Distribution Channel Desc
          vkgrp        TYPE knvv-vkgrp,                         " Sales Group
          bezei        TYPE tvgrt-bezei,                        " Sales Group Desc
          vkbur        TYPE knvv-vkbur,                         " Sales office
          bezei_so     TYPE tvkbt-bezei,                        " Sales office Desc
          fkart        TYPE vbrk-fkart,                         " Billing Type
          vtext_bill   TYPE tvfkt-vtext,                        " Billing Desc
          kunag        TYPE vbrk-kunag,                         " Customer
          kunrg        TYPE vbrk-kunrg, "Desoky                   Payer
          name1        TYPE kna1-name1,                         " Customer Name
          namep        TYPE kna1-name1, "Desoky                   Payer Name
          land1        TYPE kna1-land1,
          ktokd        TYPE kna1-ktokd,
          txt30	       TYPE txt30_077t,
          pernr        TYPE vbpa-pernr,                         " Sales Employee No
          vorna        TYPE p0002-vorna,                        " Sales Employee First name
          nachn        TYPE p0002-nachn,                        " Sales Employee Last name
          cname        TYPE p0002-cname,                        " Sales Employee Full Name
          matkl        TYPE mara-matkl,                         " Mechendise Catagory
          wgbez        TYPE t023t-wgbez,                        " Mechendise Catagory Desc
          wwgha2       TYPE wwgha,                              " MC Level 2
          wwghb2       TYPE wwghb,                              " MC Level 2 Desc
          wwgha3       TYPE wwgha,                              " MC Level 3
          wwghb3       TYPE wwghb,                              " MC Level 3 Desc
          wwgha4       TYPE wwgha,                              " MC Level 4
          wwghb4       TYPE wwghb,                              " MC Level 4 Desc
          wwgha5       TYPE wwgha,                              " MC Level 5
          wwghb5       TYPE wwghb,                              " MC Level 5 Desc
          brand_id     TYPE mara-brand_id,                      " Brand
          brd_desc     TYPE wrf_brands_t-brand_descr,           " Brand Desc
*Start of changes by csc_abap on 26.9.13 for Inc 7000002684
          fashgrd      TYPE mara-fashgrd,                        "Sub Brand
          sub_brd_desc TYPE t6wfgt-vtext,                      "Sub Brand Desc
*End of changes by csc_abap on 26.9.13 for Inc 7000002684
          dispo        TYPE marc-dispo,                         " Stock Planner
          dsnam        TYPE t024d-dsnam,                        " Stock Planner Name
          extwg        TYPE mara-extwg,                         " External Mechendise
          ewbez        TYPE twewt-ewbez,                        " External Mechendise Desc
          matnr        TYPE vbrp-matnr,                         " Article
          maktx        TYPE makt-maktx,                         " Article Desc
          maktxf       TYPE makt-maktx,                         " Article Desc in FR
          pstyv        TYPE vbrp-pstyv,
          fkimg        TYPE vbrp-fkimg,                         " Billed Quantity
          vrkme        TYPE char3,                         " Unit
          wavwr        TYPE vbrp-wavwr,                         " Cost
          month        TYPE char8,
          qrt          TYPE char2,
          year         TYPE char4,
          waerk        TYPE waerk,
          netwr        TYPE vbrp-netwr,                         " Net Value
          ekgrp        TYPE marc-ekgrp,
* Insert csc_ryugandh on Feb 13
          gmval        TYPE vbrp-netwr,
          gmper        TYPE netwr, " TYPE p DECIMALS 2,
          kdgrp        TYPE kdgrp,
          kvgr1        TYPE knvv-kvgr1, "Added by Pravin Bagul on 13.11.2014
          lv_gr1       TYPE tvv1t-bezei,    " Added by Pravin Bagul on 19.11.2014
          kvgr2        TYPE knvv-kvgr2, "Added by Pravin Bagul on 13.11.2014
          lv_gr2       TYPE tvv2t-bezei,    " Added by Pravin Bagul on 19.11.2014
          kvgr3        TYPE knvv-kvgr3, "Added by Pravin Bagul on 13.11.2014
          lv_gr3       TYPE tvv3t-bezei,    " Added by Pravin Bagul on 19.11.2014
          kvgr4        TYPE knvv-kvgr4, "Added by Pravin Bagul on 13.11.2014
          lv_gr4       TYPE tvv4t-bezei,    " Added by Pravin Bagul on 19.11.2014
          kvgr5        TYPE knvv-kvgr5, "Added by Pravin Bagul on 13.11.2014
          lv_gr5       TYPE tvv5t-bezei,    " Added by Pravin Bagul on 19.11.2014
          ktext        TYPE t151t-ktext,
          meins        TYPE char3,  " Added by Pravin Bagul on 25.11.2014
          base_quan    TYPE vbrp-fkimg, " Added by Pravin Bagul on 05.01.2015
*          werks TYPE t001w-werks," Added by Pravin Bagul on 14.10.2015
*          name1_t TYPE t001w-name1," Added by Pravin Bagul on 14.10.2015
*End of Insert csc_ryugandh on Feb 13
*          jan        TYPE vbrp-netwr,
*          feb        TYPE vbrp-netwr,
*          mar        TYPE vbrp-netwr,
*          q1        TYPE vbrp-netwr,
*          april        TYPE vbrp-netwr,
*          may        TYPE vbrp-netwr,
*          june        TYPE vbrp-netwr,
*          q2        TYPE vbrp-netwr,
*          july       TYPE vbrp-netwr,
*          aug       TYPE vbrp-netwr,
*          sept        TYPE vbrp-netwr,
*          q3        TYPE vbrp-netwr,
*          oct       TYPE vbrp-netwr,
*          nov        TYPE vbrp-netwr,
*          dec        TYPE vbrp-netwr,
*          q4        TYPE vbrp-netwr,
*          netsales  TYPE vbrp-netwr,

          bstnk_vf     TYPE vbrk-bstnk_vf,   "Marwan 20012106
          bezei1       TYPE tvm1t-bezei,
          mvgr1        TYPE mvke-mvgr1,
          bezei2       TYPE tvm2t-bezei,
          mvgr2        TYPE mvke-mvgr2,
          bezei3       TYPE tvm3t-bezei,
          mvgr3        TYPE mvke-mvgr3,
          bezei4       TYPE tvm4t-bezei,
          mvgr4        TYPE mvke-mvgr4,
          bezei5       TYPE tvm5t-bezei,
          mvgr5        TYPE mvke-mvgr5,
          GL_netwr        TYPE vbrp-netwr,                         " Net Value for Specific GL
          wadat_ist    TYPE likp-wadat_ist,                     " Post Goods Issue Date
        END OF ty_main.

************** Added by Pravin Bagul on 19.11.2014 ************

TYPES : BEGIN OF ty_tvv1t,
          kvgr1 TYPE  tvv1t-kvgr1,
          bezei TYPE  tvv1t-bezei,
        END OF ty_tvv1t,

        BEGIN OF ty_tvv2t,
          kvgr2 TYPE tvv2t-kvgr2,
          bezei TYPE tvv2t-bezei,
        END OF ty_tvv2t,

        BEGIN OF ty_tvv3t,
          kvgr3 TYPE  tvv3t-kvgr3,
          bezei TYPE  tvv3t-bezei,
        END OF ty_tvv3t,

        BEGIN OF ty_tvv4t,
          kvgr4 TYPE tvv4t-kvgr4,
          bezei TYPE tvv4t-bezei,
        END OF ty_tvv4t,

        BEGIN OF ty_tvv5t,
          kvgr5 TYPE  tvv5t-kvgr5,
          bezei TYPE  tvv5t-bezei,
        END OF ty_tvv5t.

DATA : it_gr1 TYPE TABLE OF ty_tvv1t,
       wa_gr1 TYPE ty_tvv1t,

       it_gr2 TYPE TABLE OF ty_tvv2t,
       wa_gr2 TYPE ty_tvv2t,

       it_gr3 TYPE TABLE OF ty_tvv3t,
       wa_gr3 TYPE ty_tvv3t,

       it_gr4 TYPE TABLE OF ty_tvv4t,
       wa_gr4 TYPE ty_tvv4t,

       it_gr5 TYPE TABLE OF ty_tvv5t,
       wa_gr5 TYPE ty_tvv5t.
***************************************************************

DATA : lt_main  TYPE STANDARD TABLE OF ty_main,
       lw_main  TYPE ty_main,

       gt_tcurr TYPE STANDARD TABLE OF tcurr,
       gw_tcurr TYPE tcurr,

       gv_date1 TYPE char10.

*--start of insertion by Prajakta
DATA:lt_t001 TYPE TABLE OF t001,
     ls_t001 TYPE t001.
*--end of insertion by Prajakta

TYPES : BEGIN OF TY_ACDOCA,
        BILL_NO   TYPE ACDOCA-AWREF,
        BILL_ITEM TYPE ACDOCA-AWITEM,
        END OF TY_ACDOCA.

DATA : lt_vbrk   TYPE TABLE OF lty_vbrk,
*      lt_vbrk TYPE STANDARD TABLE OF vbrk,
*       lt_knvv TYPE STANDARD TABLE OF knvv,
       lt_knvv   TYPE TABLE OF lty_knvv,
*       lt_vbpa TYPE STANDARD TABLE OF vbpa,
       lt_vbpa   TYPE TABLE OF lty_vbpa,
*       lt_mara TYPE STANDARD TABLE OF mara,
       lt_mara   TYPE TABLE OF lty_mara,
*       lt_marc TYPE STANDARD TABLE OF marc,
       lt_marc   TYPE TABLE OF lty_marc,
*       lt_vbrp TYPE STANDARD TABLE OF vbrp,
       lt_vbrp   TYPE TABLE OF lty_vbrp,
       lt_tvkwz  TYPE STANDARD TABLE OF tvkwz,
       l_t_t077x TYPE TABLE OF t077x,
       l_s_t077x TYPE t077x,
       l_t_tvko  TYPE TABLE OF lty_tvko,
       l_s_tvko  TYPE lty_tvko,
       LT_ACDOCA TYPE TABLE OF TY_ACDOCA,
       lt_likp   TYPE TABLE OF lty_likp. " PGI Date

DATA : lw_vbrk   LIKE LINE OF lt_vbrk,
*       lw_vbrk TYPE vbrk,
*       lw_knvv TYPE knvv,

       l_t_waerk TYPE TABLE OF lty_waerk,
       l_s_waerk LIKE LINE OF l_t_waerk,
       lw_knvv   LIKE LINE OF lt_knvv,
*       lw_vbpa TYPE vbpa,
       lw_vbpa   LIKE LINE OF lt_vbpa,
*       lw_mara TYPE mara,
       lw_mara   LIKE LINE OF lt_mara,
*       lw_marc TYPE marc,
       lw_marc   LIKE LINE OF lt_marc,
*       lw_vbrp TYPE vbrp,
       lw_vbrp   LIKE LINE OF lt_vbrp,
       lw_tvkwz  TYPE tvkwz,
       lt_marm   TYPE STANDARD TABLE OF lty_marm,
       lw_marm1  TYPE lty_marm,
       lw_marm2  TYPE lty_marm,
       lt_vbak   TYPE TABLE OF lty_vbak, "Added by Assadulla Khan
       lw_vbak   TYPE lty_vbak, "Added by Assadulla Khan
       gt_marm   TYPE TABLE OF lty_marm, " Added by Pravin Bagul on 05.01.2015
       gw_marm   TYPE lty_marm. " Added by Pravin Bagul on 05.01.2015
*       it_t001w TYPE TABLE OF ty_t001w,"Added by Pravin Bagul on 14.10.2015
*       wa_t001w TYPE ty_t001w."Added by Pravin Bagul on 14.10.2015

DATA : lt_tvkot        TYPE STANDARD TABLE OF tvkot,
       lt_tvtwt        TYPE STANDARD TABLE OF tvtwt,
       lt_tvgrt        TYPE STANDARD TABLE OF tvgrt,
       lt_tvgrt1       TYPE STANDARD TABLE OF tvgrt,
       lt_tvkbt        TYPE STANDARD TABLE OF tvkbt,
       lt_tvkbt1       TYPE STANDARD TABLE OF tvkbt,
       lt_tvfkt        TYPE STANDARD TABLE OF tvfkt,
*       lt_kna1           TYPE STANDARD TABLE OF kna1,
       lt_kna1         TYPE TABLE OF lty_kna1,
*       lt_pa0002         TYPE STANDARD TABLE OF pa0002,
       lt_pa0002       TYPE TABLE OF lty_pa0002,
*       lt_t023t          TYPE STANDARD TABLE OF t023t,
       lt_t023t        TYPE TABLE OF lty_t023t,
       lt_wrf_brands_t TYPE STANDARD TABLE OF wrf_brands_t,
*       lt_t024d          TYPE STANDARD TABLE OF t024d,
       lt_t024d        TYPE TABLE OF lty_t024d,
       lt_twewt        TYPE STANDARD TABLE OF twewt,
*       lt_makt           TYPE STANDARD TABLE OF makt.
       lt_makt         TYPE TABLE OF lty_makt,
       lt_maktf        TYPE TABLE OF lty_makt,
       lt_mvke         TYPE TABLE OF lty_mvke,
       lw_mvke         TYPE lty_mvke.

DATA : lw_tvkot        TYPE tvkot,
       lw_tvtwt        TYPE tvtwt,
       lw_tvgrt        TYPE tvgrt,
       lw_tvkbt        TYPE tvkbt,
       lw_tvfkt        TYPE tvfkt,
*       lw_kna1           TYPE kna1,
       lw_kna1         LIKE LINE OF lt_kna1,
*       lw_pa0002         TYPE pa0002,
       lw_pa0002       LIKE LINE OF lt_pa0002,
*       lw_t023t          TYPE t023t,
       lw_t023t        LIKE LINE OF lt_t023t,
       lw_wrf_brands_t TYPE wrf_brands_t,
*       lw_t024d          TYPE t024d,
       lw_t024d        LIKE LINE OF lt_t024d,
       lw_twewt        TYPE twewt,
*       lw_makt           TYPE makt,
       lw_makt         LIKE LINE OF lt_makt,
       lv_year         TYPE char4.

DATA : lt_t151t TYPE STANDARD TABLE OF t151t,
       ls_t151t TYPE t151t.

DATA : lv_filename     LIKE gxxlt_f-file,            " Inser csc_ryugandh
       lv_header       LIKE gxxlt_p-text,
       l_s_col_text    TYPE gxxlt_v,
       l_t_col_text    TYPE TABLE OF gxxlt_v,
       l_s_online_text TYPE gxxlt_o,
       l_t_online_text TYPE TABLE OF gxxlt_o,
       l_s_print_text  TYPE gxxlt_p,
       l_t_print_text  TYPE TABLE OF gxxlt_p.

DATA : o_wgh01 TYPE TABLE OF wgh01 WITH HEADER LINE INITIAL SIZE 0.
FIELD-SYMBOLS : <fs_lw_main> TYPE ty_main.

SELECTION-SCREEN BEGIN OF BLOCK blck WITH FRAME TITLE TEXT-011.
  SELECT-OPTIONS :
* s_vbeln       FOR vbrk-vbeln ,                     " Billing Document
   s_vkorg       FOR tvko-vkorg,                      " Sales Org
   s_vtweg       FOR tvtw-vtweg,                      " Distribution Channel
* s_spart       FOR tspa-spart,                      " Division
   s_kunnr       FOR kna1-kunnr,                      " Sold to Party
   s_land1       FOR kna1-land1," OBLIGATORY,
   s_ktokd       FOR t077d-ktokd ,                "Account Group
   s_matkl       FOR t023-matkl,                      " Mechendise Catagory
   s_pernr       FOR p0001-pernr,                     " pernr
*   s_brd_id      FOR wrf_brands_t-brand_id,           " Brand
   s_dispo       FOR t024d-dispo,                     " Stock Planner
   s_vkgrp       FOR tvkgr-vkgrp,                     " Sales Group
   s_vkbur       FOR tvbur-vkbur,                     " Sales office
   s_matnr       FOR mara-matnr ,                     " Material
   s_extwg       FOR twew-extwg,                      " External Mechendise Catagory
   s_fkdat       FOR vbrk-fkdat  OBLIGATORY,
   s_ekgrp       FOR marc-ekgrp,
   s_kdgrp       FOR knvv-kdgrp,
   s_bstnk       FOR vbrk-bstnk_vf,
   s_kunrg       FOR vbrk-kunrg.          "Payer Added by Marwan 10032016

  DATA : lv_grper(16) TYPE c.

*PARAMETERS :
* p_year      TYPE vbrk-gjahr OBLIGATORY MATCHCODE OBJECT /bi0/ocalyear.                      " Year

SELECTION-SCREEN END OF BLOCK blck.

SELECTION-SCREEN : BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
  PARAMETERS:p_ziv AS CHECKBOX.
SELECTION-SCREEN: END OF BLOCK b3.


SELECTION-SCREEN : BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_local RADIOBUTTON GROUP rad1 DEFAULT 'X', "  USER-COMMAND act ,
               p_aed   RADIOBUTTON GROUP rad1, " MODIF ID m1,
               p_usd   RADIOBUTTON GROUP rad1,
               p_sar   RADIOBUTTON GROUP rad1. "Added by Assadulla Khan


SELECTION-SCREEN: END OF BLOCK b2.

DATA : gv_lines TYPE i.
DATA : gw_land  LIKE LINE OF s_land1,
       gw_vkorg LIKE LINE OF s_vkorg.

DATA : gv_flag  TYPE char1,
       gv_flag1 TYPE char1.


AT SELECTION-SCREEN.
*--start of deletion by Prajakta
*  IF p_local = 'X'.
*    IF NOT s_land1-high IS INITIAL.
*      REFRESH s_land1.
*      CLEAR s_land1.
*      MESSAGE 'Only single country can be enterd when local currency is selected' TYPE 'S'.
*      LEAVE TO SCREEN sy-dynnr.
*    ENDIF.
*
*    DESCRIBE TABLE s_land1 LINES gv_lines.
*
*    IF gv_lines GT 1.
*      REFRESH s_land1.
*      CLEAR s_land1.
*      MESSAGE 'Only single country can be enterd when local currency is selected' TYPE 'S'.
*      LEAVE TO SCREEN sy-dynnr.
**    ELSEIF gv_lines IS INITIAL.
**      REFRESH s_land1.
**      CLEAR s_land1.
**      MESSAGE 'Only single country can be enterd when local currency is selected' TYPE 'S'.
**      LEAVE TO SCREEN sy-dynnr.
*    ELSE.
*      READ TABLE s_land1 INTO gw_land INDEX 1.
*      IF sy-subrc = 0.
*        IF gw_land-option = 'BT' OR gw_land-sign = 'E'.
*          REFRESH s_land1.
*          CLEAR s_land1.
*          MESSAGE 'Only single country can be enterd when local currency is selected' TYPE 'S'.
*          LEAVE TO SCREEN sy-dynnr.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*--end of deletion by Prajakta


  SELECT vkorg FROM tvko
    INTO TABLE l_t_tvko
    WHERE vkorg IN s_vkorg.
  IF sy-subrc = 0.
    REFRESH s_vkorg.
    CLEAR s_vkorg.
    LOOP AT l_t_tvko INTO l_s_tvko.
      AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
               ID 'VKORG' FIELD l_s_tvko-vkorg
               ID 'VTWEG' DUMMY
               ID 'SPART' DUMMY
               ID 'ACTVT' FIELD '03'.
      IF sy-subrc = 0.
        s_vkorg-sign = 'I'.
        s_vkorg-option = 'EQ'.
        s_vkorg-low = l_s_tvko-vkorg.
        APPEND s_vkorg.
        CLEAR s_vkorg.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF s_vkorg[] IS INITIAL.
    MESSAGE 'You are not authorized to run this report for the entered Sales org.' TYPE 'E'.
    LEAVE TO SCREEN sy-dynnr.
  ENDIF.

*  PERFORM authority_check.
*----------------------------------------
***********************************************************************
*               START-OF-SELECTION EVENT                             *
***********************************************************************
START-OF-SELECTION.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 1
      text       = 'Getting data, Please Wait ...'.

  IF p_aed = 'X'.
    gv_curr = 'AED'.
  ELSEIF p_usd = 'X'.
    gv_curr = 'USD'.
  ELSEIF p_sar = 'X'.
    gv_curr = 'SAR'. "added by Assadulla Khan
  ELSEIF p_local = 'X'.
*    IF NOT l_s_tvko-vkorg IS INITIAL.
*      SELECT SINGLE waers FROM t001
*      INTO gv_curr
*      WHERE bukrs = l_s_tvko-vkorg.
*    ENDIF.
  ENDIF.

  PERFORM get_data.
  PERFORM fill_lt_main.

***********************************************************************
*               END-OF-SELECTION EVENT                              *
***********************************************************************

END-OF-SELECTION.
  PERFORM build_fieldcatalog.
  PERFORM display_alv_report.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  DATA : lv_date  TYPE sy-datum,
         lv_edate TYPE sy-datum.

*  CONCATENATE p_year '0101' INTO lv_date.
*  CONCATENATE p_year '1231' INTO lv_edate.

  IF p_ziv = 'X'.
    SELECT vbeln fkart waerk vkorg fkdat kunag vtweg spart kurrf fksto bstnk_vf kunrg "Marwan 20012016
    FROM   vbrk
    INTO TABLE lt_vbrk
    WHERE  vkorg IN s_vkorg
    AND    vtweg IN s_vtweg
    AND    kunag IN s_kunnr
    AND    bstnk_vf IN s_bstnk    "Marwan 20012106
    AND    kunrg IN s_kunrg       "Marwan 10032106
*    AND   ( fkart <> 'S1'  AND fkart <> 'ZF5').
      AND ( fkart <> 'ZF5'
        AND fkart <> 'B1'
        AND fkart <> 'B2'
        AND fkart <> 'B3'
        AND fkart <> 'B4'
        AND fkart <> 'F5'
        AND fkart <> 'F8' ). "Change by Assadulla Khan
*    LOOP AT LT_VBRK INTO LW_VBRK.
*      SELECT NAME1 AS NAMEP     "Desoky
*           FROM KNA1
*           INTO CORRESPONDING FIELDS OF TABLE LT_KNA1
*           FOR ALL ENTRIES IN LT_VBRK
*           WHERE  KUNNR = LT_VBRK-KUNRG.
*      MODIFY LT_VBRK FROM LW_VBRK.
*    ENDLOOP.
***************** Commeneted by Pravin Bagul on 23.03.2015************
*    IF sy-subrc = 0.
*      LOOP AT lt_vbrk INTO lw_vbrk.
*        IF lw_vbrk-fksto = 'X'.
*          IF lw_vbrk-fkart = 'ZIV' OR lw_vbrk-fkart = 'IVS'.
*          ELSE.
*            DELETE lt_vbrk.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
******************************************************************
  ELSE.
    SELECT vbeln fkart waerk vkorg fkdat kunag vtweg spart kurrf fksto bstnk_vf kunrg "Marwan 20012016
          FROM       vbrk
          INTO TABLE lt_vbrk
          WHERE
*                   vbeln IN s_vbeln      AND
                     vkorg IN s_vkorg      AND
                     vtweg IN s_vtweg      AND
*                   spart IN s_spart      AND
                     kunag    IN s_kunnr   AND
                     bstnk_vf IN s_bstnk   AND    "Marwan 20012106
                     kunrg IN s_kunrg      AND    "Marwan 10032106
*                     fksto <> 'X'          AND "  Commented by Pravin Bagul on 23.03.2015
                     ( "fkart <> 'S1'       AND "Change by Assadulla Khan
                       fkart <> 'ZF5'      AND
                       fkart <> 'IVS'
                   AND fkart <> 'B1'   "changed by Assadulla Khan
                   AND fkart <> 'B2'
                   AND fkart <> 'B3'
                   AND fkart <> 'B4'
                   AND fkart <> 'F5'
                   AND fkart <> 'F8' )."     AND
*                  fkdat in s_fkdat.
*                  fkdat BETWEEN lv_date AND lv_edate.

*    LOOP AT LT_VBRK INTO LW_VBRK.
*      SELECT NAME1 AS NAMEP     "Desoky
*           FROM KNA1
*           INTO CORRESPONDING FIELDS OF TABLE LT_KNA1
*           FOR ALL ENTRIES IN LT_VBRK
*           WHERE  KUNNR = LT_VBRK-KUNRG.
*      MODIFY LT_VBRK FROM LW_VBRK.
*    ENDLOOP.

  ENDIF.
  DELETE lt_vbrk WHERE fkdat    NOT IN s_fkdat.
  DELETE lt_vbrk WHERE bstnk_vf NOT IN s_bstnk.
  DELETE lt_vbrk WHERE kunrg    NOT IN s_kunrg.

  IF NOT lt_vbrk[] IS INITIAL.

*    SELECT * FROM tcurr
*      INTO TABLE gt_tcurr
*      FOR ALL ENTRIES IN lt_vbrk
*      WHERE "kurst = 'M' AND
*            fcurr = lt_vbrk-waerk AND
**            tcurr = 'AED'.
*            tcurr = gv_curr.
**                gdatu LE sy-datum.
*    IF sy-subrc = 0..
*
*    ENDIF.
    l_s_waerk-waerk = gv_curr.
    APPEND l_s_waerk TO l_t_waerk.
    CLEAR : lw_vbrk, l_s_waerk.

    LOOP AT lt_vbrk INTO lw_vbrk.
      l_s_waerk-waerk = lw_vbrk-waerk.
      APPEND l_s_waerk TO l_t_waerk.
      CLEAR : lw_vbrk, l_s_waerk.
    ENDLOOP.

    SORT l_t_waerk BY waerk.
    DELETE ADJACENT DUPLICATES FROM l_t_waerk COMPARING waerk.

**--start of insert by Prajakta
*    IF NOT gv_curr IS INITIAL.
*      l_s_waerk-waerk = gv_curr.
*      APPEND l_s_waerk TO l_t_waerk.
*      CLEAR : lw_vbrk, l_s_waerk.
*    ENDIF.
**--end of insert by Prajakta


    CALL FUNCTION 'Z_GET_EXCH_RATE_MULTI_CURR'
      TABLES
        e_curr  = l_t_waerk      " Exchange rates of currencies
      CHANGING
        e_tcurr = gt_tcurr. "Currencies of documents



    SELECT vbeln posnr netwr
           aubel " Added by Assadulla Khan on 16.03.2014
           matnr pstyv fkimg vrkme werks wavwr
           vkgrp " Added by Nirav
           vkbur " Added by Nirav
           vkorg_auft vtweg_auft meins
           vgbel " PGI Date
           FROM vbrp
           INTO TABLE lt_vbrp
           FOR ALL ENTRIES IN lt_vbrk
           WHERE  vbeln = lt_vbrk-vbeln .
*                  matnr IN s_matnr.
    DELETE lt_vbrp WHERE matnr NOT IN s_matnr.

*    DELETE lt_vbrp WHERE vkbur NOT IN s_vkbur.
*
*    DELETE lt_vbrp WHERE vkgrp NOT IN s_vkgrp.

    IF NOT lt_vbrp[] IS INITIAL.

*************** Added by Pravin Bagul on 05.01.2014 & 14.10.2015***********************
      SELECT matnr meinh umrez umren
        FROM marm
        INTO TABLE gt_marm
        FOR ALL ENTRIES IN lt_vbrp
        WHERE matnr = lt_vbrp-matnr
        AND   meinh = lt_vbrp-vrkme.
***************************************************************************************

*********************** Commneted by Pravin Bagul on 26.10.2015 *************
*      SELECT werks name1
*             FROM t001w
*             INTO TABLE it_t001w
*             FOR ALL ENTRIES IN lt_vbrp
*             WHERE werks = lt_vbrp-werks.

*****************************************************************************

      SELECT matnr vkorg vtweg vrkme mvgr1 mvgr2 mvgr3 mvgr4 mvgr5
        FROM mvke
        INTO TABLE lt_mvke
        FOR ALL ENTRIES IN lt_vbrp
        WHERE matnr = lt_vbrp-matnr AND
              vkorg = lt_vbrp-vkorg_auft AND
              vtweg = lt_vbrp-vtweg_auft.
      IF sy-subrc = 0.
        SELECT matnr meinh umrez umren
          FROM marm
          INTO TABLE lt_marm
          FOR ALL ENTRIES IN lt_mvke
          WHERE matnr = lt_mvke-matnr.
        IF sy-subrc = 0.

        ENDIF.

      ENDIF.

******Added by Assadulla Khan on 16.03.2014******
      SELECT vbeln audat bstnk
      FROM vbak
      INTO TABLE lt_vbak
      FOR ALL ENTRIES IN lt_vbrp
      WHERE vbeln = lt_vbrp-aubel.
*******End of add by Assadulla Khan*******

      """"""""""""""""""""""" added by M GAD """""""""""""""
        SELECT AWREF AS BILL_NO, AWITEM AS BILL_ITEM FROM ACDOCA
          INTO TABLE @LT_ACDOCA
          FOR ALL ENTRIES IN @lt_vbrp
          WHERE AWREF EQ @LT_VBRP-VBELN
          AND AWITEM EQ @LT_VBRP-POSNR
          AND RACCT IN ('0000400011','0000400012','0000400014','0000400021').

      SORT lt_acdoca BY bill_no bill_item.
      """"""""""""""""""""""" added by M GAD """""""""""""""

      " PGI Date
      SELECT vbeln wadat_ist
        FROM likp
        INTO TABLE lt_likp
        FOR ALL ENTRIES IN lt_vbrp
        WHERE vbeln = lt_vbrp-vgbel.
      SORT lt_likp BY vbeln.
    ENDIF.
    SELECT matnr matkl brand_id extwg meins fashgrd
         FROM mara
         INTO TABLE lt_mara
        WHERE matnr    IN s_matnr    AND
*              brand_id IN s_brd_id AND
              matkl    IN s_matkl    AND
              extwg    IN s_extwg.

    " For Stock Planner & Stock Planner  Desc

    SELECT *
         FROM tvkwz
         INTO TABLE lt_tvkwz
         WHERE vkorg IN s_vkorg      AND
               vtweg IN s_vtweg.

    IF NOT lt_tvkwz[] IS INITIAL.
* Changes by Parvez Khan Monday, September 14, 2015 12:44:31
      IF s_matnr[] IS INITIAL.
        SELECT matnr werks ekgrp dispo
            FROM marc
            INTO TABLE lt_marc
            FOR ALL ENTRIES IN lt_tvkwz
            WHERE  werks = lt_tvkwz-werks AND
                   matnr    IN s_matnr AND
                   ekgrp    IN s_ekgrp AND
                   dispo    IN  s_dispo.         " CSC_RYUGANDH ON sep 18
      ENDIF.
* End of Chnages by Parvez Khan Monday, September 21, 2015 13:18:11

* BOA: Parvez Khan Monday, September 21, 2015 12:44:31
* To avoid RSQL Dump which was due to above commented query
      RANGES: r_matnr FOR mara-matnr,
              r_matnr_cpy FOR mara-matnr.

      r_matnr[] = s_matnr[].
      WHILE NOT r_matnr[] IS INITIAL.
        APPEND LINES OF r_matnr[] FROM 1 TO 999 TO r_matnr_cpy[].
        DELETE r_matnr[] FROM 1 TO 999.
        SELECT matnr werks ekgrp dispo
            FROM marc
            APPENDING TABLE lt_marc
            FOR ALL ENTRIES IN lt_tvkwz
            WHERE  werks = lt_tvkwz-werks AND
                   matnr    IN r_matnr_cpy AND
                   ekgrp    IN  s_ekgrp AND
                   dispo    IN  s_dispo.
        CLEAR : r_matnr_cpy[].
      ENDWHILE.
* EOA: Parvez Khan Monday, September 21, 2015 12:44:31
    ENDIF.
    IF lt_vbrk[] IS NOT INITIAL.
      " For Pernr
      SELECT vbeln pernr
          FROM vbpa
          INTO TABLE lt_vbpa
          FOR ALL ENTRIES IN lt_vbrk
          WHERE  vbeln = lt_vbrk-vbeln AND
                 pernr IN s_pernr AND           " CSC_RYUGANDH on sep 18
                 ( parvw = 'SE' OR
                   parvw = 'VE' ).
*                 parvw = 'AG'.
    ENDIF.

    " For Sales Org Desc
    SELECT *
          FROM tvkot
          INTO TABLE lt_tvkot
          WHERE vkorg IN s_vkorg AND
                  spras = 'E' .
    " DC Desc
    SELECT *
          FROM tvtwt
          INTO TABLE lt_tvtwt
          WHERE vtweg IN s_vtweg AND
                  spras = 'E' .

    " For Sales Group & Sales office

    IF lt_vbrk[] IS NOT INITIAL.
      SELECT kunnr vkorg vtweg spart kdgrp vkgrp vkbur kvgr1 kvgr2 kvgr3 kvgr4 kvgr5 " kvgr1 kvgr2 kvgr3 Added by Pravin Bagul on 13.11.2014
             FROM knvv
             INTO TABLE lt_knvv
             FOR ALL ENTRIES IN lt_vbrk
             WHERE  vkorg = lt_vbrk-vkorg AND
                    kunnr = lt_vbrk-kunag    AND
                    vtweg = lt_vbrk-vtweg  AND                      " Distribution Channel
                    spart = lt_vbrk-spart AND
                    kdgrp IN s_kdgrp.

    ENDIF.

    IF NOT lt_knvv[] IS INITIAL.

      SELECT * FROM t151t INTO TABLE lt_t151t
              FOR ALL ENTRIES IN lt_knvv
              WHERE kdgrp = lt_knvv-kdgrp
                AND spras = sy-langu.
*Start of changes by Nirav

      " for Sales Group Description

      SELECT *
          FROM tvgrt
          INTO TABLE lt_tvgrt1
          FOR ALL ENTRIES IN lt_knvv
          WHERE vkgrp =  lt_knvv-vkgrp AND
                spras = 'E'.

      " For Sales Office Description

      SELECT *
          FROM tvkbt
          INTO TABLE lt_tvkbt1
          FOR ALL ENTRIES IN lt_knvv
          WHERE vkbur =  lt_knvv-vkbur AND
                spras = 'E' .

************* Added by Pravin Bagul on 19.11.2014 ************
      SELECT kvgr1 bezei
                    FROM tvv1t
                    INTO TABLE it_gr1
                    FOR ALL ENTRIES IN lt_knvv
                    WHERE spras = 'E'
                    AND  kvgr1 = lt_knvv-kvgr1.

      SELECT kvgr2 bezei
                   FROM tvv2t
                   INTO TABLE it_gr2
                   FOR ALL ENTRIES IN lt_knvv
                   WHERE spras = 'E'
                   AND  kvgr2 = lt_knvv-kvgr2.

      SELECT kvgr3 bezei
                   FROM tvv3t
                   INTO TABLE it_gr3
                   FOR ALL ENTRIES IN lt_knvv
                   WHERE spras = 'E'
                   AND  kvgr3 = lt_knvv-kvgr3.

      SELECT kvgr4 bezei
                   FROM tvv4t
                   INTO TABLE it_gr4
                   FOR ALL ENTRIES IN lt_knvv
                   WHERE spras = 'E'
                   AND  kvgr4 = lt_knvv-kvgr4.

      SELECT kvgr5 bezei
                   FROM tvv5t
                   INTO TABLE it_gr5
                   FOR ALL ENTRIES IN lt_knvv
                   WHERE spras = 'E'
                   AND  kvgr5 = lt_knvv-kvgr5.

****************************************************************

    ENDIF.
*End of changes by Nirav

    IF NOT lt_vbrp[] IS INITIAL.


      " for Sales Group Description

      SELECT *
          FROM tvgrt
          INTO TABLE lt_tvgrt
          FOR ALL ENTRIES IN lt_vbrp
          WHERE vkgrp =  lt_vbrp-vkgrp AND
                spras = 'E'.

      " For Sales Office Description

      SELECT *
          FROM tvkbt
          INTO TABLE lt_tvkbt
          FOR ALL ENTRIES IN lt_vbrp
          WHERE vkbur =  lt_vbrp-vkbur AND
                spras = 'E' .

    ENDIF.

    SELECT *
           FROM tvfkt
           INTO TABLE lt_tvfkt
           FOR ALL ENTRIES IN lt_vbrk
           WHERE  fkart = lt_vbrk-fkart    AND
                  spras = 'E' .

    SELECT kunnr land1 name1 ktokd
         FROM kna1
         INTO TABLE lt_kna1
         FOR ALL ENTRIES IN lt_vbrk
         WHERE  kunnr = lt_vbrk-kunag
         AND    land1 IN s_land1
         AND    ktokd IN s_ktokd.

    IF lt_kna1 IS NOT  INITIAL.
      SELECT *
       FROM t077x INTO TABLE l_t_t077x
       FOR ALL ENTRIES IN lt_kna1
       WHERE ktokd = lt_kna1-ktokd
       AND   spras   = sy-langu.
    ENDIF.

    IF NOT  lt_vbpa[] IS INITIAL.

      SELECT pernr vorna nachn
           FROM pa0002
           INTO TABLE lt_pa0002
           FOR ALL ENTRIES IN lt_vbpa
           WHERE  pernr = lt_vbpa-pernr.

    ENDIF.

    IF NOT lt_mara[] IS INITIAL.

      SELECT matkl wgbez
           FROM t023t
           INTO TABLE lt_t023t
           FOR ALL ENTRIES IN lt_mara
           WHERE  matkl = lt_mara-matkl.

*      SELECT *
*           FROM wrf_brands_t
*           INTO TABLE lt_wrf_brands_t
**           FOR ALL ENTRIES IN lt_mara
*           WHERE  "brand_id = lt_mara-brand_id AND  " csc_ryugandh sep 18
*                brand_id IN s_brd_id AND
*                  language = 'EN' .
      SELECT *
            FROM twewt
            INTO TABLE lt_twewt
            FOR ALL ENTRIES IN lt_mara
            WHERE  extwg = lt_mara-extwg AND
                   spras = 'E' .
    ENDIF.

    IF NOT lt_marc[] IS INITIAL.
      SELECT werks dispo dsnam
           FROM t024d
           INTO TABLE lt_t024d
           FOR ALL ENTRIES IN lt_marc
           WHERE  dispo = lt_marc-dispo
                AND werks = lt_marc-werks.     " Inser csc_ryugandh on sep 18

    ENDIF.

    IF NOT lt_vbrp[] IS INITIAL.

      SELECT matnr maktx
             spras         "ECDK910782(+)
           FROM makt
           INTO TABLE lt_makt
           FOR ALL ENTRIES IN lt_vbrp
           WHERE  matnr = lt_vbrp-matnr.

      SELECT matnr maktx
           FROM makt
           INTO TABLE lt_maktf
           FOR ALL ENTRIES IN lt_vbrp
           WHERE  matnr = lt_vbrp-matnr
             AND spras = 'FR'.
    ENDIF.

*Start of changes by csc_abap on 26.9.13 for Inc 7000002684
    SELECT * FROM t6wfgt
      INTO TABLE lt_t6wfgt
      FOR ALL ENTRIES IN lt_mara
      WHERE fashgrd = lt_mara-fashgrd
            AND spras = 'E'.
*Start of changes by csc_abap on 26.9.13 for Inc 7000002684

  ENDIF.

ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  FILL_LT_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_lt_main .
  DATA : lv_month(2),
        lv_tabix TYPE sy-tabix.

  DATA : lv_exch_rate TYPE c.

  SORT:lt_vbrp BY vbeln posnr,
       lt_vbrk BY vbeln,
       lt_tvkot BY vkorg,
       lt_tvtwt BY vtweg,
       lt_knvv  BY kunnr vkorg vtweg spart,
       lt_tvgrt BY vkgrp,
       lt_tvgrt1 BY vkgrp, "added by Nirav
       lt_tvkbt1 BY vkbur, "added by Nirav
       lt_tvkbt BY vkbur,
       lt_tvfkt BY fkart,
       lt_kna1 BY kunnr,
       l_t_t077x BY ktokd,
       lt_vbpa BY vbeln,
       lt_pa0002 BY pernr,
       lt_mara  BY matnr,
       lt_t023t BY matkl,
       lt_wrf_brands_t BY brand_id,
       lt_twewt BY extwg,
       lt_marc BY matnr werks,
       lt_t024d BY werks dispo,
*       lt_makt BY matnr. "ECDK910782(-)
       lt_vbak BY vbeln, "Added by Assadulla Khan
       it_gr1 BY kvgr1, " Added by Pravin Bagul on 19.11.2014
       it_gr2 BY kvgr2, " Added by Pravin Bagul on 19.11.2014
       it_gr3 BY kvgr3, " Added by Pravin Bagul on 19.11.2014
       it_gr4 BY kvgr4, " Added by Pravin Bagul on 19.11.2014
       it_gr5 BY kvgr5, " Added by Pravin Bagul on 19.11.2014
       gt_marm BY matnr meinh. " Added by Pravin Bagul on 05.01.2015
*       it_t001w BY werks. "Added by Pravin Bagul on 14.10.2015

  SORT lt_makt BY matnr spras."ECDK910782(+)

  CLEAR lv_tabix.

*  LOOP AT gt_tcurr INTO gw_tcurr .
*
*    lv_tabix = lv_tabix + 1.
*
*    CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
*      EXPORTING
*        input  = gw_tcurr-gdatu
*      IMPORTING
*        output = gv_date1.
*    CALL FUNCTION 'CONVERSION_EXIT_PDATE_INPUT'
*      EXPORTING
*        input        = gv_date1
*      IMPORTING
*        output       = gw_tcurr-gdatu
*      EXCEPTIONS
*        invalid_date = 1
*        OTHERS       = 2.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.
**    MODIFY gt_tcurr FROM gw_tcurr INDEX sy-tabix TRANSPORTING gdatu.
*    MODIFY gt_tcurr FROM gw_tcurr INDEX lv_tabix TRANSPORTING gdatu.
*    CLEAR gw_tcurr.
*  ENDLOOP.

  IF lt_mvke IS NOT INITIAL.
    SELECT mvgr1,
           bezei
      FROM tvm1t
      INTO TABLE @DATA(lt_tvm1t)
      FOR ALL ENTRIES IN @lt_mvke
      WHERE spras = 'E'
       AND  mvgr1 = @lt_mvke-mvgr1.

    SELECT mvgr2,
           bezei
      FROM tvm2t
      INTO TABLE @DATA(lt_tvm2t)
      FOR ALL ENTRIES IN @lt_mvke
      WHERE spras = 'E'
       AND  mvgr2 = @lt_mvke-mvgr2.

    SELECT mvgr3,
           bezei
      FROM tvm3t
      INTO TABLE @DATA(lt_tvm3t)
      FOR ALL ENTRIES IN @lt_mvke
      WHERE spras = 'E'
       AND  mvgr3 = @lt_mvke-mvgr3.

    SELECT mvgr4,
           bezei
      FROM tvm4t
      INTO TABLE @DATA(lt_tvm4t)
      FOR ALL ENTRIES IN @lt_mvke
      WHERE spras = 'E'
       AND  mvgr4 = @lt_mvke-mvgr4.

    SELECT mvgr5,
           bezei
      FROM tvm5t
      INTO TABLE @DATA(lt_tvm5t)
      FOR ALL ENTRIES IN @lt_mvke
      WHERE spras = 'E'
       AND  mvgr5 = @lt_mvke-mvgr5.
  ENDIF.

  DELETE gt_tcurr WHERE gdatu GT sy-datum.
  "-----add by by badr 19-3-2018 .
  SORT gt_tcurr DESCENDING .

  LOOP AT lt_vbrp INTO lw_vbrp.



*Start of changes by Nirav
    CLEAR : gw_tcurr, gv_flag, gv_flag1.
    READ TABLE lt_vbrk INTO lw_vbrk WITH KEY vbeln = lw_vbrp-vbeln BINARY SEARCH.

*    LOOP AT gt_tcurr INTO gw_tcurr WHERE fcurr = lw_vbrk-waerk AND
*                                           tcurr = gv_curr.
*      IF  lw_vbrk-fkdat GE gw_tcurr-gdatu AND lw_vbrk-fkdat LE sy-datum.
*        gv_flag = 'X'.
*        EXIT.
*      ENDIF.
*      CLEAR gw_tcurr.
*    ENDLOOP.
*
*    IF gv_flag NE 'X'.
*      CLEAR gw_tcurr.
*
*      LOOP AT gt_tcurr INTO gw_tcurr WHERE fcurr = gv_curr AND
*                                             tcurr = lw_vbrk-waerk.
*
*        IF  lw_vbrk-fkdat GE gw_tcurr-gdatu AND lw_vbrk-fkdat LE sy-datum.
*          gv_flag1 = 'X'.
*          EXIT.
*        ENDIF.
*        CLEAR gw_tcurr.
*      ENDLOOP.
*    ENDIF.

*    IF gv_flag NE 'X'.
*      IF gv_flag1 NE 'X'.
*        gw_tcurr-ukurs = 1.
*      ELSE.
*        gw_tcurr-ukurs  = 1 / gw_tcurr-ukurs .
*      ENDIF.
*    ENDIF.

    lv_exrate = lw_vbrp-netwr * gw_tcurr-ukurs.
*    lw_vbrp-netwr = lv_exrate.

******Added by Assadull Khan on 16.03.2014******
    READ TABLE lt_vbak INTO lw_vbak WITH KEY vbeln = lw_vbrp-aubel.
    IF sy-subrc = 0.
      lw_main-order_no = lw_vbak-vbeln.
      lw_main-order_date = lw_vbak-audat.
    ENDIF.
**********End of add by Assadulla Khan**********

    READ TABLE lt_kna1 INTO lw_kna1 WITH KEY kunnr = lw_vbrk-kunag  BINARY SEARCH.
    IF sy-subrc = 0.
      "  Customer Name
      READ TABLE l_t_t077x INTO l_s_t077x WITH KEY ktokd = lw_kna1-ktokd BINARY SEARCH.

      lw_main-name1 = lw_kna1-name1.
      lw_main-land1 = lw_kna1-land1.
      "Account Group and Description
      lw_main-ktokd = lw_kna1-ktokd.
      lw_main-txt30 = l_s_t077x-txt30.
    ELSE.
      CLEAR : lw_vbrp, lw_kna1, lw_vbrk, lw_vbak.
      CONTINUE.

    ENDIF.

*End of changes by Nirav

    READ TABLE lt_marc INTO lw_marc WITH KEY matnr = lw_vbrp-matnr werks = lw_vbrp-werks BINARY SEARCH.
    IF sy-subrc NE 0.
      CLEAR : lw_marc, lw_vbrp.
      CONTINUE.
    ELSE.
      lw_main-ekgrp = lw_marc-ekgrp.
    ENDIF.
    CLEAR lw_marc.

*    READ TABLE lt_vbrk INTO lw_vbrk WITH KEY vbeln = lw_vbrp-vbeln BINARY SEARCH. " Commeneted BY Nirav

    " Billing Doc
    lw_main-vbeln = lw_vbrp-vbeln.
    lw_main-pstyv = lw_vbrp-pstyv.
    "Currency
    lw_main-waerk = lw_vbrk-waerk.

    "Billing Date

    lw_main-fkdat = lw_vbrk-fkdat.
    lv_year = lw_vbrk-fkdat(4).

    "Year
    lw_main-year = lv_year.

    " Sales Org
    IF sy-subrc = 0.
      lw_main-vkorg = lw_vbrk-vkorg.

      lv_month =  lw_vbrk-fkdat+4(2).


      CASE lv_month.
        WHEN '01'.
*          lw_main-jan = lw_vbrk-netwr.
*          lw_main-q1  = lw_vbrk-netwr.
          lw_main-qrt = 'Q1'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '01' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Jan'.
        WHEN '02'.
*          lw_main-feb = lw_vbrk-netwr.
*          lw_main-q1  = lw_vbrk-netwr.
          lw_main-qrt = 'Q1'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '02' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Feb'.
        WHEN '03'.
*          lw_main-mar = lw_vbrk-netwr.
*          lw_main-q1  = lw_vbrk-netwr.
          lw_main-qrt = 'Q1'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '03' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Mar'.
        WHEN '04'.
*          lw_main-april = lw_vbrk-netwr.
*          lw_main-q2    = lw_vbrk-netwr.
          lw_main-qrt = 'Q2'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '04' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Apr'.
        WHEN '05'.
*          lw_main-may = lw_vbrk-netwr.
*          lw_main-q2    = lw_vbrk-netwr.
          lw_main-qrt = 'Q2'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '05' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'May'.
        WHEN '06'.
*          lw_main-june = lw_vbrk-netwr.
*          lw_main-q2    = lw_vbrk-netwr.
          lw_main-qrt = 'Q2'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '06' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Jun'.
        WHEN '07'.
*          lw_main-july = lw_vbrk-netwr.
*          lw_main-q3    = lw_vbrk-netwr.
          lw_main-qrt = 'Q3'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '07' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Jul'.
        WHEN '08'.
*          lw_main-aug = lw_vbrk-netwr.
*          lw_main-q3    = lw_vbrk-netwr.
          lw_main-qrt = 'Q3'.
          lw_main-netwr   = lw_vbrp-netwr.
          lw_main-month = 'Aug'.
*          CONCATENATE '08' '/' lv_year    INTO lw_main-month .
        WHEN '09'.
*          lw_main-sept = lw_vbrk-netwr.
*          lw_main-q3    = lw_vbrk-netwr.
          lw_main-qrt = 'Q3'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '09' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Sep'.
        WHEN '10'.
*          lw_main-oct = lw_vbrk-netwr.
*          lw_main-q4    = lw_vbrk-netwr.
          lw_main-qrt = 'Q4'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '10' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Oct'.
        WHEN '11'.
*          lw_main-nov = lw_vbrk-netwr.
*          lw_main-q4    = lw_vbrk-netwr.
          lw_main-qrt = 'Q4'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '11' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Nov'.
        WHEN '12'.
*          lw_main-dec = lw_vbrk-netwr.
*          lw_main-q4    = lw_vbrk-netwr.
          lw_main-qrt = 'Q4'.
          lw_main-netwr   = lw_vbrp-netwr.
*          CONCATENATE '12' '/' lv_year    INTO lw_main-month .
          lw_main-month = 'Dec'.
      ENDCASE.

    ENDIF.

*    lw_main-netsales = lw_vbrk-netwr.
    READ TABLE lt_tvkot INTO lw_tvkot WITH KEY vkorg = lw_vbrk-vkorg BINARY SEARCH.
    " Sales Org Text
    IF sy-subrc = 0.
      lw_main-vtext = lw_tvkot-vtext.
    ENDIF.

    " Distribution Channel
    lw_main-vtweg = lw_vbrk-vtweg.

    READ TABLE lt_tvtwt INTO lw_tvtwt WITH KEY vtweg = lw_vbrk-vtweg BINARY SEARCH.
    " Distribution Channel Desc
    IF sy-subrc = 0.
      lw_main-vtext_dc = lw_tvtwt-vtext.
    ENDIF.

    READ TABLE lt_knvv INTO lw_knvv WITH KEY  kunnr = lw_vbrk-kunag
                                              vkorg = lw_vbrk-vkorg
                                              vtweg = lw_vbrk-vtweg
                                              spart = lw_vbrk-spart BINARY SEARCH.
*Start of changes by Nirav
    IF sy-subrc = 0.
*      " Sales Group
*      lw_main-vkgrp = lw_knvv-vkgrp.
*      " Sales office
*      lw_main-vkbur = lw_knvv-vkbur.
      lw_main-kdgrp = lw_knvv-kdgrp.
      lw_main-kvgr1 = lw_knvv-kvgr1. "Added by Pravin Bagul on 13.11.2014
      lw_main-kvgr2 = lw_knvv-kvgr2. "Added by Pravin Bagul on 13.11.2014
      lw_main-kvgr3 = lw_knvv-kvgr3. "Added by Pravin Bagul on 13.11.2014
      lw_main-kvgr4 = lw_knvv-kvgr4. "Added by Pravin Bagul on 13.11.2014
      lw_main-kvgr5 = lw_knvv-kvgr5. "Added by Pravin Bagul on 13.11.2014
    ELSE.
      CLEAR: lw_main-kdgrp ,lw_main-kvgr1, lw_main-kvgr2, lw_main-kvgr3, lw_main-kvgr4, lw_main-kvgr5.
    ENDIF.

********* Added by Pravin Bagul on 19.11.2014*********************************
    " For Customer Group Description

    READ TABLE it_gr1 INTO wa_gr1 WITH KEY kvgr1 = lw_knvv-kvgr1 BINARY SEARCH.
    IF sy-subrc = 0.
      lw_main-lv_gr1 = wa_gr1-bezei.
    ENDIF.

    READ TABLE it_gr2 INTO wa_gr2 WITH KEY kvgr2 = lw_knvv-kvgr2 BINARY SEARCH.
    IF sy-subrc = 0.
      lw_main-lv_gr2 = wa_gr2-bezei.
    ENDIF.

    READ TABLE it_gr3 INTO wa_gr3 WITH KEY kvgr3 = lw_knvv-kvgr3 BINARY SEARCH.
    IF  sy-subrc = 0.
      lw_main-lv_gr3 = wa_gr3-bezei.
    ENDIF.

    READ TABLE it_gr4 INTO wa_gr4 WITH KEY kvgr4 = lw_knvv-kvgr4 BINARY SEARCH.
    IF sy-subrc = 0.
      lw_main-lv_gr4 = wa_gr4-bezei.
    ENDIF.

    READ TABLE it_gr5 INTO wa_gr5 WITH KEY kvgr5 = lw_knvv-kvgr5 BINARY SEARCH.
    IF  sy-subrc = 0.
      lw_main-lv_gr5 = wa_gr5-bezei.
    ENDIF.
********************************************************************************

    lw_main-meins = lw_vbrp-meins. " Added by Pravin Bagul on 25.11.2014

    READ TABLE lt_t151t INTO ls_t151t WITH KEY kdgrp = lw_knvv-kdgrp.
    IF sy-subrc = 0.
      lw_main-ktext = ls_t151t-ktext.
    ELSE.
      CLEAR lw_main-ktext.
    ENDIF.


    CLEAR lw_tvgrt.
    " Sales Grop and Sales Group Desc
    IF NOT lw_vbrp-vkgrp IS INITIAL.
      lw_main-vkgrp = lw_vbrp-vkgrp.
      READ TABLE lt_tvgrt INTO lw_tvgrt WITH KEY vkgrp =  lw_vbrp-vkgrp  BINARY SEARCH.

      IF sy-subrc = 0.
        lw_main-bezei = lw_tvgrt-bezei.
      ENDIF.

    ELSE.
      lw_main-vkgrp = lw_knvv-vkgrp.
      READ TABLE lt_tvgrt1 INTO lw_tvgrt WITH KEY vkgrp =  lw_knvv-vkgrp BINARY SEARCH.

      IF sy-subrc = 0.
        lw_main-bezei = lw_tvgrt-bezei.
      ENDIF.
    ENDIF.

    CLEAR lw_tvkbt.
*sales office and Sales office description
    IF NOT lw_vbrp-vkbur IS INITIAL.
      lw_main-vkbur = lw_vbrp-vkbur.
      READ TABLE lt_tvkbt INTO lw_tvkbt WITH KEY vkbur =  lw_vbrp-vkbur BINARY SEARCH.
      " Sales office Desc
      IF sy-subrc = 0.
        lw_main-bezei_so = lw_tvkbt-bezei.
      ENDIF.
    ELSE.
      lw_main-vkbur = lw_knvv-vkbur.
      READ TABLE lt_tvkbt1 INTO lw_tvkbt WITH KEY vkbur =  lw_knvv-vkbur BINARY SEARCH.
      " Sales office Desc
      IF sy-subrc = 0.
        lw_main-bezei_so = lw_tvkbt-bezei.
      ENDIF.
    ENDIF.


*    READ TABLE lt_tvgrt INTO lw_tvgrt WITH KEY vkgrp =  lw_knvv-vkgrp BINARY SEARCH.
*    " Sales Group Desc
*    IF sy-subrc = 0.
*      lw_main-bezei = lw_tvgrt-bezei.
*    ENDIF.
*
*    READ TABLE lt_tvkbt INTO lw_tvkbt WITH KEY vkbur =  lw_knvv-vkbur BINARY SEARCH.
*    " Sales office Desc
*    IF sy-subrc = 0.
*      lw_main-bezei_so = lw_tvkbt-bezei.
*    ENDIF.

*    READ TABLE lt_tvgrt INTO lw_tvgrt WITH KEY vkgrp =  lw_vbrp-vkgrp.
*    " Sales Group Desc
*    IF sy-subrc = 0.
*      lw_main-bezei = lw_tvgrt-bezei.
*    ENDIF.
*
*    READ TABLE lt_tvkbt INTO lw_tvkbt WITH KEY vkbur =  lw_vbrp-vkbur.
*    " Sales office Desc
*    IF sy-subrc = 0.
*      lw_main-bezei_so = lw_tvkbt-bezei.
*    ENDIF.

*End of changes by Nirav

    " Billing Type
    lw_main-fkart = lw_vbrk-fkart.
    READ TABLE lt_tvfkt INTO lw_tvfkt WITH KEY fkart = lw_vbrk-fkart BINARY SEARCH.
    " Billing Desc
    IF sy-subrc = 0.
      lw_main-vtext_bill =  lw_tvfkt-vtext.
    ENDIF.

    " Customer
    lw_main-kunag = lw_vbrk-kunag.
    "Payer No. Desoky
    lw_main-kunrg = lw_vbrk-kunrg.

*      BREAK-POINT.
    SELECT SINGLE name1 AS namep     "Desoky
     FROM kna1
     INTO CORRESPONDING FIELDS OF lw_kna1
     WHERE  kunnr = lw_main-kunrg.
    lw_main-namep = lw_kna1-namep.
*Start of changes by Nirav
*    READ TABLE lt_kna1 INTO lw_kna1 WITH KEY kunnr = lw_vbrk-kunag  BINARY SEARCH.
*    IF sy-subrc = 0.
*      "  Customer Name
*      READ TABLE l_t_t077x INTO l_s_t077x WITH KEY ktokd = lw_kna1-ktokd BINARY SEARCH.
*      lw_main-name1 = lw_kna1-name1.
*      "Account Group and Description
*      lw_main-ktokd = lw_kna1-ktokd.
*      lw_main-txt30 = l_s_t077x-txt30.
*    ENDIF.
*End of changes by Nirav


    READ TABLE lt_vbpa INTO lw_vbpa WITH KEY vbeln = lw_vbrk-vbeln BINARY SEARCH.
    IF sy-subrc = 0 OR ( p_ziv = 'X' AND lw_vbrk-fkart = 'ZIV')
    OR ( p_ziv = 'X' AND lw_vbrk-fkart = 'IVS'). "Added by Prajakta
      " Sales Employee No
      lw_main-pernr = lw_vbpa-pernr.
*    ENDIF.

      READ TABLE lt_pa0002 INTO lw_pa0002 WITH KEY pernr = lw_vbpa-pernr BINARY SEARCH.
      IF sy-subrc = 0.
        " Sales Employee Full Name
        CONCATENATE lw_pa0002-vorna
                    lw_pa0002-nachn
         INTO lw_main-cname SEPARATED BY space.

      ENDIF.
    ENDIF.
    READ TABLE lt_mara INTO lw_mara WITH KEY matnr = lw_vbrp-matnr BINARY SEARCH.
    IF sy-subrc = 0.
      " Mechendise Catagory
      lw_main-matkl = lw_mara-matkl.

*Start of changes by csc_abap on 26.9.13 for Inc 7000002684
      lw_main-fashgrd = lw_mara-fashgrd.

      READ TABLE lt_t6wfgt  INTO lw_t6wfgt WITH KEY fashgrd = lw_mara-fashgrd.
      IF sy-subrc = 0.
        lw_main-sub_brd_desc = lw_t6wfgt-vtext.
      ENDIF.

*End of changes by csc_abap on 26.9.13 for Inc 7000002684

      READ TABLE lt_t023t INTO lw_t023t WITH KEY matkl = lw_mara-matkl BINARY SEARCH.
      IF sy-subrc = 0.
        " Mechendise Catagory Desc
        lw_main-wgbez = lw_t023t-wgbez.
      ENDIF.

      " Brand
*        lw_main-brand_id = lw_mara-brand_id. "--Chanakya
      lw_main-brand_id = lw_mara-matkl.  "++Chanakya
      lw_main-brd_desc = lw_t023t-wgbez.
*        READ TABLE lt_wrf_brands_t INTO lw_wrf_brands_t WITH KEY brand_id = lw_mara-brand_id .
*        IF sy-subrc = 0.
      " Brand Desc
*          lw_main-brd_desc = lw_wrf_brands_t-brand_descr. "--Chanakya
*      ENDIF.        " csc_ryugandh on sep 18

      " External Mechendise
      lw_main-extwg = lw_mara-extwg.
      READ TABLE lt_twewt INTO lw_twewt WITH KEY extwg = lw_mara-extwg .
      IF sy-subrc = 0.
        " External Mechendise Desc
        lw_main-ewbez = lw_twewt-ewbez.
      ENDIF.

*        ENDIF.

      READ TABLE lt_marc INTO lw_marc WITH KEY matnr = lw_vbrp-matnr werks = lw_vbrp-werks BINARY SEARCH.
      IF sy-subrc = 0.
        " Stock Planner
        lw_main-dispo  = lw_marc-dispo.

*    ENDIF.     " csc_ryugandh on sep 18

        READ TABLE lt_t024d INTO lw_t024d WITH KEY werks = lw_vbrp-werks
                                                   dispo = lw_marc-dispo BINARY SEARCH.
        IF sy-subrc = 0.
          " Stock Planner Name
          lw_main-dsnam  = lw_t024d-dsnam.

        ENDIF.

        " Article
        lw_main-matnr  = lw_vbrp-matnr.
*ECDK910782 start of deletion
*          READ TABLE lt_makt INTO lw_makt WITH KEY matnr = lw_vbrp-matnr BINARY SEARCH.
*          IF sy-subrc = 0.
*            " Article Desc
*            lw_main-maktx  = lw_makt-maktx.
*
*          ENDIF.
*ECDK910782 end of deletion
*ECDK910782 start of insertion
        READ TABLE lt_makt INTO lw_makt WITH KEY matnr = lw_vbrp-matnr spras = 'EN' BINARY SEARCH.
        IF sy-subrc <> 0.
          READ TABLE lt_makt INTO lw_makt WITH KEY matnr = lw_vbrp-matnr spras = 'AR' BINARY SEARCH.
        ENDIF.
        lw_main-maktx  = lw_makt-maktx.
*ECDK910782 end of insertion
        READ TABLE lt_maktf INTO lw_makt WITH KEY matnr = lw_vbrp-matnr BINARY SEARCH.
        IF sy-subrc = 0.
          " Article Desc in FR
          lw_main-maktxf  = lw_makt-maktx.
        ENDIF.
        " Billed Quantity
        " Cost
        "Net Value
        "Added by Assadulla Khan 11.08.2014
        IF ( lw_vbrk-fksto = 'X' )
        OR ( lw_vbrk-fkart = 'CBRE'
        OR lw_vbrk-fkart = 'G2' ).
          lw_main-fkimg  = lw_vbrp-fkimg * -1.
          lw_main-netwr  = lw_vbrp-netwr * -1.
        ELSE.
          lw_main-fkimg  = lw_vbrp-fkimg.
          lw_main-netwr  = lw_vbrp-netwr.
        ENDIF.
        "End of add by Assadulla Khan

        IF lw_vbrk-fkart NE 'ZRE'.
          lw_main-fkimg  = lw_vbrp-fkimg.
          lw_main-netwr  = lw_vbrp-netwr.
          lw_main-wavwr  = lw_vbrp-wavwr.
        ELSE.
          lw_main-fkimg  = lw_vbrp-fkimg * -1.
          lw_main-netwr  = lw_vbrp-netwr * -1.
          lw_main-wavwr  = lw_vbrp-wavwr * -1.
        ENDIF.

******************* Added by Pravin Bagul on 25.05.2015 & 27.10.2015 ****************

        IF lw_vbrk-fkart = 'S1' OR
           lw_vbrk-fkart = 'G2' OR
           lw_vbrk-fkart = 'CBRE'.


          lw_main-fkimg  = lw_vbrp-fkimg * -1.
          lw_main-netwr  = lw_vbrp-netwr * -1.
*************BOA Parvez khan 5.7.15
************* Cost negative
          lw_main-wavwr  = lw_vbrp-wavwr * -1.
*************EOA Parvez Khan.
        ENDIF.
***********************************************************************

        IF lw_vbrk-fkart = 'G2' OR      " nage7 12022017
        lw_vbrk-fkart = 'CBRE' OR
        lw_vbrk-fkart = 'S1'  .
          lw_main-netwr = lw_vbrp-netwr * -1 .
*        lw_main-gmval = lw_vbrp-gmval * -1 .
*        lw_main-base_quan = lw_vbrp-base_quan * -1 .
          lw_main-wavwr = lw_vbrp-wavwr * -1 .
          lw_main-fkimg = lw_vbrp-fkimg * -1 .

        ENDIF.
*************************************************************************




        " Sales Unit

*          lw_main-vrkme  = lw_vbrp-vrkme. " Added by Pravin Bagul on 1.7.2015 & Commented by Pravin Bagul on 10.9.2015

******************************************************************
        " PO

*          lw_main-bstnk_vf  = lw_vbrk-bstnk_vf. "  Added by Marwan Al-Tawansy on 20012016
        lw_main-bstnk_vf  = lw_vbak-bstnk. "  Added by Chanakya

*********************** Commented by Pravin Bagul on 1.7.2015  & Added by Pravin Bagul on 10.9.2015 ***********

        CLEAR lw_mvke.

        READ TABLE lt_mvke INTO lw_mvke WITH KEY matnr = lw_vbrp-matnr
                                                 vkorg = lw_vbrp-vkorg_auft
                                                 vtweg = lw_vbrp-vtweg_auft.
        IF sy-subrc = 0.
          lw_main-mvgr1 = lw_mvke-mvgr1.
          lw_main-mvgr2 = lw_mvke-mvgr2.
          lw_main-mvgr3 = lw_mvke-mvgr3.
          lw_main-mvgr4 = lw_mvke-mvgr4.
          lw_main-mvgr5 = lw_mvke-mvgr5.

          IF line_exists( lt_tvm1t[ mvgr1 = lw_mvke-mvgr1 ] ).
            DATA(ls_mvgr1) = lt_tvm1t[ mvgr1 = lw_mvke-mvgr1 ].
            lw_main-bezei1 = ls_mvgr1-bezei.
          ENDIF.

          IF line_exists( lt_tvm2t[ mvgr2 = lw_mvke-mvgr2 ] ).
            DATA(ls_mvgr2) = lt_tvm2t[ mvgr2 = lw_mvke-mvgr2 ].
            lw_main-bezei2 = ls_mvgr2-bezei.
          ENDIF.

          IF line_exists( lt_tvm3t[ mvgr3 = lw_mvke-mvgr3 ] ).
            DATA(ls_mvgr3) = lt_tvm3t[ mvgr3 = lw_mvke-mvgr3 ].
            lw_main-bezei3 = ls_mvgr3-bezei.
          ENDIF.

          IF line_exists( lt_tvm4t[ mvgr4 = lw_mvke-mvgr4 ] ).
            DATA(ls_mvgr4) = lt_tvm4t[ mvgr4 = lw_mvke-mvgr4 ].
            lw_main-bezei4 = ls_mvgr4-bezei.
          ENDIF.

          IF line_exists( lt_tvm5t[ mvgr5 = lw_mvke-mvgr5 ] ).
            DATA(ls_mvgr5) = lt_tvm5t[ mvgr5 = lw_mvke-mvgr5 ].
            lw_main-bezei5 = ls_mvgr5-bezei.
          ENDIF.



          IF lw_vbrp-vrkme = lw_mvke-vrkme.

            lw_main-vrkme  = lw_vbrp-vrkme.
          ELSE.
            IF NOT lw_mvke-vrkme IS INITIAL.

              lw_main-vrkme = lw_mvke-vrkme.

              CLEAR lw_marm1.
              READ TABLE lt_marm INTO lw_marm1 WITH KEY matnr = lw_vbrp-matnr
                                                       meinh = lw_vbrp-vrkme.

              CLEAR lw_marm2.
              READ TABLE lt_marm INTO lw_marm2 WITH KEY matnr = lw_vbrp-matnr
                                                        meinh = lw_mvke-vrkme.

              IF NOT lw_marm2-umren IS INITIAL.
                lw_main-fkimg = lw_main-fkimg * ( lw_marm1-umrez / lw_marm2-umrez ).
              ENDIF.

            ELSE. " blank from MVKE
              CLEAR lw_mara.
              READ TABLE lt_mara INTO lw_mara WITH KEY matnr = lw_vbrp-matnr.

              IF lw_vbrp-vrkme = lw_mara-meins.
                lw_main-vrkme  = lw_vbrp-vrkme.
              ELSE.

                lw_main-vrkme = lw_mara-meins.

                CLEAR lw_marm1.
                READ TABLE lt_marm INTO lw_marm1 WITH KEY matnr = lw_vbrp-matnr
                                                         meinh = lw_vbrp-vrkme.

                CLEAR lw_marm2.
                READ TABLE lt_marm INTO lw_marm2 WITH KEY matnr = lw_vbrp-matnr
                                                          meinh = lw_mara-meins.

                IF NOT lw_marm2-umren IS INITIAL.
                  lw_main-fkimg = lw_main-fkimg * ( lw_marm1-umrez / lw_marm2-umrez ).
                ENDIF.
              ENDIF.
            ENDIF.

          ENDIF.
        ELSE.
        ENDIF.
********************************** Commented by Pravin Bagul on 1.7.2015 ************

*          IF ( p_aed = 'X' OR p_usd = 'X' ) AND NOT gt_tcurr[] IS INITIAL.
*            CLEAR gw_tcurr.
*            READ TABLE gt_tcurr INTO gw_tcurr WITH KEY fcurr = lw_vbrk-waerk.
*            IF sy-subrc = 0.
*              IF gw_tcurr-ukurs < 0.
*                gw_tcurr-ukurs = gw_tcurr-ukurs *  -1.
*                gw_tcurr-ukurs = 1 / gw_tcurr-ukurs.
*              ENDIF.
*
*              IF lw_vbrk-waerk = 'KWD' OR
*                 lw_vbrk-waerk = 'OMR' OR
*                 lw_vbrk-waerk = 'BHD'.
*                lw_main-netwr = lw_main-netwr / 10.
*                lw_main-wavwr = lw_main-wavwr / 10.
*              ENDIF.
*
*              lw_main-netwr = lw_main-netwr * gw_tcurr-ukurs.
*              lw_main-wavwr = lw_main-wavwr * gw_tcurr-ukurs.
**              lw_main-waerk = 'AED'.
*              lw_main-waerk = gv_curr.
*            ENDIF.
*
*          ENDIF.

****************** Added by Pravin Bagul on 05.01.2015 **************************
        READ TABLE gt_marm INTO gw_marm WITH KEY matnr = lw_vbrp-matnr  meinh = lw_vbrp-vrkme BINARY SEARCH.
        IF sy-subrc = 0.

          lw_main-base_quan = lw_vbrp-fkimg * ( gw_marm-umrez / gw_marm-umren ).
          IF lw_main-fkimg LT 0.  "Added by Parvez to make neagativity w.r to Invoice
            lw_main-base_quan = lw_main-base_quan * -1.
          ENDIF.
        ENDIF.
*********************************************************************************
************************** Commneted by Pravin Bagul on 26.10.2015 *********

*          lw_main-werks = lw_vbrp-werks.
*
*          READ TABLE it_t001w INTO wa_t001w WITH KEY werks = lw_vbrp-werks BINARY SEARCH.
*          IF sy-subrc = 0.
*
*            lw_main-name1_t = wa_t001w-name1.
*
*          ENDIF.
******************************************************************************
        READ TABLE LT_ACDOCA INTO DATA(LS_ACDOCA) WITH KEY bill_no = lw_vbrp-VBELN bill_item = lw_vbrp-posnr BINARY SEARCH.
        IF SY-SUBRC EQ 0.
          LW_MAIN-GL_NETWR = LW_MAIN-NETWR.
        ENDIF.

        CLEAR : LS_ACDOCA.

        " PGI Date
        READ TABLE lt_likp INTO DATA(ls_likp) WITH KEY vbeln = lw_vbrp-vgbel BINARY SEARCH.
        IF sy-subrc EQ 0.
          lw_main-wadat_ist = ls_likp-wadat_ist.
        ENDIF.
        CLEAR : ls_likp.

        COLLECT lw_main INTO lt_main.

        CLEAR : lw_main,
                lw_vbrk ,
                lw_knvv ,
                lw_vbpa ,
                lw_mara ,
                lw_marc ,
                lw_vbrp ,
                lw_tvkwz,
                lw_tvkot,
                lw_tvtwt,
                lw_tvgrt,
                lw_tvkbt,
                lw_tvfkt,
                lw_kna1,
                lw_pa0002,
                lw_t023t,
                lw_wrf_brands_t,
                lw_t024d,
                lw_twewt,
                lw_makt,
                wa_gr1, " Added by Pravin Bagul on 19.11.2014
                wa_gr2, " Added by Pravin Bagul on 19.11.2014
                wa_gr3, " Added by Pravin Bagul on 19.11.2014
                gw_marm." Added by Pravin Bagul on 05.01.2015
*                  wa_t001w.
      ENDIF.       " CSC_RYUGANDH on sep 18
    ENDIF.
*    ENDIF.
  ENDLOOP.

  IF s_kdgrp[] IS NOT INITIAL.
    DELETE lt_main WHERE kdgrp NOT IN s_kdgrp.
  ENDIF.
  IF s_vkbur[] IS NOT INITIAL.
    DELETE lt_main WHERE vkbur NOT IN s_vkbur.
  ENDIF.
  IF s_vkgrp[] IS NOT INITIAL.
    DELETE lt_main WHERE vkgrp NOT IN s_vkgrp.
  ENDIF.

  IF s_bstnk[] IS NOT INITIAL.        "  Added by Marwan Al-Tawansy on 20012016
    DELETE lt_main WHERE bstnk_vf NOT IN s_bstnk.
  ENDIF.

  IF s_kunrg[] IS NOT INITIAL.        "  Added by Marwan Al-Tawansy on 10032016
    DELETE lt_main WHERE kunrg NOT IN s_kunrg.
  ENDIF.

* Insert csc_ryugandh on Feb 13

*--start of addition by Prajakta
*  SORT gt_tcurr BY gdatu DESCENDING.

  IF p_local = 'X'.
    IF NOT lt_main IS INITIAL.
      SELECT * FROM t001
      INTO TABLE lt_t001
      FOR ALL ENTRIES IN lt_main
      WHERE bukrs = lt_main-vkorg.
    ENDIF.
  ENDIF.
*--end of addition by Prajakta

  LOOP AT lt_main INTO lw_main.
    IF ( p_aed = 'X' OR p_usd = 'X' OR p_sar = 'X' ) AND NOT gt_tcurr[] IS INITIAL.
      CLEAR gw_tcurr.
*      READ TABLE gt_tcurr INTO gw_tcurr WITH KEY fcurr = lw_main-waerk.
      LOOP AT gt_tcurr INTO gw_tcurr WHERE fcurr = lw_main-waerk AND
                                           tcurr = gv_curr.
        IF  lw_main-fkdat GE gw_tcurr-gdatu AND lw_main-fkdat LE sy-datum.
          EXIT.
        ENDIF.
        CLEAR gw_tcurr.
      ENDLOOP.
      IF gw_tcurr IS NOT INITIAL."sy-subrc = 0.
        IF gw_tcurr-ukurs < 0.
          gw_tcurr-ukurs = gw_tcurr-ukurs *  -1.
          gw_tcurr-ukurs = 1 / gw_tcurr-ukurs.
        ENDIF.

        IF lw_main-waerk = 'KWD' OR
           lw_main-waerk = 'OMR' OR
           lw_main-waerk = 'BHD' OR
           lw_main-waerk = 'TND'. "Changes done by Assadulla Khan on 20.04.2014
          lw_main-netwr = lw_main-netwr / 10.
          lw_main-wavwr = lw_main-wavwr / 10.
        ENDIF.

        lw_main-netwr = lw_main-netwr * gw_tcurr-ukurs.
        lw_main-wavwr = lw_main-wavwr * gw_tcurr-ukurs.
*              lw_main-waerk = 'AED'.
        lw_main-waerk = gv_curr.
      ELSE.
        lw_main-waerk = ' '."gv_curr.
      ENDIF.

    ENDIF.

*--start of insertion by Prajakta
    IF p_local = 'X'.
      READ TABLE lt_vbrk INTO lw_vbrk WITH KEY vbeln = lw_main-vbeln.
      IF sy-subrc = 0.
        lw_main-netwr = lw_main-netwr * lw_vbrk-kurrf.
        lw_main-wavwr = lw_main-wavwr * lw_vbrk-kurrf.
      ENDIF.

      READ TABLE lt_t001 INTO ls_t001 WITH KEY bukrs = lw_main-vkorg.
      IF sy-subrc = 0.
        lw_main-waerk = ls_t001-waers.

*        IF lw_main-waerk = 'KWD' OR
*           lw_main-waerk = 'OMR' OR
*           lw_main-waerk = 'BHD'.
*          lw_main-netwr = lw_main-netwr / 10.
*          lw_main-wavwr = lw_main-wavwr / 10.
*        ENDIF.
      ENDIF.
    ENDIF.
*--end of insertion by Prajakta



* Gross Margin Value
    lw_main-gmval = lw_main-netwr - lw_main-wavwr.

* Gross Margin Percentage
    IF NOT lw_main-netwr IS INITIAL.
      lv_grper = ( lw_main-netwr - lw_main-wavwr ) / lw_main-netwr.
      lv_grper = lv_grper * 100.
      MOVE lv_grper TO lw_main-gmper.
*      lw_main-gmper = lw_main-gmper * 100.
    ENDIF.

*    MODIFY TABLE lt_main FROM lw_main.
    MODIFY lt_main FROM lw_main TRANSPORTING netwr wavwr
                                             waerk gmval
                                             gmper.

    CLEAR lw_main.
  ENDLOOP.
*End Insert csc_ryugandh on Feb 13
*BOA: Parvez Khan MC hierarchical include Sunday, September 27, 2015 15:14:28
  LOOP AT lt_main ASSIGNING <fs_lw_main>.

*added by Hossam 09/01/2017
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = <fs_lw_main>-vrkme
        language       = sy-langu
      IMPORTING
*       LONG_TEXT      =
        output         = <fs_lw_main>-vrkme
*       SHORT_TEXT     =
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = <fs_lw_main>-meins
        language       = sy-langu
      IMPORTING
*       LONG_TEXT      =
        output         = <fs_lw_main>-meins
*       SHORT_TEXT     =
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION 'MERCHANDISE_GROUP_HIER_ART_SEL'
      EXPORTING
        matkl       = <fs_lw_main>-matkl
        spras       = sy-langu
      TABLES
        o_wgh01     = o_wgh01[]
      EXCEPTIONS
        no_basis_mg = 1
        no_mg_hier  = 2
        OTHERS      = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE o_wgh01 WITH KEY stufe = '01'. "level 1
    <fs_lw_main>-wwgha2 = o_wgh01-wwgha.
    <fs_lw_main>-wwghb2 = o_wgh01-wwghb.
    CLEAR o_wgh01.
    READ TABLE o_wgh01 WITH KEY stufe = '02'. "Level 2
    <fs_lw_main>-wwgha3 = o_wgh01-wwgha.
    <fs_lw_main>-wwghb3 = o_wgh01-wwghb.
    CLEAR o_wgh01.
    READ TABLE o_wgh01 WITH KEY stufe = '03'. "level 1
    <fs_lw_main>-wwgha4 = o_wgh01-wwgha.
    <fs_lw_main>-wwghb4 = o_wgh01-wwghb.
    CLEAR o_wgh01.
    READ TABLE o_wgh01 WITH KEY stufe = '04'. "Level 2
    <fs_lw_main>-wwgha5 = o_wgh01-wwgha.
    <fs_lw_main>-wwghb5 = o_wgh01-wwghb.
    CLEAR o_wgh01.

    REFRESH : o_wgh01[].

  ENDLOOP.
*EOA: Parvez Khan MC hierarchical include Sunday, September 27, 2015 15:14:28
ENDFORM.                    " FILL_LT_MAIN
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog .

*  -Fill field catalog table
  PERFORM fill_field_cat USING:

                   'VBELN'             '13'     'Billing Doc'              '' '' '' '' '' 'L' '' 'X',
                   'FKDAT'             '14'     'Billing Date'              '' '' '' '' '' 'L' '' 'X',

                   'VKORG'             '10'     'Sales Org'                '' '' '' '' '' 'L' '' 'X',
                   'VTEXT'             '20'     'Sales Org desc'           '' '' '' '' '' 'L' '' 'X',

                   'BSTNK_VF'          '10'     'PO'                       '' '' '' '' '' 'L' '' 'X', "Marwan 20012016

*                   'WAERK'             '10'     'Currency'                 '' '' '' 'X' '' 'L' '' '',

                   'VTWEG'             '10'     'Distribution Channel'     '' '' '' '' '' 'L' '' '',
                   'ORDER_NO'          '15'     'Sales Order No.'          '' '' '' '' '' 'L' '' '',
                   'ORDER_DATE'        '15'     'Sales Order Date'         '' '' '' '' '' 'L' '' '',
                   'VTEXT_DC'          '15'     'DC Desc'                  '' '' '' '' '' 'L' '' '',

                   'VKGRP'             '12'     'Sales Group'              '' '' '' '' '' 'L' '' '',
                   'BEZEI'             '20'     'Sales Group Desc'         '' '' '' '' '' 'L' '' '',

                   'VKBUR'             '10'     'Sales office'             '' '' '' '' '' 'L' '' '',
                   'BEZEI_SO'          '20'     'Sales office Desc'        '' '' '' '' '' 'L' '' '',

                   'FKART'             '10'     'Billing Type'             '' '' '' '' '' 'L' '' '',
                   'VTEXT_BILL'        '20'     'Billing Desc'             '' '' '' '' '' 'L' '' '',

                   'KUNAG'             '10'     'Customer'                 '' '' '' '' '' 'L' '' '',
                   'NAME1'             '20'     'Customer Name'            '' '' '' '' '' 'L' '' '',
                   'LAND1'             '20'     'Customers Country'            '' '' '' '' '' 'L' '' '',

                   'KUNRG'             '10'     'Payer'                 '' '' '' '' '' 'L' '' '',      "Desoky
                   'NAMEP'             '20'     'Payer Name'            '' '' '' '' '' 'L' '' '',      "Desoky


                   'KTOKD'           '20'     'Customer Account Group'                 '' '' '' '' '' 'L' '' '',
                   'TXT30'           '30'      'Customer Account Group Description'            '' '' '' '' '' 'L' '' '',

                   'PERNR'             '10'     'Sales Emp No'             '' '' '' '' '' 'L' '' '',
                   'CNAME'             '20'     'Sales Emp Name'           '' '' '' '' '' 'L' '' '',

                   'MVGR1'             '20'     'MG Level 1'      '' '' '' '' '' 'L' '' '',
                   'BEZEI1'            '25'     'MG Desc Level 1' '' '' '' '' '' 'L' '' '',

                   'MVGR2'             '10'     'MG Level 2'      '' '' '' '' '' 'L' '' '',
                   'BEZEI2'             '20'     'MG Desc Level 2' '' '' '' '' '' 'L' '' '',

                   'MVGR3'             '10'     'MG Level 3'      '' '' '' '' '' 'L' '' '',
                   'BEZEI3'             '20'     'MG Desc Level 3' '' '' '' '' '' 'L' '' '',

                   'MVGR4'             '10'     'MG Level 4'      '' '' '' '' '' 'L' '' '',
                   'BEZEI4'             '20'     'MG Desc Level 4' '' '' '' '' '' 'L' '' '',

                   'MVGR5'             '10'     'MG Level 5'      '' '' '' '' '' 'L' '' '',
                   'BEZEI5'             '20'     'MG Desc Level 5' '' '' '' '' '' 'L' '' '',

                   'BRAND_ID'          '10'     'Material Group'                    '' '' '' '' '' 'L' '' '',
                   'BRD_DESC'          '20'     'Material Group Description'               '' '' '' '' '' 'L' '' '',

*Start of changes by csc_abap on 26.9.13 for Inc 7000002684
*                    'FASHGRD'          '10'     'Sub Brand'                    '' '' '' '' '' 'L' '' '',
*                    'SUB_BRD_DESC'     '20'     'Sub Brand Desc'               '' '' '' '' '' 'L' '' '',
*End of changes by csc_abap on 26.9.13 for Inc 7000002684

                   'DISPO'             '20'     'Material Controller'            '' '' '' '' '' 'L' '' '',
                   'DSNAM'             '20'     'Material Controller Name'       '' '' '' '' '' 'L' '' '',

                   'EXTWG'             '20'     'External Material Group'      '' '' '' '' '' 'L' '' '',
                   'EWBEZ'             '25'     'External Material Group Desc' '' '' '' '' '' 'L' '' '',

                   'MATNR'             '10'     'Material'                  '' '' '' '' '' 'L' '' '',
                   'MAKTX'             '20'     'Material Desc'             '' '' '' '' '' 'L' '' '',
                   'MAKTXF'             '20'     'Material Desc(FR)'             '' '' '' '' '' 'L' '' '',
                   'PSTYV'             '20'     'Item Category'             '' '' '' '' '' 'L' '' '',

                   'FKIMG'             '20'     'Billed Quantity'          '' '' '' '' '' 'R' '' '',
                   'VRKME'             '10'     'Sales UOM'                     '' '' '' '' '' 'L' '' ''.

  IF sy-tcode = 'ZSDR025'.
    PERFORM fill_field_cat USING:
                       'WAVWR'             '10'     'Cost'                     '' '' '' '' '' 'R' 'WAERK' ''.
  ENDIF.
  PERFORM fill_field_cat USING:
                     'MONTH'              '10'     'Month'                  '' '' '' '' '' 'L' '' '',
                     'QRT'                '10'     'Quarter'              '' '' '' '' '' 'L' '' '',
                     'YEAR'               '10'     'Year'                   '' '' '' '' '' 'L' '' '',
                     'NETWR'             '10'     'Net Value'               '' '' '' '' '' 'R' 'WAERK' '',
                     'WAERK'             '10'     'Currency'               '' '' '' 'X' '' 'L' '' '',
                     'EKGRP'             '15'     'Purchasing Group'         '' '' '' '' '' 'L' '' '',
*                     'GMVAL'             '10'     'Gross Margin Value'               '' '' '' '' '' 'R' 'WAERK' '',
*                     'GMPER'             '10'     'Gross Margin Percentage'  '' '2' '' '' '' 'R' '' '',
*                   'KDGRP'             '20'     'Cust Group Code'         '' '' '' '' '' 'L' '' '',
                     'KVGR1'             '15'     'Customer group 1'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 13.11.2014
                     'LV_GR1'            '15'     'Customer Gr1 Dsc'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 19.11.2014
                     'KVGR2'             '15'     'Customer group 2'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 13.11.2014
                     'LV_GR2'            '15'     'Customer Gr2 Dsc'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 19.11.2014
                     'KVGR3'             '15'     'Customer group 3'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 13.11.2014
                     'LV_GR3'            '15'     'Customer Gr3 Dsc'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 19.11.2014
                     'KVGR4'             '15'     'Customer group 4'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 13.11.2014
                     'LV_GR4'            '15'     'Customer Gr4 Dsc'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 19.11.2014
                     'KVGR5'             '15'     'Customer group 5'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 13.11.2014
                     'LV_GR5'            '15'     'Customer Gr5 Dsc'        '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 19.11.2014
                     'KTEXT'             '20'     'Customer Group'          '' '' '' '' '' 'L' '' '',
                     'MEINS'             '20'     'Base UOM'                '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 25.11.2014
                     'BASE_QUAN'         '20'     'Base Quantity'           '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 05.01.2015
                     'GL_NETWR'             '10'     'Net Value for Specific GL'               '' '' '' '' '' 'R' 'WAERK' '',
                     'WADAT_IST'         '15'     'Post Goods Issue Date'   '' '' '' '' '' 'L' '' ''.
                    " GL_NETWR
*                   'WERKS'             '20'     'Site'                    '' '' '' '' '' 'L' '' '', "Added by Pravin Bagul on 14.10.2015
*                   'NAME1_T'           '20'     'Site Description'        '' '' '' '' '' 'L' '' ''. "Added by Pravin Bagul on 14.10.2015
*                   'JAN'               '10'     'January'                  '' '' '' '' '' 'L',
*                   'FEB'               '10'     'February'                 '' '' '' '' '' 'L',
*                   'MAR'               '10'     'March'                    '' '' '' '' '' 'L',
*                   'Q1'                '10'     'Quarter1'                '' '' '' '' '' 'L',

*                   'APRIL'             '10'     'April'                    '' '' '' '' '' 'L',
*                   'MAY'               '10'     'May'                      '' '' '' '' '' 'L',
*                   'JUNE'              '10'     'June'                     '' '' '' '' '' 'L',
*                   'Q2'                '10'     'Quarter 2'                '' '' '' '' '' 'L',
*
*                   'JULY'              '10'     'July'                     '' '' '' '' '' 'L',
*                   'AUG'               '10'     'August'                   '' '' '' '' '' 'L',
*                   'SEPT'              '10'     'September'                '' '' '' '' '' 'L',
*                   'Q3'                '10'     'Quarter 3'                '' '' '' '' '' 'L',
*
*                   'OCT'               '10'     'October'                  '' '' '' '' '' 'L',
*                   'NOV'               '10'     'November'                 '' '' '' '' '' 'L',
*                   'DEC'               '10'     'December'                 '' '' '' '' '' 'L',
*                   'Q4'                '10'     'Quarter 4'                '' '' '' '' '' 'L',
*                   'NETSALES'          '20'     'Net Sales Till Date'      '' '' '' '' '' 'L'.

ENDFORM.                    " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_report .

*  CALL FUNCTION 'XXL_FULL_API'
*    EXPORTING
**     DATA_ENDING_AT          = -1
**     DATA_STARTING_AT        = 1
*     FILENAME                = 'Test'
**     HEADER_1                = ' '
**     HEADER_2                = ' '
**     NO_DIALOG               = 'X'
**     NO_START                = ' '
*      n_att_cols              = 38
*      n_hrz_keys              = 1
*      n_vrt_keys              = 3
**     SEMA_TYPE               = ' '
**     SO_TITLE                = ' '
*    TABLES
*      data                    = lt_main
*      hkey                    =
*      online_text             =
*      print_text              =
*      sema                    =
*      vkey                    =
**   EXCEPTIONS
**     CANCELLED_BY_USER       = 1
**     DATA_TOO_BIG            = 2
**     DIM_MISMATCH_DATA       = 3
**     DIM_MISMATCH_SEMA       = 4
**     DIM_MISMATCH_VKEY       = 5
**     ERROR_IN_HKEY           = 6
**     ERROR_IN_SEMA           = 7
**     FILE_OPEN_ERROR         = 8
**     FILE_WRITE_ERROR        = 9
**     INV_DATA_RANGE          = 10
**     INV_WINSYS              = 11
**     INV_XXL                 = 12
**     OTHERS                  = 13
*            .
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       = ' '
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'ZPFAPPROVE'      " Inser csc_ryugandh
      i_callback_user_command  = 'USER_COMMAND'    " Inser csc_ryugandh
*     I_CALLBACK_TOP_OF_PAGE   = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME         = I_STRUCTURE_NAME
*     I_BACKGROUND_ID          = ' '
*     I_GRID_TITLE             = I_GRID_TITLE
*     I_GRID_SETTINGS          = I_GRID_SETTINGS
*     IS_LAYOUT                = IS_LAYOUT
      it_fieldcat              = it_fieldcat[]
*     IT_EXCLUDING             = IT_EXCLUDING
*     IT_SPECIAL_GROUPS        = IT_SPECIAL_GROUPS
*     IT_SORT                  = IT_SORT
*     IT_FILTER                = IT_FILTER
*     IS_SEL_HIDE              = IS_SEL_HIDE
*     I_DEFAULT                = 'X'
      i_save                   = 'A'
*     IS_VARIANT               = IS_VARIANT
*     IT_EVENTS                = IT_EVENTS
*     IT_EVENT_EXIT            = IT_EVENT_EXIT
*     is_print                 = w_print
*     IS_REPREP_ID             = IS_REPREP_ID
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*     I_HTML_HEIGHT_TOP        = 0
*     I_HTML_HEIGHT_END        = 0
*     IT_ALV_GRAPHICS          = IT_ALV_GRAPHICS
*     IT_HYPERLINK             = IT_HYPERLINK
*     IT_ADD_FIELDCAT          = IT_ADD_FIELDCAT
*     IT_EXCEPT_QINFO          = IT_EXCEPT_QINFO
*     IR_SALV_FULLSCREEN_ADAPTER        = IR_SALV_FULLSCREEN_ADAPTER
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  = E_EXIT_CAUSED_BY_CALLER
*     ES_EXIT_CAUSED_BY_USER   = ES_EXIT_CAUSED_BY_USER
    TABLES
      t_outtab                 = lt_main
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " DISPLAY_ALV_REPORT


*&---------------------------------------------------------------------*
*&      Form  fill_field_cat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FIELDNAME    text
*      -->LENGTH       text
*      -->DESCRIPTION  text
*      -->DATATYPE     text
*      -->DECIMALS     text
*      -->SUMMATION    text
*      -->NO_OUT       text
*      -->EDIT         text
*      -->JUST         text
*----------------------------------------------------------------------*
FORM fill_field_cat  USING   fieldname
                              length
                              description
                              datatype
                              decimals
                              summation
                              no_out
                              edit
                              just
                              ref_field
                              key.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = fieldname.
  it_fieldcat-outputlen = length.
  it_fieldcat-seltext_l = description.
  it_fieldcat-datatype = datatype.
  it_fieldcat-decimals_out = decimals.
  it_fieldcat-do_sum = summation.
  it_fieldcat-no_out = no_out.
  it_fieldcat-just   = just.
  it_fieldcat-edit  = edit.
  it_fieldcat-cfieldname = ref_field.
*  it_fieldcat-no_out = &5.
  it_fieldcat-ctabname = 'LT_MAIN'.
  it_fieldcat-key    = key.
  APPEND it_fieldcat.

ENDFORM.                    " FILL_FIELD_CAT

*&---------------------------------------------------------------------*
*&      Form  zpfapprove
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM zpfapprove USING rt_extab TYPE slis_t_extab.      " Inser csc_ryugandh
  SET PF-STATUS 'ZSTANDARD'.
ENDFORM.                    "pfAPPROVE


*----------------------------------------------------------------------*
FORM user_command USING ucomm LIKE sy-ucomm            " Inser csc_ryugandh
               dj_selfield TYPE slis_selfield.
  DATA:lv_ucomm TYPE sy-ucomm.
  BREAK-POINT.
  lv_ucomm = ucomm.
  CASE lv_ucomm.
    WHEN 'PIVOT'.
      PERFORM  download_pivot.
      SET SCREEN 0.
      LEAVE TO LIST-PROCESSING.
  ENDCASE.
  CLEAR lv_ucomm.
ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  download_pivot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM download_pivot.           " Inser csc_ryugandh

  DATA lv_counter TYPE i.
  lv_filename = 'ASR.xls'.
  lv_header = 'Article Sales Report'.

*  l_s_col_text-col_no = '1'.
*  l_s_col_text-col_name = 'Billing Doc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '2'.
*  l_s_col_text-col_name = 'Billing Date'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '3'.
*  l_s_col_text-col_name = 'Sales Org'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '4'.
*  l_s_col_text-col_name = 'Sales Org desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '5'.
*  l_s_col_text-col_name = 'Distribution Channel'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '6'.
*  l_s_col_text-col_name = 'DC Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '7'.
*  l_s_col_text-col_name = 'Sales Group'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '8'.
*  l_s_col_text-col_name = 'Sales Group Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '9'.
*  l_s_col_text-col_name = 'Sales office'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '10'.
*  l_s_col_text-col_name = 'Sales office Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '11'.
*  l_s_col_text-col_name = 'Billing Type'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '12'.
*  l_s_col_text-col_name = 'Billing Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '13'.
*  l_s_col_text-col_name = 'Customer'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '14'.
*  l_s_col_text-col_name = 'Customer Name'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '15'.
*  l_s_col_text-col_name = 'Customer Country'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '16'.
*  l_s_col_text-col_name = 'Customer Account Group'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '17'.
*  l_s_col_text-col_name = 'Customer Account Group Description'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '18'.
*  l_s_col_text-col_name = 'Sales Emp No'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*
*  l_s_col_text-col_no = '19'.
*  l_s_col_text-col_name = 'Sales Emp Fnam'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '20'.
*  l_s_col_text-col_name = 'Sales Emp Lnam'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*
*
*  l_s_col_text-col_no = '21'.
*  l_s_col_text-col_name = 'Sales Emp Name'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '22'.
*  l_s_col_text-col_name = 'Mechendise Catagory'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '23'.
*  l_s_col_text-col_name = 'Mechendise Catagory Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '24'.
*  l_s_col_text-col_name = 'Brand'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '25'.
*  l_s_col_text-col_name = 'Brand Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '26'.
*  l_s_col_text-col_name = 'Stock Planner'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '27'.
*  l_s_col_text-col_name = 'Stock Planner Name'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '28'.
*  l_s_col_text-col_name = 'External Mechendise'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '29'.
*  l_s_col_text-col_name = 'External Mechendise Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '30'.
*  l_s_col_text-col_name = 'Article'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '31'.
*  l_s_col_text-col_name = 'Article Desc'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '32'.
*  l_s_col_text-col_name = 'Article Desc(FR)'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '33'.
*  l_s_col_text-col_name = 'Billed Quantity'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '34'.
*  l_s_col_text-col_name = 'Sales UOM'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '35'.
*  l_s_col_text-col_name = 'Cost'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '36'.
*  l_s_col_text-col_name = 'Month'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '37'.
*  l_s_col_text-col_name = 'Quarter'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '38'.
*  l_s_col_text-col_name = 'Year'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '39'.
*  l_s_col_text-col_name = 'Cuurency'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '40'.
*  l_s_col_text-col_name = 'Net Value'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '41'.
*  l_s_col_text-col_name = 'Central Planner'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '42'.
*  l_s_col_text-col_name = 'Gross Margin Value'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '43'.
*  l_s_col_text-col_name = 'Gross Margin Percentage'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '44'.
*  l_s_col_text-col_name = 'Cust Group Code'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  l_s_col_text-col_no = '45'.
*  l_s_col_text-col_name = 'Customer Group'.
*  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no =   lv_counter.
  l_s_col_text-col_name = 'Billing Doc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Billing Date'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Org'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Org desc'.
  APPEND l_s_col_text TO l_t_col_text.


  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Distribution Channel'.
  APPEND l_s_col_text TO l_t_col_text.

*--start of addition of changes
  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Order No'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Order Date'.
  APPEND l_s_col_text TO l_t_col_text.
*--end of addition of changes

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'DC Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Group'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Group Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales office'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales office Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Billing Type'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Billing Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer Name'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer Country'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Payer'.        "Desoky
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Payer Name'.   "Desoky
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer Account Group'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer Account Group Description'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Emp No'.
  APPEND l_s_col_text TO l_t_col_text.


  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Emp Fnam'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Emp Lnam'.
  APPEND l_s_col_text TO l_t_col_text.


  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales Emp Name'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Level 1'."'Mechendise Catagory'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Desc Level 1'."'Mechendise Catagory Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Level 2'."'Mechendise Catagory'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Desc Level 2'."'Mechendise Catagory Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Level 3'."'Mechendise Catagory'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Desc Level 3'."'Mechendise Catagory Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Level 4'."'Mechendise Catagory'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Desc Level 4'."'Mechendise Catagory Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Level 5'."'Mechendise Catagory'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'MC Desc Level 5'."'Mechendise Catagory Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Brand'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Brand Desc'.
  APPEND l_s_col_text TO l_t_col_text.

*  ADD 1 TO lv_counter.
*  l_s_col_text-col_no = lv_counter.
*  l_s_col_text-col_name = 'Sub Brand'.
*  APPEND l_s_col_text TO l_t_col_text.
*
*  ADD 1 TO lv_counter.
*  l_s_col_text-col_no = lv_counter.
*  l_s_col_text-col_name = 'Sub Brand Desc'.
*  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Stock Planner'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Stock Planner Name'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'External Mechendise'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'External Mechendise Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Article'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Article Desc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Article Desc(FR)'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Billed Quantity'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Sales UOM'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Cost'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Month'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Quarter'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Year'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Cuurency'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Net Value'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Central Planner'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Gross Margin Value'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Gross Margin Percentage'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Cust Group Code'.
  APPEND l_s_col_text TO l_t_col_text.

********** Added by Pravin Bagul on 13.11.2014 & 19.11.2014 *************
  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer group 1'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer gr1 Dsc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer group 2'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer gr2 Dsc'.
  APPEND l_s_col_text TO l_t_col_text.


  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer group 3'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer gr3 Dsc'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer group 4'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer gr4 Dsc'.
  APPEND l_s_col_text TO l_t_col_text.


  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer group 5'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer gr5 Dsc'.
  APPEND l_s_col_text TO l_t_col_text.

************************************************************

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Customer Group'.
  APPEND l_s_col_text TO l_t_col_text.

*********** Added by Pravin Bagul on 25.11.2014 *************

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Base UOM'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter.
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'Base Quantity'.
  APPEND l_s_col_text TO l_t_col_text.

  ADD 1 TO lv_counter."hablas
  l_s_col_text-col_no = lv_counter.
  l_s_col_text-col_name = 'PO number'.
  APPEND l_s_col_text TO l_t_col_text.
*
*  ADD 1 TO lv_counter.
*  l_s_col_text-col_no = lv_counter.
*  l_s_col_text-col_name = 'Site Description'.
*  APPEND l_s_col_text TO l_t_col_text.

**************************************************************
  REFRESH: l_t_col_text.
  LOOP AT it_fieldcat INTO DATA(ls_fcat).
    APPEND VALUE #( col_no = sy-tabix
                    col_name = ls_fcat-seltext_l ) TO l_t_col_text.
    CLEAR: ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'XXL_SIMPLE_API'
    EXPORTING
      filename          = lv_filename
      header            = lv_header
      n_key_cols        = 1
    TABLES
      col_text          = l_t_col_text
      data              = lt_main
      online_text       = l_t_online_text
      print_text        = l_t_print_text
    EXCEPTIONS
      dim_mismatch_data = 1
      file_open_error   = 2
      file_write_error  = 3
      inv_winsys        = 4
      inv_xxl           = 5
      OTHERS            = 6.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "download_pivot
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check .
  DATA: gt_tvko TYPE STANDARD TABLE OF tvko,
        gs_tvko TYPE tvko.
  SELECT * FROM tvko INTO TABLE gt_tvko
                     WHERE vkorg IN s_vkorg.
  LOOP AT gt_tvko INTO gs_tvko.
    AUTHORITY-CHECK OBJECT 'ZRPT1'
                       ID 'ACTVT' FIELD '03'
                       ID 'BUKRS' DUMMY
                       ID 'VKORG' FIELD gs_tvko-vkorg
                       ID 'LAND1' DUMMY
                       ID 'ZBRAND' DUMMY
                       ID 'WERKS' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Sales Org' TYPE 'E'.
    ENDIF.
  ENDLOOP.
*  DATA: gt_brand TYPE STANDARD TABLE OF wrf_brands,
*        gs_brand TYPE wrf_brands.
*  SELECT * FROM wrf_brands INTO TABLE gt_brand
*                     WHERE brand_id IN s_brd_id.
*  LOOP AT gt_brand INTO gs_brand.
*    AUTHORITY-CHECK OBJECT 'ZRPT1'
*                       ID 'ACTVT' FIELD '03'
*                       ID 'BUKRS' DUMMY
*                       ID 'VKORG' DUMMY
*                       ID 'LAND1' DUMMY
*                       ID 'ZBRAND' FIELD gs_brand-brand_id
*                       ID 'WERKS' DUMMY.
*    IF sy-subrc <> 0.
*      MESSAGE 'You are not authorized to view given Brand' TYPE 'E'.
*    ENDIF.
*  ENDLOOP.

  DATA: gt_tvtw TYPE STANDARD TABLE OF tvtw,
        gs_tvtw TYPE tvtw.

  SELECT * FROM tvtw INTO TABLE gt_tvtw
                     WHERE vtweg IN s_vtweg.

  LOOP AT gt_tvtw INTO gs_tvtw.

    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' FIELD gs_tvtw-vtweg
                       ID 'VKBUR' DUMMY
                       ID 'VKGRP' DUMMY
                       ID 'DISPO' DUMMY
                       ID 'EKGRP' DUMMY
                       ID 'PERNR' DUMMY
                       ID 'KDGRP' DUMMY
                       ID 'ZKTOKL' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Dist Channel' TYPE 'E'.
    ENDIF.

  ENDLOOP.

  DATA: gt_t005 TYPE STANDARD TABLE OF t005,
        gs_t005 TYPE t005.

  SELECT * FROM t005 INTO TABLE gt_t005
                     WHERE land1 IN s_land1.

  LOOP AT gt_t005 INTO gs_t005.

    AUTHORITY-CHECK OBJECT 'ZRPT1'
                       ID 'ACTVT' FIELD '03'
                       ID 'BUKRS' DUMMY
                       ID 'VKORG' DUMMY
                       ID 'LAND1' FIELD gs_t005-land1
                       ID 'ZBRAND' DUMMY
           ID 'WERKS' DUMMY.

    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given input Country' TYPE 'E'.
    ENDIF.

  ENDLOOP.




  DATA: gt_thizu TYPE STANDARD TABLE OF thizu,
        gs_thizu TYPE thizu.
  SELECT * FROM thizu INTO TABLE gt_thizu
                     WHERE ktokd IN s_ktokd.
  LOOP AT gt_thizu INTO gs_thizu.
    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' DUMMY
                       ID 'VKBUR' DUMMY
                       ID 'VKGRP' DUMMY
                       ID 'DISPO' DUMMY
                       ID 'EKGRP' DUMMY
                       ID 'PERNR' DUMMY
                       ID 'KDGRP' DUMMY
                       ID 'ZKTOKL' FIELD gs_thizu-ktokd.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Customer a/c Group' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  DATA: gt_pa0000 TYPE STANDARD TABLE OF pa0000,
        gs_pa0000 TYPE pa0000.
  SELECT * FROM pa0000 INTO TABLE gt_pa0000
                     WHERE pernr IN s_pernr.
  LOOP AT gt_pa0000 INTO gs_pa0000.
    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' DUMMY
                       ID 'VKBUR' DUMMY
                       ID 'VKGRP' DUMMY
                       ID 'DISPO' DUMMY
                       ID 'EKGRP' DUMMY
                       ID 'PERNR' FIELD gs_pa0000-pernr
                       ID 'KDGRP' DUMMY
                       ID 'ZKTOKL' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Employee' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  DATA: gt_t024d TYPE STANDARD TABLE OF t024d,
        gs_t024d TYPE t024d.
  SELECT * FROM t024d INTO TABLE gt_t024d
                     WHERE dispo IN s_dispo.
  LOOP AT gt_t024d INTO gs_t024d.
    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' DUMMY
                       ID 'VKBUR' DUMMY
                       ID 'VKGRP' DUMMY
                       ID 'DISPO' FIELD gs_t024d-dispo
                       ID 'EKGRP' DUMMY
                       ID 'PERNR' DUMMY
                       ID 'KDGRP' DUMMY
                       ID 'ZKTOKL' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Stock Planner' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  DATA: gt_tvbvk TYPE STANDARD TABLE OF tvbvk,
        gs_tvbvk TYPE tvbvk.
  SELECT * FROM tvbvk INTO TABLE gt_tvbvk
                     WHERE vkbur IN s_vkbur.
  LOOP AT gt_tvbvk INTO gs_tvbvk.
    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' DUMMY
                       ID 'VKBUR' FIELD gs_tvbvk-vkbur
                       ID 'VKGRP' DUMMY
                       ID 'DISPO' DUMMY
                       ID 'EKGRP' DUMMY
                       ID 'PERNR' DUMMY
                       ID 'KDGRP' DUMMY
                       ID 'ZKTOKL' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Sales Office' TYPE 'E'.
    ENDIF.
  ENDLOOP.

*  DATA: gt_tvbvk TYPE STANDARD TABLE OF tvbvk,
*    gs_tvbvk TYPE tvbvk.
  SELECT * FROM tvbvk INTO TABLE gt_tvbvk
                     WHERE vkgrp IN s_vkgrp.
  LOOP AT gt_tvbvk INTO gs_tvbvk.
    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' DUMMY
                       ID 'VKBUR' DUMMY
                       ID 'VKGRP' FIELD gs_tvbvk-vkgrp
                       ID 'DISPO' DUMMY
                       ID 'EKGRP' DUMMY
                       ID 'PERNR' DUMMY
                       ID 'KDGRP' DUMMY
                       ID 'ZKTOKL' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Sales Office' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  DATA: gt_t024 TYPE STANDARD TABLE OF t024,
        gs_t024 TYPE t024.
  SELECT * FROM t024 INTO TABLE gt_t024
                     WHERE ekgrp IN s_ekgrp.
  LOOP AT gt_t024 INTO gs_t024.
    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' DUMMY
                       ID 'VKBUR' DUMMY
                       ID 'VKGRP' DUMMY
                       ID 'DISPO' DUMMY
                       ID 'EKGRP' FIELD gs_t024-ekgrp
                       ID 'PERNR' DUMMY
                       ID 'KDGRP' DUMMY
                       ID 'ZKTOKL' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Central Planner' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  DATA: gt_t151 TYPE STANDARD TABLE OF t151,
        gs_t151 TYPE t151.
  SELECT * FROM t151 INTO TABLE gt_t151
                     WHERE kdgrp IN s_kdgrp.
  LOOP AT gt_t151 INTO gs_t151.
    AUTHORITY-CHECK OBJECT 'ZRPT2'
                       ID 'ACTVT' FIELD '03'
                       ID 'VTWEG' DUMMY
                       ID 'VKBUR' DUMMY
                       ID 'VKGRP' DUMMY
                       ID 'DISPO' DUMMY
                       ID 'EKGRP' DUMMY
                       ID 'PERNR' DUMMY
                       ID 'KDGRP' FIELD gs_t151-kdgrp
                       ID 'ZKTOKL' DUMMY.
    IF sy-subrc <> 0.
      MESSAGE 'You are not authorized to view given Customer group' TYPE 'E'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " AUTHORITY_CHECK
