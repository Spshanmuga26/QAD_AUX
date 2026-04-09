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
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "After"}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "Before"}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "Update"}
    {com/qad/base/codes/dsGeneralizedCode.i}
    {com/qad/qra/base/dsFilter.i}


//-----------------------------------------------create method -----------------------------------------------------------


method public override void CreateWithConfirmation
   ( input-output dataset-handle dsSalesOrderHeader,
     input-output dataset        dsSalesOrderHeaderConf ):
   
   dataset dsUpdateSalesOrderHeader:handle:copy-dataset(dsSalesOrderHeader:handle).
   
   for each ttUpdateSalesOrderHeader:
      message "HDR BEFORE"
         ttUpdateSalesOrderHeader.SoldToCustomerCode
         ttUpdateSalesOrderHeader.FreeOnBoardPoint.
      
      ttUpdateSalesOrderHeader.FreeOnBoardPoint = "DAP".
      
      message "HDR AFTER"
         ttUpdateSalesOrderHeader.SoldToCustomerCode
         ttUpdateSalesOrderHeader.FreeOnBoardPoint.
   end.
   
   dataset dsSalesOrderHeader:handle:copy-dataset(dataset dsUpdateSalesOrderHeader:handle).
   
   for each ttSalesOrderHeader:
      message "VERIFICATION" 
         ttSalesOrderHeader.domaincode
         ttSalesOrderHeader.FreeOnBoardPoint.
   end.
   
   super:CreateWithConfirmation(
      input-output dataset dsSalesOrderHeader,
      input-output dataset dsSalesOrderHeaderConf).
      
end method.


end class. //class                                                       