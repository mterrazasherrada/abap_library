*In ABAP, the STRING_AGG function is used to concatenate values from multiple rows into a single string, with a specified delimiter.
*Here is a small example, this table have a customer id and course name, want to aggregate all course name for each customer id into a single string, separated by commas. 
*this can be easily achieved through STRING_AGG function.
*Note: STRING_AGG concatenates the results of an SQL expression in one line (type SSTRING, length 1333). 
*If the string is longer than 1333 characters, an exception (CX_SY_OPEN_SQL_DB) is thrown. 
*The limitation to 1333 characters can be bypassed by the function TO_CLOB. This is available in ABAP SQL from ABAP 7.54+.

TYPES: BEGIN OF ty_employee,
  employee_id TYPE pernr_d,
  course_name TYPE text100,
END OF ty_employee,
tt_employee TYPE TABLE OF ty_employee WITH EMPTY KEY.

DATA(lt_employees) = VALUE tt_employee( 
  ( employee_id = '1' course_name = 'ABAP' )
  ( employee_id = '1' course_name = 'UI5' )
  ( employee_id = '1' course_name = 'Fiori' )
  ( employee_id = '2' course_name = 'ABAP' )
  ( employee_id = '2' course_name = 'UI5' ) ).

SELECT FROM @lt_employees AS employees
  FIELDS employee_id,
         to_clob( STRING_AGG( course_name, ',' ) ) AS courses
  GROUP BY employee_id
  INTO TABLE @DATA(lt_emp_courses).

"Output
*EMPLOYEE_ID    COURSES
*00000001        ABAP, UI5, Fiori
*00000002        ABAP, UI5