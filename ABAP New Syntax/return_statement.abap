*In ABAP, the 𝗥𝗘𝗧𝗨𝗥𝗡 statement has been used to exit a procedure, such as a method or a function module. 
*Unlike many other programming languages where 𝗿𝗲𝘁𝘂𝗿𝗻 is used to pass a value back from a function, earlier versions of ABAP did not support this functionality. 
*However, starting with ABAP 7.58, the 𝗥𝗘𝗧𝗨𝗥𝗡 statement can now be used to return a value directly from a method.
*Note: This applies only to methods that have a returning parameter.
CLASS lcl_demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      return RETURNING VALUE(rv_value) TYPE text100,
      return_with_value RETURNING VALUE(rv_value) TYPE text100,
      return_structure RETURNING VALUE(rs_vbak) TYPE vbak,
      return_table RETURNING VALUE(rt_table) TYPE tt_vbak.
ENDCLASS.

CLASS lcl_demo IMPLEMENTATION.
  METHOD return.
    rv_value = 'Something'.
    RETURN.
  ENDMETHOD.

  METHOD return_with_value.
    RETURN 'something'.
  ENDMETHOD.

  METHOD return_structure.
    RETURN VALUE #( vbeln = '1' erdat = '20231212' ).
  ENDMETHOD.

  METHOD return_table.
    RETURN VALUE #( ( vbeln = '1' erdat = '20231212' ) 
                    ( vbeln = '2' erdat = '20231212' ) ).
  ENDMETHOD.
ENDCLASS.