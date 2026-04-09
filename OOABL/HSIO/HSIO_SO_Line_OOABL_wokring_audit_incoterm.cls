/* SalesOrderLine.cls - This class file is extension of Standard Update Method to audit Single Line in WEBUI*/
/*PROGRAM-TYPE=CLASS-PROGRAM                                                        */
/*----------------------------------------------------------------------------------*/
/* #### | Shanmuga Sundar | 04-Aug-24 | Program to capture changes for audit        */
/*----------------------------------------------------------------------------------*/

using com.qad.sales.SalesMessageKey.
using com.qad.lang.IList.
using com.qad.lang.IMessage.
using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.lang.IMessage.
using com.qad.lang.String.
using com.qad.sales.salesorder.*.
using com.qad.sales.SalesServices.
using com.qad.sales.SalesConstants.
using com.qad.sales.SalesError.
using com.qad.sales.salesorder.ISalesOrderLine.
using com.qad.sales.salesorder.ISalesOrderLineDataObject.
using com.qad.sales.salesorder.SalesOrderLineBase.
using com.qad.base.BaseError.
using com.qad.base.BaseMessageKey.
using com.qad.base.BaseUtils.
using com.qad.qra.QraServices.
using com.qad.base.BaseServices.
using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.
using com.qad.base.codes.IGeneralizedCode.
using com.qad.sales.SalesServices.
using com.qad.sales.salesorder.ISalesOrderHeader.

   

class com.hsio.xxsalesapp.salesorderline.SalesOrderLine inherits SalesOrderLineBase implements ISalesOrderLine:

    {com/qad/sales/salesorder/dsSalesOrderLine.i}
    {com/qad/sales/salesorder/dsSalesOrderLineConf.i}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i}
    {com/qad/sales/salesorder/dsSalesOrderHeaderConf.i}
    {com/qad/sales/salesorder/dsSalesOrderLine.i &PREFIX = "Update"}
    {com/qad/sales/salesorder/dsSalesOrderLine.i &PREFIX = "After"}
    {com/qad/base/codes/dsGeneralizedCode.i}
    {com/qad/qra/base/dsFilter.i}

/*define temp-table ttFilter no-undo
    field FieldName  as character
    field Operator   as character
    field FieldValue as character.

define dataset dsFilter for ttFilter.*/

    
    
method public override void CreateWithConfirmation(input-output dataset-handle dsSalesOrderLine,
                                                           input-output dataset dsSalesOrderLineConf):


        
        define variable gcmFieldName as character no-undo.
        define variable supplier     as character no-undo.
        define variable incotermList as character no-undo initial "".
        define variable soldToCustCode as character no-undo.
	define variable gcmSoldToCust as character no-undo. 
	define variable isIncotermApplied as logical no-undo initial no.
        define variable salesOrderHeaderService as ISalesOrderHeader no-undo.
        define variable generalizedCodeService as IGeneralizedCode no-undo.



        salesOrderHeaderService = SalesServices:GetSalesOrder().
        generalizedCodeService = BaseServices:GetGeneralizedCode().

        dataset dsUpdateSalesOrderLine:handle:copy-dataset(dsSalesOrderLine:handle).

        gcmFieldName = "EMT_SUPPLIER_INCOTERM".


        for each ttUpdateSalesOrderLine:

            soldToCustCode = ttUpdateSalesOrderLine.SoldToCustomerCode.
	    supplier = ttUpdateSalesOrderLine.EMTSupplier.
            incotermList = "".
            message "lineew" soldToCustCode.
	
//empty temp-table ttFilter.


create ttFilter.
assign
    ttFilter.FieldName  = "code_fldname"
    ttFilter.Operator   = "="
    ttFilter.FieldValue = "EMT_soldto_incoterm".
generalizedCodeService:GetList(
    input dataset dsFilter by-reference,
    output dataset dsGeneralizedCode by-reference
).       
	   for each ttGeneralizedCode:
                message "dddddline" isIncotermApplied.
                gcmSoldToCust = ttGeneralizedCode.CodeValue.
                message "eeeeline" gcmSoldToCust .
                
                if gcmSoldToCust = ttUpdateSalesOrderLine.soldToCustomerCode then do:
                    isIncotermApplied = yes.
		    leave.
                end.

            end.	
message "suppp" ttUpdateSalesOrderLine.EMTSupplier gcmFieldName ttUpdateSalesOrderLine.DomainCode.
            if isIncotermApplied = no then do:

message "suppp gcm loop".
                    generalizedCodeService:Fetch(
                            input ttUpdateSalesOrderLine.DomainCode,
                            input "EMT_SUPPLIER_INCOTERM",
                            input supplier,
                            output dataset dsGeneralizedCode by-reference
                        ).
                            for each ttGeneralizedCode:
                                message "mmmmline" ttGeneralizedCode.comments.

                                salesOrderHeaderService:Fetch(input ttUpdateSalesOrderLine.DomainCode, 
                                                        input ttUpdateSalesOrderLine.SalesOrderNumber, 
                                                        output dataset dsSalesOrderHeader).

                            
                                for each ttSalesOrderHeader:
                                    ttSalesOrderHeader.FreeOnBoardPoint = ttGeneralizedCode.comments.
                                            message "iiiiline" ttSalesOrderHeader.FreeOnBoardPoint.
                                end.

                                        salesOrderHeaderService:UpdateWithConfirmation (input-output dataset dsSalesOrderHeader by-reference,
                                                            input-output dataset dsSalesOrderHeaderConf by-reference).

                            end. /* for each GCM supplier*/

            end. /*if incotermlist empty*/
        


        end. /*ttUpdateSalesOrderLine*/

        dataset dsSalesOrderLine:handle:copy-dataset(dataset dsUpdateSalesOrderLine:handle).

    super:CreateWithConfirmation(
        input-output dataset dsSalesOrderLine by-reference,
        input-output dataset dsSalesOrderLineConf by-reference
    ).


