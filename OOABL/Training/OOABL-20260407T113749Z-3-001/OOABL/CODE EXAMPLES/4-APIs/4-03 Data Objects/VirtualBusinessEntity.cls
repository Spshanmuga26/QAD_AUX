using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.

using com.qad.base.BaseServices.
using com.qad.base.address.ICountry.
using com.qad.base.address.IEmployee.
using com.qad.base.BaseUtils.

using com.qad.base.codes.IGeneralizedCodeDataObject.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:

   {com/qad/qra/base/dsKeyField.i}
   {com/qad/base/address/dsEmployee.i}
         
   define private variable DEFAULT_TYPE   as character initial "qad" no-undo.
   define private variable DEFAULT_CTRY   as character initial "US" no-undo.
   define private variable DEFAULT_EMAIL  as character initial "mfg@qad.com" no-undo.

      method public override void Initialize(input entityURI as character, 
                                          output dataset-handle dsEntity):
      define variable qry  as handle no-undo.
      define variable buf  as handle no-undo.

      define variable gcDO as IGeneralizedCodeDataObject no-undo.
        
      /* Call the standard code */
      super:Initialize(
         input entityURI,
         output dataset-handle dsEntity by-reference).

      if entityURI = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
      then do on error undo, throw:

         buf = dsEntity:get-buffer-handle("ttSpeakers").
         create query qry.
         qry:set-buffers(buf).
         qry:query-prepare("for each ttSpeakers").
         qry:query-open().
         qry:get-first().

         do while not qry:query-off-end:
            assign
               buf::Country         = DEFAULT_CTRY
               buf::EMail           = DEFAULT_EMAIL
               buf::IsActive        = yes.
            
            gcDO = BaseServices:GetGeneralizedCode():GetGeneralizedCode(input BaseUtils:GetSessionDomain(),
                                                                        input "XX_SPEAKER_DEFAULT_TYPE", 
                                                                        input "").
            if gcDO:available then
               buf::EmploymentType = gcDO:Comments.             
            
            qry:get-next().
         end.

         finally:
            if qry:is-open
            then qry:query-close().

            delete object qry no-error.
            delete object buf no-error.
            assign qry = ?
                   buf = ?.
         end.         
      end.                

		finally:
         delete object dsEntity no-error.
      end finally.
   end method.

end class.
