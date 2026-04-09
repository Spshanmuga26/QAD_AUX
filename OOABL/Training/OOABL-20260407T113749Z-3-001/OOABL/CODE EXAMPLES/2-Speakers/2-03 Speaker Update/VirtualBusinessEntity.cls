using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:

   {com/qad/qra/base/dsKeyField.i}
         
   define private variable DEFAULT_TYPE   as character initial "qad" no-undo.
   define private variable DEFAULT_CTRY   as character initial "US" no-undo.
   define private variable DEFAULT_EMAIL  as character initial "mfg@qad.com" no-undo.

	method public override void Update(input entityURI as character, input dataset-handle dsEntity):

      if entityURI = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
      then do on error undo, throw:
         this-object:IsValidSpeaker(input dataset-handle dsEntity by-reference).
      end.   

      /* Call the standard code */
      super:Update(
         input entityURI,
         input dataset-handle dsEntity by-reference).

		finally:
         delete object dsEntity no-error.
      end finally.
   end method.

   method private void IsValidSpeaker(input dataset-handle dsEntity):
      define variable qry        as handle   no-undo.
      define variable buf        as handle   no-undo.
      define variable valMsgs    as List     no-undo.
      define variable msg        as Message  no-undo.

      assign valMsgs = new List()
             buf     = dsEntity:get-buffer-handle("ttSpeakers").

      create query qry.      
      qry:set-buffers(buf).
      qry:query-prepare("for each ttSpeakers").
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:
         if buf::SpeakerName = "" then do:
            assign msg = new Message(1, "SpeakerName is mandatory").
            msg:SetContext(buf:buffer-field("SpeakerName")).
            valMsgs:Add(msg).            
         end.
         if buf::Email = "" then do:
            assign msg = new Message(2, "Email is mandatory").
            msg:SetContext(buf:buffer-field("Email")).
            valMsgs:Add(msg).            
         end.

         qry:get-next().
      end.

      if not valMsgs:IsEmpty()
      then undo, throw new BaseError(valMsgs).

      finally:
         if qry:is-open
            then qry:query-close().
 
         delete object qry no-error.
         delete object buf no-error.
         assign qry = ?
                buf = ?.
         delete object dsEntity no-error.
      end finally.
   end method.  

end class.
