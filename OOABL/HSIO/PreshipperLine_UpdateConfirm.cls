using com.qad.logistics.shipping.IPreShipperLine.
using com.qad.logistics.LogisticsServices.
using com.qad.logistics.shipping.PreShipperLineBase.
using com.qad.logistics.shipping.IPreShipperLineComment.
using com.qad.sales.salesorder.*.
using com.qad.sales.SalesServices.
using com.qad.lang.AppError.
using com.qad.logistics.LogisticsError.
using com.qad.logistics.LogisticsMessageKey.


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

      //preShipperLineCommentService = LogisticsServices:GetPreShipperLineComment().

      preShipperLineCommentService = LogisticsServices:GetPreShipperLineComment().
      salesOrderLineCommentService = SalesServices:GetSalesOrderLineComment().

      message "ttcreate". 
      dataset dsPreShipperLine:copy-dataset(dsPreShipperLine, false, true, true).
      super:CreateWithConfirmation(input dataset-handle dsPreShipperLine by-reference,
                                   input-output dataset dsPreShipperConf by-reference).
      dataset dsUpdatePreShipperLine:copy-dataset(dsPreShipperLine, false, true, true).

      dataset dsPreShipperLine:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_After_Super" + string(time) + ".xml", yes).

      //dataset dsUpdatePreShipperLine:handle:copy-dataset(dsPreShipperLine:handle).
      //dataset dsUpdatePreShipperLineComment:handle:copy-dataset(dsPreShipperLineComment:handle).
      //dataset dsUpdatePreShipperLine:handle:copy-dataset(dataset dsPreShipperLine:handle).

      dataset dsUpdatePreShipperLine:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_Before" + string(time) + ".xml", yes).


      for each ttUpdatePreShipperLine:
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
   method public override void UpdateWithConfirmation(
    input dataset-handle dsPreShipperLine,
    input-output dataset dsPreShipperConf):

    define variable preShipperLineCommentService as IPreShipperLineComment no-undo.
    define variable salesOrderLineCommentService as ISalesOrderLineComment no-undo.
    define variable preshipperlineService as IPreShipperLine no-undo.

    define variable iNextPageNumber as integer no-undo.
    define variable iMaxPageNumber as integer no-undo.

    preShipperLineCommentService = LogisticsServices:GetPreShipperLineComment().
    salesOrderLineCommentService = SalesServices:GetSalesOrderLineComment().

    message "ttupdate". 

    dataset dsPreShipperLine:copy-dataset(dsPreShipperLine, false, true, true).

    

    dataset dsUpdatePreShipperLine:copy-dataset(dsPreShipperLine, false, true, true).

    dataset dsPreShipperLine:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_After_Super" + string(time) + ".xml", yes).
    dataset dsUpdatePreShipperLine:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_Before" + string(time) + ".xml", yes).

    
    for each ttUpdatePreShipperLine:
        message ttUpdatePreShipperLine.DomainCode "TTTT update".
        message ttUpdatePreShipperLine.OrderNumber "oOOO".

    
        salesOrderLineCommentService:FetchAll(
            input ttUpdatePreShipperLine.DomainCode,
            input ttUpdatePreShipperLine.OrderNumber,
            input integer(ttUpdatePreShipperLine.OrderLine),
            output dataset dsSalesOrderLineComment by-reference).

        preShipperLineCommentService:FetchAll(
            input ttUpdatePreShipperLine.DomainCode,
            input ttUpdatePreShipperLine.ShipFromCode,
            input ttUpdatePreShipperLine.ShipperID,
            output dataset dsPreShipperLineComment by-reference).

        iMaxPageNumber = 0.
        for each ttPreShipperLineComment:
            if ttPreShipperLineComment.PageNumber > iMaxPageNumber then
                iMaxPageNumber = ttPreShipperLineComment.PageNumber.
        end.
        iNextPageNumber = iMaxPageNumber + 1.


        EMPTY TEMP-TABLE ttPreShipperLineComment. //Clearing the dataset

        for each ttSalesOrderLineComment:
            message "order line " ttSalesOrderLineComment.SalesOrderNumber.
            message "CommentShipper" ttSalesOrderLineComment.CombinedComment.

            create ttPreShipperLineComment.

            assign
                ttPreShipperLineComment.DomainCode            = ttUpdatePreShipperLine.DomainCode
                ttPreShipperLineComment.LanguageCode          = ""
                ttPreShipperLineComment.CommentType           = ""
                ttPreShipperLineComment.ShipFromCode          = ttUpdatePreShipperLine.ShipFromCode
                ttPreShipperLineComment.ShipperID             = ttUpdatePreShipperLine.ShipperID
                ttPreShipperLineComment.Reference             = ttUpdatePreShipperLine.ShipToCode
                ttPreShipperLineComment.PageNumber            = iNextPageNumber
                ttPreShipperLineComment.IsPrintOnShipper      = TRUE
                ttPreShipperLineComment.CombinedComment       = ttSalesOrderLineComment.CombinedComment
                ttPreShipperLineComment.IsPrintOnBillOfLading = TRUE
                //ttPreShipperLineComment.DataOperation         = "CREATE".
                //ttPreShipperLineComment.StoredPageNumber      = iNextPageNumber.

            iNextPageNumber = iNextPageNumber + 1.
        end. /* end salesOrderLineComment loop */

        for each ttPreShipperLineComment:
            message "page no update" ttPreShipperLineComment.PageNumber.   
            message "note update from shipperline" ttPreShipperLineComment.CombinedComment.                             
        end. /* after combining */
    end. /* end ttUpdatePreShipperLine loop */
    

    dataset dsPreShipperLineComment:write-xml("FILE", "/home/Janardhanr/dsPreShipperLineComment__update_Before_Create" + string(time) + ".xml", yes).


    for each ttPreShipperLineComment:
        message "Sending to Create:" skip
            "Comment: " ttPreShipperLineComment.CombinedComment skip
            "Operation: " ttPreShipperLineComment.DataOperation
            view-as alert-box.
    end.
    
    do on error undo, throw:
        preShipperLineCommentService:Create(input-output dataset dsPreShipperLineComment).

        catch e as AppError:
            output to "/home/Janardhanr/update_lineerror.txt" append.
            put unformatted "e Val: " e skip.
            output close.
        end catch.
    end.

    dataset dsPreShipperLineComment:write-xml("FILE", "/home/Janardhanr/dsPreShipperLineComment_update_After_Create" + string(time) + ".xml", yes).
    
    super:UpdateWithConfirmation(
        input dataset-handle dsPreShipperLine by-reference,
        input-output dataset dsPreShipperConf by-reference).
        dataset dsPreShipperLine:write-xml("FILE", "/home/Janardhanr/dsPreShipperLine_update_After_Save" + string(time) + ".xml", yes).

end method.


end class.
