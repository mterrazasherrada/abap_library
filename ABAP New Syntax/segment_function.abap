"Segment - This function returns the occurrence of a segment of the argument text specified by index

"index: Number of segment
"sep: Substring specified is searched and used as limit
"Hallo
DATA(segment1) = segment( val = `Hallo,world,123` index = 1 sep = `,` ). 

"123
DATA(segment2) = segment( val = `Hallo,world,123` index = -1 sep = `,` ). 

"world
DATA(segment3) = segment( val = `Hallo<br>world<br>123` index = 2 sep = `<br>` ). 

"space: Each individual character is searched and used as limit
DATA(to_be_segmented) = `a/b#c d.e`.

"b
DATA(segment4) = segment( val = `a/b#c d.e` index = 2 space = `. #/` ). 

DATA segment_tab TYPE string_table.
DO.
  TRY.
      INSERT segment( val   = to_be_segmented
                      index = sy-index
                      space = `. #/` ) INTO TABLE segment_tab.
    CATCH cx_sy_strg_par_val.
      EXIT.
  ENDTRY.
ENDDO.

*Content of segment_tab
*a           
*b           
*c           
*d           
*e      