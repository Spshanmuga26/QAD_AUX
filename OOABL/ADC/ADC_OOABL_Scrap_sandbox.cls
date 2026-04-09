using com.qad.lang.List.
using com.qad.lang.Message.
  
using com.qad.qra.be.IVirtualBusinessEntity.
using com.qad.qra.be.VirtualBusinessEntityBase.
using com.qad.base.BaseError.
using com.qad.base.BaseMessageKey.
using com.qad.base.BaseServices.
using com.qad.base.codes.IGeneralizedCode.

routine-level on error undo, throw.
  
/* Since we're writing code for a Platform component, this custom class needs to implement the IVirtualBusinessEntity interface.           */
/* Also, it needs to inherit from the base class that gets generated when the app/module is built, in this case VirtualBusinessEntityBase. */
class com.adckcl.xxadcsalesquote.be.VirtualBusinessEntity inherits VirtualBusinessEntityBase implements IVirtualBusinessEntity:


{com/qad/base/codes/dsGeneralizedCode.i}
   

    method public override void Create(
        input entityURI as character,
        input dataset-handle dsEntity):

            define Variable valMsgs as List no-undo.
            define Variable buf     as handle no-undo.
            define Variable qry     as handle no-undo.
            DEFINE VARIABLE i          AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
            DEFINE VARIABLE j          AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
            DEFINE VARIABLE k          AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
            define Variable generalizedCodeService as IGeneralizedCode no-undo.
            define variable msg     as Message             no-undo.
		  
            OUTPUT TO VALUE ("/home/srushti/messages_scrap_start").
message "EntityURI" entityURI.


            if entityURI = "urn:be:com.adckcl.xxadcscrap.Scrap.IScrap"
            then do on error undo, throw:
                OUTPUT TO VALUE ("/home/srushti/messages_scrap").

                message " entity ". 
                message " before val msg and buf".

                assign valMsgs = new List()
                       buf = dsEntity:get-buffer-handle("ttxxscrap").       
                create query qry.
                qry:set-buffers(buf).
                qry:query-prepare("for each ttxxscrap").
                qry:query-open().
                qry:get-first().
                generalizedCodeService = BaseServices:GetGeneralizedCode().
                
                do while not qry:query-off-end:







                    message "Sundar - Scrap " buf::DomainCode.
                    message Today.
                    message "Doc " buf::DocRefNo.

                    if buf::DocRefNo = "" then do:
                        assign msg = new Message(1,"Doc Ref No cannot be empty").
                        msg:SetContext(buf:buffer-field("DocRefNo")).
                        valMsgs:Add(msg).

                        message valMsgs.
                    end.
                     message "No Doc No".



                    generalizedCodeService:Fetch (input buf::DomainCode,
                                    input 'xx_scrap_incr',
                                    input 'scrap',
                                    output dataset dsGeneralizedCode by-reference).                
                        for each ttGeneralizedCode:
                            message "Before " ttGeneralizedCode.Comments.
                            i = integer(ttGeneralizedCode.Comments).
                            message "int i " i.
                            j = i + 1.
                            message "int j " j.
                            ttGeneralizedCode.Comments = STRING(j). 
                            message "After " ttGeneralizedCode.Comments.
                            
                            message "After Update".
                            message STRING(DAY(Today),"99"). 
                            buf::Key1 = STRING(ttGeneralizedCode.Comments) + STRING(DAY(Today),"99") 
                                      + STRING(MONTH(Today),"99") + STRING(YEAR(Today),"9999") + replace(STRING(time, "HH:MM:SS"),":","").
                            message "PK 2 " buf::Key1.
                            generalizedCodeService:Update (input dataset dsGeneralizedCode by-reference).           
                        end.       
                    //message "Item No " buf::ItemCode.
					qry:get-next().	
                   

                    if not valMsgs:IsEmpty()
                        then do on error undo, throw:
                        new BaseError(valMsgs).
                    end.            


                end. //do while

                
				
                finally:
                    if qry:is-open
                    then qry:query-close().
        
                    delete object qry.
                    assign qry = ?.
                    
                end.
            end.  

            if entityURI ="urn:be:com.adckcl.xxadcscrap.ScrapDetails.IScrapDetails"
                         //urn:be:com.adckcl.xxadcscrap.ScrapDetails.IScrapDetails
            then do on error undo, throw:
                     OUTPUT TO VALUE ("/home/srushti/messages_scrap_details").
                message "test scrap details".
                assign valMsgs = new List()
                       buf = dsEntity:get-buffer-handle("ttxxscrapdetails").   
                                                           //xxScrapDetails    
                create query qry.
                qry:set-buffers(buf).
                qry:query-prepare("for each ttxxscrapdetails").
                qry:query-open().
                qry:get-first().
                //GeneralizedCodeService = BaseServices:GetGeneralizedCode().
                
                do while not qry:query-off-end:
                    message "Item check " buf::ItemCode.
                    message "Sundar - ScrapDetials ". 
                    message "Resaon " buf::Reason.

                    qry:get-next().	
                   

                    if not valMsgs:IsEmpty()
                        then do on error undo, throw:
                        new BaseError(valMsgs).
                     end.           


                end. //do while

                
				
                finally:
                    if qry:is-open
                    then qry:query-close().
        
                    delete object qry.
                    assign qry = ?.
                    
                end.

            end.
            


	    super:Create(
            input entityURI,
            input dataset-handle dsEntity by-reference).	
        finally:
           delete object dsEntity no-error.
        end finally.    
output close.

    end method.




end class.