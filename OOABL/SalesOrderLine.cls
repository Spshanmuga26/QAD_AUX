/* SalesOrderLine.cls - This class file is extension of Standard Create Method to create Single Line EMT PO in WEBUI    */
/*PROGRAM-TYPE=CLASS-PROGRAM                                                        */
/*----------------------------------------------------------------------------------*/
/* #### | Jigar Panchal| 28-Nov-24 | ROP Program call to create EMT PO             */
/*----------------------------------------------------------------------------------*/
/* #### | Afreen Shaikh| 17-Dec-24 | Date Management and Pricelist def             */
/*----------------------------------------------------------------------------------*/

using com.qad.sales.SalesMessageKey.
using com.qad.lang.IList.
using com.qad.lang.IMessage.
using com.qad.lang.List.
using com.qad.lang.Message.
using com.qad.lang.String.
using com.qad.base.BaseConstants.
using com.qad.base.BaseError.
using com.qad.base.BaseMessageKey.
using com.qad.base.BaseServices.
using com.qad.sales.salesorder.*.
using com.qad.sales.SalesServices.
using com.qad.sales.SalesConstants.
using com.qad.sales.SalesError.
using com.qad.sales.salesorder.ISalesOrderLine.
using com.qad.sales.salesorder.ISalesOrderLineDataObject.
using com.qad.sales.salesorder.SalesOrderLineBase.
using com.qad.base.item.IItemPlanningDataObject.
using com.qad.base.item.IItemPlanning.
using com.qad.base.item.IItemDataObject.
using com.qad.base.item.IItem.
using com.qad.qra.QraServices.
using com.qad.base.address.IMfgAddress.
using com.qad.base.customer.IMfgCustomer.


routine-level on error undo, throw.

/* Since were extending Sales Order Line, this custom class needs to implement the ISalesOrderLine interface. */
/* Also, it needs to inherit from the base class that gets generated when the app/module is built.           */
/* You get to that class by removing the I at the beginning of the interface name and add Base at the end.   */
/* ISalesOrderLine becomes SalesOrderLineBase.                                                               */

