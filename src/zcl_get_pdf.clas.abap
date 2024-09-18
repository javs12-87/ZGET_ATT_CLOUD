CLASS zcl_get_pdf DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: get_html IMPORTING lv_xml TYPE string RETURNING VALUE(ui_html) TYPE string.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_PDF IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    TRY.
        DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                               i_name = |S4H_RFC| ).

        DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).

        DATA lv_hex TYPE string.

        DATA lv_result TYPE c LENGTH 200.
        DATA msg       TYPE c LENGTH 255.

        CALL FUNCTION 'RFC_SYSTEM_INFO' DESTINATION lv_rfc_dest
          IMPORTING
            rfcsi_export          = lv_result
          EXCEPTIONS
            system_failure        = 1 MESSAGE msg
            communication_failure = 2 MESSAGE msg
            OTHERS                = 3.

        CALL FUNCTION 'Z_WF_GET_ATT' DESTINATION lv_rfc_dest
          EXPORTING
            userid = 'I834429'
            workitemid ='000000148002'
          IMPORTING
            pdf_b64 = lv_hex.


      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.

    response->set_text( get_html( lv_hex ) ).

  ENDMETHOD.


  METHOD get_html.

    ui_html = '<!DOCTYPE html>' && |\n|  &&
              '<html lang="en-US">' && |\n|  &&
              |\n|  &&
              '<head>' && |\n|  &&
              '  <meta charset="UTF-8">' && |\n|  &&
              '  <meta name="viewport" content="width=device-width, initial-scale=1">' && |\n|  &&
              '  <title>PDF from BTP</title>' && |\n|  &&
              '</head>' && |\n|  &&
              |\n|  &&
              '<body>' && |\n|  &&
              |\n|  &&
              '  <script>' && |\n|  &&
              '    var encodedPdfContent =' && '''' && |{ lv_xml }| && '''' && ';' && |\n|  &&
              '    var decodedPdfContent = atob(encodedPdfContent);' && |\n|  &&
              '    var byteArray = new Uint8Array(decodedPdfContent.length);' && |\n|  &&
              '    for (var i = 0; i < decodedPdfContent.length; i++) {' && |\n|  &&
              '      byteArray[i] = decodedPdfContent.charCodeAt(i);' && |\n|  &&
              '    }' && |\n|  &&
              '    var blob = new Blob([byteArray.buffer], {' && |\n|  &&
              '      type: ''application/pdf''' && |\n|  &&
              '    });' && |\n|  &&
              '    var _pdfurl = URL.createObjectURL(blob);' && |\n|  &&
              '    window.open(_pdfurl, "_self");' && |\n|  &&
              '  </script>' && |\n|  &&
              |\n|  &&
              '</body>' && |\n|  &&
              |\n|  &&
              '</html>'.

  ENDMETHOD.
ENDCLASS.
