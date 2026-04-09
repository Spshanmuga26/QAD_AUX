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
using com.qad.base.item.IItem.
using com.qad.qra.QraServices.
using com.qad.qra.notification.INotificationService.
using com.qad.qra.notification.INotificationRequestBuilder.
using com.qad.qra.notification.NotificationContent.
using com.qad.qra.notification.INotificationRequest.
using com.qad.qra.adapter.role.*.
using com.qad.qra.adapter.role.IRoleUser.
using com.qad.base.BaseUtils.




routine-level on error undo, throw.

class com.hsio.xxcreditnote.be.VirtualBusinessEntity 
    inherits VirtualBusinessEntityBase 
    implements IVirtualBusinessEntity:


    	{com/qad/base/codes/dsGeneralizedCode.i}
	{com/qad/base/item/dsItem.i}
	{com/qad/qra/adapter/role/dsRoleUser.i}




method public override void Initialize(
    input entityURI as character,
    output dataset-handle dsEntity):
message "bbb".

if entityURI = "urn:be:com.hsio.xxcreditnote.CreditNoteRequest.ICreditNoteRequest" then 
                do on error undo, throw:


    message "vvvv ini".

    super:Initialize(
        input entityURI,
        output dataset-handle dsEntity).

    finally:
        delete object dsEntity no-error.
    end finally.
end.

end method.



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
		define variable processMessage as IMessage no-undo.
    		define variable successMessage as char  no-undo.

		message "vvvv".

                if entityURI = "urn:be:com.hsio.xxcreditnote.CreditNoteRequest.ICreditNoteRequest" then 
                do on error undo, throw:

                message "eeentity". 
                message "bbefore val msg and buf".

                assign valMsgs = new List()
                buf = dsEntity:get-buffer-handle("ttxx_cred_note_req").
                message "before qry".                                   
                create query qry.
                message "buf open".
                qry:set-buffers(buf).
                qry:query-prepare("for each ttxx_cred_note_req").
                qry:query-open().
                qry:get-first().
                        
                        generalizedCodeService = BaseServices:GetGeneralizedCode().


                        do while not qry:query-off-end:
                        message "Sundarr creditnote ". 
                        message Today.

                        if not valMsgs:IsEmpty() then 
                        undo, throw new BaseError(valMsgs).  
                        message valMsgs.

                        generalizedCodeService:Fetch (input buf::DomainCode,
                                            input 'xxcredit_note_key',
                                            input 'creditNotePK',
                                            output dataset dsGeneralizedCode by-reference).                
                                for each ttGeneralizedCode:
                                    message "Before " ttGeneralizedCode.comments.
                                    //ttGeneralizedCode.comments.
                                    k = buf::CreditNoteNumberPK.

                                    i = integer(ttGeneralizedCode.Comments).
                                    message "int i " i.
                                    j = i + 1.

                                    ttGeneralizedCode.Comments = STRING(j). 
                                    message "After " ttGeneralizedCode.Comments.

					buf::CreditnotenumberPK = "CN" + STRING(ttGeneralizedCode.Comments) + STRING(DAY(Today),"99") 
                                      + STRING(MONTH(Today),"99") + STRING(YEAR(Today),"9999").

                                    generalizedCodeService:Update (input dataset dsGeneralizedCode by-reference).
                                end. //generalizedCodeService
                                
                        qry:get-next().	
                end. // do while

                if qry:is-open then 
                    qry:query-close().

                delete object qry.
                assign qry = ?.
            end.      
            
            super:Create(
             input entityURI,
             input dataset-handle dsEntity by-reference).


            end method.

