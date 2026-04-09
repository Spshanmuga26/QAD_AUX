using com.qad.base.address.IEmployee.
using com.qad.base.address.EmployeeBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.
using com.qad.base.BaseUtils.

using com.qad.base.BaseServices.
using com.qad.base.address.ICountry.

block-level on error undo, throw.

class com.extensions.xxconference.employees.EmployeeExt 
        inherits EmployeeBase 
        implements IEmployee:

   {com/qad/base/address/dsEmployee.i &PREFIX = "Temp"}

   method public override void Fetch (input entityID as int64,
                                      input employeeCode as character,
                                      output dataset-handle dsEmployee).
      define variable countryService as ICountry no-undo.

      /* Call the standard code */
      super:Fetch(input entityID, 
                  input employeeCode, 
                  output dataset-handle dsEmployee by-reference).

      countryService = BaseServices:GetCountry().

      /* Copy the employees to the typed dataset */
      dataset dsTempEmployee:copy-dataset(dsEmployee, false, true, true).
      for each ttTempEmployee 
      no-lock:
         if countryService:IsValidCountry(ttTempEmployee.CountryCode) and
            countryService:IsECCountry(ttTempEmployee.CountryCode)
         then ttTempEmployee.CustomCombo0 = "yes".
         else ttTempEmployee.CustomCombo0 = "no".
      end.
      dsEmployee:copy-dataset(dataset dsTempEmployee:handle, false, true, true).
                                      
      finally:
         delete object dsEmployee  no-error.
      end finally.  
   end method.  


end class.