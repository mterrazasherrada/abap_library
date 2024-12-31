The additions `𝘄𝗶𝘁𝗵 𝗮𝗱𝗱𝗶𝘁𝗶𝗼𝗻𝗮𝗹 𝘀𝗮𝘃𝗲` and `𝘄𝗶𝘁𝗵 𝘂𝗻𝗺𝗮𝗻𝗮𝗴𝗲𝗱 𝘀𝗮𝘃𝗲` can be used to enhance or to replace the default save sequence in a managed RAP BO. 
Both additions require a reimplementation of the `𝘀𝗮𝘃𝗲_𝗺𝗼𝗱𝗶𝗳𝗶𝗲𝗱` method of the RAP saver class.

When the `𝘀𝗮𝘃𝗲_𝗺𝗼𝗱𝗶𝗳𝗶𝗲𝗱` method called we will receive only changed fields value in the update method. 
In scenarios where all fields, not only changed fields, are required for further processing, the addition `𝘄𝗶𝘁𝗵 𝗳𝘂𝗹𝗹 𝗱𝗮𝘁𝗮` can be used. 
By doing this, the RAP BO consumer avoids having to do an extra READ operation.

`..𝘄𝗶𝘁𝗵 𝗮𝗱𝗱𝗶𝘁𝗶𝗼𝗻𝗮𝗹 𝘀𝗮𝘃𝗲 𝘄𝗶𝘁𝗵 𝗳𝘂𝗹𝗹 𝗱𝗮𝘁𝗮`
`..𝘄𝗶𝘁𝗵 𝘂𝗻𝗺𝗮𝗻𝗮𝗴𝗲𝗱 𝘀𝗮𝘃𝗲 𝘄𝗶𝘁𝗵 𝗳𝘂𝗹𝗹 𝗱𝗮𝘁𝗮`

Note:
The fields of the component group `%𝗰𝗼𝗻𝘁𝗿𝗼𝗹` are not affected by this. Still, only the changed fields of %𝗰𝗼𝗻𝘁𝗿𝗼𝗹 are flagged.

For More Info.
https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/index.htm?file=abenbdl_saving.htm