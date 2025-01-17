* Validates whether a string is a syntactic valid mail address (according to RFC 5322 Standard)
CLASS lcl_email DEFINITION.
    PUBLIC SECTION.
      CLASS-METHODS: validate IMPORTING iv_email        TYPE string
                              RETURNING VALUE(rv_valid) TYPE abap_bool.
  ENDCLASS.
  
  CLASS lcl_email IMPLEMENTATION.
    METHOD validate.
      TRY.
          cl_bcs_email_address=>validate( iv_full_email = iv_email ).
          rv_valid = abap_true.
        CATCH cx_address_bcs INTO DATA(lx_address).
          rv_valid = abap_false.
      ENDTRY.
    ENDMETHOD.
  ENDCLASS.

* Test the email address
IF lcl_email=>validate( iv_email = 'anyemailaddress@gmail.com' ).
    "Valid Email Address
ELSE.
    "Invalid Email address
ENDIF.