end method.




    method public override void UpdateWithConfirmation(input-output dataset-handle dsSalesOrderLine,
                                                           input-output dataset dsSalesOrderLineConf):
                                                            
        define variable l_buff_handle as handle no-undo.
        define variable l_query_handle as handle no-undo.
        define variable queryString as char no-undo.
        define variable queryStringReasonCode as char no-undo.
        define variable dueDateOld as date no-undo.  
        define variable listPriceOld as decimal no-undo.
        define variable quantityOld as decimal no-undo.
        define variable reasonCode as character no-undo.   
        define Variable buf     as handle no-undo.
        define Variable qry     as handle no-undo.   
        define Variable valMsgs as List no-undo. 
        define variable dsEntity as handle no-undo.
        define variable msg     as Message no-undo.
        define variable processMessage as IMessage no-undo.
        define variable currentUser as character no-undo.
                                                 

      dataset dsUpdateSalesOrderLine:handle:copy-dataset(dsSalesOrderLine:handle).



            for each ttUpdateSalesOrderLine
                    break by ttUpdateSalesOrderLine.DomainCode
                        by ttUpdateSalesOrderLine.SalesOrderNumber
                on error undo, throw:    
                create buffer l_buff_handle for table "sod_det".
                create query l_query_handle.
                l_query_handle:set-buffers (l_buff_handle).
                queryString = "".
		        queryString = "for each sod_det no-lock where sod_domain = " + 
                                quoter(ttUpdateSalesOrderLine.DomainCode) +
                                " and sod_nbr = " + quoter(ttUpdateSalesOrderLine.salesOrderNumber) +
                                " and sod_line = " + quoter(ttUpdateSalesOrderLine.salesOrderLine) + ":".

                l_query_handle:query-prepare(queryString).
                l_query_handle:query-open().
                l_query_handle:get-first().
                
                if not l_query_handle:query-off-end then
                    dueDateOld = l_buff_handle:buffer-field("sod_due_date"):buffer-value.
                    quantityOld = l_buff_handle:buffer-field("sod_qty_ord"):buffer-value.
                    listPriceOld = l_buff_handle:buffer-field("sod_list_pr"):buffer-value.

                l_query_handle:query-close().
                delete object l_query_handle.
                delete object l_buff_handle.  

            end.


        dataset dsSalesOrderLine:handle:copy-dataset(dataset dsUpdateSalesOrderLine:handle).

       /* Call the standard code */
        super:UpdateWithConfirmation(input-output dataset dsSalesOrderLine by-reference,
                                    input-output dataset dsSalesOrderLineConf by-reference
                                    ).

        dataset dsAfterSalesOrderLine:handle:copy-dataset(dataset dsSalesOrderLine:handle).   
        
        for each ttAfterSalesOrderLine:
            currentUser = "".
            assign currentUser = BaseUtils:GetSessionUserID().

            if ttAfterSalesOrderLine.DueDate ne dueDateOld then do:
                reasonCode = ttAfterSalesOrderLine.SodDetChr09. 
                    run "us/xx/xxsoaudit.p" (
                                            input ttAfterSalesOrderLine.DomainCode,
                                            input ttAfterSalesOrderLine.SalesOrderNumber,
                                            input ttAfterSalesOrderLine.SalesOrderLine,
                                            input "Due Date", /* field */
                                            input string(dueDateOld), /* Old value */
                                            input string(ttAfterSalesOrderLine.DueDate), /* New value */
                                            input reasonCode, /* Log description or reason */
                                            input currentUser
                                            ).
            end.
                if ttAfterSalesOrderLine.QuantityOrdered ne quantityOld then do:
                        run "us/xx/xxsoaudit.p" (
                                                input ttAfterSalesOrderLine.DomainCode,
                                                input ttAfterSalesOrderLine.SalesOrderNumber,
                                                input ttAfterSalesOrderLine.SalesOrderLine,
                                                input "Quantity ordered", /* field */
                                                input string(quantityOld), /* Old value */
                                                input string(ttAfterSalesOrderLine.QuantityOrdered), /* New value */
                                                input "Quantity Changed", /* Log description or reason */
                                                input currentUser
                                                ).
                end.

                    if ttAfterSalesOrderLine.ListPrice ne listPriceOld then do:
                        run "us/xx/xxsoaudit.p" (
                                                input ttAfterSalesOrderLine.DomainCode,
                                                input ttAfterSalesOrderLine.SalesOrderNumber,
                                                input ttAfterSalesOrderLine.SalesOrderLine,
                                                input "List Price", /* field */
                                                input string(listPriceOld), /* Old value */
                                                input string(ttAfterSalesOrderLine.ListPrice), /* New value */
                                                input "List Price Changed", /* Log description or reason */                                            
                                                input currentUser
                                                ).
                    end.
        end. //for                                       
    end method. //method update close


    
end class. //class
