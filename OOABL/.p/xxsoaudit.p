/* xxsoaudit.p - This class file is extension of Standard Update Method to audit Single sales orderLine from WEBUI*/
/*PROGRAM-TYPE=CLASS-PROGRAM                                                        */
/*----------------------------------------------------------------------------------*/
/* #### | Shanmuga Sundar | 08-Aug-24 | Program to capture changes for audit        */
/*----------------------------------------------------------------------------------*/


define input parameter domainCode   as character no-undo.
define input parameter orderNumber  as character no-undo.
define input parameter orderLine    as integer   no-undo.
define input parameter fieldName    as character no-undo.
define input parameter oldValue     as character no-undo.
define input parameter newValue     as character no-undo.
define input parameter descValue      as character no-undo.
define input parameter modBy as character no-undo.

create xx_sod_audit.
assign
    xx_sod_audit.xx_sod_audit_domain     = domainCode
    xx_sod_audit.xx_sod_audit_so_nbr     = orderNumber
    xx_sod_audit.xx_sod_audit_so_line    = orderLine
    xx_sod_audit.xx_sod_audit_field_Name = fieldName
    xx_sod_audit.xx_sod_audit_old_value  = oldValue
    xx_sod_audit.xx_sod_audit_new_value  = newValue
    xx_sod_audit.xx_sod_audit_desc       = descValue
    xx_sod_audit.xx_sod_audit_mod_by     = modBy
    xx_sod_audit.xx_sod_audit_mod_date   = now.