method public override void Update(
                input entityURI as character,
                input dataset-handle dsEntity):

		define Variable valMsgs 	as List no-undo.
                define Variable buf     	as handle no-undo.
                define Variable qry     	as handle no-undo.
                define Variable i          	AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
                define Variable j          	AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
                define Variable k          	AS INTEGER   FORMAT "99999" INITIAL 001 NO-UNDO.
		define variable cnkey 		as char no-undo.
		define variable cnstatus 	as char no-undo.
                define Variable generalizedCodeService as IGeneralizedCode no-undo.
		define variable processMessage 	as IMessage no-undo.
    		define variable successMessage  as char  no-undo.
		define variable currentUser 	as character no-undo.

if entityURI = "urn:be:com.hsio.xxcreditnote.CreditNoteRequest.ICreditNoteRequest" then 
                do on error undo, throw:

message "uupdare".

 assign valMsgs = new List()
                buf = dsEntity:get-buffer-handle("ttxx_cred_note_req").
                message "before qry".                                   
                create query qry.
                message "buf open".
                qry:set-buffers(buf).
                qry:query-prepare("for each ttxx_cred_note_req").
                qry:query-open().
                qry:get-first().

do while not qry:query-off-end:
                        message "Sundarr creditnote ". 
                        message Today.
			cnkey = buf::CreditNoteNumberPK.
			message "kk" cnkey.
cnstatus = buf::DocStatus.
			message "ll" cnstatus.
if cnstatus = "APPROVED" then do:
        message "### Credit Note APPROVED – sending email ###".
assign currentUser = buf::approvedBy.
message "jhjhj" currentUser.
        this-object:SendNotification(cnkey,currentUser).
    end.

                        if not valMsgs:IsEmpty() then 
                        undo, throw new BaseError(valMsgs).  
                        message valMsgs.
			qry:get-next().	
                end. // do while

                if qry:is-open then 
                    qry:query-close().

                delete object qry.
                assign qry = ?.



end. 

super:Update(input entityURI,input dataset-handle dsEntity by-reference).
message "PK" k.	
    finally:
        delete object dsEntity no-error.
    end finally.
end method.

define protected property NotificationService as INotificationService no-undo
    get:
        if not valid-object(NotificationService) then
            this-object:NotificationService = QraServices:GetNotificationService().
        return NotificationService.
    end get.
    set.

define protected property NotificationRequestBuilder as INotificationRequestBuilder no-undo
    get:
        if not valid-object(NotificationRequestBuilder) then
            this-object:NotificationRequestBuilder = QraServices:GetNotificationRequestBuilder().
        return NotificationRequestBuilder.
    end get.
    set.

method private void SendNotification(input cnKey as character,input approver as character):
    	define variable builder as INotificationRequestBuilder.
	define variable req     as INotificationRequest.
	define variable emailBody as character no-undo.
	define variable usrid as character no-undo.
	define variable roleServices as IRoleUser no-undo.
	define variable currentUser as character no-undo.

 message "emial".

    emailBody =
        "Hello Finance Team,<br><br>" +
        "The Credit Note Request (" + cnKey + ") has been approved by Customer Service Manager.<br>" +
        "Please process the Credit Note.<br><br>" +
        "Thanks.<br><br>" +
        "*** This is auto generated email - do not reply ***".

message "llrolemm".

roleServices = QraServices:GetRoleUser().

roleServices:GetUsersOfRole(
        input "FinEmail",        /* YOUR ROLE NAME */
        output dataset dsRoleUser by-reference
    ).
for each ttRoleUser:
usr = ttRoleUser.usrId.
message "kkk" usr.

assign currentUser = approver.
 builder = this-object:NotificationRequestBuilder.

message "curr" currentUser .

	req = builder 
		:AddToUserid(ttRoleUser.usrId)
            :FromUserid(currentUser)
            :EmailContentType("html")
            :AddMessageContent(NotificationContent:EmailSubject,"Credit Note Approved - " + cnKey)
            :AddMessageContent(NotificationContent:EmailBody, emailBody)
            :Request.
message "beforesend".
    this-object:NotificationService:SubmitRequest(req).
end.
message "aftersend".
end method.


end class.    