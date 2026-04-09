using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.base.BaseError.

using com.qad.base.BaseServices.
using com.qad.base.address.ICountry.
using com.qad.base.address.IEmployee.
using com.qad.base.BaseUtils.

block-level on error undo, throw.

class com.extensions.xxconference.be.VirtualBusinessEntity 
        inherits VirtualBusinessEntityBase 
        implements IVirtualBusinessEntity:

   {com/qad/qra/base/dsKeyField.i}
   {com/qad/base/address/dsEmployee.i}
         
   define private variable DEFAULT_TYPE   as character initial "qad" no-undo.
   define private variable DEFAULT_CTRY   as character initial "US" no-undo.
   define private variable DEFAULT_EMAIL  as character initial "mfg@qad.com" no-undo.

   method private void CreateEmployee(input dataset-handle dsEntity):
      define variable qry              as handle no-undo.
      define variable buf              as handle no-undo.
      define variable empCode          as character no-undo.
      define variable EmployeeService  as IEmployee no-undo.
      define variable dsInitEmployee   as handle no-undo. 
      define variable dsCreateEmployee as handle no-undo. 

      EmployeeService = BaseServices:GetEmployee(). 

      assign
         buf = dsEntity:get-buffer-handle("ttSpeakers").

      create query qry.
      qry:set-buffers(buf).
      qry:query-prepare("for each ttSpeakers").
      qry:query-open().
      qry:get-first().
      do while not qry:query-off-end:

         empCode = "S-" + string(buf::SpeakerID).   

         if not EmployeeService:Exists (input '10USACO',
                                        input empCode)
         then do:
            EmployeeService:Initialize(output dataset-handle dsInitEmployee by-reference).
            
            /* Copy dataset */
            dataset dsEmployee:copy-dataset(dsInitEmployee, false, true, true).

            for each ttEmployee exclusive-lock:
               ttEmployee.EmployeeCode = empCode.
               ttEmployee.AddressSearchName = buf::SpeakerName.
            end.

            /* Create new dataset */
            create dataset dsCreateEmployee.            
            dsCreateEmployee:copy-dataset(dataset dsEmployee:handle, false, true, true).            
            
            do transaction:
               EmployeeService:Create(input dataset-handle dsCreateEmployee by-reference).
            end.   

         end. 

         qry:get-next().
      end.

      finally:
         if qry:is-open
            then qry:query-close().
 
         delete object qry no-error.
         delete object buf no-error.
         delete object dsEntity no-error.
         delete object dsInitEmployee no-error.
         delete object dsCreateEmployee no-error.
      end finally.
   end method.

	method public override void Create(input entityURI as character, input dataset-handle dsEntity):

      if entityURI = "urn:be:com.extensions.xxconference.Speakers.ISpeakers"
      then do on error undo, throw:
         this-object:CreateEmployee(input dataset-handle dsEntity by-reference).
      end.   

      /* Call the standard code */
      super:Create(
         input entityURI,
         input dataset-handle dsEntity by-reference).

		finally:
         delete object dsEntity no-error.
      end finally.
   end method.

end class.
