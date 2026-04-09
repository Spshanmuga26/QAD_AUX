using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

using com.qad.base.BaseServices.
using com.qad.base.BaseUtils.

using com.qad.qra.QraServices.
using com.qad.qra.browsev2.IBrowseServiceV2.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:
   
   {com/qad/qra/browse/dsBrowseCondition.i}

   method private character BrowseAPIForCustomers():
      define variable qry as handle no-undo.
      define variable buf as handle no-undo.

      define variable aBrowseService as IBrowseServiceV2 no-undo.

      define variable startPosition as character no-undo.
      define variable endPosition as character no-undo.
      define variable hasMore as logical no-undo.
      define variable browseResults as handle no-undo.
      define variable sName as character no-undo initial "".
      define variable sEMail as character no-undo initial "".
      define variable cResult as character no-undo initial "".
      
      aBrowseService = QraServices:GetBrowseServiceV2().

      aBrowseService:GetBrowseResults(input "urn:browse:mfg:ad001",
                                      input "FIRST",
                                      input 10,
                                      input "",
                                      input dataset dsBrowseCondition by-reference,
                                      output startPosition,
                                      output endPosition,
                                      output hasMore,
                                      output dataset-handle browseResults by-reference). 

      buf = browseResults:get-buffer-handle(1).         
      create query qry.   
      qry:set-buffers(buf).
      qry:query-prepare("for each " + buf:table + " no-lock").
      qry:query-open().
      qry:get-first().
      
      do while not qry:query-off-end on error undo, throw:

         assign
            sName   = buf:buffer-field("cm_mstr.cm_addr"):buffer-value
            sEMail  = buf:buffer-field("ad_mstr.ad_sort"):buffer-value
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
