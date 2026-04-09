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

	method public override void Delete(input entityURI as character, input dataset-handle dsEntity):

      if entityURI = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
      then do on error undo, throw:
         this-object:IsValidForDelete(input dataset-handle dsEntity by-reference).
      end.   

      /* Call the standard code */
      super:Delete(
         input entityURI,
         input dataset-handle dsEntity by-reference).

      finally:
         delete object dsEntity no-error.
      end finally.
   end method.    

   method private void IsValidForDelete(input dataset-handle dsEntity):
      define variable qry        as handle no-undo.
      define variable buf        as handle no-undo.
      define variable dsFetch    as handle no-undo.
      define variable bufFetch   as handle no-undo.
      
      define variable valMsgs as List                no-undo.
      define variable msg     as Message             no-undo.

      define variable isFound as logical no-undo.
      define variable findString as character no-undo.

      assign valMsgs = new List()
             buf     = dsEntity:get-buffer-handle("ttSpeakers").

      create query qry.      
      qry:set-buffers(buf).
      qry:query-prepare("for each ttSpeakers").
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end
      on error undo, throw:
         dataset dsKeyField:empty-dataset().
         create ttKeyField.
         assign
            ttKeyField.KeyFieldName = "SpeakerID"
            ttKeyField.KeyFieldValue = buf::SpeakerID.

         super:Fetch(
               input "urn:be:com.extensions.xxconference.Speakers.ISpeakers",
               input dataset dsKeyField by-reference,
               output dataset-handle dsFetch by-reference
            ).
         
         bufFetch = dsFetch:get-buffer-handle("ttSpeakers").    

         findString = "where SpeakerID = " + buf::SpeakerID + " and IsActive = true".

         isFound = bufFetch:find-unique(findString) no-error.

         if isFound
         then do:
            assign msg = new Message(1, "Delete Not Allowed. Active Speaker." ).
            valMsgs:Add(msg).
         end.

         qry:get-next().
         finally:
            delete object bufFetch no-error.
            delete object dsFetch no-error.
         end finally.
      end.

      if not valMsgs:IsEmpty()
      then undo, throw new BaseError(valMsgs).
      
      finally:
         if qry:is-open
            then qry:query-close().
 
         delete object qry no-error.
         delete object buf no-error.
         delete object dsEntity no-error.
      end finally.
   end method.  

end class.
