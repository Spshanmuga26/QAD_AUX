
define variable debug as character no-undo initial no.



if debug = "yes" then
          this-object:LogToFile("HDR BEFORE - Customer: " + soldToCustCode).
		  
		  
		          generalizedCodeService = BaseServices:GetGeneralizedCode().
domain = BaseUtils:GetSessionDomain().
   generalizedCodeService:Fetch(
       input domain,  
       input "dev_debug",         
	input "yes",    
       output dataset dsGeneralizedCode by-reference
   ).
   
   for each ttGeneralizedCode:
	debug = ttGeneralizedCode.comments.

   end. /*if dug gcm*/
   
   method private void LogToFile(input pcMessage as character):
    
    define variable cLogFile as character no-undo.
    define variable cTimeStamp as character no-undo.
    
    cLogFile = "/home/ravim/WEB_UI_Logs/Sales_Order_Headers.log".
    cTimeStamp = string(now, "99/99/9999 HH:MM:SS").
    
    output to value(cLogFile) append.
    put unformatted 
        cTimeStamp " - " pcMessage skip.
    output close.
    
end method.

