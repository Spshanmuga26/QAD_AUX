using com.qad.approvals.entityv3.IApprovalVirtualEntity.
using com.qad.approvals.GenericApprovalConstants.
using com.qad.approvals.GenericApprovalServices.
using com.qad.approvals.IGenericApproval.
using com.qad.approvals.entityv2.IGenericApprovalEntityV2.
using com.qad.approvals.config.IGenericApprovalConfiguration.
using com.qad.qra.resource.ResourceIdentityUtils.
using com.qad.qra.resource.IResourceResolver.
using com.qad.qra.transaction.ITransactionManager.
/* using com.qad.qra.businessentity.IEntityFetchService. */
using com.qad.qra.QraServices.
using com.qad.lang.IList.
using com.qad.qra.core.GlobalServiceLocator.
using com.qad.qra.QraError.
using com.qad.lang.Message.
using com.qad.lang.Properties.
using com.qad.qra.logging.ILogger.
using com.qad.qra.config.QraConfig.
using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.extensible.IInterfaceDatasets.
using com.qad.qra.metadata.IEntityMapping.
using com.qad.qra.QraMessageKey.
using com.qad.base.BaseServices.
 
using com.qad.base.currency.ICurrency.
routine-level on error undo, throw.


class com.hsio.xxcreditnote.approval.entity.ApprovalVirtualEntityCust implements IApprovalVirtualEntity:

    {com/qad/approvals/dsApproval.i}
    {com/qad/approvals/entityv3/dsApprovalField.i}
    {com/qad/approvals/entityv3/dsApprovalFieldList.i}
    {com/qad/approvals/entityv3/dsEntityFieldValidation.i}
    {com/qad/approvals/entityv3/dsApprovalAction.i}
    {com/qad/approvals/config/dsApprovalConfiguration.i}
 
 
    {com/qad/qra/base/dsKeyField.i }
    {com/qad/qra/metadata/dsEntityMapping.i}
    
    define private variable logger as class ILogger no-undo.
    define variable virtualBe   as IVirtualBusinessEntity no-undo.
    define variable virtualBeDs as IInterfaceDatasets     no-undo.
    define variable config      as class IGenericApprovalConfiguration no-undo.

method public void VirtualBEFetch(input entityInstanceUri as character,
                                     output dataset-handle dsEntityVirtual):
         
        define variable entityURI as character no-undo.
         
        this-object:ParseInstanceUri(input entityInstanceUri,
                                     output EntityURI,
                                     output dataset dsKeyField by-reference).
        virtualBe:Fetch(
            input entityURI,
            input dataset dsKeyField,
            output dataset-handle dsEntityVirtual by-reference).
		
		finally:
           delete object dsEntityVirtual no-error.
        end finally.
    end.


method public void ParseInstanceUri (input entityInstanceUri as character,
                                          output entityURI as character,
                                          output dataset dsKeyField):
       
        define variable uriResolver     as class IResourceResolver no-undo.
        define variable entityMapping   as class IEntityMapping no-undo.
        define variable businessKeys    as class IList no-undo.
        define variable mappingKeyFields as character no-undo.
        define variable iA              as integer no-undo.
 
        uriResolver     = QraServices:GetResourceResolver().
        entityMapping   = QraServices:GetEntityMappingService().
         
        uriResolver:SetUri (entityInstanceUri).
        assign entityURI = "urn:" + uriResolver:GetType() mappingKeyFields = "".
