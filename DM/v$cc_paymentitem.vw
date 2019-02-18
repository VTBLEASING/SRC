create or replace force view dm.v$cc_paymentitem as
select PAYMENT_ITEM_KEY
       --,"PAYMENT_ITEM_CD"
       ,PAYMENT_ITEM_NAM
--,"CODE1C_CD","VALID_FROM_DTTM","VALID_TO_DTTM","PROCESS_KEY","FILE_ID"
  from dwh.payment_items where valid_to_dttm=date'2400-01-01'
;

