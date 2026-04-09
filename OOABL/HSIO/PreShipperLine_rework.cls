using com.qad.logistics.shipping.IPreShipperLine.
using com.qad.logistics.LogisticsServices.
using com.qad.logistics.shipping.PreShipperLineBase.
using com.qad.logistics.shipping.IPreShipperLineComment.
using com.qad.sales.salesorder.*.
using com.qad.sales.SalesServices.
using com.qad.lang.AppError.
using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.logistics.LogisticsError.
using com.qad.logistics.LogisticsMessageKey.
using com.qad.base.BaseError.
using com.qad.base.BaseMessageKey.


routine-level on error undo, throw.


class com.hsio.xxlogisticsapp.preshipperline.PreShipperLine inherits PreShipperLineBase implements IPreShipperLine:

   {com/qad/logistics/shipping/dsPreShipperLine.i}
   {com/qad/logistics/shipping/dsPreShipperLine.i &PREFIX = "Update"}
   {com/qad/logistics/shipping/dsPreShipperLine.i &PREFIX = "Before"}
   {com/qad/logistics/shipping/dsPreShipperConf.i}
   {com/qad/logistics/shipping/dsPreShipperLineComment.i}
   {com/qad/sales/salesorder/dsSalesOrderLineComment.i}
   method public override void CreateWithConfirmation(
                  input dataset-handle dsPreShipperLine,
                  input-output dataset dsPreShipperConf):

      define variable preShipperLineCommentService as IPreShipperLineComment no-undo.
      define variable salesOrderLineCommentService as ISalesOrderLineComment no-undo.
      define variable preshipperlineService as IPreShipperLine no-undo.


      preShipperLineCommentService = LogisticsServices:GetPreShipperLineComment().
      salesOrderLineCommentService = SalesServices:GetSalesOrderLineComment().

                  super:CreateWithConfirmation(input dataset-handle dsPreShipperLine by-reference,
                                          input-output dataset dsPreShipperConf by-reference).
	dataset dsUpdatePreShipperLine:copy-dataset(dsPreShipperLine, false, true, true).
            for each ttUpdatePreShipperLine:
                salesOrderLineCommentService:FetchAll(
                            input ttUpdatePreShipperLine.DomainCode,
                            input ttUpdatePreShipperLine.OrderNumber,
                            input INTEGER(ttUpdatePreShipperLine.OrderLine),
                            output dataset dsSalesOrderLineComment by-reference).

                        for each ttSalesOrderLineComment:
                            create ttPreShipperLineComment.
                    
                            assign
                            ttPreShipperLineComment.DomainCode               = ttUpdatePreShipperLine.DomainCode
                            ttPreShipperLineComment.LanguageCode             = ""
                            ttPreShipperLineComment.CommentType              = ""
                            ttPreShipperLineComment.ShipFromCode             = ttUpdatePreShipperLine.ShipFromCode
                            ttPreShipperLineComment.ShipperID                = ttUpdatePreShipperLine.ShipperID
                            ttPreShipperLineComment.Reference                = ttUpdatePreShipperLine.ShipToCode
                            ttPreShipperLineComment.PageNumber               = ttSalesOrderLineComment.PageNumber
                            ttPreShipperLineComment.IsPrintOnShipper         = TRUE
                            ttPreShipperLineComment.CombinedComment          = ttSalesOrderLineComment.CombinedComment
                            ttPreShipperLineComment.IsPrintOnBillOfLading    = TRUE.
                        end.    
            end.
preShipperLineCommentService:Create (input-output dataset dsPreShipperLineComment).
   
end method.    
end class.
