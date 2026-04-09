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

   method public override void Create (input dataset-handle dsEmployee):

      this-object:AddPrimaryContact(
         input-output dataset-handle dsEmployee by-reference
      ).

      /* Call the standard code */
      super:Create(input dataset-handle dsEmployee by-reference).

      finally:
         delete object dsEmployee no-error.
      end finally.
   end method.   

   method private void AddPrimaryContact(input-output dataset-handle dsEmployee):
      
      dataset dsTempEmployee:empty-dataset.

      /* Copy the employees to the typed dataset */
      dataset dsTempEmployee:copy-dataset(dsEmployee, false, true, true).

      for each ttTempEmployee
      no-lock:
         if not can-find(first ttTempEmployeeContact where
                               ttTempEmployeeContact.EntityID = ttTempEmployee.EntityID and
                               ttTempEmployeeContact.EmployeeCode = ttTempEmployee.EmployeeCode and
                               ttTempEmployeeContact.IsPrimaryContact = true)
         then do:
            create ttTempEmployeeContact.
            assign
               ttTempEmployeeContact.EntityID      = ttTempEmployee.EntityID
               ttTempEmployeeContact.EmployeeCode  = ttTempEmployee.EmployeeCode
               ttTempEmployeeContact.ContactName   = ttTempEmployee.AddressSearchName
               ttTempEmployeeContact.ContactEmail  = ttTempEmployee.EMail
               ttTempEmployeeContact.ContactTelephone = ttTempEmployee.Telephone
               ttTempEmployeeContact.IsPrimaryContact = true.
         end.

      end.
      dsEmployee:copy-dataset(dataset dsTempEmployee:handle, false, true, true).

      finally:
         delete object dsEmployee  no-error.
      end finally.  
   end method.

end class.