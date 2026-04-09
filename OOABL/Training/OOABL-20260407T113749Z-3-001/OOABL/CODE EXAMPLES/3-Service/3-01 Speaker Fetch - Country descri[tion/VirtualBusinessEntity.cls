using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.

using com.qad.base.BaseServices.
using com.qad.base.address.ICountry.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:

   {com/qad/qra/base/dsKeyField.i}
         
   method private void PopulateCtryDesc(input-output dataset-handle dsEntity):
      define variable qry              as handle no-undo.
      define variable buf              as handle no-undo.
      define variable countryService   as ICountry no-undo.
      define variable ctryDesc         as character no-undo.
      
      countryService = BaseServices:GetCountry().

      create query qry.
      buf = dsEntity:get-buffer-handle("ttSpeakers").
      qry:set-buffers(buf).
      qry:query-prepare("for each ttSpeakers").
      qry:query-open().
      qry:get-first().

      do while not qry:query-off-end:
         if countryService:IsValidCountry(buf::Country)
         then do:
            countryService:GetDescription(buf::Country, ctryDesc).
            buf::CountryDescription = ctryDesc.                 
         end.

         qry:get-next().

      end.

      finally:
         if qry:is-open then
            qry:query-close().
         delete object qry  no-error. 
         delete object buf no-error.
         delete object dsEntity  no-error.
      end finally.  
   end method.

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

      if entityURI = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
      then do on error undo, throw:
         this-object:PopulateCtryDesc(input-output dataset-handle dsEntity by-reference).
      end.   
   
      finally:
         delete object dsEntityKey no-error.
         delete object dsEntity no-error.
      end finally.
   end method.
         
end class.
