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

    method public override void CreateWithConfirmation
    (input-output dataset-handle dsSalesOrderHeader,
     input-output dataset dsSalesOrderHeaderConf):

    define variable generalizedCodeService as IGeneralizedCode no-undo.
    define variable incotermList as character no-undo.

    generalizedCodeService = BaseServices:GetGeneralizedCode().

    dataset dsUpdateSalesOrderHeader:handle:copy-dataset(dsSalesOrderHeader:handle).

    /* =====================================================
       Decide & SET Incoterm BEFORE CREATE
       ===================================================== */
    for each ttUpdateSalesOrderHeader:

        if ttUpdateSalesOrderHeader.SoldToCustomerCode ne "" then do:

            generalizedCodeService:Fetch(
                input ttUpdateSalesOrderHeader.DomainCode,
                input "EMT_soldto_incoterm",
                input ttUpdateSalesOrderHeader.SoldToCustomerCode,
                output dataset dsGeneralizedCode by-reference
            ).

            for each ttGeneralizedCode:
                    incotermList = ttGeneralizedCode.Comments.
                    message "qqq" incotermList.    
                    MESSAGE "Valuesssssss!" ttUpdateSalesOrderHeader.FreeOnBoardPoint.
            end.
        end.
            if incotermList <> "" then do:
                ttUpdateSalesOrderHeader.FreeOnBoardPoint = incotermList.
                MESSAGE "xcxcxcxc!" ttUpdateSalesOrderHeader.FreeOnBoardPoint.
            end.

    end.
    dataset dsSalesOrderHeader:handle:copy-dataset(dataset dsUpdateSalesOrderHeader:handle).

    super:CreateWithConfirmation(
        input-output dataset-handle dsSalesOrderHeader by-reference,
        input-output dataset dsSalesOrderHeaderConf by-reference
    ).

end method.



    method public override void UpdateWithConfirmation
    (input-output dataset-handle dsSalesOrderHeader,
     input-output dataset dsSalesOrderHeaderConf):

    define variable salesOrderLineService  as ISalesOrderLine  no-undo.
    define variable generalizedCodeService as IGeneralizedCode no-undo.

    define variable gcmFieldName as character no-undo.
    define variable supplier     as character no-undo.
    define variable incotermList as character no-undo.

    salesOrderLineService  = SalesServices:GetSalesOrderLine().
    generalizedCodeService = BaseServices:GetGeneralizedCode().

    dataset dsUpdateSalesOrderHeader:handle:copy-dataset(dsSalesOrderHeader:handle).

    gcmFieldName = "EMT_SUPPLIER_INCOTERM".

    for each ttUpdateSalesOrderHeader:

        supplier = "".

        /* ===============================
           SOLD-TO BASED INCOTERM
           =============================== */
        if ttUpdateSalesOrderHeader.SoldToCustomerCode ne "" then do:
            message "valuessss!update".

            generalizedCodeService:Fetch(
                input ttUpdateSalesOrderHeader.DomainCode,
                input "EMT_soldto_incoterm",
                input "SO Sold To",
                output dataset dsGeneralizedCode by-reference
            ).

            for each ttGeneralizedCode:

                incotermList = ttGeneralizedCode.Comments.

                if lookup(ttUpdateSalesOrderHeader.SoldToCustomerCode, incotermList) > 0 then do:
                    ttUpdateSalesOrderHeader.FreeOnBoardPoint = "DAP".
                end.
            end.
        end.

        /* ===============================
           SUPPLIER BASED INCOTERM 
           =============================== */
        salesOrderLineService:GetLinesForSalesOrder(
            input ttUpdateSalesOrderHeader.DomainCode,
            input ttUpdateSalesOrderHeader.SalesOrderNumber,
            input 0,
            output dataset dsSalesOrderLine by-reference
        ).

        find first ttSalesOrderLine no-error.
        if available ttSalesOrderLine then do:

            supplier = ttSalesOrderLine.EMTSupplier.

            if supplier ne "" then do:
             message "qqqq!update ".
                generalizedCodeService:Fetch(
                    input ttUpdateSalesOrderHeader.DomainCode,
                    input gcmFieldName,
                    input supplier,
                    output dataset dsGeneralizedCode by-reference
                ).

                for each ttGeneralizedCode:
                    message "geeee" ttGeneralizedCode.Comments.
                        ttUpdateSalesOrderHeader.FreeOnBoardPoint
                            = ttGeneralizedCode.Comments.
                            message "yyyy!update " ttGeneralizedCode.Comments ttUpdateSalesOrderHeader.FreeOnBoardPoint.
                end.        
            end.
        end.

    end. /* ttUpdateSalesOrderHeader end*/

    dataset dsSalesOrderHeader:copy-dataset(dataset dsUpdateSalesOrderHeader:handle).

    super:UpdateWithConfirmation(
        input-output dataset-handle dsSalesOrderHeader by-reference,
        input-output dataset dsSalesOrderHeaderConf by-reference
    ).
        

end method.



    
end class. //class                                                       