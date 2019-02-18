CREATE OR REPLACE PROCEDURE DM.P_DM_FINANCE_REPORT(
p_REPORT_DT IN date
)
is
BEGIN
  /* ��������� ������� ������� ��� ������ CHR - 417.
     � �������� �������� ��������� �������� ���� ����������� ������
  */

  dm.u_log(p_proc => 'DM.P_DM_FINANCE_REPORT',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);

 delete from DM_FINANCE_REPORT
 where snapshot_dt = p_REPORT_DT;

  dm.u_log(p_proc => 'DM.P_DM_FINANCE_REPORT',
           p_step => 'delete from DM_FINANCE_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  commit;

  INSERT INTO DM.DM_FINANCE_REPORT
select
      p_REPORT_DT AS SNAPSHOT_DT
      ,rlp.contract_app_key -- KEY!
      ,con.contract_num -- ����� �������� �������
      ,con.contract_id_cd -- ID �������� �������
      ,lca.presentation -- ���������� � �������� �������
      ,con.contract_id_cd || ' ' || lca.presentation as id_appendix_lease_agreement -- ID ���������� � �������� �������
      ,cli.full_client_ru_nam -- ����������
      ,mir.col_mircode -- ���-���
      ,mir.manager -- �������� ���-����
      ,lcs.sector -- ������ ��
      ,mir.grfrepsegment -- �������
      ,cli.inn -- ���
      ,lcs.leasing_asset_kind_desc as type_of_property -- ��� ���������
      ,lcs.contract_fin_kind_desc as type_of_lease -- ��� �������
      ,org.branch_nam -- �����������
      ,rlp.maturitydate as maturitydate_fin -- ���� �������������� �������� --?
      ,rlp.startdate -- ���� ������ ��������
      ,rlp.maturitydate -- ���� ��������� ��������
      ,(fpp1.sum1 - fpp2.sum2) as ammount_of_sale -- ����� �����-������� ��������� (��� ���)
      ,psi.future_leasepmnt_amt --����� ������� ���������� �������� � ������ ��������� �������� (��� ���)
      ,asa.avans -- ����� ������ �� �������� ������� (��� ���)
      ,ass.subsid -- ����� �������� �� ���������� ������ (��������)
      ,(nvl(rlp1.exposureprincipal,0) + nvl(rlp1.exposureprincipaloverdue,0) - nvl(rlp1.accruedinterest,0)) as start_nil  -- �������������� NIL
      ,(nvl(rlp.exposureprincipal,0) + nvl(rlp.exposureprincipaloverdue,0) - nvl(rlp.accruedinterest,0)) as progno_nil -- ���������� �������� NIL
      ,rlp.accruedinterestboy -- ���������� �������� FLI �� ������ � ������ ����
      ,rlp.accruedinterestboq -- ���������� �������� FLI �� ������ � ������ ��������
      ,rlp.accruedinterestbom -- ���������� �������� FLI �� ������ � ������ ������
      ,rlp.accruedinterestbow -- ���������� �������� FLI �� ������ � ������ ������
from dwh.reportloanportfolio rlp
left join (
          select DISTINCT contract_key, contract_num, contract_id_cd
          from dwh.contracts
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
           ) con
           on con.contract_key = rlp.contract_key
left join (
          select DISTINCT contract_app_key, presentation
          from dwh.leasing_contracts_appls
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          ) lca
          on lca.contract_app_key = rlp.contract_app_key
left join (
          select DISTINCT contract_key, mircode_key, sector, leasing_asset_kind_desc, contract_fin_kind_desc
          from dwh.leasing_contracts
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          ) lcs
          on lcs.contract_key = rlp.contract_key
left join (
          select mircode_key, col_mircode, manager, grfrepsegment
          from dwh.mircode
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          ) mir
          on mir.mircode_key = lcs.mircode_key
left join (
          select DISTINCT client_key, branch_key, full_client_ru_nam, inn
          from dwh.clients
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          ) cli
          on cli.client_key = rlp.client_key
left join (
          select DISTINCT branch_key, branch_nam
          from dwh.org_structure
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          ) org
          on org.branch_key = cli.branch_key
left join (
          select contract_app_key, sum(sum_) as future_leasepmnt_amt
          from dwh.paymentscheduleifrs
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          AND payment_item_key in (48,50)
          and date_ > to_date(P_REPORT_DT,'DD.MM.YYYY')
          group by contract_APP_key
          ) psi
          on psi.contract_app_key = rlp.contract_app_key
left join (
          select a.contract_app_key, a.avans from
                 (
                 select distinct contract_app_key, payment_item_key,sum(sum_) as avans
                 from dwh.accrualscheduleifrs
                 where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
                 and   date_ > to_date(P_REPORT_DT,'DD.MM.YYYY')
                 group by contract_app_key, payment_item_key
                 ) a left join
                 (
                 select distinct payment_item_key,payment_item_nam
                 from dwh.payment_items
                 where payment_item_nam like '%�����%'
                 and
                 VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')) b
                 on a.payment_item_key =b.payment_item_key
          ) asa
          on asa.contract_app_key = rlp.contract_app_key
left join (
          select a.contract_app_key, A.SUBSID from
                 (
                 select distinct contract_app_key, payment_item_key,sum(sum_) as SUBSID
                 from dwh.accrualscheduleifrs
                 where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
                 and   date_ > to_date(P_REPORT_DT,'DD.MM.YYYY')
                 group by contract_app_key, payment_item_key
                 ) a left join
                 (
                 select distinct payment_item_key,payment_item_nam
                 from dwh.payment_items
                 where payment_item_nam like '%�������%'
                 and
                 VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')) b
                 on a.payment_item_key =b.payment_item_key
          ) ass
          on ass.contract_app_key = rlp.contract_app_key -- ��������
left join (
          select contract_app_key, sum(pay_amt) as sum1
          from dwh.fact_plan_payments
          where cbc_desc like '%��.3.1%'
          and VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yyyy')
          and pay_dt <= to_date(P_REPORT_DT,'DD.MM.YYYY')
          group by contract_app_key
          ) fpp1
          on fpp1.contract_app_key = rlp.contract_app_key -- ����� �����-������� ��������� 1 (��� ���)
left join (
          select contract_app_key, sum(pay_amt) as sum2
          from dwh.fact_plan_payments
          where cbc_desc like '%��.3.1%'
          and payment_item_key in (8, 2)
          and VALID_TO_DTTM=TO_DATE('01.01.2400', 'dd.mm.yyyy')
          and pay_dt <= to_date(P_REPORT_DT,'DD.MM.YYYY')
          group by contract_app_key
          ) fpp2
          on fpp2.contract_app_key = rlp.contract_app_key -- ����� �����-������� ��������� 2 (��� ���)
left join (
          select contract_app_key, exposureprincipal, exposureprincipaloverdue, accruedinterest
          from dwh.reportloanportfolio
          where startdate = to_date(P_REPORT_DT,'DD.MM.YYYY')
          ) rlp1
          on rlp1.contract_app_key = rlp.contract_app_key
          where rlp.reportingdate=TO_DATE(p_REPORT_DT,'DD.MM.YYYY');
         COMMIT;
          dm.u_log(p_proc => 'DM.P_DM_FINANCE_REPORT',
           p_step => 'INSERT INTO DM_FINANCE_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
           etl.P_DM_LOG('DM_FINANCE_REPORT');
          END;
/

