CLASS zcl_sql_window_functions DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
    TYPES: BEGIN OF ty_students,
             student_id   TYPE int4,
             student_name TYPE c LENGTH 40,
             dep_name     TYPE c LENGTH 40,
             score        TYPE int4,
           END OF ty_students.
    DATA: lt_students TYPE TABLE OF ty_students WITH DEFAULT KEY.
    METHODS: constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_sql_window_functions IMPLEMENTATION.
  METHOD constructor.
    lt_students = VALUE #( ( student_id = 1 student_name = 'Bharathi S' dep_name = 'IT' score = 90  )
                           ( student_id = 2 student_name = 'Dhakshan' dep_name = 'CSE' score = 87  )
                           ( student_id = 3 student_name = 'Shroy' dep_name = 'EEE' score = 95  )
                           ( student_id = 4 student_name = 'Bhuvi' dep_name = 'EEE' score = 78  )
                           ( student_id = 5 student_name = 'Thara' dep_name = 'IT' score = 85  )
                           ( student_id = 6 student_name = 'Anish' dep_name = 'EEE' score = 95  )
                           ( student_id = 7 student_name = 'Aravind' dep_name = 'MECH' score = 91  )
                           ( student_id = 8 student_name = 'Mohan' dep_name = 'CSE' score = 82  )
                           ( student_id = 9 student_name = 'Saurabh' dep_name = 'IT' score = 92  )
                           ( student_id = 10 student_name = 'Rohan' dep_name = 'CSE' score = 65  )
                           ( student_id = 11 student_name = 'Surya' dep_name = 'MECH' score = 72  )
                           ( student_id = 12 student_name = 'Boopalan' dep_name = 'MECH' score = 67  )
                           ( student_id = 13 student_name = 'Shasank' dep_name = 'CSE' score = 75  )
                           ( student_id = 14 student_name = 'Kaviya' dep_name = 'EEE' score = 90  ) ).
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    SELECT FROM @lt_students AS lt_students
    FIELDS student_id,
           student_name,
           dep_name,
           score,

           " note: If partition by is not mentioned whole data will be considered as a single result set
           SUM( score ) OVER( ) AS total_score,
           MAX( score ) OVER( ) AS maximum_score,
           MIN( score ) OVER( ) AS mininum_score,
           CAST( AVG( score ) OVER( ) AS INT4 ) AS average_score,

           SUM( score ) OVER( PARTITION BY dep_name ORDER BY dep_name ASCENDING ) AS dep_total_score,
           MIN( score ) OVER( PARTITION BY dep_name ORDER BY dep_name ASCENDING ) AS dep_min_score,
           MAX( score ) OVER( PARTITION BY dep_name ORDER BY dep_name ASCENDING ) AS dep_max_score,
           CAST( AVG( score ) OVER( PARTITION BY dep_name ORDER BY dep_name ASCENDING ) AS INT4 ) AS dep_avg_score,

           ROW_NUMBER( ) OVER( ORDER BY student_name ) AS name_serial_number,
           RANK( ) OVER( PARTITION BY dep_name ORDER BY score DESCENDING ) AS dep_wise_rank_with_gaps,
           DENSE_RANK( ) OVER( PARTITION BY dep_name ORDER BY score DESCENDING ) AS dep_wise_rank_wo_gaps,

           LAG( score ) OVER( PARTITION BY dep_name ORDER BY score ) AS prev_score_by_dept,
           LEAD( score ) OVER( PARTITION BY dep_name ORDER BY score ) AS next_score_by_dept,

           SUM( score ) OVER( ORDER BY student_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS cumulative_sum,
           SUM( score ) OVER( ORDER BY student_id ) AS running_sum,

           FIRST_VALUE( student_id ) OVER( PARTITION BY dep_name ORDER BY score DESCENDING ) AS top_perfomer_dep_wise,
           LAST_VALUE( student_id ) OVER( PARTITION BY dep_name ORDER BY score DESCENDING ) AS low_perfomer_dep_wise,

           NTILE( 3 ) OVER( ORDER BY score ) AS group_students_by_3_levels

    ORDER BY dep_name, score DESCENDING
    INTO TABLE @DATA(lt_result)
    .
    out->write( lt_result ).
  ENDMETHOD.
ENDCLASS.


" Output
*STUDENT_ID    STUDENT_NAME    DEP_NAME    SCORE    TOTAL_SCORE    MAXIMUM_SCORE    MININUM_SCORE    AVERAGE_SCORE    DEP_TOTAL_SCORE    DEP_MIN_SCORE    DEP_MAX_SCORE    DEP_AVG_SCORE    NAME_SERIAL_NUMBER    DEP_WISE_RANK_WITH_GAPS    DEP_WISE_RANK_WO_GAPS    PREV_SCORE_BY_DEPT    NEXT_SCORE_BY_DEPT    CUMULATIVE_SUM    RUNNING_SUM    TOP_PERFOMER_DEP_WISE    LOW_PERFOMER_DEP_WISE    GROUP_STUDENTS_BY_3_LEVELS
*2             Dhakshan        CSE         87       1164           95               65               83               309                65               87               77               6                     1                          1                        82                    0                     177               177            2                        2                        2                         
*8             Mohan           CSE         82       1164           95               65               83               309                65               87               77               8                     2                          2                        75                    87                    703               703            2                        8                        2                         
*13            Shasank         CSE         75       1164           95               65               83               309                65               87               77               11                    3                          3                        65                    82                    1074              1074           2                        13                       1                         
*10            Rohan           CSE         65       1164           95               65               83               309                65               87               77               9                     4                          4                        0                     75                    860               860            2                        10                       1                         
*3             Shroy           EEE         95       1164           95               65               83               358                78               95               89               12                    1                          1                        95                    0                     272               272            6                        3                        3                         
*6             Anish           EEE         95       1164           95               65               83               358                78               95               89               1                     1                          1                        90                    95                    530               530            6                        3                        3                         
*14            Kaviya          EEE         90       1164           95               65               83               358                78               95               89               7                     3                          2                        78                    95                    1164              1164           6                        14                       2                         
*4             Bhuvi           EEE         78       1164           95               65               83               358                78               95               89               4                     4                          3                        0                     90                    350               350            6                        4                        1                         
*9             Saurabh         IT          92       1164           95               65               83               267                85               92               89               10                    1                          1                        90                    0                     795               795            9                        9                        3                         
*1             Bharathi S      IT          90       1164           95               65               83               267                85               92               89               3                     2                          2                        85                    92                    90                90             9                        1                        2                         
*5             Thara           IT          85       1164           95               65               83               267                85               92               89               14                    3                          3                        0                     90                    435               435            9                        5                        2                         
*7             Aravind         MECH        91       1164           95               65               83               230                67               91               76               2                     1                          1                        72                    0                     621               621            7                        7                        3                         
*11            Surya           MECH        72       1164           95               65               83               230                67               91               76               13                    2                          2                        67                    91                    932               932            7                        11                       1                         
*12            Boopalan        MECH        67       1164           95               65               83               230                67               91               76               5                     3                          3                        0                     72                    999               999            7                        12                       1                         