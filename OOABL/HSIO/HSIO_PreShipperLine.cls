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
      define variable msg     as Message no-undo.
      define Variable valMsgs as List no-undo.
      define Variable setMessage as Char no-undo.


      //preShipperLineCommentService = LogisticsServices:GetPreShipperLineComment().

      preShipperLineCommentService = LogisticsServices:GetPreShipperLineComment().
      salesOrderLineCommentService = SalesServices:GetSalesOrderLineComment().

      message "ttcreate". 

               assign valMsgs = new List().  

               do on error undo, throw:
                  super:CreateWithConfirmation(input dataset-handle dsPreShipperLine by-reference,
                                          input-output dataset dsPreShipperConf by-reference).        
                  catch e as AppError:
                     output to "/home/Janardhanr/lineerror.txt" append.
                        put unformatted "e Val" e skip.
                     output close.
                     setMessage = String(e).
                  end catch.		 
               end.

               message setMessage "settmessage".
               
      dataset dsUpdatePreShipperLine:copy-dataset(dsPreShipperLine, false, true, true).
      dataset dsPreShipperConf:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_After_Super_confg" + string(time) + ".xml", yes).
      dataset dsUpdatePreShipperLine:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_Before" + string(time) + ".xml", yes).


      for each ttUpdatePreShipperLine on error undo, throw:
         if setMessage <> "" then do:
            assign msg = new Message(LogisticsMessageKey:YOU_CANNOT_HAVE_MULTIPLE_ITEMS_FOR_SAME,"","").
            valMsgs:Add(msg).
         end.  

         if not valMsgs:IsEmpty()
                  then do on error undo, throw:
                  new BaseError(valMsgs).
         end. 
         message valMsgs.
         message ttUpdatePreShipperLine.DomainCode "TTTT".
         message ttUpdatePreShipperLine.OrderNumber "oOOO".

         salesOrderLineCommentService:FetchAll(
            input ttUpdatePreShipperLine.DomainCode,
            input ttUpdatePreShipperLine.OrderNumber,
            input INTEGER(ttUpdatePreShipperLine.OrderLine),
            output dataset dsSalesOrderLineComment by-reference).

         for each ttSalesOrderLineComment:
            message "order line " ttSalesOrderLineComment.SalesOrderNumber.
            message "CommentShipper" ttSalesOrderLineComment.CombinedComment.
            //message "ShipperCode" ttSalesOrderLineComment.ShipFromCode.
            create ttPreShipperLineComment.
      
            assign
               ttPreShipperLineComment.DomainCode               = ttUpdatePreShipperLine.DomainCode
               //ttPreShipperLineComment.StoredPageNumber         = 0
               //ttPreShipperLineComment.CommentIndex             = ttSalesOrderLineComment.CommentIndex
               ttPreShipperLineComment.LanguageCode             = ""
               ttPreShipperLineComment.CommentType              = ""
               ttPreShipperLineComment.ShipFromCode             = ttUpdatePreShipperLine.ShipFromCode
               ttPreShipperLineComment.ShipperID                = ttUpdatePreShipperLine.ShipperID
               ttPreShipperLineComment.Reference                = ttUpdatePreShipperLine.ShipToCode
               ttPreShipperLineComment.PageNumber               = ttSalesOrderLineComment.PageNumber
               ttPreShipperLineComment.IsPrintOnShipper         = TRUE
               ttPreShipperLineComment.CombinedComment          = ttSalesOrderLineComment.CombinedComment
               ttPreShipperLineComment.IsPrintOnBillOfLading    = TRUE.







               // ttPreShipperLineComment.IsCommentsReadOnly       = ttSalesOrderLineComment.IsCommentsReadOnly
               // ttPreShipperLineComment.MasterCommentOID         = ttSalesOrderLineComment.MasterCommentOID
               // ttPreShipperLineComment.DataOperation            = "CREATE"
               // ttPreShipperLineComment.DisallowedActions        = ttSalesOrderLineComment.DisallowedActions
               // ttPreShipperLineComment.DisallowedActionsMessage = ttSalesOrderLineComment.DisallowedActionsMessage.
         end.

         message "combinedmessage" ttPreShipperLineComment.CombinedComment.

         dataset dsPreShipperLineComment:write-xml("FILE", "/home/Janardhanr/dsPreShipperLineComment_Before_Create" + string(time) + ".xml", yes).
         

         do on error undo, throw:
            preShipperLineCommentService:Create (input-output dataset dsPreShipperLineComment).
	
				catch e as AppError:
					output to "/home/Janardhanr/lineerror.txt" append.
						put unformatted "e Val" e skip.
					output close.
				end catch.			
			
			end.
            dataset dsPreShipperLineComment:write-xml("FILE", "/home/Janardhanr/dsPreShipperLineComment_After_Create" + string(time) + ".xml", yes).

      end.


   
   // preShipperLineService:UpdateWithConfirmation(input dataset-handle dsPreShipperLine by-reference,
   //                                 input-output dataset dsPreShipperConf by-reference).                                           
      dataset dsPreShipperLine:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_After_Save" + string(time) + ".xml", yes).
                             

   end method.


end class.
