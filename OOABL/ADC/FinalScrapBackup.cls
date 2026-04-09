USING com.qad.lang.List.
USING com.qad.lang.IMessage.
USING com.qad.lang.Message.
USING com.qad.qra.be.IVirtualBusinessEntity.
USING com.qad.qra.be.VirtualBusinessEntityBase.
USING com.qad.base.BaseError.
USING com.qad.base.BaseMessageKey.
USING com.qad.base.BaseServices.
USING com.qad.base.codes.IGeneralizedCode.
USING com.qad.inventory.InventoryServices.
USING com.qad.inventory.inv.IInventoryDetail.
USING com.qad.base.item.IItem.
USING com.qad.qra.QraServices.

CLASS com.adckcl.xxadcsalesquote.be.VirtualBusinessEntity
    INHERITS VirtualBusinessEntityBase
    IMPLEMENTS IVirtualBusinessEntity:

    {com/qad/base/codes/dsGeneralizedCode.i}
    {com/qad/inventory/inv/dsInventoryDetail.i}
    {com/qad/base/item/dsItem.i}

    /* =======================================================
       INITIALIZE Method
       ======================================================= */
    METHOD PUBLIC OVERRIDE VOID Initialize (
        INPUT entityURI AS CHARACTER,
        OUTPUT DATASET-HANDLE dsEntity ):

        DEFINE VARIABLE valMsgs               AS List       NO-UNDO.
        DEFINE VARIABLE bufScrap              AS HANDLE     NO-UNDO.
        DEFINE VARIABLE qryScrap              AS HANDLE     NO-UNDO.
        DEFINE VARIABLE generalizedCodeService AS IGeneralizedCode NO-UNDO.
        DEFINE VARIABLE vToday                AS DATE       NO-UNDO.
        DEFINE VARIABLE prnbr                 AS INTEGER    NO-UNDO.

        ASSIGN vToday = TODAY.

        /* Call super method first */
        SUPER:Initialize(INPUT entityURI, OUTPUT DATASET-HANDLE dsEntity BY-REFERENCE).

        /* Scrap Header Logic */
        IF entityURI = "urn:be:com.adckcl.xxadcscrap.Scrap.IScrap" THEN DO ON ERROR UNDO, THROW:
            ASSIGN valMsgs = NEW List().
            bufScrap = dsEntity:Get-Buffer-Handle("ttxxscrap").

            CREATE QUERY qryScrap.
            qryScrap:SET-BUFFERS(bufScrap).
            qryScrap:QUERY-PREPARE("FOR EACH ttxxscrap").
            qryScrap:QUERY-OPEN().
            qryScrap:GET-FIRST().

            generalizedCodeService = BaseServices:GetGeneralizedCode().

            /* Fetch only once per header for key1 */
            generalizedCodeService:Fetch(
                INPUT bufScrap::DomainCode,
                INPUT 'xx_scrap_incr',
                INPUT 'scrap',
                OUTPUT DATASET dsGeneralizedCode BY-REFERENCE
            ).

            FOR EACH ttGeneralizedCode:
                DEFINE VARIABLE i AS INTEGER NO-UNDO.
                DEFINE VARIABLE j AS INTEGER NO-UNDO.

                i = INTEGER(ttGeneralizedCode.Comments) NO-ERROR.
                IF i = ? THEN i = 0.
                j = i + 1.
                prnbr = j.
                ttGeneralizedCode.Comments = STRING(j).

                /* Build Key1 only once per scrap header */
                bufScrap:BUFFER-FIELD("key1"):BUFFER-VALUE = 
                    STRING(ttGeneralizedCode.Comments) 
                    + STRING(DAY(vToday),"99") 
                    + STRING(MONTH(vToday),"99") 
                    + STRING(YEAR(vToday),"9999") 
                    + REPLACE(STRING(TIME, "HH:MM:SS"),":","").

                /* Update generalized code once */
                generalizedCodeService:Update(INPUT DATASET dsGeneralizedCode BY-REFERENCE).
                MESSAGE "Generated Key1:" bufScrap:BUFFER-FIELD("key1"):BUFFER-VALUE VIEW-AS ALERT-BOX.
            END.

            /* Close query */
            IF qryScrap:IS-OPEN THEN qryScrap:QUERY-CLOSE().
            DELETE OBJECT qryScrap. ASSIGN qryScrap = ?.
        END.

    END METHOD.

    /* =======================================================
       CREATE Method
       ======================================================= */
    METHOD PUBLIC OVERRIDE VOID Create(
        INPUT entityURI AS CHARACTER,
        INPUT dataset-handle dsEntity):

        DEFINE VARIABLE valMsgs AS List NO-UNDO.
        DEFINE VARIABLE buf AS HANDLE NO-UNDO.
        DEFINE VARIABLE qry AS HANDLE NO-UNDO.
        DEFINE VARIABLE msg AS Message NO-UNDO.
        DEFINE VARIABLE isValidItem AS LOGICAL NO-UNDO.
        DEFINE VARIABLE inventoryDetailService AS IInventoryDetail NO-UNDO.
        DEFINE VARIABLE itemService AS IItem NO-UNDO.
        DEFINE VARIABLE generalizedCodeService AS IGeneralizedCode NO-UNDO.
        DEFINE VARIABLE vToday AS DATE NO-UNDO.
        DEFINE VARIABLE scrapKey AS CHARACTER NO-UNDO.
        DEFINE VARIABLE bufScrap AS HANDLE NO-UNDO.

        ASSIGN vToday = TODAY.

        /* Scrap Details Logic */
        IF entityURI = "urn:be:com.adckcl.xxadcscrap.ScrapDetails.IScrapDetails" THEN DO ON ERROR UNDO, THROW:
            ASSIGN valMsgs = NEW List().
            buf = dsEntity:Get-Buffer-Handle("ttxxscrapdetails").

            CREATE QUERY qry.
            qry:SET-BUFFERS(buf).
            qry:QUERY-PREPARE("FOR EACH ttxxscrapdetails").
            qry:QUERY-OPEN().
            qry:GET-FIRST().

            generalizedCodeService = BaseServices:GetGeneralizedCode().
            inventoryDetailService = InventoryServices:GetInventoryDetail().
            itemService = BaseServices:GetItem().

            /* Fetch scrap header key1 for details */
            bufScrap = dsEntity:Get-Buffer-Handle("ttxxscrap").
            bufScrap:FIND-FIRST("WHERE TRUE") NO-ERROR.
            IF bufScrap:AVAILABLE THEN
                scrapKey = bufScrap:BUFFER-FIELD("key1"):BUFFER-VALUE.

            /* Loop through detail records */
            DO WHILE NOT qry:QUERY-OFF-END:
                /* Assign key1 if missing */
                IF (buf:BUFFER-FIELD("key1"):BUFFER-VALUE = "" OR buf:BUFFER-FIELD("key1"):BUFFER-VALUE = ?) 
                   AND scrapKey <> "" THEN
                    ASSIGN buf:BUFFER-FIELD("key1"):BUFFER-VALUE = scrapKey.

                /* Validate Item and Reason */
                isValidItem = itemService:IsValidItem(INPUT buf::DomainCode, INPUT buf::ItemCode).

                IF buf::Reason = "" THEN DO:
                    ASSIGN msg = NEW Message(1,"Reason cannot be empty").
                    msg:SetContext(buf:BUFFER-FIELD("Reason")).
                    valMsgs:Add(msg).
                END.

                IF NOT isValidItem THEN DO:
                    ASSIGN msg = NEW Message(1,"Entered Item is not valid").
                    msg:SetContext(buf:BUFFER-FIELD("ItemCode")).
                    valMsgs:Add(msg).
                END.

                IF NOT valMsgs:IsEmpty() THEN 
                    UNDO, THROW NEW BaseError(valMsgs).  

                qry:GET-NEXT().
            END.

            IF qry:IS-OPEN THEN qry:QUERY-CLOSE().
            DELETE OBJECT qry. ASSIGN qry = ?.
        END.

        /* Call super method */
        SUPER:Create(INPUT entityURI, INPUT dataset-handle dsEntity BY-REFERENCE).

        /* Optional success message */
        QraServices:GetSupplementaryMessageLogger():Warn("Scrap Details processed successfully").

    END METHOD.

END CLASS.