message "## entityInstanceUri = "  entityInstanceUri skip.
message "## entityUri=" entityURI skip.       
         /* Check if it's a "be:" resource */  
        if index(entityURI, "be:") = 0 then
            undo, throw new QraError(new Message(QraMessageKey:INVALID_URI, entityURI)).
 
        /*GetEntityMapping*/
        dataset dsEntityMapping:empty-dataset().
        entityMapping:Fetch(input entityURI,
            output dataset dsEntityMapping by-reference).
       
        find first ttEntityMapping
            where ttEntityMapping.EntityUri = entityURI
            no-error.
       
        if available ttEntityMapping then
            assign mappingKeyFields = ttEntityMapping.KeyFields.
        else
            undo, throw new QraError(new Message(QraMessageKey:ENTITY_MAPPING_DOES_NOT_EXIST, entityURI)).
 
        businessKeys = uriResolver:ParseIdentifier().
        if businessKeys:Count <> num-entries(mappingKeyFields) then
            undo, throw new QraError (new Message(QraMessageKey:INVALID_URI, entityURI)).
       
        dataset dsKeyField:empty-dataset().
        do iA = 1 to businessKeys:Count:
            create ttKeyField.
            assign ttKeyField.KeyFieldName  = entry(iA, mappingKeyFields)
                   ttKeyField.KeyFieldValue = businessKeys:Get(iA):ToString().
        end.
 
    end method.
 
    method public character getEntityUri (input entityInstanceUri as character):
 
        define variable uriResolver     as class IResourceResolver no-undo.
 
        uriResolver     = QraServices:GetResourceResolver().
        uriResolver:SetUri (entityInstanceUri).
        return uriResolver:GetType().
 
    end method.
 
    method public character CreateApprovalField (
        input pEntityUri as character,
        input pUserId as character,
        input pFieldName as character,
        input pFieldValue as character,
        input pIsEnable as logical,
        input pIsReadOnly as logical,
        input pIsVisible as logical,
        input pIsRequired as logical,
        input pFieldLabel as character,
        input pDataList as character,
        input pHelp as character,
        input-output dataset dsApprovalField):
 
        create ttApprovalField.
        assign
            ttApprovalField.EntityInstanceUri = pEntityUri
            ttApprovalField.ApproverUserid    = pUserId
            ttApprovalField.FieldName         = pFieldName
            ttApprovalField.FieldValue        = pFieldValue
            ttApprovalField.IsEnable          = pIsEnable
            ttApprovalField.IsReadOnly        = pIsReadOnly
            ttApprovalField.IsVisible         = pIsVisible
            ttApprovalField.IsRequired        = pIsRequired
            ttApprovalField.FieldLabel        = pFieldLabel
            ttApprovalField.DataListCode      = pDataList
            ttApprovalField.HelpId            = pHelp
            .
 
    end method.

method public void GetApprovalFieldList (input entityInstanceUri as character, output dataset dsApprovalFieldList):
 
        define variable entityUri             as character   no-undo.
         
        entityUri         = this-object:getEntityUri(entityInstanceUri).
         
        dataset dsApprovalFieldList:empty-dataset().
        dataset dsApprovalConfiguration:empty-dataset().
 
        config = GenericApprovalServices:GetGenericApprovalConfiguration().
        config:Fetch(input entityUri, output dataset dsApprovalConfiguration by-reference).
 
        for each ttApprovalConfigurationField on error undo, throw:
            create ttApprovalFieldList.
            assign
                ttApprovalFieldList.EntityInstanceUri = entityInstanceUri
                ttApprovalFieldList.FieldName         = ttApprovalConfigurationField.FieldName.
                .
        end.       
    end method.

 define public property CurrencyService as class ICurrency no-undo
        get:
            if not valid-object(CurrencyService) then
                this-object:CurrencyService = BaseServices:GetCurrency().
            return CurrencyService.
        end get.
        set.

method public void SetApprovalFields (input dataset dsApprovalField, input dataset dsApprovalAction):
        define variable dsEntity     as handle no-undo.
        define variable transManager as ITransactionManager no-undo.
        define variable Xid          as character no-undo.
        define variable bufferField  as handle no-undo.
        define variable qry          as handle no-undo.
        define variable qryBuf       as handle no-undo.
 
message '## CUST: SetApprovalFields() -START' skip.
dataset dsApprovalField:write-xml("FILE", "Cust_SetApprovalFields_dsApprovalField_VirtualApprovalEntity" + string(time) + ".xml", yes).
dataset dsApprovalAction:write-xml("FILE", "Cust_SetApprovalFields_dsApprovalAction_VirtualApprovalEntity" + string(time) + ".xml", yes).
 
        transManager = QraServices:GetTransactionManager().
 
        for each ttApprovalField break by ttApprovalField.EntityInstanceUri on error undo, throw:
          
            if first(ttApprovalField.EntityInstanceUri) then
                Xid = transManager:StartTransaction().
 
            if first-of(ttApprovalField.EntityInstanceUri) then do:
                this-object:VirtualBEFetch(input ttApprovalField.EntityInstanceUri,
                                         output dataset-handle dsEntity by-reference).
dsEntity:write-xml("FILE", "Cust_SetApprovalFields_dsEntity" + string(time) + ".xml", yes).
            end.   
 
 
 
 
