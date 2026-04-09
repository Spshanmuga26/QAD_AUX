using com.qad.sales.SalesError.
using com.qad.sales.SalesServices.
using com.qad.sales.salesorder.ISalesOrderHeaderDataObject.
using com.qad.sales.salesorder.ISalesOrderLine.
using com.qad.sales.salesorder.SalesOrderLineBase.
  
                                                        
class com.extensions.xxsalesapp.salesorder.SalesOrderLine inherits SalesOrderLineBase implements ISalesOrderLine:
    { com/qad/sales/salesorder/dsSalesOrderLine.i }
    { com/qad/sales/salesorder/dsSalesOrderLineConf.i }
    { com/qad/sales/salesorder/dsSalesOrderLine.i  &PREFIX = "Before"}
    

    

method public override void UpdateWithConfirmation(
        input-output dataset-handle dsSalesOrderLine,
        input-output dataset dsSalesOrderLineConf):
  
       //assign valMsgs = new List().
    define Variable buf as handle no-undo.
    define Variable bAuditLog as handle no-undo.
    define Variable qry     as handle no-undo.
    define Variable reasonCodeOld as char no-undo.
    define Variable reasonCodeNew as char no-undo.
    define Variable queryString as char no-undo.
    define Variable reasonCode as char no-undo.

    //dataset dsBeforeSalesOrderLine:copy-dataset(dsSalesOrderLine, false, true, true).
    dataset dsSalesOrderLine:handle:copy-dataset(dsSalesOrderLine:handle).

    for each ttSalesOrderLine:
        message "ffffirst " ttSalesOrderLine.SalesOrderNumber.                   
        create query qry.
        create buffer buf for table "xx_sod_line".
        message "buf open".
        qry:set-buffers(buf).

	    queryString = "for each xx_sod_line
                  where xx_sod_line.xx_domain = " + 
                                        quoter(ttSalesOrderLine.DomainCode)
               + " and xx_sod_line.xx_so_nbr = " + 
                             quoter(ttSalesOrderLine.SalesOrderNumber)
                             + " and xx_sod_line.xx_so_line = " + 
                             quoter(ttSalesOrderLine.SalesOrderLine)
              + " no-lock:".
	    message "qqqist " queryString.
        qry:query-prepare(queryString).
        qry:query-open().
        qry:get-first().
        message "qry " qry.
          do while not qry:query-off-end:
            reasonCodeOld = buf:buffer-field("xx_reason_code"):buffer-value.
          qry:get-next().
          end.

          if qry:is-open then 
            qry:query-close().

        delete object qry.
        assign qry = ?.
        
            message "TTTTTist ".
            message "reason code oldd" reasonCodeOld.
    end. //for each 

    //salesOrderLineService = SalesServices:GetSalesOrderLine().
    
        //dataset dsSalesOrderLine:copy-dataset(dsBeforeSalesOrderLine, false, true, true).
        dataset dsSalesOrderLine:handle:copy-dataset(dsSalesOrderLine:handle).

        /*for each ttSalesOrderLine:
            salesOrderLineService:Fetch (input ttSalesOrderLine.DomainCode, input ttSalesOrderLine.SalesOrderNumber, input ttSalesOrderLine.SalesOrderLine, output dataset dsSalesOrderLine by-reference).
                for each
        end. //end for each*/    

        super:UpdateWithConfirmation(
                    input-output dataset-handle dsSalesOrderLine by-reference,
                    input-output dataset dsSalesOrderLineConf by-reference).
          
                    for each ttSalesOrderLine:
                        message "ffff " ttSalesOrderLine.SalesOrderNumber.                   
                        create query qry.
                        create buffer buf for table "xx_sod_line".
                        message "buf open".
                        qry:set-buffers(buf).
                
                        queryString = "for each xx_sod_line
                                  where xx_sod_line.xx_domain = " + 
                                                        quoter(ttSalesOrderLine.DomainCode)
                               + " and xx_sod_line.xx_so_nbr = " + 
                                             quoter(ttSalesOrderLine.SalesOrderNumber)
                                             + " and xx_sod_line.xx_so_line = " + 
                                             quoter(ttSalesOrderLine.SalesOrderLine)
                              + " no-lock:".
                        message "qqq " queryString.
                        qry:query-prepare(queryString).
                        qry:query-open().
                        qry:get-first().
                        message "qry " qry.
                          do while not qry:query-off-end:
                          reasonCodeNew = buf:buffer-field("xx_reason_code"):buffer-value.
                          qry:get-next().
                          end.
                
                          if qry:is-open then 
                            qry:query-close().
                
                        delete object qry.
                        assign qry = ?.
                        
                            message "TTTTT ".
                            message "reason code neww" reasonCodeNew " and old " reasonCodeOld.

                           /*  if reasonCodeNew <> reasonCodeOld then do:
                                create buffer bAuditLog for table "audit_log".
                                assign
                                    bAuditLog.business_component = "SalesOrderLines"
                                    bAuditLog.description         = "Reason code updated"
                                    bAuditLog.field_name          = "xx_reason_code"
                                    bAuditLog.modified_date       = NOW
                                    bAuditLog.old_value           = reasonCodeOld
                                    bAuditLog.new_value           = reasonCodeNew
                                    bAuditLog.p_key1              = ttSalesOrderLine.DomainCode
                                    bAuditLog.p_key2              = ttSalesOrderLine.SalesOrderNumber
                                    bAuditLog.p_key3              = STRING(ttSalesOrderLine.SalesOrderLine)
                                    bAuditLog.p_key4              = ""
                                    bAuditLog.p_key5              = ""
                                    bAuditLog.user_modified       = USERID("ASI").
        
                            end. //if end*/
                    end. //for each 

                    
                                                  

end method.
end class.