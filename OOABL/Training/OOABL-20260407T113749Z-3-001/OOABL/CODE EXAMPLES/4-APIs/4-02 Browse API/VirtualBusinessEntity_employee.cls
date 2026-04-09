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

   method private character BrowseAPIForEmployees():
      define variable qry as handle no-undo.
      define variable buf as handle no-undo.

      define variable BcBrowseService as IBcBrowseHelper no-undo.

      define variable startPosition as character no-undo.
      define variable endPosition as character no-undo.
      define variable hasMore as logical no-undo.
      define variable browseResults as handle no-undo.
      define variable empCode as character no-undo initial "".
      define variable empName as character no-undo initial "".
      define variable cResult as character no-undo initial "".
      
      BcBrowseService = QraServices:GetBcBrowseHelper().

      dataset dsBrowseCondition:empty-dataset().
      create ttSearchCondition.
      assign
         ttSearchCondition.FieldName        = "employee.employeeCode"
         ttSearchCondition.SearchOperator   = BcBrowseSearchOperator:STARTS_WITH
         ttSearchCondition.SearchValue1     = "S-"
         ttSearchCondition.SearchValue1Type = SearchValueType:LITERAL.
      create ttSortCondition.
      assign
         ttSortCondition.FieldName        = "employee.addressSearchName"
         ttSortCondition.IsDescending     = no.
  
      BcBrowseService:GetBrowseResults("urn:browse:bebrowse:com.qad.erp.base.employees",
                                       input substitute("page=1,pageSize=10,pageAction=next"),
                                       input ?,
                                       input "employee.employeeCode,employee.addressSearchName",
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
            empCode = buf:buffer-field("employee.employeeCode"):buffer-value
            empName = buf:buffer-field("employee.addressSearchName"):buffer-value
            cResult   = cResult +
                      empCode + " (" + empName + ")" + "\n".

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
