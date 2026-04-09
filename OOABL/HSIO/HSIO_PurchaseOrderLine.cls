using com.qad.purchasing.PurchasingServices.
using com.qad.purchasing.purchaseorders.IPurchaseOrderLine.
using com.qad.purchasing.purchaseorders.PurchaseOrderLineBase.
using com.qad.purchasing.purchaseorders.IPurchaseOrderHeader.


class com.hsio.xxpurchasingapp.purchaseorderline.PurchaseOrderLine inherits PurchaseOrderLineBase implements IPurchaseOrderLine:

      {com/qad/purchasing/purchaseorders/dsPurchaseOrderLine.i}
      {com/qad/purchasing/purchaseorders/dsPurchaseOrderLineConf.i}
      {com/qad/purchasing/purchaseorders/dsPurchaseOrderLine.i &PREFIX = "Update"}
      {com/qad/purchasing/purchaseorders/dsPurchaseOrderLine.i &PREFIX = "Before"}
      {com/qad/purchasing/purchaseorders/dsPurchaseOrderHeader.i}
      {com/qad/purchasing/purchaseorders/dsPurchaseOrderHeaderConf.i}

        
    method public override void CreateWithConfirmation(input dataset-handle dsPurchaseOrderLine,
                                                        input-output dataset dsPurchaseOrderLineConf):


            define variable purchaseOrderHeaderService as IPurchaseOrderHeader no-undo.
            define variable purchaseOrderLineService as IPurchaseOrderLine no-undo.
            define Variable buf as handle no-undo.
            define Variable qry     as handle no-undo.
            define Variable queryString as char no-undo.
            define Variable revisionPO as Decimal no-undo.
            define Variable revisionPONew as Decimal no-undo.


            purchaseOrderHeaderService = PurchasingServices:GetPurchaseOrderHeader().  
            purchaseOrderLineService = PurchasingServices:GetPurchaseOrderLine().

        dataset dsUpdatePurchaseOrderLine:handle:copy-dataset(dsPurchaseOrderLine:handle).

        for each ttUpdatePurchaseOrderLine:
            create query qry.
            create buffer buf for table "po_mstr".
            qry:set-buffers(buf).

            queryString = "for each po_mstr
                    where po_mstr.po_domain = " + 
                                            quoter(ttUpdatePurchaseOrderLine.DomainCode)
                + " and po_mstr.po_nbr = " + 
                                quoter(ttUpdatePurchaseOrderLine.PurchaseOrderNumber)
                + " no-lock:".
            qry:query-prepare(queryString).
            qry:query-open().
            qry:get-first().
            do while not qry:query-off-end:
                revisionPO = buf:buffer-field("po_rev"):buffer-value.
            qry:get-next().
            end.

            if qry:is-open then 
                qry:query-close().

            delete object qry.
            assign qry = ?.
        end.

                super:CreateWithConfirmation(input dataset-handle dsPurchaseOrderLine by-reference,
                                    input-output dataset dsPurchaseOrderLineConf by-reference).

        for each ttUpdatePurchaseOrderLine:

            revisionPONew = revisionPO + 1.

            purchaseOrderHeaderService:Fetch(input ttUpdatePurchaseOrderLine.DomainCode,
                                                input ttUpdatePurchaseOrderLine.PurchaseOrderNumber,
                                                output dataset dsPurchaseOrderHeader by-reference).

                            for each ttPurchaseOrderHeader:
                                assign ttPurchaseOrderHeader.OrderRevision = revisionPONew.
                            end.
                        
                            purchaseOrderHeaderService:UpdateWithConfirmation(
                                input dataset dsPurchaseOrderHeader by-reference,
                                input-output dataset dsPurchaseOrderHeaderConf by-reference).

        end.  

    end method.                                                   


    
    method public override void UpdateWithConfirmation(
                  input dataset-handle dsPurchaseOrderLine,
                  input-output dataset dsPurchaseOrderLineConf):

        define variable purchaseOrderLineService as IPurchaseOrderLine no-undo.
        define variable purchaseOrderHeaderService as IPurchaseOrderHeader no-undo.  
        define Variable qtyOrderOld as Decimal no-undo.
        define Variable qtyOrderNew as Decimal no-undo.
        define Variable priceOld as Decimal no-undo.
        define Variable priceNew as Decimal no-undo.
        define Variable buf as handle no-undo.
        define Variable qry     as handle no-undo.
        define Variable queryString as char no-undo.
        define Variable buf1 as handle no-undo.
        define Variable qry1     as handle no-undo.
        define Variable queryString1 as char no-undo.
        define Variable revisionPO as Decimal no-undo.
        define Variable revisionPONew as Decimal no-undo.
        define Variable oldCount as Decimal no-undo.
        define Variable newCount as Decimal no-undo.



        purchaseOrderLineService = PurchasingServices:GetPurchaseOrderLine().
        purchaseOrderHeaderService = PurchasingServices:GetPurchaseOrderHeader().


        //OrderRevision
        //UnitPrice



        dataset dsUpdatePurchaseOrderLine:copy-dataset(dsPurchaseOrderLine, false, true, true).
            for each ttUpdatePurchaseOrderLine:
                
                

                                                purchaseOrderHeaderService:Fetch(input ttUpdatePurchaseOrderLine.DomainCode,
                                                input ttUpdatePurchaseOrderLine.PurchaseOrderNumber,
                                                output dataset dsPurchaseOrderHeader by-reference).                                
                                                for each ttPurchaseOrderHeader:
                                                    revisionPO = ttPurchaseOrderHeader.OrderRevision.
                                                end. // end ttpoheader    

                create query qry.
                create buffer buf for table "pod_det".
                qry:set-buffers(buf).

                queryString = "for each pod_det
                        where pod_det.pod_domain = " + 
                                                quoter(ttUpdatePurchaseOrderLine.DomainCode)
                    + " and pod_det.pod_nbr = " + 
                                    quoter(ttUpdatePurchaseOrderLine.PurchaseOrderNumber)
                                    + " and pod_det.pod_line = " + 
                                    quoter(ttUpdatePurchaseOrderLine.PurchaseOrderLine)
                    + " no-lock:".
                qry:query-prepare(queryString).
                qry:query-open().
                qry:get-first().
                do while not qry:query-off-end:
                    qtyOrderOld = buf:buffer-field("pod_qty_ord"):buffer-value.
                    priceOld = buf:buffer-field("pod_pur_cost"):buffer-value.
                    oldCount = buf:buffer-field("pod__chr01"):buffer-value.
                qry:get-next().
                end.

                if qry:is-open then 
                    qry:query-close().

                delete object qry.
                assign qry = ?.
                ttUpdatePurchaseOrderLine.PodDetDec01 = oldCount + 1.

                message "Count Old | " ttUpdatePurchaseOrderLine.PodDetDec01.
            end.
            super:UpdateWithConfirmation(input dataset-handle dsPurchaseOrderLine by-reference,
                                        input-output dataset dsPurchaseOrderLineConf by-reference).
                                        
            for each ttUpdatePurchaseOrderLine:

                create query qry1.
                create buffer buf1 for table "pod_det".
                qry1:set-buffers(buf1).

                message "ttupdate" ttUpdatePurchaseOrderLine.DomainCode.

                queryString1 = "FOR EACH pod_det " +
               "WHERE pod_det.pod_domain = " + 
                   quoter(ttUpdatePurchaseOrderLine.DomainCode) +
               " AND pod_det.pod_nbr = " + 
                   quoter(ttUpdatePurchaseOrderLine.PurchaseOrderNumber) +
               " NO-LOCK:".

                MESSAGE "queryString1: " queryString1.

                qry1:QUERY-PREPARE(queryString1).
                qry1:QUERY-OPEN().
                qry1:GET-FIRST().

                DO WHILE NOT qry1:QUERY-OFF-END:
                    qtyOrderOld = buf1:BUFFER-FIELD("pod_qty_ord"):BUFFER-VALUE.
                    priceOld = buf1:BUFFER-FIELD("pod_pur_cost"):BUFFER-VALUE.
                    newCount = buf1:BUFFER-FIELD("pod__chr01"):BUFFER-VALUE.

                    /* You can now process each record here */
                    MESSAGE "Qty: " qtyOrderOld " | Price: " priceOld " | Count: " newCount.

                    qry1:GET-NEXT().
                END.

                qry1:QUERY-CLOSE().
                DELETE OBJECT buf1.
                DELETE OBJECT qry1.

                        qtyOrderNew = ttUpdatePurchaseOrderLine.QuantityOrdered.
                        priceNew = ttUpdatePurchaseOrderLine.PurchaseCost.

                        if qtyOrderNew <> qtyOrderOld or priceNew <> priceOld then do:
                            
                            revisionPONew = revisionPO + 1.

                            purchaseOrderHeaderService:Fetch(input ttUpdatePurchaseOrderLine.DomainCode,
                                                input ttUpdatePurchaseOrderLine.PurchaseOrderNumber,
                                                output dataset dsPurchaseOrderHeader by-reference).

                            for each ttPurchaseOrderHeader:
                                assign ttPurchaseOrderHeader.OrderRevision = revisionPONew.
                            end.
                        
                            purchaseOrderHeaderService:UpdateWithConfirmation(
                                input dataset dsPurchaseOrderHeader by-reference,
                                input-output dataset dsPurchaseOrderHeaderConf by-reference).
                        end.    

                    end.   
   end method.  
   
   
   method public override void DeleteWithConfirmation(input dataset-handle dsPurchaseOrderLine,
                                                        input-output dataset dsPurchaseOrderLineConf):


            define variable purchaseOrderHeaderService as IPurchaseOrderHeader no-undo.
            define variable purchaseOrderLineService as IPurchaseOrderLine no-undo.
            define Variable buf as handle no-undo.
            define Variable qry     as handle no-undo.
            define Variable queryString as char no-undo.
            define Variable revisionPO as Decimal no-undo.
            define Variable revisionPONew as Decimal no-undo.


            purchaseOrderHeaderService = PurchasingServices:GetPurchaseOrderHeader().  
            purchaseOrderLineService = PurchasingServices:GetPurchaseOrderLine().

        dataset dsUpdatePurchaseOrderLine:handle:copy-dataset(dsPurchaseOrderLine:handle).

        for each ttUpdatePurchaseOrderLine:
            create query qry.
            create buffer buf for table "po_mstr".
            qry:set-buffers(buf).

            queryString = "for each po_mstr
                    where po_mstr.po_domain = " + 
                                            quoter(ttUpdatePurchaseOrderLine.DomainCode)
                + " and po_mstr.po_nbr = " + 
                                quoter(ttUpdatePurchaseOrderLine.PurchaseOrderNumber)
                + " no-lock:".
            qry:query-prepare(queryString).
            qry:query-open().
            qry:get-first().
            do while not qry:query-off-end:
                revisionPO = buf:buffer-field("po_rev"):buffer-value.
            qry:get-next().
            end.

            if qry:is-open then 
                qry:query-close().

            delete object qry.
            assign qry = ?.
        end.

                super:DeleteWithConfirmation(input dataset-handle dsPurchaseOrderLine by-reference,
                                    input-output dataset dsPurchaseOrderLineConf by-reference).

        for each ttUpdatePurchaseOrderLine:

            revisionPONew = revisionPO + 1.

            purchaseOrderHeaderService:Fetch(input ttUpdatePurchaseOrderLine.DomainCode,
                                                input ttUpdatePurchaseOrderLine.PurchaseOrderNumber,
                                                output dataset dsPurchaseOrderHeader by-reference).

                            for each ttPurchaseOrderHeader:
                                assign ttPurchaseOrderHeader.OrderRevision = revisionPONew.
                            end.
                        
                            purchaseOrderHeaderService:UpdateWithConfirmation(
                                input dataset dsPurchaseOrderHeader by-reference,
                                input-output dataset dsPurchaseOrderHeaderConf by-reference).

        end.  

    end method. 
end class.