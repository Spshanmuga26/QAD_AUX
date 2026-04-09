
using com.qad.base.BaseServices.
using com.qad.base.BaseUtils.
using com.qad.base.label.ILabelMaster. 

using com.qad.qra.QraServices.
using com.qad.qra.globalization.ITranslatedStringProvider.

   method private void PopulatePersonInfo(input-output dataset-handle dsEntity):
      define variable bufSpeaker       as handle    no-undo.
      define variable bufContacts      as handle    no-undo.
      define variable qry              as handle    no-undo.
      define variable cInfo            as character no-undo.
      define variable cLabel           as character no-undo.

      define variable labelMasterService     as ILabelMaster      no-undo. 
      labelMasterService = BaseServices:GetLabelMaster().

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
         then assign cInfo = "" cLabel = "".

         if bufContacts::ContactType = "Email"
         then cLabel = this-object:TranslationService:GetString("WORK_EMAIL").

         if bufContacts::ContactType = "Website"
         then cLabel = labelMasterService:GetLongLabelByTerm(
                                          input 'US',
                                          input "STATIC_WEB_CONTEXT_URL") .

         cInfo = cInfo + cLabel + ": " + bufContacts::ContactValue + "\n".

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