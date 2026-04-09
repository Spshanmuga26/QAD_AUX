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

      this-object:IsValidForCreate(
         input dataset-handle dsEmployee by-reference
      ).

      /* Call the standard code */
      super:Create(input dataset-handle dsEmployee by-reference).

      finally:
         delete object dsEmployee no-error.
      end finally.
   end method.   

   method private void IsValidForCreate(input dataset-handle dsEmployee):
      define variable cPrefix    as character   no-undo initial "S-" .
      define variable cJob       as character   no-undo initial "Speaker" .
      define variable msg        as Message     no-undo.
      define variable valMsgs    as List        no-undo.

      valMsgs = new List().
      dataset dsTempEmployee:empty-dataset.

      /* Copy the employees to the typed dataset */
      dataset dsTempEmployee:copy-dataset(dsEmployee, false, true, true).

      for each ttTempEmployee 
      no-lock:
         if (ttTempEmployee.JobTitle = cJob and not ttTempEmployee.EmployeeCode begins cPrefix) 
         then do:
            assign msg = new Message(1, "EmployeeCode should contain prefix " + cPrefix + " for employee with job title " + cJob ).
            msg:SetContext(buffer ttTempEmployee:buffer-field("EmployeeCode")).
            valMsgs:Add(msg).
         end.
      end.

      if not valMsgs:IsEmpty()
      then undo, throw new BaseError(valMsgs).

      finally:
         delete object dsEmployee  no-error.
      end finally.  
   end method.

end class.