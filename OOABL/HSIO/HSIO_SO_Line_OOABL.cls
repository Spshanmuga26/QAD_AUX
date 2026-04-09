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

class com.hsio.xxsalesapp.salesorderline.SalesOrderLine inherits SalesOrderLineBase implements ISalesOrderLine:

    {com/qad/sales/salesorder/dsSalesOrderLine.i}
    {com/qad/sales/salesorder/dsSalesOrderLineConf.i}
    {com/qad/sales/salesorder/dsSalesOrderLine.i &PREFIX = "Update"}
    {com/qad/sales/salesorder/dsSalesOrderLine.i &PREFIX = "After"}

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
                    listPriceOld = l_buff_handle:buffe#2r-field("sod_list_pr"):buffer-value.

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
                reasonCode = ttAfterSalesOrderLine.SodDetChr01. 
                
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
