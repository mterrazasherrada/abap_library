*To group internal table data and process it based on specific fields, older statements like AT NEW <field> and AT END OF <field> within loops were commonly used. 
*However, these statements are now obsolete.
*But now, the new ABAP Syntax 𝗟𝗢𝗢𝗣 𝗔𝗧 𝗚𝗥𝗢𝗨𝗣 or 𝗙𝗢𝗥 𝗚𝗥𝗢𝗨𝗣𝗦 𝗢𝗙 used to achieve the same functionality.

DATA(lt_courses) = VALUE tt_course ( 
    ( employee_id = '1' course_id = '1' course_name = 'ABAP'  amount = '1000' )
    ( employee_id = '1' course_id = '2' course_name = 'UI5'   amount = '2000' )
    ( employee_id = '1' course_id = '3' course_name = 'Fiori' amount = '3000' )
    ( employee_id = '2' course_id = '1' course_name = 'ABAP'  amount = '1000' )
    ( employee_id = '2' course_id = '2' course_name = 'UI5'   amount = '2000' )
    ( employee_id = '2' course_id = '3' course_name = 'Fiori' amount = '3000' )
    ( employee_id = '3' course_id = '1' course_name = 'ABAP'  amount = '1000' )
).

"Loop At Group and For in Group
DATA(lt_employee_w_loop) = VALUE tt_employee( ).

LOOP AT lt_courses INTO DATA(wa)
    GROUP BY ( employee_id = wa-employee_id 
              size = GROUP SIZE 
              index = GROUP INDEX ) 
    ASSIGNING FIELD-SYMBOL(<course>).
    
    DATA(ls_employee) = VALUE ty_employee( 
        employee_id = <course>-employee_id 
        no_of_courses = <course>-size 
        total_amount = 0 ).

    "Option 1
    LOOP AT GROUP <course> ASSIGNING FIELD-SYMBOL(<member>).
        ls_employee-total_amount += <member>-amount.
    ENDLOOP.

    "Option 2
    ls_employee-total_amount = REDUCE #( 
        INIT amount = 0 
        FOR <member> IN GROUP <course> 
        NEXT amount = amount + <member>-amount 
    ).
    
    APPEND ls_employee TO lt_employee_w_loop.
ENDLOOP.

"For in Group
DATA(lt_employee_w_for) = VALUE tt_employee( 
    FOR GROUPS course OF wa IN lt_courses 
    GROUP BY ( employee_id = wa-employee_id 
               size = GROUP SIZE 
               index = GROUP INDEX ) 
    ( employee_id = course-employee_id 
      no_of_courses = course-size 
      total_amount = REDUCE #( 
          INIT amount = 0 
          FOR member IN GROUP course 
          NEXT amount = amount + member-amount 
      ) 
    ) 
).

"Output
"EMPLOYEE_ID NO_OF_COURSES TOTAL_AMOUNT
"00000001    3            6000
"00000002    3            6000
"00000003    1            1000