/*           
            /*SetApprovalFields*/
            dsEntity:get-top-buffer():find-first() no-error.
            if dsEntity:get-top-buffer():available
            then do:
                bufferField = dsEntity:get-top-buffer():buffer-field(ttApprovalField.FieldName) no-error.
                if bufferField:available then do:
                    case bufferField:data-type:
                        when "decimal" then bufferField:buffer-value = decimal(ttApprovalField.FieldValue).
                        when "date" then bufferField:buffer-value = date(ttApprovalField.FieldValue).
                        when "integer" then bufferField:buffer-value = integer(ttApprovalField.FieldValue).
                        when "logical" then bufferField:buffer-value = logical(ttApprovalField.FieldValue).
                    end case.
                end.
                    /*bufferField:buffer-value = if bufferField:data-type = "decimal" then decimal(ttApprovalField.FieldValue)
                                              else if bufferField:data-type = "integer" then integer(ttApprovalField.FieldValue)
                                              else if bufferField:data-type = "datetime" then date(ttApprovalField.FieldValue)
                                              else ttApprovalField.FieldValue.*/
            end.
            if last-of(ttApprovalField.EntityInstanceUri) then do:
                this-object:VirtualBEUpdate(input ttApprovalField.EntityInstanceUri,
                                          input dataset-handle dsEntity by-reference).
            end.
            finally:
                if valid-handle(qry) and
                   qry:is-open
                then qry:query-close().
                 
                delete object qry no-error.
            end finally.
*/
        end.
        if Xid <> "" then do on error undo, throw:
            transManager:Commit(Xid).
          
            catch e as Progress.Lang.Error:
                transManager:Rollback(Xid).
                undo, throw e.
            end catch.
        end.

		finally:
           delete object dsEntity no-error.
        end finally.
    end method.
method public void GetApprovalFields ( input dataset dsApprovalAction,
                                          output dataset dsApprovalField):
        define variable entityInstanceUri     as character   no-undo.
        define variable approverUserid        as character   no-undo.
        define variable dsEntity              as handle      no-undo.
        define variable bufferField           as handle no-undo.
 
message '## CUST:GetApprovalFields() -START' skip.
dataset dsApprovalAction:write-xml("FILE", "Cust_GetApprovalFields_dsApprovalAction_VirtualApprovalEntity" + string(time) + ".xml", yes).
        dataset dsApprovalField:empty-dataset().
 
        for each ttApprovalAction on error undo, throw:
            entityInstanceUri = ttApprovalAction.EntityInstanceUri.
            approverUserid    = ttApprovalAction.ApproverActionUserid.
 
            this-object:VirtualBEFetch(input entityInstanceUri,
                                     output dataset-handle dsEntity by-reference).
             
            dsEntity:get-top-buffer():find-first() no-error.
            /*if dsEntity:get-top-buffer():available
            then do:
                bufferField = dsEntity:get-top-buffer():buffer-field(ttApprovalField.FieldName) no-error.
                if bufferField:available then
                   bufferField:buffer-value = ttApprovalField.FieldValue.
            end.*/
             
            this-object:GetApprovalFieldList(input entityInstanceUri, output dataset dsApprovalFieldList by-reference).
             
            for each ttApprovalFieldList
            on error undo, throw:
                bufferField = dsEntity:get-top-buffer():buffer-field(ttApprovalFieldList.FieldName) no-error.
                if bufferField:available then do:
                    create ttApprovalField.
                    assign
                        ttApprovalField.EntityInstanceUri = entityInstanceUri
                        ttApprovalField.ApproverUserid    = approverUserid
                        ttApprovalField.FieldName         = ttApprovalFieldList.FieldName
                        ttApprovalField.FieldValue        = string(bufferField:buffer-value)
                        /*ttApprovalField.IsEnable          = pIsEnable
                        ttApprovalField.IsReadOnly        = pIsReadOnly
                        ttApprovalField.IsVisible         = pIsVisible
                        ttApprovalField.IsRequired        = pIsRequired
                        ttApprovalField.FieldLabel        = pFieldLabel
                        ttApprovalField.DataListCode      = pDataList
                        ttApprovalField.HelpId            = pHelp*/
                        .
                end.    
            end.
        end.
dataset dsApprovalAction:write-xml("FILE", "Cust_GetApprovalFields_dsApprovalField_VirtualApprovalEntity" + string(time) + ".xml", yes).

       finally:
           delete object dsEntity no-error.
        end finally.
    end method.

 method public character GetApprovalHash (input entityInstanceUri as character):
        define variable dsEntity as handle no-undo.
        define variable approvalApi as class IGenericApproval no-undo.
        define variable fieldsList as character no-undo.
         
