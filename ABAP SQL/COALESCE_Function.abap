*The COALESCE function takes a list of at least two (and up to 255) arguments (arg1, arg2, ..., argn). 
*It returns the first non-null value from the list, or the last argument if all are null.

DATA(lt_salesorders) = VALUE tt_salesorder(
  ( salesorder = '1' netvalue = '100.00' customer = 'CUST_1' )
  ( salesorder = '2' netvalue = '100.00' customer = 'CUST_2' )
  ( salesorder = '3' netvalue = '100.00' customer = 'CUST_3' )
).

DATA(lt_customer_one) = VALUE tt_customer(
  ( customer = 'CUST_1' customername = 'Customer 1' addressid = 1 )
).

DATA(lt_customer_two) = VALUE tt_customer(
  ( customer = 'CUST_2' customername = 'Customer 2' addressid = 2 )
).

DATA(lt_customer_address) = VALUE tt_customer_address(
  ( addressid = 1 address = 'Sitheri, Cuddalore' )
  ( addressid = 2 address = 'Velluvadi, Perambalur' )
).

SELECT FROM @lt_salesorders AS a
  LEFT OUTER JOIN @lt_customer_one AS b ON b~customer = a~customer
  LEFT OUTER JOIN @lt_customer_two AS c ON c~customer = a~customer
  LEFT OUTER JOIN @lt_customer_address AS d ON d~addressid = COALESCE( b~addressid, c~addressid )
  FIELDS a~salesorder,
         a~netvalue,
         a~customer,
         COALESCE( b~customername, c~customername ) AS customername,
         d~address AS customeraddress
  INTO TABLE @DATA(lt_salesorders_with_customer).

"Output
*SALESORDER NETVALUE CUSTOMER CUSTOMERNAME CUSTOMERADDRESS
*1          100.0    CUST_1   Customer 1   Sitheri, Cuddalore
*2          100.0    CUST_2   Customer 2   Velluvadi, Perambalur
*3          100.0    CUST_3