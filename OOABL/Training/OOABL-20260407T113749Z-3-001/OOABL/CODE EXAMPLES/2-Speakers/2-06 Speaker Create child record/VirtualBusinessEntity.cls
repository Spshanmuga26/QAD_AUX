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

   method private void CreatePrimaryContact(input-output dataset-handle dsEntity):
      define variable qry        as handle no-undo.
      define variable buf        as handle no-undo.
      define variable hContact   as handle no-undo.
      define variable findString as character no-undo.
      define variable isFound    as logical no-undo.
      
      assign
         buf      = dsEntity:get-buffer-handle("ttSpeakers")
         hContact = dsEntity:get-buffer-handle("ttSpeakerContacts").

      create query qry.
      qry:set-buffers(buf).
      qry:query-prepare("for each ttSpeakers").
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:

         findString = "where SpeakerID = " + buf::SpeakerID + " and ContactLine = 1 ".
         isFound = hContact:find-unique(findString) no-error.

         if not isFound then
         do transaction:
            hContact:buffer-create().
            assign
               hContact::SpeakerID     = buf::SpeakerID
               hContact::ContactLine   = 1
               hContact::ContactType   = "Email"
               hContact::ContactValue  = buf::EMail
               hContact::IsPrimary     = true.
            hContact:buffer-release().
         end.

         qry:get-next().
      end.

      finally:
         if qry:is-open
            then qry:query-close().

         delete object qry no-error.
         delete object buf no-error.
         delete object hContact no-error.
         delete object dsEntity no-error.
      end finally.
   end method.



   method public override void Create(input entityURI as character, input dataset-handle dsEntity):

      if entityURI = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
      then do on error undo, throw:
         this-object:CreatePrimaryContact(input-output dataset-handle dsEntity by-reference).
      end.   

      /* Call the standard code */
      super:Create(
         input entityURI,
         input dataset-handle dsEntity by-reference).

		finally:
         delete object dsEntity no-error.
      end finally.
   end method.

end class.
