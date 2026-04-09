using com.qad.base.address.IEmployee.
using com.qad.base.address.EmployeeBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.
using com.qad.base.BaseUtils.

using com.qad.base.BaseServices.

using com.qad.qra.QraServices.
using com.qad.qra.be.IVirtualBusinessEntity.

block-level on error undo, throw.

class com.extensions.xxconference.employees.EmployeeExt 
        inherits EmployeeBase 
        implements IEmployee:

   {com/qad/base/address/dsEmployee.i &PREFIX = "Temp"}

   method public override void Create (input dataset-handle dsEmployee):

      /* Call the standard code */
      super:Create(input dataset-handle dsEmployee by-reference).

      this-object:CreateSpeaker(
         input dataset-handle dsEmployee by-reference
      ).

      finally:
         delete object dsEmployee no-error.
      end finally.
   end method.  

   method private void CreateSpeaker(input dataset-handle dsEmployee):
      define variable bufEmployee      as handle      no-undo.
      define variable qry              as handle      no-undo.
      define variable vbeService       as IVirtualBusinessEntity no-undo.
      define variable entityUri        as character no-undo.
      define variable spCode           as integer no-undo.

      define variable qrySpeaker       as handle no-undo.
      define variable bufSpeaker       as handle no-undo.
      define variable hSpeaker         as handle no-undo.
      

      assign
         bufEmployee = dsEmployee:get-buffer-handle("ttEmployee")
         entityUri = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
         vbeService = QraServices:GetVirtualBusinessEntity().

      create query qry.
      qry:set-buffers(bufEmployee).
      qry:query-prepare("for each ttEmployee").
      qry:query-open().
      qry:get-first().

      do while not qry:query-off-end
      on error undo, throw:
         if bufEmployee::JobTitle = "Speaker"
         then do:
            spCode = integer(replace(bufEmployee::EmployeeCode, "S-", "")) no-error.

            if spCode > 0 then do:
               dataset dsKeyField:empty-dataset().
               create ttKeyField.
               assign
                  ttKeyField.KeyFieldName = "SpeakerID"
                  ttKeyField.KeyFieldValue = string(spCode).
            end.      

             if not vbeService:Exists(input entityUri, 
                                      input dataset dsKeyField by-reference)
             then do:

               /* initialize defaults */
               vbeService:Initialize(input entityUri, output dataset-handle hSpeaker by-reference).

               create query qrySpeaker.
               bufSpeaker = hSpeaker:get-buffer-handle("ttSpeakers").
               qrySpeaker:set-buffers(bufSpeaker).
               qrySpeaker:query-prepare("for each ttSpeakers").
               qrySpeaker:query-open().
               qrySpeaker:get-first().

               do while not qrySpeaker:query-off-end:
                  assign
                     bufSpeaker::SpeakerID   = spCode
                     bufSpeaker::SpeakerName = bufEmployee::AddressSearchName.
                  qrySpeaker:get-next().
               end.
               
               vbeService:Create(input entityUri, input dataset-handle hSpeaker by-reference).
               
             end.                         
         end. 
         
         qry:get-next().

         finally:
            if valid-object(qrySpeaker) and qrySpeaker:is-open then
               qrySpeaker:query-close().
            delete object qrySpeaker no-error. 
            delete object bufSpeaker no-error.
            delete object hSpeaker  no-error.
         end finally.
      end.

      finally:
         if qry:is-open then
            qry:query-close().
         delete object qry  no-error. 
         delete object bufEmployee no-error.
         delete object dsEmployee  no-error.
      end finally.  
   end method.   

end class.