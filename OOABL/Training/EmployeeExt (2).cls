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

   method public override void Update (input dataset-handle dsEmployee):
      dataset dsTempEmployee:empty-dataset.

      /* Copy the employees to the typed dataset */
      dataset dsTempEmployee:copy-dataset(dsEmployee, false, true, true).
      for each ttTempEmployee 
      no-lock:
         if ttTempEmployee.EndDate = ? and ttTempEmployee.IsActive = yes
         then ttTempEmployee.EndDate = today + 7.
         
         if ttTempEmployee.EndDate < today
         then ttTempEmployee.IsActive = false.
      end.
      dsEmployee:copy-dataset(dataset dsTempEmployee:handle, false, true, true).

      /* Call the standard code */
      super:Update(input dataset-handle dsEmployee by-reference).

      finally:
         delete object dsEmployee  no-error.
      end finally.  
   end method.

end class.