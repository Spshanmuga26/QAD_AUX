using com.qad.base.BaseUtils.
using com.qad.qra.QraServices.
using com.qad.qra.globalization.ITranslatedStringProvider.

add property

   define private property TranslationService as class ITranslatedStringProvider no-undo  
      get:
         if not valid-object(TranslationService) then do:
            this-object:TranslationService = QraServices:GetTranslatedStringProvider().
         end.
         return TranslationService.
      end get.
      set.

IsValidSpeaker

         /* additional validation */
         if not BaseServices:GetCountry():IsValidCountry(input buf::Country)
         then do:
            assign msg = new Message(1, this-object:TranslationService:GetString("INVALID_COUNTRY")).
            msg:SetContext(buf:buffer-field("Country")).
            valMsgs:Add(msg).            
         end. 
         if BaseUtils:HasValue(buf::Email) and 
            not buf::Email matches ".*@.*~~..*" 
         then do:
            assign msg = new Message(1, this-object:TranslationService:GetString("INVALID_EMAIL_ADDRESS")).
            msg:SetContext(buf:buffer-field("Email")).
            valMsgs:Add(msg).            
         end.    