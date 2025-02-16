CLASS lcl_sb_zip DEFINITION
  CREATE PUBLIC .
  PUBLIC SECTION.
    TYPES:
      tt_customerid TYPE TABLE OF s_customer WITH EMPTY KEY .
    METHODS get_form
      IMPORTING
        !iv_customer_id TYPE s_customer
      RETURNING
        VALUE(rv_pdf)   TYPE fpcontent .
    METHODS build_zip
      IMPORTING VALUE(it_customers_id) TYPE tt_customerid
      RETURNING VALUE(rv_zip_file)     TYPE xstring.
    METHODS download_zip IMPORTING VALUE(iv_zip_file) TYPE xstring.
    METHODS send_email IMPORTING VALUE(iv_zip_file) TYPE xstring.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_customer_data
      IMPORTING
        !iv_customer_id  TYPE s_customer
      EXPORTING
        !customer_detail TYPE scustom
        !bookings        TYPE ty_bookings
        !connections     TYPE ty_connections .
ENDCLASS.

CLASS lcl_sb_zip IMPLEMENTATION.
  METHOD get_customer_data.

    SELECT SINGLE FROM scustom
    FIELDS *
    WHERE id = @iv_customer_id
    INTO @customer_detail.
    SELECT FROM bookings
    FIELDS *
    WHERE customid = @iv_customer_id
    INTO TABLE @bookings.
    IF lines( bookings ) > 0.
      SELECT * FROM spfli INTO TABLE @connections
      FOR ALL ENTRIES IN @bookings
      WHERE carrid = @bookings-carrid
      AND connid = @bookings-connid.
    ENDIF.

  ENDMETHOD.

  METHOD get_form.

    DATA(lv_form_name) = CONV tdsfname( 'FP_TEST_03' ).
    DATA(lv_form_fm_name) = VALUE rs38l_fnam( ).
    DATA(ls_docparams) = VALUE sfpdocparams( ).
    DATA(ls_outputparams) = VALUE sfpoutputparams( ).
    DATA(ls_formoutput) = VALUE fpformoutput( ).
* Get data
    get_customer_data(
    EXPORTING
        iv_customer_id = iv_customer_id
    IMPORTING
        customer_detail = DATA(customer)
        bookings = DATA(bookings)
        connections = DATA(connections) ).
* get name of the generated function module
    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = lv_form_name
          IMPORTING
            e_funcname = lv_form_fm_name.
      CATCH cx_fp_api INTO DATA(lx_fp_api).
        MESSAGE ID lx_fp_api->msgid TYPE lx_fp_api->msgty
        NUMBER lx_fp_api->msgno
        WITH lx_fp_api->msgv1 lx_fp_api->msgv2
        lx_fp_api->msgv3 lx_fp_api->msgv4.
        RETURN.
    ENDTRY.
* Set output parameters and open spool job
    ls_outputparams-nodialog = 'X'. " no print preview
    ls_outputparams-getpdf = 'X'. " request PDF
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      RETURN.
    ENDIF.
* Now call the generated function module
    CALL FUNCTION lv_form_fm_name
      EXPORTING
        /1bcdwb/docparams  = ls_docparams
        customer           = customer
        bookings           = bookings
        connections        = connections
      IMPORTING
        /1bcdwb/formoutput = ls_formoutput
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
* Close spool job
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    rv_pdf = ls_formoutput-pdf.
  ENDMETHOD.

  METHOD build_zip.
    DATA(lo_zip) = NEW cl_abap_zip( ).
    LOOP AT it_customers_id ASSIGNING FIELD-SYMBOL(<customer_id>).
      lo_zip->add( name = |{ <customer_id> }.pdf|
                   content = get_form( <customer_id> ) ).
    ENDLOOP.
    rv_zip_file = lo_zip->save( ).
  ENDMETHOD.

  METHOD download_zip.
    DATA(lv_file_path) = VALUE string( ).
    DATA(lv_file_name) = VALUE string( ).
    DATA(lv_path) = VALUE string( ).
    DATA(lv_user_action) = VALUE i( ).

    cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension         = 'zip'
    CHANGING
      fullpath                  = lv_file_path
      filename                  = lv_file_name
      path                      = lv_path
      user_action               = lv_user_action
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5 ).

    IF lv_user_action <> cl_gui_frontend_services=>action_ok.
      RETURN.
    ENDIF.

    DATA(lt_binary_tab) = VALUE solix_tab( ).

    lt_binary_tab = cl_bcs_convert=>xstring_to_solix( iv_zip_file ).

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_file_path
        filetype                = 'BIN'
      CHANGING
        data_tab                = lt_binary_tab
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
  ENDMETHOD.

  METHOD send_email.
    TRY.
        DATA(lo_mail) = cl_bcs=>create_persistent( ).
        DATA(lo_sender_address) = cl_cam_address_bcs=>create_internet_address(
                                        i_address_string = CONV #( 'sender@gmail.com' ) ).
        lo_mail->set_sender( lo_sender_address ).

        DATA(recipient_address) = cl_cam_address_bcs=>create_internet_address(
                                        i_address_string = CONV #( 'receiver@gmail.com' ) ).
        lo_mail->add_recipient( i_recipient = recipient_address ).

        DATA(lo_document) = cl_document_bcs=>create_document(
                                       i_type = 'htm'
                                       i_subject = `ZIP File Attachment`
                                       i_text = VALUE #( ( CONV #( 'ZIP File Attachment' ) ) )
                                       i_sender = lo_sender_address ).

        lo_document->add_attachment(  i_attachment_type = 'ZIP'
                                      i_attachment_subject = 'Zip_File'
                                      i_attachment_size = CONV #( xstrlen( iv_zip_file ) )
                                      i_att_content_hex = cl_bcs_convert=>xstring_to_solix( iv_zip_file ) ).
        lo_mail->set_document( lo_document ).

        lo_mail->set_send_immediately( abap_true ).
        DATA(lv_send_success) = lo_mail->send( ).
        COMMIT WORK.
      CATCH cx_send_req_bcs cx_address_bcs cx_document_bcs INTO DATA(lx_mail).
        MESSAGE lx_mail TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  DATA(lo_zip) = NEW lcl_sb_zip( ).
  DATA(lv_zip_data) = lo_zip->build_zip( it_customers_id = VALUE #( ( CONV #( 00000001 ) )
                                                                    ( CONV #( 00000002 ) ) ) ).
  lo_zip->download_zip( lv_zip_data ).
  lo_zip->send_email( lv_zip_data ).