class com.amphenol-aben.adevcustshiptoaddr.salesorder.SalesOrderLine inherits SalesOrderLineBase implements ISalesOrderLine:

   {com/qad/sales/salesorder/dsSalesOrderLine.i}
   {com/qad/sales/salesorder/dsSalesOrderLineConf.i}
   {com/qad/sales/salesorder/dsSalesOrderLine.i &PREFIX = "Update"}
   {com/qad/base/address/dsMfgAddress.i}
   {com/qad/base/customer/dsMfgCustomer.i}

   define temp-table ttSOLine no-undo
      field DomainCode as char
      field OrderNbr   as char
      field OrderLine  as int 
      field ttEMTType  as char
      field ttEMTSupplier as char
   index ttLnIdx DomainCode OrderNbr OrderLine .    

   method public override void CreateWithConfirmation(input-output dataset-handle dsSalesOrderLine,
                                                      input-output dataset dsSalesOrderLineConf):

      define variable valMsgs        as List          no-undo.
      define variable msg            as Message       no-undo.
      define variable p_pod_nbr      as char             no-undo.
      define variable p_pod_line     as integer       no-undo.
      define variable processMessage as IMessage      no-undo.
    
      /* Copy the sales order lines to the typed dataset */
      dataset dsUpdateSalesOrderLine:handle:copy-dataset(dsSalesOrderLine:handle).
   

      valMsgs = new List().
         for each ttUpdateSalesOrderLine
         break by ttUpdateSalesOrderLine.DomainCode
               by ttUpdateSalesOrderLine.SalesOrderNumber
      on error undo, throw:

         create ttSOLine.
         assign
            ttSOLine.DomainCode    = ttUpdateSalesOrderLine.DomainCode
            ttSOLine.OrderNbr      = ttUpdateSalesOrderLine.SalesOrderNumber
            ttSOLine.OrderLine     = ttUpdateSalesOrderLine.SalesOrderLine
            ttSOLine.ttEMTType     = ttUpdateSalesOrderLine.EMTType
            ttSOLine.ttEMTSupplier = ttUpdateSalesOrderLine.EMTSupplier.

         assign 
            ttUpdateSalesOrderLine.EMTPONumber         = ""
            ttUpdateSalesOrderLine.EMTPOLine           = 0
            ttUpdateSalesOrderLine.EMTType             = "01"
            ttUpdateSalesOrderLine.EMTSupplier         = "" 
            ttUpdateSalesOrderLine.EMTTypeDisplayValue = "NON-EMT" . 
      
     /** Price List Default START  *********/
     
        updatedate(input-output dataset dsUpdateSalesOrderLine
                       by-reference).
    
        /** Price List Default END *********/
          
      end. /* FOR EACH ttUpdateSalesOrderLine */

      dataset dsSalesOrderLine:handle:copy-dataset(dataset dsUpdateSalesOrderLine:handle).

      /* Call the standard code */
      super:CreateWithConfirmation(input-output dataset dsSalesOrderLine by-reference,
                                   input-output dataset dsSalesOrderLineConf by-reference).

      for each ttSalesOrderLine,
         each ttSOLine 
            where  ttSOLine.DomainCode = ttSalesOrderLine.DomainCode
            and    ttSOLine.OrderNbr   = ttSalesOrderLine.SalesOrderNumber
            and    ttSOLine.OrderLine  = ttSalesOrderLine.SalesOrderLine:

         run "us/xx/xxcsoemttrg.p" (input ttSalesOrderLine.SalesOrderNumber, 
                                    input ttSalesOrderLine.SalesOrderLine, 
                                    input ttSalesOrderLine.SiteCode,
                                    input ttSalesOrderLine.DomainCode, 
                                    input ttSalesOrderLine.ItemCode, 
                                    input ttSOLine.ttEMTType, 
                                    input ttSOLine.ttEMTSupplier,
                                    output p_pod_nbr, 
                                    output p_pod_line).
         if p_pod_nbr <> ""
         then do:
            processMessage = new Message(input SalesMessageKey:IN_ORDER_TO_SOURCE_THIS_ITEM_EMT_PO_CREATED,
                                         input p_pod_nbr,
                                         input string(p_pod_line)).
            QraServices:GetSupplementaryMessageLogger():Warn(processMessage:String).
         end.  /* IF  p_pod_nbr <> "" */
      end. /* FOR EACH ttSalesOrderLine */
      empty temp-table ttSOLine.

    end method.

    method public override void UpdateWithConfirmation(input-output dataset-handle dsSalesOrderLine,
                                                       input-output dataset dsSalesOrderLineConf):  

      /* Copy the sales order lines to the typed dataset */
      dataset dsUpdateSalesOrderLine:handle:copy-dataset(dsSalesOrderLine:handle).

      for each ttUpdateSalesOrderLine
         break by ttUpdateSalesOrderLine.DomainCode
               by ttUpdateSalesOrderLine.SalesOrderNumber
      on error undo, throw:

      end. /* FOR EACH ttUpdateSalesOrderLine */

      dataset dsSalesOrderLine:handle:copy-dataset(dataset dsUpdateSalesOrderLine:handle).

       /* Call the standard code */
       super:UpdateWithConfirmation(input-output dataset dsSalesOrderLine by-reference,
                                    input-output dataset dsSalesOrderLineConf by-reference).

       for each ttSalesOrderLine:

          run  "us/xx/xxcpoupd.p" (input ttSalesOrderLine.DomainCode,
                                   input ttSalesOrderLine.SalesOrderNumber,
                                   input ttSalesOrderLine.SalesOrderLine,
                                   input ttSalesOrderLine.EMTType,
                                   input ttSalesOrderLine.EMTPONumber,
                                   input ttSalesOrderLine.EMTPOLine,
                                   input ttSalesOrderLine.SodDetLog01).

       end. /* FOR EACH  ttSalesOrderLine */

    end method.
  
   method public void updatedate
                         (input-output dataset dsUpdateSalesOrderLine):
  
       DEFINE VARIABLE apiHandle       AS HANDLE             NO-UNDO.
       define variable pManualList     as character          no-undo.
       define variable pMsgLvl         as integer            no-undo initial 0.
       define variable pMsgNbr         as character          no-undo initial "".
       define variable MsgLvl          as integer            no-undo initial 0.
       define variable MsgNbr1          as character          no-undo initial "".
       define variable duedate         as date    no-undo.
       define variable msgnbr          as int                no-undo.
       define variable l_atp_horizon   as integer            no-undo.
       define variable processMessage1 as IMessage           no-undo.
       DEFINE VARIABLE op_offset       AS LOGICAL NO-UNDO initial no. 
       define variable rqdate          as date     no-undo.
       define variable itemPlanningService  as IItemPlanning no-undo.
       define variable itemPlanningDO       as IItemPlanningDataObject no-undo.
       define variable l_buff_handle as handle no-undo.
       define variable l_query_handle as handle no-undo.
       define variable queryString as char no-undo.
       define variable l_atp as logical no-undo.
       define variable transit    as integer no-undo.
       DEFINE VARIABLE category AS CHARACTER NO-UNDO.
       define variable mfgAddressService as IMfgAddress no-undo.
       define variable mfgCustomerService as IMfgCustomer no-undo.
       define variable lvc_country as character no-undo.
       define variable lvc_city as character no-undo.
       define variable lvc_state as character no-undo.

     
     
       itemPlanningService = BaseServices:GetItemPlanning().
       
         for each ttUpdateSalesOrderLine
            break by ttUpdateSalesOrderLine.DomainCode
                  by ttUpdateSalesOrderLine.SalesOrderNumber
         on error undo, throw:
       message "datesss"   ttUpdateSalesOrderLine.SoldToCustomerCode ttUpdateSalesOrderLine.RequiredDate.  
     
     
       run us/xx/xxso01xr.p persistent set apiHandle.
       
       RUN getFCIPriceList IN apiHandle(INPUT ttUpdateSalesOrderLine.SoldToCustomerCode ,
                                        INPUT ttUpdateSalesOrderLine.ShipToAddressCode,
                                        INPUT ttUpdateSalesOrderLine.SiteCode,
                                        INPUT ttUpdateSalesOrderLine.OrderCurrencyCode,
                                        INPUT ttUpdateSalesOrderLine.ItemCode,
                                        INPUT ttUpdateSalesOrderLine.UnitOfMeasure,
                                        INPUT ttUpdateSalesOrderLine.CustomerItemCode,
                                        INPUT ttUpdateSalesOrderLine.QuantityOrdered,
                                        INPUT ttUpdateSalesOrderLine.PricingDate,
                                        OUTPUT pManualList,
                                        OUTPUT pmsglvl,
                                        OUTPUT pMsgNbr).
       if pMsgLvl <> 0 
       then do:
          ttUpdateSalesOrderLine.ManualPriceListCode = pManualList.
       end.
       
       run "us/xx/xxshpday.p" (INPUT ttUpdateSalesOrderLine.RequiredDate,
                               INPUT ttUpdateSalesOrderLine.SoldToCustomerCode,
                               INPUT ttUpdateSalesOrderLine.SiteCode,
                               INPUT YES,
                               OUTPUT rqdate,
                               OUTPUT op_offset,
                               OUTPUT msgnbr).
                   
                    message "xxshpday" msgnbr.
       
       if msgnbr  = 0 and  ttUpdateSalesOrderLine.RequiredDate <> rqdate
       then do:
          ttUpdateSalesOrderLine.RequiredDate = rqdate.
       end.
     
      itemPlanningDO = itemPlanningService:GetItemPlanning (input ttUpdateSalesOrderLine.DomainCode,
                                                            input ttUpdateSalesOrderLine.ItemCode,
                                                            input ttUpdateSalesOrderLine.SiteCode).
          
      if itemPlanningDO:Available
      then do:
         l_atp_horizon = itemPlanningDO:ATPHorizon.
      end.
      

       message "l_atp_horizon" l_atp_horizon.
       
      if ttUpdateSalesOrderLine.RequiredDate  >  today + l_atp_horizon
      then
         ttUpdateSalesOrderLine.DueDate = ttUpdateSalesOrderLine.RequiredDate.
      
      else
         ttUpdateSalesOrderLine.DueDate =  today + l_atp_horizon.
         
      
      
      run us/xx/xxso01xr.p persistent set apiHandle.
          
      RUN getCustConsoDate IN apiHandle(INPUT ttUpdateSalesOrderLine.DueDate,
                                        INPUT ttUpdateSalesOrderLine.SoldToCustomerCode,
                                        INPUT ttUpdateSalesOrderLine.SiteCode,
                                        OUTPUT duedate,
                                        OUTPUT msglvl,
                                        OUTPUT msgnbr1).
        message "msgnbrrrrr" msgnbr1.
      
      if msgnbr1 = ""
      then do:
         ttUpdateSalesOrderLine.DueDate = ttUpdateSalesOrderLine.DueDate.
      end.
      
      
      create buffer l_buff_handle for table "xpt_mstr".
      create query l_query_handle.
      l_query_handle:set-buffers (l_buff_handle).
      queryString = "".
      queryString =   "for each xpt_mstr no-lock where xpt_domain = " + 
      quoter(ttUpdateSalesOrderLine.DomainCode) + "  and xpt_part = " + quoter(ttUpdateSalesOrderLine.ItemCode) + ":"  .
      message "queryString" queryString 
      l_query_handle:query-prepare(queryString).
      l_query_handle:query-open().
      l_query_handle:get-first().
      
      do while not l_query_handle:query-off-end:
         l_atp = l_buff_handle:buffer-field("xpt_auto_promise"):buffer-value.
         l_query_handle:get-next().
      end.
      
      l_query_handle:query-close(). 
      delete object l_query_handle.
      delete object l_buff_handle.
      
      if l_atp = no
      then do:
      
         ttUpdateSalesOrderLine.performancedate =  date(month(ttUpdateSalesOrderLine.DueDate), day(ttUpdateSalesOrderLine.DueDate), 2049).
          
      end.
      else
          ttUpdateSalesOrderLine.performancedate = ttUpdateSalesOrderLine.DueDate.
          
      
       mfgAddressService = BaseServices:GetMfgAddress().
       
       mfgAddressService:Fetch (input ttUpdateSalesOrderLine.domaincode,
                                input ttUpdateSalesOrderLine.ShipToAddressCode,
                                output dataset dsMfgAddress by-reference).
          
           FOR EACH ttMfgAddress: 
       
              assign lvc_country = ttMfgAddress.CountryCode
                     lvc_state   = ttMfgAddress.State
                     lvc_city    = ttMfgAddress.city.
           end.
       
       mfgCustomerService = BaseServices:GetMfgCustomer().
       
       mfgCustomerService:Fetch(input ttUpdateSalesOrderLine.domaincode,
                                input ttUpdateSalesOrderLine.SoldToCustomerCode,
                    output dataset dsMfgCustomer by-reference).
           
       for each ttMfgCustomer:
          if customertype <> "4000"
        then 
           category = "02".
        else 
           category = "01".
       
       end.
      
       run "us/ad/addelt.p" (INPUT ttUpdateSalesOrderLine.sitecode,
                             INPUT lvc_country,
                             INPUT lvc_state,
                             INPUT lvc_city,
                             INPUT category,
                             OUTPUT transit).
       
      message "transait" transit.
       ttUpdateSalesOrderLine.promisedate =  ttUpdateSalesOrderLine.performancedate + transit.

     end. /* for each ttUpdateSalesOrderLine */
     
    
             
  end Method.
end class.

