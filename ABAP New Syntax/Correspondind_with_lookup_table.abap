"𝗖𝗢𝗥𝗥𝗘𝗦𝗣𝗢𝗡𝗗𝗜𝗡𝗚 𝘄𝗶𝘁𝗵 𝗹𝗼𝗼𝗸𝘂𝗽 𝘁𝗮𝗯𝗹𝗲.
"The CORRESPONDING operator can be used to create a new data object from a structured data object, such as an internal table or structure, by copying the values of fields with matching names. 
"Additionally, the operator can perform a lookup on another internal table to populate specific field values.

TYPES: BEGIN OF ty_employee,
  emp_id       TYPE pernr_d,
  emp_name     TYPE text100,
  manager_id   TYPE pernr_d,
  manager_name TYPE text100,
  emp_position TYPE text100,
END OF ty_employee,
tt_employee TYPE TABLE OF ty_employee WITH EMPTY KEY,
BEGIN OF ty_manager,
  mgr_id   TYPE pernr_d,
  mgr_name TYPE text100,
END OF ty_manager.

DATA lt_managers TYPE HASHED TABLE OF ty_manager WITH UNIQUE KEY mgr_id.
DATA lt_employees TYPE tt_employee.
DATA lt_emp_with_mgr_name TYPE tt_employee.

"Employee data w/o manager name
lt_employees = VALUE #( 
  ( emp_id = '1' emp_name = 'Name 1' emp_position = 'DEV_1' manager_id = '1' )
  ( emp_id = '2' emp_name = 'Name 2' emp_position = 'DEV_2' manager_id = '2' ) ).

"Manager data - Lookup Table
lt_managers = VALUE #( 
  ( mgr_id = '1' mgr_name = 'Manager 1' )
  ( mgr_id = '2' mgr_name = 'Manager 2' ) ).

"Employee data with manager name from lookup table
lt_emp_with_mgr_name = CORRESPONDING #( lt_employees 
  FROM lt_managers USING manager_id 
  MAPPING manager_name = mgr_name ).

"Output
"EMP_ID   EMP_NAME  MANAGER_ID  MANAGER_NAME  EMP_POSITION
"00000001 Name 1    00000001    Manager 1     DEV_1
"00000002 Name 2    00000002    Manager 2     DEV_2