message '## CUST: GetApprovalHash() -START' skip.
        this-object:VirtualBEFetch(input entityInstanceUri ,
                                 output dataset-handle dsEntity by-reference).
 
        this-object:GetApprovalFieldList(input entityInstanceUri, output dataset dsApprovalFieldList by-reference).
             
        fieldsList = "".
        for each ttApprovalFieldList on error undo, throw:
            fieldsList = if fieldsList = "" then ttApprovalFieldList.FieldName
                         else (fieldsList + "," + ttApprovalFieldList.FieldName).
        end.
 
        approvalApi = GenericApprovalServices:GetGenericApproval().
       
        return approvalApi:CalculateHash (input dataset-handle dsEntity, "", fieldsList).
 
		finally:
           delete object dsEntity no-error.
        end finally.
    end method.
 
    method public character GetStakeholders (input entityInstanceUri as character):
message '## CUST: GetStakeholders() -START' skip.
    end method.

method public void GetCurrencyConvertedEntity (input entityInstanceUri as character, input currencyCode as character, output dataset-handle dsEntity):
        define variable bufferCurr  as handle no-undo.
        define variable bufferAmt  as handle no-undo.
message '## CUST:GetCurrencyConvertedEntity() -START' skip.
        this-object:VirtualBEFetch(input entityInstanceUri,
                                 output dataset-handle dsEntity by-reference).
                dsEntity:get-top-buffer():find-first() no-error.
                if dsEntity:get-top-buffer():available
                then do:
                    assign
                        bufferCurr = dsEntity:get-top-buffer():buffer-field("CurrencyCode").
                        bufferAmt = dsEntity:get-top-buffer():buffer-field("Amount")
                        no-error.
                    if bufferAmt:available and
                       bufferCurr:available and
                       bufferCurr:buffer-value <> currencyCode
                    then do:
                       /*convert amount*/
                       /* bufferAmt:buffer-value = bufferAmt:buffer-value * 2. */
                    end.
                end.
 
		finally:
           delete object dsEntity no-error.
        end finally.
    end method.

method public void ValidateEntityFields (input dataset dsApprovalField, output dataset dsEntityFieldValidation):
        define variable dsEntity            as handle no-undo.
        define variable entityInstanceUri   as character   no-undo.
        define variable bufferField         as handle no-undo.
        define variable totAmt              as decimal no-undo.
         
message '## CUST:ValidateEntityFields() -START' skip.
dataset dsApprovalField:write-xml("FILE", "Cust_ValidateEntityFields_dsApprovalField_VirtualApprovalEntity" + string(time) + ".xml", yes).
        dataset dsEntityFieldValidation:empty-dataset().
 
        for each ttApprovalField break by ttApprovalField.EntityInstanceUri on error undo, throw:
            if first-of(ttApprovalField.EntityInstanceUri) then do:
                entityInstanceUri = ttApprovalField.EntityInstanceUri.
                this-object:VirtualBEFetch(input ttApprovalField.EntityInstanceUri,
                                         output dataset-handle dsEntity by-reference).
            end.   
 
            dsEntity:get-top-buffer():find-first() no-error.
            if dsEntity:get-top-buffer():available
            then
                bufferField = dsEntity:get-top-buffer():buffer-field(ttApprovalField.FieldName) no-error.
 
            /* Validations on the Additional Approval fields */
            case ttApprovalField.FieldName:
                when "TotalAmount" then do:
                    totAmt = decimal(ttApprovalField.FieldValue).
                    if totAmt > 1000 then do:
                        create ttEntityFieldValidation.
                        assign
                            ttEntityFieldValidation.EntityInstanceUri = entityInstanceUri
                            ttEntityFieldValidation.FieldName = ttApprovalField.FieldName
                            ttEntityFieldValidation.ValidationMessage = "TotalAmount is > 1000".
                    end.
                    if totAmt > 5000 then do:
                        create ttEntityFieldValidation.
                        assign
                            ttEntityFieldValidation.EntityInstanceUri = entityInstanceUri
                            ttEntityFieldValidation.FieldName = ttApprovalField.FieldName
                            ttEntityFieldValidation.ValidationMessage = "TotalAmount is > 5000".
                    end.
                end.
            end case.   
        end.
 
		finally:
           delete object dsEntity no-error.
        end finally.
    end method.

method public logical isValidCurrency (input currencyCode as character ):
        define variable isValidCurency as logical    no-undo.
        isValidCurency = this-object:CurrencyService:IsValidActiveCurrency (input currencyCode).
        return isValidCurency.
    end method.

	method public void SetApprovalResult (input dataset dsApproval):
        	define variable dsEntity     as handle no-undo.
        	define variable transManager as ITransactionManager no-undo.
        	define variable Xid          as character no-undo.
        	define variable bufferField  as handle no-undo.
 
		message '## CUST: SetApprovalResult() -START' skip.

	end method.
end class.