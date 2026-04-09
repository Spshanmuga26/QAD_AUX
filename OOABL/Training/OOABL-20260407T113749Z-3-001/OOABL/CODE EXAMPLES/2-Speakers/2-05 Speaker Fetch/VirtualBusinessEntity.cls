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
         this-object:PopulatePersonInfo(input-output dataset-handle dsEntity by-reference).
      end.   
   
      finally:
         delete object dsEntityKey no-error.
         delete object dsEntity no-error.
      end finally.
   end method.

   method private void PopulatePersonInfo(input-output dataset-handle dsEntity):
      define variable bufSpeaker       as handle    no-undo.
      define variable bufContacts      as handle    no-undo.
      define variable qry              as handle    no-undo.
      define variable cInfo            as character no-undo.

      assign
         bufSpeaker  = dsEntity:get-buffer-handle("ttSpeakers")
         bufContacts = dsEntity:get-buffer-handle("ttSpeakerContacts").

      create query qry.
      qry:set-buffers(bufSpeaker, bufContacts).
      qry:query-prepare("for each ttSpeakers, each ttSpeakerContacts where ttSpeakerContacts.SpeakerID = ttSpeakers.SpeakerID break by ttSpeakers.SpeakerID").      
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:
         if qry:first-of(1)
         then cInfo = "".

         cInfo = cInfo + bufContacts::ContactType + ": " + bufContacts::ContactValue + "\n".

         if qry:last-of(1)
         then bufSpeaker::PersonInfo = cInfo.
         
         qry:get-next().
      end.

      finally:
         if qry:is-open then
            qry:query-close().
         delete object qry  no-error. 
         delete object bufSpeaker no-error.
         delete object bufContacts no-error.
         delete object dsEntity  no-error.
      end finally.  
   end method.   
        
end class.
