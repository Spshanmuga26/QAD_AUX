/* SalesOrderHeader.cls - This class file is extension of Standard Method to handle Single Order in WEBUI*/
/*PROGRAM-TYPE=CLASS-PROGRAM                                                        */
/*----------------------------------------------------------------------------------*/
/* #1587 & #3251 | Shanmuga Sundar | 18-Feb-26 | Program to set incoterms         */
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
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "After"}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "Before"}
    {com/qad/sales/salesorder/dsSalesOrderHeader.i &PREFIX = "Update"}
    {com/qad/base/codes/dsGeneralizedCode.i}
    {com/qad/qra/base/dsFilter.i}


//-----------------------------------------------create method -----------------------------------------------------------

method public override void CreateWithConfirmation
   ( input-output dataset-handle dsSalesOrderHeader,
     input-output dataset        dsSalesOrderHeaderConf ):

	//ROUTINE-LEVEL ON ERROR UNDO, THROW.
	message "hhhh".
define variable generalizedCodeService as IGeneralizedCode no-undo.
define variable incotermList as character no-undo initial "".
        define variable soldToCustCode as character no-undo.
define variable domain as character no-undo.
	    define variable gcmSoldToCust as character no-undo. 
	    define variable isIncotermApplied as logical no-undo initial no.
	define variable incoterm as character no-undo. 
        generalizedCodeService = BaseServices:GetGeneralizedCode().
   
        dataset dsBeforeSalesOrderHeader:handle:copy-dataset(dsSalesOrderHeader:handle).

	for each ttBeforeSalesOrderHeader:

		soldToCustCode = ttBeforeSalesOrderHeader.SoldToCustomerCode.

	message "dwdwdw" soldToCustCode.
	

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
                message "iuiuihead" isIncotermApplied.
                gcmSoldToCust = ttGeneralizedCode.CodeValue.
                message "gcmsold" gcmSoldToCust "sosold" ttBeforeSalesOrderHeader.soldToCustomerCode .
                
                if gcmSoldToCust = ttBeforeSalesOrderHeader.soldToCustomerCode then do:
                    isIncotermApplied = yes.

		    ttBeforeSalesOrderHeader.FreeOnBoardPoint = "".

			message "xcxcxc" isIncotermApplied "value" ttGeneralizedCode.comments.
			if isIncotermApplied = yes then do:
				incoterm = ttGeneralizedCode.comments.
			end. /*if yes end*/
		end. /* gcmSoldToCust  eq end*/	
		
            end.

			message "beforefreeonboeepoint" ttBeforeSalesOrderHeader.FreeOnBoardPoint.
			ttBeforeSalesOrderHeader.FreeOnBoardPoint = incoterm.
			message "afterfreeonboeepoint" ttBeforeSalesOrderHeader.FreeOnBoardPoint.
        	end. /*end ttBeforeSOHeader*/


	dataset dsSalesOrderHeader:handle:copy-dataset(dataset dsBeforeSalesOrderHeader:handle).
	
	message "oooo".

   
    super:CreateWithConfirmation(
      input-output dataset dsSalesOrderHeader by-reference,
      input-output dataset dsSalesOrderHeaderConf by-reference).


for each ttSalesOrderHeader:
message "afteruperfreeonboeepoint" ttBeforeSalesOrderHeader.FreeOnBoardPoint.
end.
      
end method.

end class. //class                                                       