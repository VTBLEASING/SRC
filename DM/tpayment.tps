create or replace type dm.tPayment as object
(
  contract_key     NUMBER
  ,payment_item_key NUMBER
  ,payment_num      NUMBER
  ,plan_pay_dt_orig VARCHAR2(10)
  ,pay_dt_orig      VARCHAR2(10)
  ,overdue_days     NUMBER
  ,plan_amt         NUMBER
  ,fact_pay_amt     NUMBER
  ,pre_pay          NUMBER
  ,after_pay        NUMBER
  ,off_schedule     NUMBER(1)
  ,rown             NUMBER
)
/

