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

routine-level on error undo, throw.

class com.hsio.xxsalesapp.salesorderheader.SalesOrderHeader inherits SalesOrderHeaderBase implements ISalesOrderHeader:
    
    {com/qad/sales/salesorder/dsSalesOrderHeader.i}
    {com/qad/sales/salesorder/dsSalesOrderHeaderConf.i}
    {com/qad/sales/salesorder/dsSalesOrderLine.i}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "Update"}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "After"}
    {com/qad/base/codes/dsGeneralizedCode.i}

    method public override void CreateWithConfirmation
      ( input-output dataset-handle dsSalesOrderHeader,
        input-output dataset        dsSalesOrderHeaderConf ):

      /* Copy incoming dataset to typed dataset */
      dataset dsUpdateSalesOrderHeader:handle:copy-dataset(dsSalesOrderHeader:handle).

      /* ===== BEFORE SUPER ===== */
      for each ttUpdateSalesOrderHeader
         break by ttUpdateSalesOrderHeader.DomainCode
               by ttUpdateSalesOrderHeader.SalesOrderNumber
      on error undo, throw:

         message
            "BEFORE SUPER - SoldToCustomer ="
            ttUpdateSalesOrderHeader.SoldToCustomerCode
            view-as alert-box info.


      end.

      /* Copy back to generic dataset */
      dataset dsSalesOrderHeader:handle:copy-dataset(dataset dsUpdateSalesOrderHeader:handle).

      /* Call standard QAD logic */
      super:CreateWithConfirmation(
            input-output dataset dsSalesOrderHeader by-reference,
            input-output dataset dsSalesOrderHeaderConf by-reference).

      /* ===== AFTER SUPER ===== */
      for each ttSalesOrderHeader:

         message
            "AFTER SUPER - SoldToCustomer ="
            ttSalesOrderHeader.SoldToCustomerCode
            view-as alert-box info.

      end.

   end method.
END CLASS.