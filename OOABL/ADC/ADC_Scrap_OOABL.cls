using com.qad.lang.List.
using com.qad.lang.IMessage.
using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.
using com.qad.base.BaseError.
using com.qad.base.BaseMessageKey.
using com.qad.base.BaseServices.
using com.qad.base.codes.IGeneralizedCode.
using com.qad.inventory.InventoryServices.
using com.qad.inventory.inv.IInventoryDetail.
using com.qad.base.item.IItem.
using com.qad.qra.QraServices.


routine-level on error undo, throw.

class com.adckcl.xxadcsalesquote.be.VirtualBusinessEntity 
    inherits VirtualBusinessEntityBase 
    implements IVirtualBusinessEntity:

{com/qad/base/codes/dsGeneralizedCode.i}
{com/qad/inventory/inv/dsInventoryDetail.i}
{com/qad/base/item/dsItem.i}

method public override void Create(
    input entityURI as character,
    input dataset-handle dsEntity):

    define Variable valMsgs as List no-undo.
    define Variable buf     as handle no-undo.
    define Variable qry     as handle no-undo.
    define Variable i          AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
    define Variable j          AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
    define Variable k          AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
    define Variable generalizedCodeService as IGeneralizedCode no-undo.
    define variable inventoryDetailService as IInventoryDetail no-undo.
    define variable itemService as IItem no-undo.
    define variable msg     as Message no-undo.
    define variable isValidItem as logical no-undo.
    define variable processMessage as IMessage no-undo.
    define variable successMessage as char  no-undo.
    define variable location as char no-undo.
    define variable prnbr as integer no-undo.

    if entityURI = "urn:be:com.adckcl.xxadcscrap.Scrap.IScrap" then 
    do on error undo, throw:
                assign valMsgs = new List()
               buf = dsEntity:get-buffer-handle("ttxxscrap").
                                           
        create query qry.

        qry:set-buffers(buf).
        qry:query-prepare("for each ttxxscrap").
        qry:query-open().
        qry:get-first().
                
        generalizedCodeService = BaseServices:GetGeneralizedCode().
        inventoryDetailService = InventoryServices:GetInventoryDetail().
        itemService = BaseServices:GetItem().

        do while not qry:query-off-end:
            
            if not valMsgs:IsEmpty() then 
                undo, throw new BaseError(valMsgs).  
           



            generalizedCodeService:Fetch (input buf::DomainCode,
                                    input 'xx_scrap_incr',
                                    input 'scrap',
                                    output dataset dsGeneralizedCode by-reference).                
                        for each ttGeneralizedCode:

                            i = integer(ttGeneralizedCode.Comments).
                            j = i + 1.
                            prnbr = j.

                            ttGeneralizedCode.Comments = STRING(j). 
                            
                            
                             
                            buf::Key1 = STRING(ttGeneralizedCode.Comments) + STRING(DAY(Today),"99") 
                                      + STRING(MONTH(Today),"99") + STRING(YEAR(Today),"9999") + replace(STRING(time, "HH:MM:SS"),":","").
                            


                            generalizedCodeService:Update (input dataset dsGeneralizedCode by-reference).           
                        end.    
                        location = buf::Location.
               
            qry:get-next().	
        end. // do while

        if qry:is-open then 
            qry:query-close().

        delete object qry.
        assign qry = ?.

         
    end. // end if scrap

    // Scrap Details
    if entityURI = "urn:be:com.adckcl.xxadcscrap.ScrapDetails.IScrapDetails" then 
    do on error undo, throw:
              assign valMsgs = new List()
               buf = dsEntity:get-buffer-handle("ttxxscrapdetails").
                                           
        create query qry.

        qry:set-buffers(buf).
        qry:query-prepare("for each ttxxscrapdetails").
        qry:query-open().
        qry:get-first().
                
        generalizedCodeService = BaseServices:GetGeneralizedCode().
        inventoryDetailService = InventoryServices:GetInventoryDetail().
        itemService = BaseServices:GetItem().

        do while not qry:query-off-end:
            isValidItem = itemService:IsValidItem(input buf::DomainCode, input buf::ItemCode).
            
            if buf::Reason = "" then 
            do:
                assign msg = new Message(1,"Reason cannot be empty").
                msg:SetContext(buf:buffer-field("Reason")).
                valMsgs:Add(msg).
            end.
            
            if not isValidItem then 
            do:
                assign msg = new Message(1,"Entered Item is not valid").
                msg:SetContext(buf:buffer-field("ItemCode")).
                valMsgs:Add(msg).
            end.
            
            inventoryDetailService:Fetch(input buf::DomainCode,
                                input buf::SiteCode,
                                input location,
				                input buf::ItemCode,
                                input buf::Lot,
                                input '',
                                output dataset dsInventoryDetail by-reference).  
                                
                        for each ttInventoryDetail:
                            if ttInventoryDetail.QtyOnHand < buf::Quantity then do:
                                assign msg = new Message(1,"Quantity Cannot be greater than Qty on hand").
                                msg:SetContext(buf:buffer-field("Quantity")).
                                valMsgs:Add(msg).
                            end.
                            
                        end.
            
                        

            if not valMsgs:IsEmpty() then 
                undo, throw new BaseError(valMsgs).  


            

            qry:get-next().	
        end. // do while

        if qry:is-open then 
            qry:query-close().

        delete object qry.
        assign qry = ?.

    end. // end if ScrapDetails

     super:Create(
             input entityURI,
             input dataset-handle dsEntity by-reference).	
        processMessage = new Message(1,successMessage).            
                            QraServices:GetSupplementaryMessageLogger():Warn(processMessage:String).

    finally:
        delete object dsEntity no-error.
    end finally.    

end method.

end class.
