create or replace force view dm.v$cc_payment as
select contract_key
		,payment_item_key
       --,cbc_desc
       ,payment_num
       ,to_char(plan_pay_dt_orig, 'yyyy-mm-dd') plan_pay_dt_orig
       ,to_char(pay_dt_orig, 'yyyy-mm-dd') pay_dt_orig
	   ,overdue_days
       ,round(plan_amt,4) plan_amt
	   ,round(pre_pay,4) pre_pay
       ,round(fact_pay_amt,4) fact_pay_amt
       ,round(after_pay,4) after_pay
       --,currency_key, pay_flg
       ,snapshot_dt
	,off_schedule
       ,rown
       --,insert_dt
  from dm.dm_details_daily d where pay_flg=1
;
comment on column DM.V$CC_PAYMENT.CONTRACT_KEY is '���� �������� ������� � ������ �� ���������� ��������� �������';
comment on column DM.V$CC_PAYMENT.PAYMENT_ITEM_KEY is '���� ������ ������� � ������ �� ���������� ������ ��������';
comment on column DM.V$CC_PAYMENT.PAYMENT_NUM is '������ ������� -���������� ����� ���������� ��������� �������, ���������������� �� ���� ������� ';
comment on column DM.V$CC_PAYMENT.PLAN_PAY_DT_ORIG is '���� ��������� ������� ';
comment on column DM.V$CC_PAYMENT.PAY_DT_ORIG is '���� ������������ �������';
comment on column DM.V$CC_PAYMENT.OVERDUE_DAYS is '���������� ���� ���������';
comment on column DM.V$CC_PAYMENT.PLAN_AMT is '����� ��������� �������';
comment on column DM.V$CC_PAYMENT.PRE_PAY is '������� �� ������ (������������� ���� ������ � ������)';
comment on column DM.V$CC_PAYMENT.FACT_PAY_AMT is '����� ������������ �������';
comment on column DM.V$CC_PAYMENT.AFTER_PAY is '������� ����� ������';
comment on column DM.V$CC_PAYMENT.SNAPSHOT_DT is '�������� ����';
comment on column DM.V$CC_PAYMENT.ROWN is '����';

