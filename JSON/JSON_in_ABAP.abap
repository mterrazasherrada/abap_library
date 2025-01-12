TYPES: BEGIN OF ty_emp_type,
         employeeid          TYPE c LENGTH 3,
         employeename        TYPE c LENGTH 20,
         employeeage         TYPE c LENGTH 3,
         employeemobilenumber TYPE c LENGTH 10,
       END OF ty_emp_type,
       tt_emp_tab_type TYPE TABLE OF ty_emp_type WITH EMPTY KEY.

DATA(emp_tab) = VALUE #(
  ( employeeid = '1' employeename = 'Bharathi S' employeeage = '24' employeemobilenumber = '1234567890' )
  ( employeeid = '2' employeename = 'Siva S'     employeeage = '24' employeemobilenumber = '1234567890' )
  ( employeeid = '3' employeename = 'Sasi S'     employeeage = '24' employeemobilenumber = '1234567890' ) ).

* Table to JSON
DATA(lv_emp_table_to_json) = /ui2/cl_json=>serialize(
                               data          = emp_tab
                               format_output = abap_true
                               pretty_name   = /ui2/cl_json=>pretty_mode-camel_case ).  "none,low_case,camel_case,extended, user, user_low_case
                    
* JSON to table (with different column names)
TYPES: BEGIN OF ty_emp_type_map,
         empid        TYPE c LENGTH 3,
         empname      TYPE c LENGTH 20,
         empage       TYPE c LENGTH 3,
         empmobnumber TYPE c LENGTH 10,
       END OF ty_emp_type_map,
       tt_emp_tab_type_map TYPE TABLE OF ty_emp_type_map WITH EMPTY KEY.

DATA(lt_emp_data_from_json_map) = VALUE tt_emp_tab_type_map( ).
/ui2/cl_json=>deserialize(
  EXPORTING
    json          = lv_emp_table_to_json
    name_mappings = VALUE #( ( abap = 'EMPID'        json = 'EMPLOYEEID' )
                             ( abap = 'EMPNAME'      json = 'EMPLOYEENAME' )
                             ( abap = 'EMPAGE'       json = 'EMPLOYEEAGE' )
                             ( abap = 'EMPMOBNUMBER' json = 'EMPLOYEEMOBILENUMBER' ) )
  CHANGING
    data          = lt_emp_data_from_json_map ).

* JSON to table
DATA(lt_emp_data_from_json) = VALUE tt_emp_tab_type( ).
/ui2/cl_json=>deserialize(
  EXPORTING
    json   = lv_emp_table_to_json
  CHANGING
    data   = lt_emp_data_from_json
).

* Conversion Exists
TYPES: BEGIN OF ty_customer_data,
        customerId TYPE kunnr,
        language   TYPE spras,
       END OF ty_customer_data.
DATA(ls_sales_data) = VALUE ty_customer_data( language = 'E' customerid = '1' ).
DATA(lv_json_Sales_data) = /ui2/cl_json=>serialize(
                      data             = ls_sales_data
                      conversion_exits = abap_true ).
"E -> Will be changed into EN

* Unknown type
DATA(lv_unknown_json) = `[ { "EmployeeId":"1", "EmployeeName":"Saranya S" },` &&
                        `{ "EmployeeId":"2", "EmployeeName":"Saran S" }]`.
DATA(lr_emp_data) = /ui2/cl_json=>generate( json = lv_unknown_json ).
" This can be accessed by lr_emp_data->*
