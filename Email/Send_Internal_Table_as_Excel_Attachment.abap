CLASS lcl_email_with_excel DEFINITION.
    PUBLIC SECTION.
      METHODS send_email.
  
    PRIVATE SECTION.
      TYPES: BEGIN OF ty_employee,
               emp_id       TYPE pernr_d,
               emp_name     TYPE text100,
               manager_id   TYPE pernr_d,
               manager_name TYPE text100,
               emp_position TYPE text100,
             END OF ty_employee,
             tt_employee TYPE TABLE OF ty_employee WITH EMPTY KEY.
  
      TYPES: BEGIN OF ty_column,
               column_name TYPE text30,
               column_text TYPE text40,
             END OF ty_column,
             tt_columns TYPE TABLE OF ty_column WITH EMPTY KEY.
      CLASS-DATA mt_emloyees TYPE tt_employee.
      CLASS-DATA mt_columns  TYPE tt_columns.
  
      METHODS load_data.
      METHODS convert_itab_to_xls_xstring RETURNING VALUE(rv_xstring) TYPE xstring.
  ENDCLASS.
  
  CLASS lcl_email_with_excel IMPLEMENTATION.
    METHOD load_data.
      mt_emloyees = VALUE #( ( emp_id = '1' emp_name = 'Name 1' emp_position = 'DEV_1' manager_id = '1' manager_name = 'Manager 1' )
                             ( emp_id = '2' emp_name = 'Name 2' emp_position = 'DEV_2' manager_id = '2' manager_name = 'Manager 2' ) ).
  
      mt_columns = VALUE #( ( column_name = 'EMP_ID'       column_text = 'Employee ID' )
                            ( column_name = 'EMP_NAME'     column_text = 'Employee Name' )
                            ( column_name = 'EMP_POSITION' column_text = 'Employee Position' )
                            ( column_name = 'MANAGER_ID'   column_text = 'Manager ID' )
                            ( column_name = 'MANAGER_NAME' column_text = 'Manager Name' ) ).
    ENDMETHOD.
  
    METHOD convert_itab_to_xls_xstring.
      TRY.
          cl_salv_table=>factory(
          EXPORTING
            list_display = abap_false
          IMPORTING
            r_salv_table = DATA(lo_salv_table)
          CHANGING
            t_table      = mt_emloyees ).
  
          LOOP AT mt_columns ASSIGNING FIELD-SYMBOL(<column>).
            DATA(lo_column) = lo_salv_table->get_columns( )->get_column( <column>-column_name ).
            lo_column->set_long_text( <column>-column_text ).
            lo_column->set_medium_text( CONV #( <column>-column_text ) ).
            lo_column->set_short_text( CONV #( <column>-column_text ) ).
          ENDLOOP.
  
          DATA(lt_fcat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
                             r_columns      = lo_salv_table->get_columns( )
                             r_aggregations = lo_salv_table->get_aggregations( ) ).
        CATCH cx_salv_msg INTO DATA(lx_mail).
          MESSAGE lx_mail TYPE 'E'.
      ENDTRY.

      "Option - 1
          "rv_xstring = lo_salv_table->to_xml( xml_type = if_salv_bs_xml=>c_type_xlsx ).
          "RETURN.

      "Option - 2
      cl_salv_bs_lex=>export_from_result_data_table(
        EXPORTING
          is_format            = if_salv_bs_lex_format=>mc_format_xlsx
          ir_result_data_table =  cl_salv_ex_util=>factory_result_data_table(
                                     r_data         = REF #( mt_emloyees )
                                     t_fieldcatalog = lt_fcat )
        IMPORTING
          er_result_file       = rv_xstring ).
    ENDMETHOD.
  
    METHOD send_email.
  
      TRY.
          load_data( ).
  
          DATA(lo_mail) = cl_bcs=>create_persistent( ).
          DATA(lo_sender_address) = cl_cam_address_bcs=>create_internet_address(
                                      i_address_string = CONV #( 'sender@gmail.com' ) ).
          lo_mail->set_sender( lo_sender_address ).
  
          DATA(recipient_address) = cl_cam_address_bcs=>create_internet_address(
                                      i_address_string = CONV #( 'receiver@gmail.com' ) ).
          lo_mail->add_recipient( i_recipient = recipient_address ).
  
          DATA(lo_document) = cl_document_bcs=>create_document(
                                i_type    = 'htm'
                                i_subject = `Excel Attachment`
                                i_text    = VALUE #( ( CONV #( 'Excel Attachment' ) ) )
                                i_sender  = lo_sender_address ).
  
          DATA(lv_excel_data) = convert_itab_to_xls_xstring( ).
          lo_document->add_attachment(
            i_attachment_type     = 'XLS'
            i_attachment_subject  = 'Employee Table'
            i_attachment_size     = CONV #( xstrlen( lv_excel_data ) )
            i_att_content_hex     = cl_bcs_convert=>xstring_to_solix( lv_excel_data ) ).
  
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
    DATA(lo_mail) = NEW lcl_email_with_excel( ).
    lo_mail->send_email( ).