using com.qad.base.address.IEmployee.
using com.qad.base.address.EmployeeBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.

block-level on error undo, throw.

class com.extensions.xxconference.employees.EmployeeExt 
        inherits EmployeeBase 
        implements IEmployee:

   {com/qad/base/address/dsEmployee.i &PREFIX = "Temp"}

   method public override void Delete (input dataset-handle dsEmployee):

      this-object:IsValidForDelete(
         input dataset-handle dsEmployee by-reference
      ).

      /* Call the standard code */
      super:Delete(input dataset-handle dsEmployee by-reference).

      finally:
         delete object dsEmployee no-error.
      end finally.
   end method.

   method private void IsValidForDelete(input dataset-handle dsEmployee):
      define variable msg        as Message     no-undo.
      define variable valMsgs    as List        no-undo.
      define variable buf        as handle      no-undo.
      define variable qry        as handle      no-undo.
      define variable cJob       as character   no-undo initial "Speaker" .

      valMsgs = new List().

      create query qry.
      buf = dsEmployee:get-buffer-handle("ttEmployee").
      qry:set-buffers(buf).
      qry:query-prepare("for each ttEmployee").
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:
         
         dataset dsTempEmployee:empty-dataset.
         super:Fetch(input buf::EntityID, 
                     input buf::EmployeeCode, 
                     output dataset dsTempEmployee by-reference).

         for each ttTempEmployee
         on error undo, throw:
            if ttTempEmployee.JobTitle = cJob and ttTempEmployee.IsActive
            then do:
               assign msg = new Message(1, "Delete Not Allowed. Active Speaker." ).
               valMsgs:Add(msg).
            end.   
         end.   

         qry:get-next().
      end.
      qry:query-close().

      if not valMsgs:IsEmpty()
      then undo, throw new BaseError(valMsgs).

      finally:
         if qry:is-open then
            qry:query-close().
         delete object qry  no-error. 
         delete object buf no-error.
         delete object dsEmployee  no-error.
      end finally.  
   end method.  

end class.