using com.qad.base.address.IEmployee.
using com.qad.base.address.EmployeeBase.

block-level on error undo, throw.

class com.extensions.xxconference.employees.EmployeeExt 
        inherits EmployeeBase 
        implements IEmployee:

   method public override void Initialize (output dataset-handle dsEmployee):
      define variable cPrefix          as character initial "S-"        no-undo.
      define variable cJob             as character initial "Speaker"   no-undo.
      define variable cCity            as character initial "New York City" no-undo.
      define variable cTaxZone         as character initial "#US"       no-undo.

      define variable buf              as handle      no-undo.
      define variable qry              as handle      no-undo.
      define variable dsInitEmployee   as handle no-undo.

      /* Call the standard code */
      super:Initialize(output dataset-handle dsInitEmployee by-reference).      

      create dataset dsEmployee.
      dsEmployee:create-like(dsInitEmployee).
      dsEmployee:copy-dataset(dsInitEmployee, false, true, true).

      create query qry.
      buf = dsEmployee:get-buffer-handle("ttEmployee").
      qry:set-buffers(buf).
      qry:query-prepare("for each ttEmployee").
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:
         assign
            buf::EmployeeCode = cPrefix
            buf::JobTitle = cJob
            buf::City = cCity
            buf::TaxZone = cTaxZone.
         qry:get-next().
      end.

      finally:
         if qry:is-open then
            qry:query-close().
         delete object qry  no-error. 
         delete object buf no-error.
         delete object dsEmployee no-error.
      end finally.
   end method.

end class.