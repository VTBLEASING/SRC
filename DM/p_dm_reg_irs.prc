CREATE OR REPLACE PROCEDURE DM.P_DM_REG_IRS (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS

BEGIN

delete from DM.DM_REG_IRS where SNAPSHOT_DT = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);

insert into DM.DM_REG_IRS (
                          SNAPSHOT_CD,
                          SNAPSHOT_DT,
                          SNAPSHOT_MONTH,
                          SNAPSHOT_YEAR,
                          BRANCH_KEY,
                          AC�OUNT_KEY,
                          CONTRACT_KEY,
                          CLIENT_KEY,
                          BANK_KEY,
                          MEMBER_KEY,
                          VTB_MEMBER_FLG,
                          INSTRUMENT_KEY,
                          INSTRUMENT_KIND_CD,
                          SRC_CURRENCY_KEY,
                          CIS_CURRENCY_KEY,
                          TERM_CNT,
                          PERIOD1_TYPE_KEY,
                          PERIOD2_TYPE_KEY,
                          PERIOD3_TYPE_KEY,
                          SRC_AMT,
                          RUR_AMT,
                          CIS_AMT,
                          RATE_W_AMT,
                          TERM_W_AMT,
                          SRC_LIQ_AMT,
                          CIS_LIQ_AMT,
                          SRC_MR_AMT,
                          RUR_MR_AMT,
                          RATE_W_MR_AMT,
                          PAY_DT,
                          EX_RATE,
                          FLOAT_RATE_FLG,
                          RATE_AMT,
                          PURPOSE_DESC,
                          ART_CD,
                          PROCESS_KEY,
                          INSERT_DT) 
                 
          
                      --������ ������ ������� IRS
                          select
                          '�������� ���' SNAPSHOT_CD,
                          p_REPORT_DT SNAPSHOT_DT,
                          to_char(p_REPORT_DT, 'MM') as snapshot_month,
                          to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                          a.BRANCH_KEY,
                          null ACCOUNT_KEY,
                          CONTRACT_KEY,
                          CLIENT_KEY,
                          null BANK_KEY,
                          MEMBER_KEY,
                          VTB_MEMBER_FLG,
                          INSTRUMENT_KEY,
                          INSTRUMENT_KIND_CD,
                          SRC_CURRENCY_KEY,
                          CIS_CURRENCY_KEY,
                          TERM_CNT,
                          PERIOD1_TYPE_KEY,
                          PERIOD2_TYPE_KEY,
                          null PERIOD3_TYPE_KEY,
                          SRC_AMT,
                          RUR_AMT,
                          CIS_AMT,
                          RATE_W_AMT,
                          TERM_W_AMT,
                          SRC_LIQ_AMT,
                          CIS_LIQ_AMT,
                          SRC_MR_AMT,
                          RUR_MR_AMT,
                          RATE_W_MR_AMT,
                          PAY_DT,
                          EX_RATE,
                          FLOAT_RATE_FLG,
                          RATE_AMT,
                          PURPOSE_DESC,
                          ART_CD,
                          777 PROCESS_KEY,
                          sysdate INSERT_DT
                          from (
                          --������
                          select 
                          br. branch_key as branch_key, 
                          IRS_CONTRACTS.CONTRACT_KEY as CONTRACT_KEY,
                          clients.CLIENT_KEY as CLIENT_KEY,
                          CLIENTS .MEMBER_KEY MEMBER_KEY,
                           case
                           when gr.MEMBER_CD<>0 then 'Y'
                           else 'N'
                           end
                          as VTB_MEMBER_FLG,
                          
                          -- ���� �����������
                           (select INSTRUMENT_KEY
                            from dwh.INSTRUMENT_TYPES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And Upper(INSTRUMENT_KIND_CD) LIKE '%�����%'
                            and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                            )
                          as INSTRUMENT_KEY,
                          
                          --������
                           (select INSTRUMENT_KIND_CD
                            from dwh.INSTRUMENT_TYPES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And Upper(INSTRUMENT_KIND_CD) LIKE '%�����%'
                            and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                            ) 
                          AS INSTRUMENT_KIND_CD,
                          cur.CURRENCY_KEY as  SRC_CURRENCY_KEY,
                          --������ ���
                           case
                           when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') 
                           then cur.CURRENCY_KEY
                           else (select CURRENCY_KEY
                                 from DWH.CURRENCIES 
                                 where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                 and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                                 and CURRENCY_LETTER_CD='OTH')
                           end
                          AS CIS_CURRENCY_KEY,
                          
                          --����, ���� ������ ���� ������ 1. ���� ����=1, �� ������ �� ���� =2.
                          decode((fct.PAY_PERIOD_END_DT -p_REPORT_DT), 1, 2,(fct.PAY_PERIOD_END_DT -p_REPORT_DT)) AS TERM_CNT,
                          --��� ������� 1
                           (select p.PERIOD_KEY
                           FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                           where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                 and pt.PERIOD_TYPE_CD=1
                                 and (fct.PAY_PERIOD_END_DT -p_REPORT_DT)>p.DAYS_FROM_CNT
                                 and (fct.PAY_PERIOD_END_DT -p_REPORT_DT)<=p.DAYS_TO_CNT
                                 and p.BEGIN_DT<=p_REPORT_DT AND p.END_DT>p_REPORT_DT
                                 and pt.BEGIN_DT<=p_REPORT_DT AND pt.END_DT>p_REPORT_DT
                                 and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                            )
                          as PERIOD1_TYPE_KEY,
                          
                          --��� ������� 2
                           (select p.PERIOD_KEY
                           FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                           where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                 and pt.PERIOD_TYPE_CD=2
                                 and (fct.PAY_PERIOD_END_DT -p_REPORT_DT)>p.DAYS_FROM_CNT and 
                                 (fct.PAY_PERIOD_END_DT -p_REPORT_DT)<=p.DAYS_TO_CNT
                                 and p.BEGIN_DT<=p_REPORT_DT AND p.END_DT>p_REPORT_DT
                                 and pt.BEGIN_DT<=p_REPORT_DT AND pt.END_DT>p_REPORT_DT 
                                 and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                 )
                          as PERIOD2_TYPE_KEY,
                          
                          --����� � �������� ������
                          fct.AMORT_AMT SRC_AMT,
                          --����� � ������
                           case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
                           then fct.AMORT_AMT
                           else
                           fct.AMORT_AMT*rate.EXCHANGE_RATE
                           end 
                          as RUR_AMT,
                          
                          --����� � ������ ���
                          fct.AMORT_AMT as CIS_AMT,
                          
                          --����� ���������� �� ������
                          fct.AMORT_AMT*nvl(fct.FLOAT_RATE,0)/100 as RATE_W_AMT,
                          
                          --����� ���������� �� �����
                          fct.AMORT_AMT* decode((fct.PAY_PERIOD_END_DT -p_REPORT_DT), 1, 2,(fct.PAY_PERIOD_END_DT -p_REPORT_DT))
                          as TERM_W_AMT,
                          
                          --����� ����������� � �������� ������
                          -- [apolyakov 13.03.2017]: ��������� � ������ �� 4689
                          fct.AMORT_AMT + fct.PAYMENT_FLOAT_AMT as  SRC_LIQ_AMT,
                          
                          --����� ����������� � ������ ���
                          -- [apolyakov 13.03.2017]: ��������� � ������ �� 4689
                          case
                             when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB')
                                then fct.AMORT_AMT + fct.PAYMENT_FLOAT_AMT
                             else (fct.AMORT_AMT + fct.PAYMENT_FLOAT_AMT) * nvl(rate.EXCHANGE_RATE,1) 
                          end as  CIS_LIQ_AMT,
                          
                          --����� MR � �������� ������
                          null as SRC_MR_AMT,
                          
                          --����� MR � ������
                          null as RUR_MR_AMT,
                          
                          --����� MR ����������
                          null as RATE_W_MR_AMT,
                          fct.PAY_PERIOD_END_DT as PAY_DT,
                          nvl(rate.EXCHANGE_RATE,1) as EX_RATE,
                          1 as FLOAT_RATE_FLG,
                          nvl(fct.FLOAT_RATE,0)/100 as RATE_AMT,
                           (select  ART_CD
                            from dwh.INSTRUMENT_TYPES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And Upper(INSTRUMENT_KIND_CD) LIKE '%�����%'
                            and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                            ) as  ART_CD,
                            (select PURPOSE_DESC
                            from dwh.OPERATION_PURPOSES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And BEGIN_DT<=p_REPORT_DT
                            AND END_DT>p_REPORT_DT
                            ) as PURPOSE_DESC
                          from
                          
                          --����� ������ �� �������� IRS
                          (Select *
                           From DM.DM_IRS_PAYMENTS
                          Where snapshot_dt=p_REPORT_DT
                          and PAY_PERIOD_END_DT>=p_REPORT_DT
                          and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) fct
                          
                          --���������� ��������� IRS
                          left join (select CONTRACT_KEY,CLIENT_KEY,BRANCH_KEY,CURRENCY_KEY from dwh.IRS_CONTRACTS  
                                     where begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT
                                     and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     ) IRS_CONTRACTS
                          on fct.CONTRACT_KEY=IRS_CONTRACTS.CONTRACT_KEY
                          
                          --���������� ��������
                          left join (select branch_key,BRANCH_NAM
                                     from dwh.org_structure
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) br
                          on upper(IRS_CONTRACTS.BRANCH_KEY)=upper(br.BRANCH_KEY)
                          
                          --���������� �������� ��� ����������� ������ ���
                          left join (select CLIENT_KEY,MEMBER_KEY,CLIENT_CD from dwh.CLIENTS 
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) CLIENTS
                          on IRS_CONTRACTS.CLIENT_KEY=CLIENTS.CLIENT_KEY
                          
                          --���������� ����� ��� ����������� ����� ������
                          left join (select MEMBER_KEY, MEMBER_CD from DWH.IFRS_VTB_GROUP 
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT) gr
                          on CLIENTS.MEMBER_KEY=gr.MEMBER_KEY
                          
                          --���������� ����� ��� ����������� ������ ���
                          left join (select CURRENCY_KEY, CURRENCY_LETTER_CD from DWH.CURRENCIES 
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT) cur
                          on IRS_CONTRACTS.CURRENCY_KEY=cur.CURRENCY_KEY
                          
                          --���� �����
                          left join (select CURRENCY_KEY, EXCHANGE_RATE
                                     from DWH.EXCHANGE_RATES 
                                     where EX_RATE_DT=p_REPORT_DT
                                     and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     and BASE_CURRENCY_KEY=(select CURRENCY_KEY from DWH.CURRENCIES 
                                                            where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                                            and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                                                            and CURRENCY_LETTER_CD in ('RUB'))
                                                            )
                           rate
                          on cur.CURRENCY_KEY=rate.CURRENCY_KEY
                          ) a, dwh.reg_group b
                          where a.branch_key = b.branch_key
                          and b.reg_group_key = p_reg_group_key
                          and b.begin_dt <= p_REPORT_DT
                          and b.end_dt > p_REPORT_DT
                        
              UNION ALL

                        --������ ������ ������� IRS

                          select
                          '�������� ���' SNAPSHOT_CD,
                          p_REPORT_DT SNAPSHOT_DT,
                          to_char(p_REPORT_DT, 'MM') as snapshot_month,
                          to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                          a.BRANCH_KEY,
                          null ACCOUNT_KEY,
                          CONTRACT_KEY,
                          CLIENT_KEY,
                          null BANK_KEY,
                          MEMBER_KEY,
                          VTB_MEMBER_FLG,
                          INSTRUMENT_KEY,
                          INSTRUMENT_KIND_CD,
                          SRC_CURRENCY_KEY,
                          CIS_CURRENCY_KEY,
                          TERM_CNT,
                          PERIOD1_TYPE_KEY,
                          PERIOD2_TYPE_KEY,
                          null PERIOD3_TYPE_KEY,
                          SRC_AMT,
                          RUR_AMT,
                          CIS_AMT,
                          RATE_W_AMT,
                          TERM_W_AMT,
                          SRC_LIQ_AMT,
                          CIS_LIQ_AMT,
                          SRC_MR_AMT,
                          RUR_MR_AMT,
                          RATE_W_MR_AMT,
                          PAY_DT,
                          EX_RATE,
                          FLOAT_RATE_FLG,
                          RATE_AMT,
                          PURPOSE_DESC,
                          ART_CD,
                          777 PROCESS_KEY,
                          sysdate INSERT_DT
                          from (
                          --�������
                          select 
                          br. branch_key as branch_key, 
                          IRS_CONTRACTS.CONTRACT_KEY as CONTRACT_KEY,
                          CLIENTS .CLIENT_KEY as CLIENT_KEY,
                          CLIENTS .MEMBER_KEY MEMBER_KEY,
                           case
                           when gr.MEMBER_CD is not null and gr.MEMBER_CD<>0 then 'Y'
                           else 'N'
                           end
                          as VTB_MEMBER_FLG,
                          
                          -- ���� �����������
                           (select INSTRUMENT_KEY
                            from dwh.INSTRUMENT_TYPES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And Upper(INSTRUMENT_KIND_CD) LIKE '%������%'
                            and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                                                        )
                          as INSTRUMENT_KEY,
                          
                          --������
                           (select INSTRUMENT_KIND_CD
                            from dwh.INSTRUMENT_TYPES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And Upper(INSTRUMENT_KIND_CD) LIKE '%������%'
                            and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                            ) 
                          AS INSTRUMENT_KIND_CD,
                          cur.CURRENCY_KEY as  SRC_CURRENCY_KEY,
                          --������ ���
                           case
                           when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') 
                           then cur.CURRENCY_KEY
                           else (select CURRENCY_KEY
                                 from DWH.CURRENCIES 
                                 where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                 and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                                 and CURRENCY_LETTER_CD='OTH')
                           end
                          AS CIS_CURRENCY_KEY,
                          
                          --����, ���� ������ ���� ������ 1. ���� ����=1, �� ������ �� ���� =2.
                          decode((fct.PAY_PERIOD_END_DT -p_REPORT_DT), 1, 2,(fct.PAY_PERIOD_END_DT -p_REPORT_DT))  AS TERM_CNT,
                          --��� ������� 1
                           (select p.PERIOD_KEY
                           FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                           where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                 and pt.PERIOD_TYPE_CD=1
                                 and (fct.PAY_PERIOD_END_DT -p_REPORT_DT)>p.DAYS_FROM_CNT and 
                                 (fct.PAY_PERIOD_END_DT -p_REPORT_DT)<=p.DAYS_TO_CNT
                                 and p.BEGIN_DT<=p_REPORT_DT AND p.END_DT>p_REPORT_DT
                                 and pt.BEGIN_DT<=p_REPORT_DT AND pt.END_DT>p_REPORT_DT
                                 and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                            )
                          as PERIOD1_TYPE_KEY,
                          
                          --��� ������� 2
                           (select p.PERIOD_KEY
                           FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                           where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                 and pt.PERIOD_TYPE_CD=2
                                 and (fct.PAY_PERIOD_END_DT -p_REPORT_DT)>p.DAYS_FROM_CNT and 
                                 (fct.PAY_PERIOD_END_DT -p_REPORT_DT)<=p.DAYS_TO_CNT
                                 and p.BEGIN_DT<=p_REPORT_DT AND p.END_DT>p_REPORT_DT
                                 and pt.BEGIN_DT<=p_REPORT_DT AND pt.END_DT>p_REPORT_DT
                                 and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                 )
                          as PERIOD2_TYPE_KEY,
                          
                          --����� � �������� ������
                          (-1)* fct.AMORT_AMT SRC_AMT,
                          --����� � ������
                          (-1)*  case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
                           then fct.AMORT_AMT
                           else
                           fct.AMORT_AMT*rate.EXCHANGE_RATE
                           end 
                          as RUR_AMT,
                          
                          --����� � ������ ���
                          (-1)* fct.AMORT_AMT as CIS_AMT,
                          
                          --����� ���������� �� ������
                          (-1)* fct.AMORT_AMT*nvl(fct.FIX_RATE ,0)/100 as RATE_W_AMT,
                          
                          --����� ���������� �� �����
                          (-1)* fct.AMORT_AMT* decode((fct.PAY_PERIOD_END_DT -p_REPORT_DT), 1, 2,(fct.PAY_PERIOD_END_DT -p_REPORT_DT))
                          as TERM_W_AMT,
                          
                          --����� ����������� � �������� ������
                          -- [apolyakov 13.03.2017]: ��������� � ������ �� 4689
                          (-1)* (fct.AMORT_AMT + fct.PAYMENT_FIX_AMT) as  SRC_LIQ_AMT,
                          
                          --����� ����������� � ������ ���
                          -- [apolyakov 13.03.2017]: ��������� � ������ �� 4689
                          (-1)* (case
                             when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB')
                                then fct.AMORT_AMT + fct.PAYMENT_FIX_AMT
                             else (fct.AMORT_AMT + fct.PAYMENT_FIX_AMT) * nvl(rate.EXCHANGE_RATE,1) 
                          end) as  CIS_LIQ_AMT,
                          
                          --����� MR � �������� ������
                          null as SRC_MR_AMT,
                          
                          --����� MR � ������
                          null as RUR_MR_AMT,
                          
                          --����� MR ����������
                          null as RATE_W_MR_AMT,
                          fct.PAY_PERIOD_END_DT as PAY_DT,
                          nvl(rate.EXCHANGE_RATE,1) as EX_RATE,
                          0 as FLOAT_RATE_FLG,
                          nvl(fct.FIX_RATE ,0)/100  as RATE_AMT,
                            (select  ART_CD
                            from dwh.INSTRUMENT_TYPES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And Upper(INSTRUMENT_KIND_CD) LIKE '%������%'
                            and BEGIN_DT<=p_REPORT_DT AND END_DT>p_REPORT_DT
                            ) as  ART_CD,
                            (select PURPOSE_DESC
                            from dwh.OPERATION_PURPOSES
                            where Upper(INSTRUMENT_RU_NAM) LIKE '%�����������%��������%������'
                            And BEGIN_DT<=p_REPORT_DT
                            AND END_DT>p_REPORT_DT
                            ) as PURPOSE_DESC
                          from
                          
                          --����� ������ �� �������� IRS
                          (Select *
                           From DM.DM_IRS_PAYMENTS
                          Where snapshot_dt=p_REPORT_DT
                          and PAY_PERIOD_END_DT>=p_REPORT_DT
                          and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) fct
                          
                          --���������� ��������� IRS
                          left join (select CONTRACT_KEY,CLIENT_KEY,BRANCH_KEY,CURRENCY_KEY from dwh.IRS_CONTRACTS  
                                     where begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT
                                     and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     ) IRS_CONTRACTS
                          on fct.CONTRACT_KEY=IRS_CONTRACTS.CONTRACT_KEY
                          
                          --���������� ��������
                          left join (select branch_key,BRANCH_NAM
                                     from dwh.org_structure
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) br
                          on upper(IRS_CONTRACTS.BRANCH_KEY)=upper(br.BRANCH_KEY)
                          
                          --���������� �������� ��� ����������� ������ ���
                          left join (select CLIENT_KEY,MEMBER_KEY,CLIENT_CD from dwh.CLIENTS 
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) CLIENTS
                          on IRS_CONTRACTS.CLIENT_KEY=CLIENTS.CLIENT_KEY
                          
                          --���������� ����� ��� ����������� ����� ������
                          left join (select MEMBER_KEY, MEMBER_CD from DWH.IFRS_VTB_GROUP 
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT) gr
                          on CLIENTS.MEMBER_KEY=gr.MEMBER_KEY
                          
                          --���������� ����� ��� ����������� ������ ���
                          left join (select CURRENCY_KEY, CURRENCY_LETTER_CD from DWH.CURRENCIES 
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT) cur
                          on IRS_CONTRACTS.CURRENCY_KEY=cur.CURRENCY_KEY
                          
                          --���� �����
                          left join (select CURRENCY_KEY, EXCHANGE_RATE
                                     from DWH.EXCHANGE_RATES 
                                     where EX_RATE_DT=p_REPORT_DT
                                     and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     and BASE_CURRENCY_KEY=(select CURRENCY_KEY from DWH.CURRENCIES 
                                                            where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                                            and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT
                                                            and CURRENCY_LETTER_CD in ('RUB'))
                                                            )
                           rate
                          on cur.CURRENCY_KEY=rate.CURRENCY_KEY
                          ) a, dwh.reg_group b
                          where a.branch_key = b.branch_key
                          and b.reg_group_key = p_reg_group_key
                          and b.begin_dt <= p_REPORT_DT
                          and b.end_dt > p_REPORT_DT;             
                  commit;
end;
/

