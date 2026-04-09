using com.qad.base.address.IEmployee.
using com.qad.base.address.EmployeeBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.
using com.qad.base.BaseUtils.
/* 
using com.qad.base.BaseServices.
using com.qad.base.address.ICountry.
*/
block-level on error undo, throw.

class com.extensions.xxconference.employees.EmployeeExt 
        inherits EmployeeBase 
        implements IEmployee:

   {com/qad/base/address/dsEmployee.i &PREFIX = "Temp"}

   method private void SkipEmptyContacts(input-output dataset-handle dsEmployee):
      define variable bufEmployee      as handle      no-undo.
      define variable bufContacts      as handle      no-undo.
      define variable qry      as handle      no-undo.

      assign
         bufEmployee = dsEmployee:get-buffer-handle("ttEmployee")
         bufContacts = dsEmployee:get-buffer-handle("ttEmployeeContact").

      create query qry.
      qry:set-buffers(bufEmployee, bufContacts).
      qry:query-prepare("for each ttEmployee, each ttEmployeeContact of ttEmployee").
      
      do transaction:
         qry:query-open().
         qry:get-first().
         do while not qry:query-off-end:
            if BaseUtils:IsNullOrEmpty(bufContacts::ContactTelephone) and
               BaseUtils:IsNullOrEmpty(bufContacts::ContactEmail)
            then do:
               bufContacts:buffer-delete().
            end. 
            
            qry:get-next().
         end.
      end.

      finally:
         if qry:is-open then
            qry:query-close().
         delete object qry  no-error. 
         delete object bufEmployee no-error.
         delete object bufContacts no-error.
         delete object dsEmployee  no-error.
      end finally.  
   end method.

   method public override void Update (input dataset-handle dsEmployee):
      dataset dsTempEmployee:empty-dataset.

      this-object:SkipEmptyContacts(input-output dataset-handle dsEmployee).

      /* Call the standard code */
      super:Update(input dataset-handle dsEmployee by-reference).

      finally:
         delete object dsEmployee  no-error.
      end finally.  
   end method.


end class.