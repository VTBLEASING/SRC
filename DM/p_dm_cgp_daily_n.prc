CREATE OR REPLACE PROCEDURE DM.P_DM_CGP_DAILY_N (
    p_REPORT_DT in date
)

is

BEGIN

delete from DM.DM_CGP_DAILY
where SNAPSHOT_DT = p_REPORT_DT;
  dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY_N',
           p_step => 'delete from DM.DM_CGP_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
            
INSERT into DM.DM_CGP_DAILY (
                          SNAPSHOT_DT,
                          SNAPSHOT_MONTH,
                          CONTRACT_KEY,
                          CONTRACT_NUM,
                          CONTRACT_ID_CD,
                          INN,
                          SHORT_CLIENT_RU_NAM,
                          TRANSMIT_SUBJECT_NAM,
                          LEASING_SUBJECT_KEY,
                          LEASING_DEAL_KEY,
                          LEASING_OFFER_KEY,
                          PRODUCT_NAM,
                          ACTUAL_FLG,
                          STATUS_1C_DESC,
                          CONTRACT_STATUS_KEY,
                          STATE_STATUS_KEY,
                          SUBJECT_STATUS_KEY,
                          CUR_LEAS_OVERDUE_DAYS,
                          MAX_LEAS_OVERDUE_DAYS,
                          MAX_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
                          AVG_LEAS_OVERDUE_DAYS,
                          AVG_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
                          CUR_ADV_OVERDUE_DAYS,
                          MAX_ADV_OVERDUE_DAYS,
                          AVG_ADV_OVERDUE_DAYS,
                          CUR_RED_OVERDUE_DAYS,
                          MAX_RED_OVERDUE_DAYS,
                          AVG_RED_OVERDUE_DAYS,
                          CUR_OTH_COM_OVERDUE_DAYS,
                          MAX_OTH_COM_OVERDUE_DAYS,
                          AVG_OTH_COM_OVERDUE_DAYS,
                          CUR_FIX_COM_OVERDUE_DAYS,
                          MAX_FIX_COM_OVERDUE_DAYS,
                          AVG_FIX_COM_OVERDUE_DAYS,
                          CUR_SUB_OVERDUE_DAYS,
                          MAX_SUB_OVERDUE_DAYS,
                          AVG_SUB_OVERDUE_DAYS,
                          CUR_ADD_INS_OVERDUE_DAYS,
                          MAX_ADD_INS_OVERDUE_DAYS,
                          AVG_ADD_INS_OVERDUE_DAYS,
                          CUR_INS_OVERDUE_DAYS,
                          MAX_INS_OVERDUE_DAYS,
                          AVG_INS_OVERDUE_DAYS,
                          CUR_REG_OVERDUE_DAYS,
                          MAX_REG_OVERDUE_DAYS,
                          AVG_REG_OVERDUE_DAYS,
                          CUR_FOR_OVERDUE_DAYS,
                          MAX_FOR_OVERDUE_DAYS,
                          AVG_FOR_OVERDUE_DAYS,
                          CUR_PEN_OVERDUE_DAYS,
                          MAX_PEN_OVERDUE_DAYS,
                          AVG_PEN_OVERDUE_DAYS,
                          CUR_OVR_OVERDUE_DAYS,
                          MAX_OVR_OVERDUE_DAYS,
                          AVG_OVR_OVERDUE_DAYS,
                          CUR_INSUR_OVERDUE_DAYS,
                          MAX_INSUR_OVERDUE_DAYS,
                          AVG_INSUR_OVERDUE_DAYS,
                          CUR_OTH_OVERDUE_DAYS,
                          MAX_OTH_OVERDUE_DAYS,
                          AVG_OTH_OVERDUE_DAYS,
                          LEASING_PAYMENTS_COUNT,
                          LEASING_PAYMENTS_COUNT_12, --[by ovilkova due to cross-checker 24/07/2017]
                          LEASING_PAYMENTS_SUM,
                          CUR_LEAS_OVERDUE_AMT,
                          CUR_ADV_OVERDUE_AMT,
                          CUR_RED_OVERDUE_AMT,
                          CUR_OTH_COM_OVERDUE_AMT,
                          CUR_FIX_COM_OVERDUE_AMT,
                          CUR_SUB_OVERDUE_AMT,
                          CUR_ADD_OVERDUE_AMT,
                          CUR_INS_OVERDUE_AMT,
                          CUR_REG_OVERDUE_AMT,
                          CUR_FOR_OVERDUE_AMT,
                          CUR_PEN_OVERDUE_AMT,
                          CUR_OVR_OVERDUE_AMT,
                          CUR_INSUR_OVERDUE_AMT,
                          CUR_OTH_OVERDUE_AMT,
                          OVERDUE_LEASING_PAYMENTS_COUNT,
                          LEAS_COUNT_12,  --[by ovilkova due to cross-checker 24/07/2017]
                          CUR_LEAS_OVERDUE_DT,
                          MAX_LEAS_PAY_DT,
                          TOTAL_LEAS_OVERDUE_DAYS,
                          CIS_OVERDUE_AMT,
                          CIS_OVERDUE_AMT_TAX,
                          CIS_TERM_AMT_RISK,
                          CIS_TERM_AMT,
                          CIS_TERM_AMT_TAX_RISK,
                          CIS_TERM_AMT_TAX,
                          NIL,
                          FINANCE_AMT,
                          GR_FIN_START_AMT,
                          CL_FIN_START_AMT,
                          GR_FIN_CUR_AMT,
                          CL_FIN_CUR_AMT,
                          PTS_FLG,
                          PTS_DT,
                          PTS_COMM,
                          INSERT_DT,
                          SUBPRODUCT_NAM,
                          LEASE_TERM_CNT, 
                          end_dt, --[by ovilkova due to cross-checker 1/08/2017]
                          advance_rub, --[by ovilkova due to cross-checker 1/08/2017]
                          SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
                          balance, --[by ovilkova due to cross-checker 1/08/2017]
                          cr_ch_flg --[by ovilkova due to cross-checker 1/08/2017]
                          )
                          
 with cgp as 
            (                                             
              select 
                          p_REPORT_DT as snapshot_dt,
                          trunc (p_REPORT_DT, 'mm') as snapshot_month,
                          LC.contract_key,
                          LC.CONTRACT_NUM,
                          LC.CONTRACT_ID_CD,
                          CL.INN,
                          CL.SHORT_CLIENT_RU_NAM,
                          TT.TRANSMIT_SUBJECT_NAM,
                          LC.LEASING_SUBJECT_KEY,
                          LC.LEASING_DEAL_KEY,
                          LC.LEASING_OFFER_KEY,
                          P.PRODUCT_NAM,
                          SP.SUBPRODUCT_NAM,
                          LO.LEASE_TERM_CNT,
                          LC.ACTUAL_FLG,
                          WS.STATUS_1C_DESC,
                          WS.CONTRACT_STATUS_KEY,
                          WS.STATE_STATUS_KEY,
                          WS.SUBJECT_STATUS_KEY,
                                                  
                          -- ���������� ���� ��������� �� ���. ��������, �������
                          max(case
                          when pi.payment_item_nam = '���������� ������ (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > case
                                                                             when par.param_type = 'ABS'
                                                                                  then param_val
                                                                             when par.param_type = 'PRC'
                                                                                  then param_val * DAILY.plan_amt
                                                                        end
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_LEAS_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ���. ��������, ������������
                          max (case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                else null
                          end) as MAX_LEAS_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ���. ��������, ������������ �� ��������� 12 ���. --[by ovilkova due to cross-checker 25/07/2017]
                          max (case
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                   and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12)--[by ovilkova due to cross-checker 25/07/2017]
                                      then
                                            DAILY.overdue_days
                                else null
                          end) as MAX_LEAS_OVERDUE_DAYS_12,                                       
                          
                          -- ������� ���������� ���� ��������� �� ���������� ��������
                          AVG(case 
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       then 
                                            DAILY.overdue_days
                               else null
                          end) as AVG_LEAS_OVERDUE_DAYS,
                          
                          -- ������� ���������� ���� ��������� �� ���������� �������� --[by ovilkova due to cross-checker 25/07/2017]
                          AVG(case 
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and DAILY.PRE_PAY > case
                                                            when par.param_type = 'ABS'
                                                                then param_val
                                                            when par.param_type = 'PRC'
                                                                then param_val * DAILY.plan_amt
                                                       end
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                   and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12) --[by ovilkova due to cross-checker 25/07/2017]
                                       then 
                                            DAILY.overdue_days
                               else null
                          end) as AVG_LEAS_OVERDUE_DAYS_12,                          
                                  
                          -- ���������� ���� ��������� �� ����� (� ���), �������
                          max(case
                          when pi.payment_item_nam = '����� (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_ADV_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ����� (� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '����� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_ADV_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����� (� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '����� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_ADV_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� �������� ��������� (� ���), �������
                          max(case
                          when pi.payment_item_nam = '�������� ��������� (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_RED_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� �������� ��������� (� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '�������� ��������� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_RED_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� �������� ��������� (� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '�������� ��������� (� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_RED_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��), �������
                          max(case
                          when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_OTH_COM_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��), ������������
                          max (case
                                  when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_OTH_COM_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ���� �������� �� ����. ������ (��������������� ��),�������
                          avg (case
                                  when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_OTH_COM_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� �������� �������������, �������
                          max(case
                          when pi.payment_item_nam = '�������� �������������'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_FIX_COM_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� �������� �������������, ������������
                          max (case
                                  when pi.payment_item_nam = '�������� �������������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_FIX_COM_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� �������� �������������,�������
                          avg (case
                                  when pi.payment_item_nam = '�������� �������������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_FIX_COM_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ��������������� ������ (��������), �������
                          max(case
                          when pi.payment_item_nam = '��������������� ������ (��������)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_SUB_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ��������������� ������ (��������), ������������
                          max (case
                                  when pi.payment_item_nam = '��������������� ������ (��������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_SUB_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ��������������� ������ (��������),�������
                          avg (case
                                  when pi.payment_item_nam = '��������������� ������ (��������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_SUB_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (���. ������), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (���. ������)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_ADD_INS_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ����������� ������ (���. ������), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (���. ������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_ADD_INS_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (���. ������),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (���. ������)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_ADD_INS_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (����������� ��), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (����������� ��)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_INS_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ����������� ������ (����������� ��), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_INS_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (����������� ��),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_INS_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_REG_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_REG_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (������ ����������� �� � �����),�������
                          avg (case
                                  when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_REG_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���), �������
                          max(case
                          when pi.payment_item_nam = '����������� ������ (������ �� ��������� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_FOR_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���), ������������
                          max (case
                                  when pi.payment_item_nam = '����������� ������ (������ �� ��������� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_FOR_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����������� ������ (������ �� ��������� ���),�������
                          avg (case
                                  when pi.payment_item_nam = '������������ ������ (������ �� ��������� ���)'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_FOR_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����, �������
                          max(case
                          when pi.payment_item_nam = '����'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_PEN_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ����, ������������
                          max (case
                                  when pi.payment_item_nam = '����'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_PEN_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ����,�������
                          avg (case
                                  when pi.payment_item_nam = '����'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_PEN_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ���������, �������
                          max(case
                          when pi.payment_item_nam = '���������'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_OVR_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ���������, ������������
                          max (case
                                  when pi.payment_item_nam = '���������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_OVR_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ���������,�������
                          avg (case
                                  when pi.payment_item_nam = '���������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_OVR_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ��������� ����������, �������
                          max(case
                          when pi.payment_item_nam = '��������� ����������'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_INSUR_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ��������� ����������, ������������
                          max (case
                                  when pi.payment_item_nam = '��������� ����������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_INSUR_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ��������� ����������,�������
                          avg (case
                                  when pi.payment_item_nam = '��������� ����������'
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_INSUR_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ������ �������, �������
                          max(case
                          when RPI.group_flg = 1
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then 0
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > 0
                                                        then p_REPORT_DT - DAILY.plan_pay_dt_orig
                                            else 0
                                            end
                                      end
                          else null
                          end) as CUR_OTH_OVERDUE_DAYS,
                          
                          
                          -- ���������� ���� ��������� �� ������ �������, ������������
                          max (case
                                  when RPI.group_flg = 1
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as MAX_OTH_OVERDUE_DAYS,
                          
                          -- ���������� ���� ��������� �� ������ �������,�������
                          avg (case
                                  when RPI.group_flg = 1
                                   and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                      then
                                            DAILY.overdue_days
                                      else null
                          end) as AVG_OTH_OVERDUE_DAYS,
                          
                          -- ���������� ��������� ���������� ��������
                          count (distinct case 
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and DAILY.pay_dt_orig <= p_REPORT_DT
                                       and DAILY.after_pay < case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                           then DAILY.payment_num
                                       else null
                                end
                          ) as LEASING_PAYMENTS_COUNT,
                          
                          -- ���������� ��������� ���������� �������� �� ��������� 12 ������� --[by ovilkova due to cross-checker 24/07/2017]
                          count (distinct case 
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT,-12) --[by ovilkova due to cross-checker 25/07/2017]
                                       and DAILY.pay_dt_orig <= p_REPORT_DT
                                       and DAILY.after_pay < case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                           then DAILY.payment_num
                                       else null
                                end
                          ) as LEASING_PAYMENTS_COUNT_12,                                             
                          
                          -- ����� ��������� ���������� ��������
                          sum (case 
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and pay_dt_orig <= p_REPORT_DT
                                           then fact_pay_amt
                                    else null
                          end) as LEASING_PAYMENTS_SUM,
                          
                          -- ������������ ������������� �� ���. ��������, �������
                          sum ( case 
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.after_pay > case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_LEAS_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ����� (� ���), �������
                          sum ( case 
                                      when pi.payment_item_nam = '����� (� ���)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_ADV_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� �������� ��������� (� ���), �������
                          sum ( case 
                                      when pi.payment_item_nam = '�������� ��������� (� ���)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_RED_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ���� �������� �� ����. ������ (��������������� ��), �������
                          sum ( case 
                                      when pi.payment_item_nam = '���� �������� �� ����. ������ (��������������� ��)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_OTH_COM_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� �������� �������������, �������
                          sum ( case 
                                      when pi.payment_item_nam = '�������� �������������'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_FIX_COM_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ��������������� ������ (��������), �������
                          sum ( case 
                                      when pi.payment_item_nam = '��������������� ������ (��������)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_SUB_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ����������� ������ (���. ������), �������
                          sum ( case 
                                      when pi.payment_item_nam = '����������� ������ (���. ������)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_ADD_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ����������� ������ (����������� ��), �������
                          sum ( case 
                                      when pi.payment_item_nam = '����������� ������ (����������� ��)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_INS_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ����������� ������ (������ ����������� �� � �����), �������
                          sum ( case 
                                      when pi.payment_item_nam = '����������� ������ (������ ����������� �� � �����)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_REG_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ����������� ������ (������ �� ��������� ���), �������
                          sum ( case 
                                      when pi.payment_item_nam = '����������� ������ (������ �� ��������� ���)'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_FOR_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ����, �������
                          sum ( case 
                                      when pi.payment_item_nam = '����'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_PEN_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ���������, �������
                          sum ( case 
                                      when pi.payment_item_nam = '���������'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_OVR_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ��������� ����������, �������
                          sum ( case 
                                      when pi.payment_item_nam = '��������� ����������'
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_INSUR_OVERDUE_AMT,
                          
                          -- ������������ ������������� �� ������ �������, �������
                          sum ( case 
                                      when RPI.group_flg = 1
                                       and pay_flg = 0
                                           then DAILY.after_pay
                                       else null
                                end
                          ) as CUR_OTH_OVERDUE_AMT,
                          
                          -- ���������� ���������� �������� � ����������
                          count (distinct case 
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and DAILY.after_pay > case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                       and pay_flg = 0
                                           then DAILY.payment_num
                                       else null
                                end
                          ) as OVERDUE_LEASING_PAYMENTS_COUNT,
                          
                          -- ���������� ��� ��������� �� ���������� �������� �� ��������� 12 ���. --[by ovilkova due to cross-checker 25/07/2017]
                          count (distinct case 
                                      when pi.payment_item_nam = '���������� ������ (� ���)'
                                       and DAILY.plan_pay_dt_orig <= p_REPORT_DT
                                       and DAILY.plan_pay_dt_orig > add_months(p_REPORT_DT, -12) --[by ovilkova due to cross-checker 25/07/2017]
                                       and DAILY.after_pay > case
                                                                  when par.param_type = 'ABS'
                                                                      then param_val
                                                                  when par.param_type = 'PRC'
                                                                      then param_val * DAILY.plan_amt
                                                              end
                                       --and pay_flg = 0
                                       and DAILY.overdue_days != 0
                                           then DAILY.overdue_days
                                       else null
                                end
                          ) as LEAS_COUNT_12  ,                        
                                                                         
                          -- ���� ������������� ������������ ������������� �� ���. ��������, �������
                          min (case
                          when pi.payment_item_nam = '���������� ������ (� ���)'
                              then
                                      case
                                      when DAILY.plan_pay_dt_orig > p_REPORT_DT
                                        or DAILY.plan_amt = 0
                                           then null
                                      else
                                            case
                                                  when (DAILY.pay_dt_orig >= p_REPORT_DT
                                                        or DAILY.pay_dt_orig is null)
                                                    and DAILY.pre_pay > case
                                                                             when par.param_type = 'ABS'
                                                                                  then param_val
                                                                             when par.param_type = 'PRC'
                                                                                  then param_val * DAILY.plan_amt
                                                                        end
                                                        then DAILY.plan_pay_dt_orig
                                            else null
                                            end
                                      end
                          else null
                          end) as CUR_LEAS_OVERDUE_DT,
                          
                          -- ���� ���������� ����������� �������
                          MAX (case 
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and plan_pay_dt_orig <= p_REPORT_DT
                                       then plan_pay_dt_orig
                               else null
                          end) as MAX_LEAS_PAY_DT, 
                          
                          -- ��������� ���������� ���� ��������� �� ���������� ��������
                          SUM(case 
                                  when pi.payment_item_nam = '���������� ������ (� ���)'
                                   and pay_flg = 0
                                   and DAILY.overdue_days > 0
                                       then DAILY.overdue_days
                               else null
                          end) as TOTAL_LEAS_OVERDUE_DAYS,  
                          
                          -- ������������ ������������� ��� ��� ���
                          CGP.OVERDUE_AMT  as CIS_OVERDUE_AMT,
                          
                          -- ������������ ������������� ��� � ���
                          CGP.OVERDUE_AMT_TAX  as CIS_OVERDUE_AMT_TAX,
                          
                          -- ������� ������������� ��� ���, ��� ����� �������� (���)
                          CGP.TERM_AMT_RISK  as CIS_TERM_AMT_RISK,
                          
                          -- ������� ������������� ��� ���, � ������ �������� (���)
                          CGP.TERM_AMT  as CIS_TERM_AMT,
                          
                          -- ������� ������������� � ���, ��� ����� �������� (���)
                          CGP.TERM_AMT_TAX_RISK  as CIS_TERM_AMT_TAX_RISK,
                          
                          -- ������� ������������� ��� ���, ��� ����� �������� (���)
                          CGP.TERM_AMT_TAX as CIS_TERM_AMT_TAX,
                          
                          -- ����� ������������� �� NIL
                          nvl (CGP.OVERDUE_AMT_TAX, 0) + nvl (CGP.TERM_AMT_TAX, 0) as NIL,
                          
                          -- ����� �������������� �� ��������, ��������������
                          TT.FINANCE_AMT,
                          
                          -- ���������� ����� �������������� �� ������ �������� �� ������� ����, ��������������
                          TT.FIRST_FIN_AMT as GR_FIN_START_AMT,
                          
                          -- ���������� ����� �������������� �� ������� �� ������� ����, ��������������
                          TT.FIRST_FIN_AMT_CLIENTS as CL_FIN_START_AMT,  
                          CFD.ACCEPT as PTS_FLG,
                          CFD.VTBLDATE as PTS_DT,
                          CFD."comment" as PTS_COMM,
                          SYSDATE as INSERT_DT,
                          LC.account_group_key,
                          LC.crm_client_key,
                          
                          
                          LC.end_dt, --[by ovilkova due to cross-checker 1/08/2017]
                          TT.ADVANCE_RUB, --[by ovilkova due to cross-checker 1/08/2017]
                          TT.SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
                          (CGP.OVERDUE_AMT_TAX + CGP.TERM_AMT_TAX) as BALANCE, --[by ovilkova due to cross-checker 1/08/2017]
                          case 
                            when LC.end_dt >=  add_months(p_REPORT_DT, -12) 
                              then 1 
                            else 0 
                          end as cr_ch_flg
                               
              from  
                    DWHRO.V_UAKR_LEASING_CONTRACTS LC
              LEFT JOIN DM.DM_TRANSMIT_SUBJECTS TT 
                    On TT.CONTRACT_ID_CD = LC.CONTRACT_ID_CD
              left join dwh.leasing_subjects ls
                     ON     tt.leasing_subject_key =
                               ls.leasing_subject_key
                        AND ls.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                        AND ls.end_dt = to_date ('31.12.3999', 'dd.mm.yyyy')
              LEFT JOIN dwh.products p
                     ON     ls.product_key = p.product_key
                        AND p.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
              LEFT JOIN dwh.subproducts sp
                     ON     ls.SUBPRODUCT_KEY = sp.SUBPRODUCT_KEY
                        AND sp.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
              left join dwh.leasing_offers lo
                     ON     lc.leasing_offer_key =
                               lo.leasing_offer_key
                        AND lo.valid_to_dttm =
                               TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                        AND lo.end_dt = to_date ('31.12.3999', 'dd.mm.yyyy')
              LEFT JOIN dwh.clients CL
                    ON LC.CLIENT_KEY = CL.CLIENT_KEY
                   AND CL.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN DM.DM_DETAILS_DAILY DAILY
                    ON LC.CONTRACT_KEY = DAILY.CONTRACT_KEY
              LEFT JOIN DWH.CRM_CONTROLOFDOC CFD
                    ON LC.CRM_CONTRACT_CD = CFD.CRM_CONTRACT_CD
                   AND CFD.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN dwh.PAYMENT_ITEMS PI
                    ON DAILY.PAYMENT_ITEM_KEY = PI.PAYMENT_ITEM_KEY
                   AND PI.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN dwh.REF_PAYMENT_ITEMS RPI
                    ON PI.PAYMENT_ITEM_NAM = RPI.PAYMENT_ITEM_NAM
              LEFT JOIN DWHRO.V_UAKR_CGP CGP
                    ON DAILY.CONTRACT_KEY = CGP.CONTRACT_KEY
                   AND CGP.SNAPSHOT_DT = case 
                                              when p_REPORT_DT = last_day (p_REPORT_DT)
                                                  then  p_REPORT_DT
                                              else trunc (p_REPORT_DT, 'mm') - 1 
                                         end
              LEFT JOIN DWH.CGP_DAILY_PARAMS par
                    ON 1 = 1
                   AND par.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
              LEFT JOIN DM.DM_WORK_STATUSES WS
                    ON DAILY.CONTRACT_KEY = WS.CONTRACT_KEY
                   AND p_REPORT_DT = WS.REPORT_DT
              --where daily.contract_key =  1836
              GROUP BY  LC.contract_key,
                        LC.CONTRACT_NUM,
                        LC.CONTRACT_ID_CD,
                        CL.INN,
                        CL.SHORT_CLIENT_RU_NAM,
                        TT.TRANSMIT_SUBJECT_NAM,
                        LC.LEASING_SUBJECT_KEY,
                        LC.LEASING_DEAL_KEY,
                        LC.LEASING_OFFER_KEY,
                        P.PRODUCT_NAM,
                        SP.SUBPRODUCT_NAM,
                        LO.LEASE_TERM_CNT,
                        LC.ACTUAL_FLG,
                        WS.STATUS_1C_DESC,
                        WS.CONTRACT_STATUS_KEY,
                        WS.STATE_STATUS_KEY,
                        WS.SUBJECT_STATUS_KEY,
                        CGP.OVERDUE_AMT,
                        CGP.OVERDUE_AMT_TAX,
                        CGP.TERM_AMT_RISK,
                        CGP.TERM_AMT,
                        CGP.TERM_AMT_TAX_RISK,
                        CGP.TERM_AMT_TAX,
                        nvl (CGP.OVERDUE_AMT_TAX, 0) + nvl (CGP.TERM_AMT_TAX, 0),
                        TT.FINANCE_AMT,
                        TT.FIRST_FIN_AMT,
                        TT.FIRST_FIN_AMT_CLIENTS,
                        LC.account_group_key,
                        LC.crm_client_key,
                        LC.end_dt,
                        TT.ADVANCE_RUB,
                        TT.Supply_Rub                        
              )
select 
        SNAPSHOT_DT,
        SNAPSHOT_MONTH,
        CONTRACT_KEY,
        CONTRACT_NUM,
        CONTRACT_ID_CD,
        INN,
        SHORT_CLIENT_RU_NAM,
        TRANSMIT_SUBJECT_NAM,
        LEASING_SUBJECT_KEY,
        LEASING_DEAL_KEY,
        LEASING_OFFER_KEY,
        PRODUCT_NAM,
        ACTUAL_FLG,
        STATUS_1C_DESC,
        CONTRACT_STATUS_KEY,
        STATE_STATUS_KEY,
        SUBJECT_STATUS_KEY,
        CUR_LEAS_OVERDUE_DAYS,
        MAX_LEAS_OVERDUE_DAYS,
        MAX_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
        AVG_LEAS_OVERDUE_DAYS,
        AVG_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
        CUR_ADV_OVERDUE_DAYS,
        MAX_ADV_OVERDUE_DAYS,
        AVG_ADV_OVERDUE_DAYS,
        CUR_RED_OVERDUE_DAYS,
        MAX_RED_OVERDUE_DAYS,
        AVG_RED_OVERDUE_DAYS,
        CUR_OTH_COM_OVERDUE_DAYS,
        MAX_OTH_COM_OVERDUE_DAYS,
        AVG_OTH_COM_OVERDUE_DAYS,
        CUR_FIX_COM_OVERDUE_DAYS,
        MAX_FIX_COM_OVERDUE_DAYS,
        AVG_FIX_COM_OVERDUE_DAYS,
        CUR_SUB_OVERDUE_DAYS,
        MAX_SUB_OVERDUE_DAYS,
        AVG_SUB_OVERDUE_DAYS,
        CUR_ADD_INS_OVERDUE_DAYS,
        MAX_ADD_INS_OVERDUE_DAYS,
        AVG_ADD_INS_OVERDUE_DAYS,
        CUR_INS_OVERDUE_DAYS,
        MAX_INS_OVERDUE_DAYS,
        AVG_INS_OVERDUE_DAYS,
        CUR_REG_OVERDUE_DAYS,
        MAX_REG_OVERDUE_DAYS,
        AVG_REG_OVERDUE_DAYS,
        CUR_FOR_OVERDUE_DAYS,
        MAX_FOR_OVERDUE_DAYS,
        AVG_FOR_OVERDUE_DAYS,
        CUR_PEN_OVERDUE_DAYS,
        MAX_PEN_OVERDUE_DAYS,
        AVG_PEN_OVERDUE_DAYS,
        CUR_OVR_OVERDUE_DAYS,
        MAX_OVR_OVERDUE_DAYS,
        AVG_OVR_OVERDUE_DAYS,
        CUR_INSUR_OVERDUE_DAYS,
        MAX_INSUR_OVERDUE_DAYS,
        AVG_INSUR_OVERDUE_DAYS,
        CUR_OTH_OVERDUE_DAYS,
        MAX_OTH_OVERDUE_DAYS,
        AVG_OTH_OVERDUE_DAYS,
        LEASING_PAYMENTS_COUNT,
        LEASING_PAYMENTS_COUNT_12, --[by ovilkova due to cross-checker 24/07/2017]    
        LEASING_PAYMENTS_SUM,
        CUR_LEAS_OVERDUE_AMT,
        CUR_ADV_OVERDUE_AMT,
        CUR_RED_OVERDUE_AMT,
        CUR_OTH_COM_OVERDUE_AMT,
        CUR_FIX_COM_OVERDUE_AMT,
        CUR_SUB_OVERDUE_AMT,
        CUR_ADD_OVERDUE_AMT,
        CUR_INS_OVERDUE_AMT,
        CUR_REG_OVERDUE_AMT,
        CUR_FOR_OVERDUE_AMT,
        CUR_PEN_OVERDUE_AMT,
        CUR_OVR_OVERDUE_AMT,
        CUR_INSUR_OVERDUE_AMT,
        CUR_OTH_OVERDUE_AMT,
        OVERDUE_LEASING_PAYMENTS_COUNT,
        LEAS_COUNT_12,  --[by ovilkova due to cross-checker 24/07/2017]        
        CUR_LEAS_OVERDUE_DT,
        MAX_LEAS_PAY_DT, 
        TOTAL_LEAS_OVERDUE_DAYS,   
        CIS_OVERDUE_AMT,
        CIS_OVERDUE_AMT_TAX,
        CIS_TERM_AMT_RISK,
        CIS_TERM_AMT,
        CIS_TERM_AMT_TAX_RISK,
        CIS_TERM_AMT_TAX,
        NIL,
        FINANCE_AMT,
        GR_FIN_START_AMT,
        CL_FIN_START_AMT,  
        -- ���������� ����� �������������� �� ������ �������� �� ������� ����, ���., �������
        SUM (NIL) OVER (PARTITION BY nvl (account_group_key, contract_key)) as GR_FIN_CUR_AMT,
                                   
        -- ���������� ����� �������������� �� ������� �� ������� ����, ���., �������
        SUM (NIL) OVER (PARTITION BY crm_client_key) as CL_FIN_CUR_AMT,
        PTS_FLG,
        PTS_DT,
        PTS_COMM,
        INSERT_DT,
        SUBPRODUCT_NAM,
        LEASE_TERM_CNT,
        end_dt, --[by ovilkova due to cross-checker 1/08/2017]
        ADVANCE_RUB, --[by ovilkova due to cross-checker 1/08/2017]
        SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
        BALANCE, --[by ovilkova due to cross-checker 1/08/2017]
        cr_ch_flg --[by ovilkova due to cross-checker 1/08/2017]
        
from cgp;
   dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY_N',
           p_step => 'INSERT into DM.DM_CGP_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');    
commit;

end;
/

