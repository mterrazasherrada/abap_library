*If you are using string templates(with ALPHA) to add leading zeros, just have a look at the use of the WIDTH keyword.
*It may be useful where we need to add dynamic number of leading zeros for the same input
CLASS lcl_add_leading_zeros DEFINITION
    CREATE PUBLIC.
    PUBLIC SECTION.
        CLASS-METHODS: add_leading_zeros
            IMPORTING iv_input TYPE string
                      iv_length TYPE int4
            RETURNING VALUE(rv_output) TYPE string.
ENDCLASS.

CLASS lcl_add_leading_zeros IMPLEMENTATION.
    METHOD add_leading_zeros.
        rv_output = |{ iv_input ALPHA = IN WIDTH = iv_length }|.
    ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
    DATA(lv_input) = '123'.
    "-> Convert input as a sales order number - VBELN (10)
    DATA(lv_so) = lcl_add_leading_zeros=>add_leading_zeros( iv_input = lv_input iv_length = 10 ).
    "Output - 0000000123
    "-> Convert input as a contract number - RANL (13)
    DATA(lv_cn) = lcl_add_leading_zeros=>add_leading_zeros( iv_input = lv_input iv_length = 13 ).
    "Output - 0000000000123
