using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:

   define private variable DEFAULT_TYPE   as character initial "qad" no-undo.
   define private variable DEFAULT_CTRY   as character initial "US" no-undo.
   define private variable DEFAULT_EMAIL  as character initial "mfg@qad.com" no-undo.

   method public override void Initialize(input entityURI as character, 
                                          output dataset-handle dsEntity):
      define variable qry  as handle no-undo.
      define variable buf  as handle no-undo.
        
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
               buf::EmploymentType  = DEFAULT_TYPE
               buf::Country         = DEFAULT_CTRY
               buf::EMail           = DEFAULT_EMAIL
               buf::IsActive        = yes.
            
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
