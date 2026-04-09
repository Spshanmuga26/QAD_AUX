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

   method private void IsValidContacts(input dataset-handle dsEntity):
      define variable qry           as handle   no-undo.
      define variable bufSpeaker    as handle   no-undo.
      define variable bufContacts   as handle   no-undo.
      define variable isFound       as logical  no-undo.
      define variable iQty          as integer  no-undo.
      define variable valMsgs       as List     no-undo.
      define variable msg           as Message  no-undo.
      
      assign
         bufSpeaker  = dsEntity:get-buffer-handle("ttSpeakers")
         bufContacts = dsEntity:get-buffer-handle("ttSpeakerContacts")
         valMsgs     = new List()
         iQty        = -1.

      create query qry.
      qry:set-buffers(bufSpeaker, bufContacts).
      qry:query-prepare("for each ttSpeakers, each ttSpeakerContacts where ttSpeakerContacts.SpeakerID = ttSpeakers.SpeakerID break by ttSpeakers.SpeakerID").      
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:
         if qry:first-of(1)
         then iQty = 0.

         if bufContacts::IsPrimary then iQty = iQty + 1.

         if qry:last-of(1)
         then do:
            if iQty = 0 then do:
               assign msg = new Message(1, "At least one contact should be primary" ).
               valMsgs:Add(msg).
            end.
            if iQty > 1 then do:
               assign msg = new Message(2, "Only one contact can be primary" ).
               valMsgs:Add(msg).
            end.
         end.   
         
         qry:get-next().
      end.
      if iQty < 0 then do:
         assign msg = new Message(3, "At least one contact should be primary" ).
         valMsgs:Add(msg).
      end.


      if not valMsgs:IsEmpty()
      then undo, throw new BaseError(valMsgs).

      finally:
         if qry:is-open
            then qry:query-close().

         delete object qry no-error.
         delete object bufSpeaker no-error.
         delete object bufContacts no-error.
         delete object dsEntity no-error.
      end finally.
   end method.

	method public override void Update(input entityURI as character, input dataset-handle dsEntity):

      if entityURI = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
      then do on error undo, throw:
         this-object:isValidContacts(input dataset-handle dsEntity by-reference).
      end.   

      /* Call the standard code */
      super:Update(
         input entityURI,
         input dataset-handle dsEntity by-reference).

		finally:
         delete object dsEntity no-error.
      end finally.
   end method.

end class.
