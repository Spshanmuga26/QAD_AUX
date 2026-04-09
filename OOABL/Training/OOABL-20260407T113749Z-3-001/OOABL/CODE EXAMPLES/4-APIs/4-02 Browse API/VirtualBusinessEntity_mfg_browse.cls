using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

using com.qad.base.BaseServices.
using com.qad.base.BaseUtils.

using com.qad.qra.QraServices.
using com.qad.qra.browse.IBcBrowseHelper.
using com.qad.qra.browse.BcBrowseSearchOperator.
using com.qad.qra.browse.SearchValueType.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:
   
   {com/qad/qra/browse/dsBrowseCondition.i}

  method private character BrowseAPIForSpeakers():
      define variable qry as handle no-undo.
      define variable buf as handle no-undo.

      define variable BcBrowseService as IBcBrowseHelper no-undo.

      define variable startPosition as character no-undo.
      define variable endPosition as character no-undo.
      define variable hasMore as logical no-undo.
      define variable browseResults as handle no-undo.
      define variable sName as character no-undo initial "".
      define variable sEMail as character no-undo initial "".
      define variable cResult as character no-undo initial "".
      
      BcBrowseService = QraServices:GetBcBrowseHelper().

      BcBrowseService:GetBrowseResults("urn:browse:bebrowse:com.extensions.xxconference.speakers",
                                       input substitute("page=1,pageSize=10,pageAction=next"),
                                       input ?,
                                       input ?,
                                       input dataset dsBrowseCondition by-reference,
                                       output hasMore,
                                       output startPosition,
                                       output endPosition,
                                       output dataset-handle browseResults by-reference).

      buf = browseResults:get-buffer-handle(1).         
      create query qry.   
      qry:set-buffers(buf).
      qry:query-prepare("for each " + buf:table + " no-lock").
      qry:query-open().
      qry:get-first().
      
      do while not qry:query-off-end on error undo, throw:

         assign
            sName   = buf:buffer-field("speakers.speakerName"):buffer-value
            sEMail  = buf:buffer-field("speakers.email"):buffer-value
            cResult   = cResult +
                      sName + " (" + sEMail + ")" + "\n".

         qry:get-next().
      end. 
      
      return cResult.

      finally:
         if qry:is-open then
            qry:query-close().
         delete object qry  no-error. 
         delete object buf no-error.
         delete object browseResults no-error.
      end finally.  
   end method.  
   
end class.
