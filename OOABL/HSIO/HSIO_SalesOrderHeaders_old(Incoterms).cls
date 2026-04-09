/* SalesOrderHeader.cls - This class file is extension of Standard Method to handle Single Order in WEBUI*/
/*PROGRAM-TYPE=CLASS-PROGRAM                                                        */
/*----------------------------------------------------------------------------------*/
/* #### | Shanmuga Sundar | 18-Aug-24 | Program to set incoterms         */
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
using com.qad.sales.salesorder.ISalesOrderHeader.
using com.qad.sales.salesorder.ISalesOrderHeaderDataObject.
using com.qad.sales.salesorder.SalesOrderHeaderBase.
using com.qad.base.BaseError.
using com.qad.base.BaseMessageKey.
using com.qad.base.BaseUtils.
using com.qad.qra.QraServices.
using com.qad.base.BaseServices.
using com.qad.base.codes.IGeneralizedCode.
using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.

class com.hsio.xxsalesapp.salesorderheader.SalesOrderHeader inherits SalesOrderHeaderBase implements ISalesOrderHeader:

    {com/qad/sales/salesorder/dsSalesOrderHeader.i}
    {com/qad/sales/salesorder/dsSalesOrderHeaderConf.i}
    {com/qad/sales/salesorder/dsSalesOrderLine.i}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "Update"}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "After"}
    {com/qad/base/codes/dsGeneralizedCode.i}

    method public override void CreateWithConfirmation(input-output dataset-handle dsSalesOrderHeader,
                                                           input-output dataset dsSalesOrderHeaderConf):

        dataset dsUpdateSalesOrderHeader:handle:copy-dataset(dsSalesOrderHeader:handle).

        for each ttUpdateSalesOrderHeader:
            message "vbvb".
            if ttUpdateSalesOrderHeader.BillToCustomerCode = "4298ERIC"
                    or ttUpdateSalesOrderHeader.BillToCustomerCode = "4297ERIC"
                    or ttUpdateSalesOrderHeader.BillToCustomerCode = "4268ERIC" 
                    or ttUpdateSalesOrderHeader.BillToCustomerCode = "4298" then do:
                        ttUpdateSalesOrderHeader.FreeOnBoardPoint = "DAP". //setting DAP default
            end. //if    
        end. //for ttUpdateSalesOrderHeader                                                       

        dataset dsSalesOrderHeader:copy-dataset(dataset dsUpdateSalesOrderHeader:handle).
    //dataset dsUpdateSalesOrderHeader:write-xml("FILE", "/home/ravim/dsUpdateSalesOrderHeader_Before" + string(time) + ".xml", yes).

       /* Call the standard code */
        super:CreateWithConfirmation(input-output dataset dsSalesOrderHeader by-reference,
                                    input-output dataset dsSalesOrderHeaderConf by-reference).

    end method.



    method public override void UpdateWithConfirmation(input-output dataset-handle dsSalesOrderHeader,
                                                           input-output dataset dsSalesOrderHeaderConf):

    define variable salesOrderLineService as ISalesOrderLine no-undo.
    define variable generalizedCodeService as IGeneralizedCode no-undo.
    define variable supplier as char no-undo.
    define variable gcmFieldName as char no-undo.
    define variable incoterm as char no-undo.
    
    salesOrderLineService = SalesServices:GetSalesOrderLine().
    generalizedCodeService = BaseServices:GetGeneralizedCode().

    dataset dsUpdateSalesOrderHeader:handle:copy-dataset(dsSalesOrderHeader:handle).
    message "wwworking".

    supplier = "".
    incoterm = "".
    gcmFieldName = "EMT_SUPPLIER_INCOTERM".

    for each ttUpdateSalesOrderHeader:

	    message "fff" ttUpdateSalesOrderHeader.DomainCode.

        salesOrderLineService:GetLinesForSalesOrder(input ttUpdateSalesOrderHeader.DomainCode, input ttUpdateSalesOrderHeader.SalesOrderNumber,input 0, output dataset dsSalesOrderLine by-reference).
            
            
            if ttUpdateSalesOrderHeader.FreeOnBoardPoint <> "DAP" and ttUpdateSalesOrderHeader.BillToCustomerCode = "4298" then do:
                        ttUpdateSalesOrderHeader.FreeOnBoardPoint = "DAP".  // setting incoterm to so header
                        message "vvvv" ttUpdateSalesOrderHeader.FreeOnBoardPoint.
            end.

                find first ttSalesOrderLine no-error.
            if not ttUpdateSalesOrderHeader.BillToCustomerCode = "4298ERIC"
                    or ttUpdateSalesOrderHeader.BillToCustomerCode = "4297ERIC"
                    or ttUpdateSalesOrderHeader.BillToCustomerCode = "4268ERIC" 
                    or ttUpdateSalesOrderHeader.BillToCustomerCode = "4298" then do: 
                if available ttSalesOrderLine then do:
                    
                    supplier = ttSalesOrderLine.EMTSupplier. // storing supplier from line level
                    message "qqqq" supplier.

                    if supplier ne "" then do:
                        generalizedCodeService:Fetch (input ttUpdateSalesOrderHeader.DomainCode,
                                        input gcmFieldName,
                                        input supplier,
                                        output dataset dsGeneralizedCode by-reference).  // fetching gcm using the supplier
                            for each ttGeneralizedCode:

                                incoterm = ttGeneralizedCode.Comments.
                                message "ggg" incoterm.
                            
                            end. //ttGeneralizedCode end                    
                end. //ttSalesOrderLine
            end.    
                    
                    if incoterm ne "" then do:
                        ttUpdateSalesOrderHeader.FreeOnBoardPoint = incoterm.  // setting incoterm to so header
                        message "vvvv" ttUpdateSalesOrderHeader.FreeOnBoardPoint.
                    end. // incoterm if end
                end. // supplier if end  // incoterm if end 
    end. // ttUpdateSalesOrderHeader

    dataset dsSalesOrderHeader:copy-dataset(dataset dsUpdateSalesOrderHeader:handle).
    //dataset dsUpdateSalesOrderHeader:write-xml("FILE", "/home/ravim/dsUpdateSalesOrderHeader_Before" + string(time) + ".xml", yes).

       /* Call the standard code */
        super:UpdateWithConfirmation(input-output dataset dsSalesOrderHeader by-reference,
                                    input-output dataset dsSalesOrderHeaderConf by-reference
                                    ).
    //dataset dsSalesOrderHeader:write-xml("FILE", "/home/ravim/dsSalesOrderHeader_After" + string(time) + ".xml", yes).
                                                       
    end method. //method update close


    
end class. //class                                                       