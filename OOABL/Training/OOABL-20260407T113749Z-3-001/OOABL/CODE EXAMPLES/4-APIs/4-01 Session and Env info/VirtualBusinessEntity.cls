using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

using com.qad.base.BaseServices.
using com.qad.base.BaseUtils.

using com.qad.qra.QraServices.
using com.qad.qra.globalization.ITranslatedStringProvider.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:

   define private property TranslationService as class ITranslatedStringProvider no-undo  
      get:
         if not valid-object(TranslationService) then do:
            this-object:TranslationService = QraServices:GetTranslatedStringProvider().
         end.
         return TranslationService.
      end get.
      set.

   method public override void Fetch(
      input entityURI as character,
      input dataset-handle dsEntityKey,
      output dataset-handle dsEntity):

      /* Call the standard code */
      super:Fetch(
         input entityURI,
         input dataset-handle dsEntityKey by-reference,
         output dataset-handle dsEntity by-reference
      ).

      if entityURI = "urn:be:com.extensions.xxconference.SpeakerInfo.ISpeakerInfo"
      then do on error undo, throw:
         this-object:PopulateSessionEnvInfo(input-output dataset-handle dsEntity by-reference).
      end.   
      

      finally:
         delete object dsEntityKey no-error.
         delete object dsEntity no-error.
      end finally.
   end method.

   method private void PopulateSessionEnvInfo(input-output dataset-handle dsEntity):
      define variable qry as handle no-undo.
      define variable buf as handle no-undo.
      
      create query qry.
      buf = dsEntity:get-buffer-handle("ttSpeakerInfo").
      qry:set-buffers(buf).
      qry:query-prepare("for each ttSpeakerInfo").
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:

         buf::TextInfo = 
            TranslationService:GetString("USER_DOMAIN") + ": " + BaseUtils:GetSessionDomain() + "\n" + 
            TranslationService:GetString("User") + ": " + BaseUtils:GetSessionUserID() + "\n" +
            TranslationService:GetString("mfg-LANGUAGE") + ": " + BaseUtils:GetSessionUserLanguage() + "\n" +
            TranslationService:GetString("mfg-CURRENT_ENTITY") + ": " + BaseUtils:GetCurrentEntity() + "\n" +
            TranslationService:GetString("ENVIRONMENT_NAMESPACE") + ": " + QraServices:GetAppInfo():GetEnvironmentNamespace().

         qry:get-next().

      end.

      finally:
         if qry:is-open
            then qry:query-close().
 
         delete object qry no-error.
         delete object buf no-error.
         delete object dsEntity no-error.
      end finally.
   end method.   
end class.
