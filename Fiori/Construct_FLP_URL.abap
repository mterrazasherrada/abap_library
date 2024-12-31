"Are you manually constructing FLP URLs? then try out this class 𝗖𝗟_𝗟𝗦𝗔𝗣𝗜_𝗠𝗔𝗡𝗔𝗚𝗘𝗥 to simplify that. 
"You will need it in case you want to

".. Launch Fiori apps from GUI.
".. Generate a Dynamic Fiori URL by using using Semantic Objects, Actions, and Parameters.
".. Share specific Fiori app links via email.
".. Call Transaction, etc,.


DATA(lo_lsapi) = cl_lsapi_manager=>get_instance( ).

"Create URL to Access Fiori Apps
DATA(lv_flp_app_url) = cl_lsapi_manager=>create_flp_url(
    object        = 'MaintenanceObject'     "Fiori Intent Semantic Object Value
    action        = 'listFunctionalLocStructure'  "Fiori Intent Action Value
    system_alias  = 'LOCAL'                 "SM59 Based System Alias of Fiori Front End Server
    parameters    = VALUE #( name = 'DY_TPLNR' value = '0001' )
).

"Create URL to Access Transaction Code
DATA(lv_tcode_url) = cl_lsapi_manager=>create_flp_url(
    system_alias  = 'LOCAL'                 "SM59 Based System Alias of Fiori Frontend Server
    parameters    = VALUE #( ( name = 'DY_TPLNR' value = '0001' ) )  "Parameters in hash part of URL
    transaction   = 'IH01'                  "Transaction Code
).

"Ways to OPEN/Navigate to URL
lo_lsapi->navigate( 
    location = lv_flp_app_url
    mode     = lo_lsapi->gc_s_navigation_mode-inplace 
).

cl_lsapi_manager=>open_url( url = lv_tcode_url ).