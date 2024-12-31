"𝗔𝗕𝗔𝗣 𝗦𝗤𝗟: 𝗜𝗻𝗱𝗶𝗰𝗮𝘁𝗼𝗿 𝗦𝘁𝗿𝘂𝗰𝘁𝘂𝗿𝗲𝘀
"If you've worked with RAP, you might be familiar with the %𝗰𝗼𝗻𝘁𝗿𝗼𝗹 component group. 
"This structure contains all key and data fields as components, represented as flags. 
"It is used to determine which fields are provided to Create/Update during CREATE or UPDATE operations using EML.

"A similar concept exists in ABAP SQL with 𝗦𝗤𝗟 𝗜𝗻𝗱𝗶𝗰𝗮𝘁𝗼𝗿𝘀. 
"These indicators are useful for partially updating a database table by setting specific fields. 

* Data structure with additional set indicator
TYPES: ty_sflight TYPE sflight WITH INDICATORS set_ind.
DATA: it_sflight TYPE STANDARD TABLE OF ty_sflight WITH DEFAULT KEY.

SELECT FROM sflight
  FIELDS carrid, connid, fldate, price
  WHERE carrid = 'AA'
    AND connid = '0017'
    AND fldate = '20230929'
  INTO CORRESPONDING FIELDS OF TABLE @it_sflight.

* Update Price
LOOP AT it_sflight ASSIGNING FIELD-SYMBOL(<flight>).
  <flight>-price = '100'.
  <flight>-set_ind-price = '01'.
ENDLOOP.

* Only update the columns with Set-Indicator='01'
UPDATE sflight FROM TABLE @it_sflight INDICATORS SET STRUCTURE set_ind.