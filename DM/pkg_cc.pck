create or replace package dm.PKG_CC is
  /******************************************************************************
     NAME:       DWH.PKG_CC
     PURPOSE:    5078: Интеграция в АС CrossChecker информации о кредитной истории контрагентов ВТБ Лизинг

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        20.06.2013      zanozinvi       1. Created this package body.
  ******************************************************************************/
  --  type TypePLS_INTEGERbyVarchar is Table Of PLS_INTEGER INDEX BY VARCHAR2(100);
  GC_PKG CONSTANT VARCHAR2(100) := 'PKG_CC'; -- package name
  --TYPE outrecset IS TABLE OF ins.VEN_T_ID_TYPE%ROWTYPE; --ins.t_id_type%rowtype; --stg.agnpasstype%rowtype;
  type t_parallel_test_row is record(
    RN            NUMBER,
    AGNTYPE       NUMBER,
    PASSPORT_TYPE NUMBER,
    AGNNAME       VARCHAR2(160));
function getColList(pTable varchar2, pMask varchar2 default ',',pExclude Varchar2 default '-1' ,p_start number default 0,p_end number default -1) return varchar2 ;

 FUNCTION xml2tab(p_xml IN XMlType, p_table_name IN VARCHAR2) Return NUMBER;






  PROCEDURE HrrXMLGen(x_XML        IN OUT XMLType,
                      p_sql        VARCHAR2,
                      p_tag        VARCHAR2,
                      p_tag_parent VARCHAR2 DEFAULT 'ROOT');

  PROCEDURE UnionXML(x_XML IN OUT XMLType, p_XML IN XMLType);

   FUNCTION XmlGen(p_sql      IN VARCHAR2,
                  p_row_tag  Varchar2,
                  p_root_tag Varchar2 default null) RETURN XMLTYPE;
   Procedure CDCPayment(p_to_dttm date default sysdate) ;

   Function GenCCPaymentItem(p_snapshot_dt date default trunc(sysdate)) return varchar2 ;
   Function GenCCPayment(p_snapshot_dt date default trunc(sysdate)) return varchar2 ;
   Function GenCCFile(p_snapshot_dt date default trunc(sysdate)) return varchar2;
   FUNCTION SEND2CCContract(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN VARCHAR2;
   FUNCTION SEND2CCPaymentItem(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN VARCHAR2;
   FUNCTION SEND2CCPayment(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN CLOB;
   FUNCTION SEND2CC(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN VARCHAR2;

end;
/

create or replace package body dm.PKG_CC is
  /******************************************************************************
     NAME:       DWH.PKG_CC
     PURPOSE: CCIntegration


     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        20.06.2017      zanozinvi       1. Created this package body.
     1.2        23.08.2018      zanozinvi       1. Add funnction GetColList
                                                2. Change GenCCFile for use GetColist for
                                                select fileds from source

  ******************************************************************************/
function getColList(pTable varchar2, pMask varchar2 default ',',pExclude Varchar2 default '-1' ,p_start number default 0,p_end number default -1) return varchar2 is
  vResult Varchar2(32767):='';
  vMask  Varchar2(32767);
  vUndef Varchar2(32767);
begin
  --vMask:='a.[COL_NAME]=b.[COL_NAME]';

  for i in (select utc.COLUMN_NAME,utc.DATA_TYPE
              from ALL_TAB_COLUMNS utc
             where utc.TABLE_NAME = substr(pTable,instr(pTable,'.')+1)
             and utc.OWNER=nvl(substr(pTable,1,instr(pTable,'.')-1),user)
           --  and utc.COLUMN_NAME not like (pExclude)
             and ','||pExclude||',' not like '%,'||utc.COLUMN_NAME||',%'
             and column_id>=p_start
             and column_id<=decode(p_end,-1,column_id,p_end)
             and COLUMN_NAME not like '%ORDER'
             ORDER BY COLUMN_ID) loop
    --vResult:=vResult||pMask||i.column_name;
    CASE i.data_type
      WHEN 'NUMBER'
        THEN
          vUndef:='-1';
      WHEN 'DATE'
        THEN
          vUndef:='TRUNC(sysdate)';
        ELSE
          vUnDef:='''UNDEF''';

    END CASE;
            vResult:=vResult||replace(replace(replace(pMask,'[COL_NAME]',i.column_name),'[col_name]',lower(i.column_name)),'[UNDEF]',vUndef);
  end loop;
  return substr(vResult,3);
end;

 procedure WriteToFile(p_file in varchar2,
                                                p_clob in clob) as
  v_file_name varchar2(64) := 'cat.bmp';

  v_blob blob;

  in_file bfile;
  out_file utl_file.file_type;
  v_buffer raw (32767);
  v_amount binary_integer := 32767;
  v_pos integer := 1;
  v_blob_len integer;
begin
  dbms_lob.createTemporary(v_blob, true, dbms_lob.SESSION);

  -- Читаем файл.
  in_file := bFileName('TMP', v_file_name);
  dbms_lob.fileOpen(in_file);
  dbms_lob.loadFromFile(v_blob, in_file, dbms_lob.getLength(in_file));
  dbms_lob.fileClose(in_file);
--  dbms_output.put_line('lob length = '||dbms_lob.getLength (v_blob)||';');

  -- Пишем в новый файл
  out_file := utl_file.fopen ('TMP', 'new_'||v_file_name, 'w', 32760);
  v_blob_len := dbms_lob.getLength (v_blob);
  while v_pos < v_blob_len loop
    dbms_lob.read (v_blob, v_amount, v_pos, v_buffer);
--    dbms_output.put_line('raw length = '||lengthb(utl_raw.cast_to_varchar2(v_buffer))||';');
    utl_file.put_raw (out_file, v_buffer, true);
    v_pos := v_pos + v_amount;
  end loop;
  utl_file.fClose(out_file);
exception when others then
  if utl_file.is_open(out_file) then
    utl_file.fClose(out_file);
  end if;
  raise;
end;


  procedure clob_to_file(p_dir  in varchar2,
                                                p_file in varchar2,
                                                p_clob in clob) as
    l_output utl_file.file_type;
    l_amt    number default 32760;
    l_offset number default 1;
    l_length number default nvl(dbms_lob.getlength(p_clob), 0);
  begin
    dbms_output.put_line(l_length);
    l_output := utl_file.fopen(p_dir, p_file, 'w', 32760);
    while (l_offset < l_length) loop
      utl_file.put(l_output, dbms_lob.substr(p_clob, l_amt, l_offset));
      utl_file.fflush(l_output);
      l_offset := l_offset + l_amt;
    end loop;
    utl_file.new_line(l_output);
    utl_file.fclose(l_output);
  end;

  --PROCEDURE GET_XMLT_DEL(p_source_system VARCHAR2, p_result_XML IN OUT  XMLTYPE);

  /*procedure TRACE(p_note varchar2) is
    pragma autonomous_transaction;
    v_sqlcode integer;
  begin
    insert into log$event
      (id, event, date_event)
    values
      (seq$event.nextval, p_note, sysdate);
    commit;
    null;
  end; */
  procedure DebugError(p_note varchar2, p_debug boolean) is
    pragma autonomous_transaction;
    v_sqlcode integer;
  begin

    v_SQLCODE := SQLCODE;
    if p_debug then
      --    DWH_H.O_SQLERRM := substr(SQLERRM(DWH_H.O_SQLCODE), 1, 2000);
      dbms_output.put_line(p_note || ' ' ||
                           SUBSTR(SQLERRM(v_SQLCODE) || CHR(13) ||
                                  DBMS_UTILITY.format_error_backtrace,
                                  1,
                                  4000));
    end if;
  end;


  FUNCTION XmlGen(c_sql      sys_refcursor,
                  p_row_tag  Varchar2,
                  p_root_tag Varchar2 default null) RETURN XMLTYPE IS
    l_context DBMS_XMLSTORE.CTXTYPE;
    l_rows    NUMBER;
    v_xml     xmltype;
    v_root    varchar2(100);
    v_sql     Varchar2(32767);
    qryCtx    DBMS_XMLSTORE.CTXTYPE;
    clXml     Clob;
    tmpXml    XmlType;
    vRootTag  Varchar2(100);
   -- csql      sys_refcursor;
  BEGIN
   -- csql:=for p_sql;
    if p_root_tag is null then
      vRootTag := vRootTag|| 's' ;
    else
      vRootTag := p_root_tag;
    end if;

    qryCtx   := DBMS_XMLGEN.newContext(c_sql);
    -- Set the row header
    DBMS_XMLGEN.setRowTag(qryCtx, p_row_TAG);
    DBMS_XMLGEN.setRowSetTag(qryCtx, vRootTag);
    DBMS_XMLGEN.setConvertSpecialChars(qryCtx,true);
   -- DBMS_XMLGEN.setNullHandling(qryCtx,DBMS_XMLGEN.EMPTY_TAG);
    -- Get the result
    --clXML := REPLACE(DBMS_XMLGEN.getXML(qryCtx),'ROWSET>',p_row_tag||'S'||'>');
    tmpXml := DBMS_XMLGEN.getXMLType(qryCtx);
    DBMS_XMLGEN.setConvertSpecialChars(qryCtx,true);
    DBMS_XMLGEN.closeContext(qryCtx);
    --dbms_output.put_line(DBMS_XMLGEN.getXMLType(qryCtx).extract('/ROWSET/'||p_row_tag).getclobval());
    return tmpXml; --DBMS_XMLGEN.getXMLType(qryCtx);
  END;

  FUNCTION XmlGen(p_sql      IN VARCHAR2,
                  p_row_tag  Varchar2,
                  p_root_tag Varchar2 default null) RETURN XMLTYPE IS
    l_context DBMS_XMLSTORE.CTXTYPE;
    l_rows    NUMBER;
    v_xml     xmltype;
    v_root    varchar2(100);
    v_sql     Varchar2(32767);
    qryCtx    DBMS_XMLSTORE.CTXTYPE;
    clXml     Clob;
    tmpXml    XmlType;
    vRootTag  Varchar2(100);
    vRootXml  XmlType;
   -- csql      sys_refcursor;
  BEGIN
   -- csql:=for p_sql;
    if p_root_tag is null then
      vRootTag := '<' || p_row_tag || 'S' || '></' || p_row_tag || 'S' || '>';
    else
      vRootTag := '<' || p_root_tag || '></' || p_root_tag || '>';
    end if;

    vRootXML := XmlType.CreateXml(vRootTag);
    qryCtx   := DBMS_XMLGEN.newContext(p_sql);
    -- Set the row header to be EMPLOYEE
    DBMS_XMLGEN.setRowTag(qryCtx, p_row_TAG);
    DBMS_XMLGEN.setConvertSpecialChars(qryCtx,true);
    -- Get the result
    --clXML := REPLACE(DBMS_XMLGEN.getXML(qryCtx),'ROWSET>',p_row_tag||'S'||'>');
    --extract(p_InXml, '/ROWSET/
    tmpXml := DBMS_XMLGEN.getXMLType(qryCtx);
    DBMS_XMLGEN.setConvertSpecialChars(qryCtx,true);
    IF tmpXml is not null then
      null;
      -- tmpXml:=tmpXml.extract('/ROWSET/*');

      tmpXml := XmlType.extract(tmpXml, '/ROWSET/*');
      tmpXml := vRootXml.appendChildXML('/*', tmpXml);
      --dbms_output.put_line(tmpXml.getRootElement());
    END IF;
     DBMS_XMLGEN.closeContext(qryCtx);
    --dbms_output.put_line(DBMS_XMLGEN.getXMLType(qryCtx).extract('/ROWSET/'||p_row_tag).getclobval());
    return tmpXml; --DBMS_XMLGEN.getXMLType(qryCtx);
  END;

  PROCEDURE xml2tab(p_xml IN XMlType, p_table_name IN VARCHAR2) IS
    l_context DBMS_XMLSTORE.CTXTYPE;
    l_rows    NUMBER;
    v_xml     xmltype;
    v_root    varchar2(100);
    c_proc constant varchar2(30) := 'xml2tab'; -- ??? ?????????
  BEGIN
    --delete from p_table_name;
    v_root := p_xml.getRootElement();
    --  dbms_output.put_line('root'||v_root);
    l_context := DBMS_XMLSTORE.NEWCONTEXT(p_table_name);
    IF v_root != 'ROWSET' or v_root is null THEN
      v_xml := XmlType.createXML('<ROWSET></ROWSET>');
      v_xml := v_Xml.appendChildXML('/ROWSET', p_xml);
    ELSE
      v_xml := p_xml;
    END IF;
    --  dbms_output.put_line(v_xml.getclobval());
    DBMS_XMLStore.setRowTag(l_context,
                            regexp_substr(p_table_name, '([^\$]+)$'));
    l_rows := DBMS_XMLSTORE.INSERTXML(l_context, v_xml);
    DBMS_XMLSTORE.CLOSECONTEXT(l_context);
    --  EXCEPTION
    --    WHEN OTHERS THEN
    --      DebugError('Incorrect Xml format for table ' || p_table_name || ' ' ||
    --                 c_proc,
    --                 true);

  END;

  FUNCTION xml2tab(p_xml IN XMlType, p_table_name IN VARCHAR2) Return NUMBER IS
    l_context DBMS_XMLSTORE.CTXTYPE;
    l_rows    NUMBER;
    v_xml     xmltype;
    v_root    varchar2(100);
    c_proc constant varchar2(30) := 'xml2tab'; -- ??? ?????????
  BEGIN
    --delete from p_table_name;
    v_root := p_xml.getRootElement();
    --  dbms_output.put_line('root'||v_root);
    l_context := DBMS_XMLSTORE.NEWCONTEXT(p_table_name);
    IF v_root != 'ROWSET' or v_root is null THEN
      v_xml := XmlType.createXML('<ROWSET></ROWSET>');
      v_xml := v_Xml.appendChildXML('/ROWSET', p_xml);
    ELSE
      v_xml := p_xml;
    END IF;
    --  dbms_output.put_line(v_xml.getclobval());
    DBMS_XMLStore.setRowTag(l_context,
                            regexp_substr(p_table_name, '([^\$]+)$'));
    l_rows := SYS.DBMS_XMLSTORE.INSERTXML(l_context, v_xml);
    SYS.DBMS_XMLSTORE.CLOSECONTEXT(l_context);
    Return 1;
  EXCEPTION
    WHEN OTHERS THEN
      DebugError('Incorrect Xml format for table ' || p_table_name || ' ' ||
                 c_proc,
                 true);
      SYS.DBMS_XMLSTORE.CLOSECONTEXT(l_context);
      return - 1;
  END;

  PROCEDURE xml2tab(p_xml IN CLOB, p_table_name IN VARCHAR2) IS
    l_context DBMS_XMLSTORE.CTXTYPE;
    l_rows    NUMBER;
  BEGIN
    --delete from p_table_name;
    l_context := DBMS_XMLSTORE.NEWCONTEXT(p_table_name);

    DBMS_XMLStore.setRowTag(l_context,
                            regexp_substr(p_table_name, '([^\$]+)$'));
    l_rows := DBMS_XMLSTORE.INSERTXML(l_context, p_xml);
    DBMS_XMLSTORE.CLOSECONTEXT(l_context);
  END;

  PROCEDURE xml2tab(p_xml_in XMLType,
                    p_xsl_in XMLType,
                    p_table  IN VARCHAR2) AS
    v_context DBMS_XMLStore.ctxType;
    v_rows    NUMBER;
  BEGIN
    --Open a new context, required for these procedures
    v_context := DBMS_XMLStore.newContext(p_table);
    -- This is the meat of the procedure.  See below for an explanation.
    v_rows := DBMS_XMLStore.insertXML(v_context,
                                      XMLType.transform(p_xml_in, p_xsl_in));
    -- Close the context
    DBMS_XMLStore.closeContext(v_context);
  END;
  /* under constraction*/
  FUNCTION GET_XMLT_CONTACT RETURN XMLTYPE is
    ctx dbms_xmlgen.ctxHandle;
    xml XMLTYPE;
  begin
    ctx := dbms_xmlgen.newContext('select * from INS.CONTACT WHERE rownum<=2');
    xml := dbms_xmlgen.getXMLType(ctx);
    DBMS_XMLGEN.closeContext(ctx);
    return xml;
  end;
/*
  FUNCTION GET_XML_CONTACT RETURN CLOB is
    ctx dbms_xmlgen.ctxHandle;
    xml CLOB;
  begin
    ctx := dbms_xmlgen.newContext('select * from INS.CONTACT WHERE rownum<=2');
    xml := dbms_xmlgen.getXML(ctx);
    DBMS_XMLGEN.closeContext(ctx);
    return xml;
  end;

  FUNCTION GET_XMLT_CONTRAGENT RETURN XMLTYPE is
    ctx dbms_xmlgen.ctxHandle;
    xml XMLTYPE;
  begin
    ctx := dbms_xmlgen.newContext('select * from V_CONTRAGENT WHERE rownum<=2');
    xml := dbms_xmlgen.getXMLType(ctx);
    DBMS_XMLGEN.closeContext(ctx);
    return xml;
  end;
*/
  -- ?????????? ???? ?????????? ??
  FUNCTION GET_XMLT_ID_CARD_TYPE(x_xml OUT XMLTYPE,
                                 p_IP  Varchar2 default null) RETURN XMLTYPE is
    ctx dbms_xmlgen.ctxHandle;
    c_proc      constant varchar2(30) := 'GET_XMLT_ID_CARD_TYPE'; -- ??? ?????????
    v_date_call constant timestamp := systimestamp;
    xErrorCodeXml XmlType := XMLTYPE('<MESSAGE><MESSAGETYPE>SUCCESS</MESSAGETYPE><MESSAGETEXT></MESSAGETEXT></MESSAGE>');
  begin
    ctx   := dbms_xmlgen.newContext('select *  from V$IDENT_CARD_TYPE');
    x_xml := dbms_xmlgen.getXMLType(ctx);
    --  raise_application_error (-20000,'SUCSESS');
    begin
      null;
      -- Call the procedure
     /* pkg_cdi_api.loging_cdicall(p_inxml        => null,
                                 p_outxml       => x_Xml,
                                 p_outxmlresult => xErrorCodeXml,
                                 p_date_call    => v_date_call,
                                 p_date_done    => systimestamp,
                                 p_ip           => null,
                                 p_obj_name     => c_proc);
    */
    end;
    return xErrorCodeXml;
  EXCEPTION
    WHEN OTHERS THEN
      -- IF SQLERRM != 'SUCSESS' THEN
      xErrorCodeXml := XMLTYPE('<MESSAGE><MESSAGETYPE>ERROR</MESSAGETYPE><MESSAGETEXT>' ||
                               SQLERRM || '</MESSAGETEXT></MESSAGE>');
      -- END IF;
      <<logging2>>
    /*  pkg_cdi_api.loging_cdicall(p_inxml        => null,
                                 p_outxml       => x_Xml,
                                 p_outxmlresult => xErrorCodeXml,
                                 p_date_call    => v_date_call,
                                 p_date_done    => systimestamp,
                                 p_ip           => null,
                                 p_obj_name     => c_proc);
  */
  null;
      return xErrorCodeXml;
  end;



  --?????????? ????????????? XML
  -- x_XML - ?????????????? XML
  -- p_sql - SQL ??? ????????? ?????
  -- p_tag - ????? ??? ? ??????? ????? ??????????? XML
  -- p_tag_parent - ???????????? ???, ? ??????? ????? ??????  p_tag
  PROCEDURE HrrXMLGen(x_XML        IN OUT XMLType,
                      p_sql        VARCHAR2,
                      p_tag        VARCHAR2,
                      p_tag_parent VARCHAR2 DEFAULT 'ROOT') AS
    l_RecXML XMLType;
    l_txt    varchar2(32500);
  BEGIN

    --  IF x_XML IS NULL AND  p_tag_parent <>  'ROOT' THEN
    --     RETURN;
    --  END IF;

    IF p_tag_parent = 'ROOT' THEN
      x_XML := XmlGen(p_sql, p_tag, 'ROWSET');
    ELSE
      l_RecXML := XmlGen(p_sql, p_tag);
      IF l_RecXML IS NOT NULL AND x_XML IS NOT NULL THEN
        x_XML := x_XML.appendChildXML('/*/' || p_tag_parent, l_RecXML);
      END IF;
    END IF;
    -- dbms_output.put_line(p_tag);
    --x_XML:= XmlType.extract(x_XML, '/ROWSET/*');
    --select x_XML||'' into l_txt  from dual;
    -- dbms_output.put_line(l_txt);
    exception

    WHEN OTHERS THEN

      dbms_output.put_line( 'p_sql='|| substr(p_sql,1,2000));
      dbms_output.put_line( 'p_tag='|| substr(p_tag,1,2000));
      dbms_output.put_line( 'p_tag_parent='|| p_tag_parent);
      dbms_output.put_line( 'l_RecXML='|| to_char(substr(l_RecXML.getclobval(),1,4000)));
      dbms_output.put_line( 'x_XML='|| to_char(substr(x_XML.getclobval(),1,4000)));
      RAISE;
  END HrrXMLGen;

  --?????????? ????????? XML ? ???? rowset
  PROCEDURE UnionXML(x_XML IN OUT XMLType, p_XML IN XMLType) AS
    -- l_RecXML XMLType;
    --l_txt varchar2(32500);
    l_xml XMLType;
  BEGIN
    IF x_XML IS NULL THEN
      x_XML := p_XML;
    ELSIF p_XML IS NOT NULL THEN
      -- l_RecXML:= XmlType.extract(p_XML, '/ROWSET/*');

      x_XML := x_XML.appendChildXML('/ROWSET',
                                    XmlType.extract(p_XML, '/ROWSET/*'));

      --select  XmlType.extract(p_XML, '/ROWSET/*')  into l_XML from dual;
      --x_XML := x_XML.appendChildXML('/ROWSET',l_xml);
    END IF;

    --select x_XML||'' into l_txt  from dual;
    --dbms_output.put_line(l_txt);

  END UnionXML;

 Procedure CDCPayment(p_to_dttm date default sysdate) as
    v_from_dttm date;
    v_to_dttm date;
    begin
    select nvl(max(snapshot_dt),date'0000-01-01') into v_from_dttm from  dm.cdc$pay_snapshot;
    if p_to_dttm>v_from_dttm then
      v_to_dttm:=p_to_dttm;
    end if;
    insert into dm.cdc$pay_snapshot(snapshot_dt) values(v_to_dttm);
    insert into dm.cdc$pay(contract_key,snapshot_dt)
      select distinct pay.*,v_to_dttm from (
      select  distinct contract_key from dwh.fact_real_payments  fp where
       greatest(valid_from_dttm,case valid_to_dttm when date'2400-01-01' then valid_from_dttm  else valid_to_dttm end) between v_from_dttm and v_to_dttm
      union all
      select  contract_key from dwh.fact_plan_payments  fp where
       greatest(valid_from_dttm,case valid_to_dttm when date'2400-01-01' then valid_from_dttm  else valid_to_dttm end) between v_from_dttm and v_to_dttm
      ) pay;
           dm.u_log(p_proc => 'DM.PKG_CC.CDCPayment',
           p_step => 'insert into dm.cdc$pay finished',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

      commit;


 end;


 Function GenCCPaymentItem(p_snapshot_dt date default trunc(sysdate)) return varchar2 AS
   result      XMLTYPE;
   c_result    CLOB;
   v_file_name varchar2(200);
   v_path      varchar2(200);
   cur  sys_refcursor;
   v_ws_result VARCHAR2(32767);
   v_length number;
 BEGIN
   execute immediate Q'~alter session set nls_numeric_characters='. '~';
   open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_PAYMENTITEM',pMask=>' ,"[COL_NAME]"',pExclude=>'PROCESS_KEY,FILE_ID')||
   Q'~  FROM DM.V$CC_PAYMENTITEM~'; --instead of ,"[COL_NAME]" as "[col_name]"

      result   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'PaymentItem',
                                  p_root_tag => 'package');

   c_result := '<?xml version="1.0" encoding="utf-8"?>' || chr(13) ||result.getClobVal();

   v_file_name := 'PaymentItem' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
              '.xml';
   v_path      := '\\vls-ora-bi\VTBL_DATA\XMLOUT\CC\';
   execute immediate Q'~alter session set nls_numeric_characters=', '~';

 --if cfg.getParam('crosys_send') like '%file%' then
 dbms_xslprocessor.clob2file(c_result,'CC_OUT',v_file_name,NLS_CHARSET_ID('AL32UTF8'));
 --end if;
 --if cfg.getParam('crosys_send') like '%soap%' then
 --  V_WS_RESULT:=DM.PKG_HTTP.WSCLOADCREDITCONTRACTS(IN_XML => RESULT);
 --end if;
  return v_path || v_file_name;
 END;

 Function GenCCContract(p_snapshot_dt date default trunc(sysdate)) return varchar2 AS
   result      XMLTYPE;
   c_result    CLOB;
   v_file_name varchar2(200);
   v_path      varchar2(200);
   cur  sys_refcursor;
 BEGIN
  execute immediate Q'~alter session set nls_numeric_characters='. '~';
   open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_CONTRACT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT')||
   '  FROM DM.V$CC_CONTRACT where snapshot_dt=:B1' using trunc(p_snapshot_dt);
   execute immediate Q'~alter session set nls_numeric_characters='. '~';

      result   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'contract',
                                  p_root_tag => 'package');

   c_result := '<?xml version="1.0" encoding="utf-8"?>' || chr(13) ||result.getClobVal();

   v_file_name := 'CCCONTRACT' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
              '.xml';
   v_path      := '\\vls-ora-bi\VTBL_DATA\XMLOUT\CC\';
   execute immediate Q'~alter session set nls_numeric_characters=', '~';

 --if cfg.getParam('crosys_send') like '%file%' then
 dbms_xslprocessor.clob2file(c_result,'CC_OUT',v_file_name,NLS_CHARSET_ID('AL32UTF8'));
 --end if;
 --if cfg.getParam('crosys_send') like '%soap%' then
 --  V_WS_RESULT:=DM.PKG_HTTP.WSCLOADCREDITCONTRACTS(IN_XML => RESULT);
 --end if;

  return v_path || v_file_name;
 END;


 Function GENCCPayment(p_snapshot_dt date default trunc(sysdate)) return varchar2 AS
   result      XMLTYPE;
   c_result    CLOB;
   v_file_name varchar2(200);
   v_path      varchar2(200);
   cur  sys_refcursor;
   v_length number;
 --  v_ws_result VARCHAR2(32767);
 BEGIN
   execute immediate Q'~alter session set nls_numeric_characters='. '~';

   open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_PAYMENT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT')||
   '  FROM DM.V$CC_PAYMENT where snapshot_dt=:B1' using trunc(p_snapshot_dt); --instead of "[COL_NAME]" as "[col_name]"
   execute immediate Q'~alter session set nls_numeric_characters='. '~';

      result   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'payment',
                                  p_root_tag => 'package');
                 --   v_length:=length(result.getClobVal())-15;
   c_result := '<?xml version="1.0" encoding="utf-8"?>' || chr(13) ||result.getClobVal();
              --'<package'||substr(result.getClobVal(),8,v_length)||'package>';
   -- Call the procedure
   v_file_name := 'Payment' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
              '.xml';
   v_path      := '\\vls-ora-bi\VTBL_DATA\XMLOUT\CC\';
   execute immediate Q'~alter session set nls_numeric_characters=', '~';
   /*clob_to_file(p_dir  => 'CC_OUT',
                p_file => v_file_name,
                p_clob => c_result);
 */
 dbms_xslprocessor.clob2file(c_result,'CC_OUT',v_file_name,NLS_CHARSET_ID('AL32UTF8'));
  return v_path || v_file_name;
 END;

Function GenCCFile(p_snapshot_dt date default trunc(sysdate))
  return varchar2 as
  result varchar2(32767);
begin
  result:= GENCCPaymentItem(nvl(p_snapshot_dt, trunc(sysdate)));
  result:= GENCCContract(nvl(p_snapshot_dt, trunc(sysdate)));
  return GENCCPayment(nvl(p_snapshot_dt, trunc(sysdate)));
end;

FUNCTION SEND2CCContract(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN VARCHAR2 AS
   --RESULT      XMLTYPE;
   C_RESULT    CLOB;
   V_FILE_NAME VARCHAR2(200);
   V_PATH      VARCHAR2(200);
   V_WS_RESULT VARCHAR2(32767);
   cur  sys_refcursor;
   l_time_point date;
 BEGIN
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCContract',
           p_step => 'INPUT PARAMS',
           p_info => 'p_snapshot_dt:'||p_snapshot_dt);
       l_time_point:=sysdate;
   v_file_name := 'CCCONTRACT' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
              '.xml';
   EXECUTE IMMEDIATE Q'~alter session set nls_numeric_characters='. '~';
   open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_CONTRACT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT')||
   '  FROM DM.V$CC_CONTRACT where snapshot_dt=:B1' using trunc(p_snapshot_dt);
   execute immediate Q'~alter session set nls_numeric_characters='. '~';


      INXML   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'contract',
                                  p_root_tag => 'package');
   IF INXML IS NULL THEN
        INXML   := XMLGEN(P_SQL      => 'SELECT * FROM DM.V$CC_ONE_CONTRACT where rownum<2',
                                  P_ROW_TAG  => 'contract',
                                  P_ROOT_TAG => 'package');

   END IF ;
if cfg.getParam('crosys_transfer_protocol') like '%file%' or cfg.getParam('crosys_transfer_protocol') is null then
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCContract',
           p_step => 'generate xml finished',
           p_info => (sysdate-l_time_point)*24*60*60||' sec');
       l_time_point:=sysdate;

       dbms_xslprocessor.clob2file(INXML.getClobVal(),'CC_OUT',v_file_name,NLS_CHARSET_ID('AL32UTF8'));
--       dbms_xslprocessor.clob2file(INXML.getClobVal(),'CC_OUT',v_file_name||'cp1251',NLS_CHARSET_ID('CL8MSWIN1251'));

       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCContract',
           p_step => 'xml file saved',
           p_info => (systimestamp-l_time_point)*24*60*60||' sec');
       l_time_point:=systimestamp;
end if;
if cfg.getParam('crosys_transfer_protocol') like '%soap%' /*or cfg.getParam('crosys_transfer_protocol') is null*/ then

   V_WS_RESULT:=DM.PKG_HTTP.WSCLOADCREDITCONTRACTS(IN_XML => INXML);

       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCContract',
           p_step => 'xml file sent; WSCLOADCREDITCONTRACTS finished',
           p_info => (sysdate-l_time_point)*24*60*60||' sec '||V_WS_RESULT);
else
  V_WS_RESULT:='only file';
end if;


    EXECUTE IMMEDIATE Q'~alter session set nls_numeric_characters=', '~';

  RETURN V_WS_RESULT;
 END;
FUNCTION SEND2CCPaymentItem(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN VARCHAR2 AS
   --RESULT      XMLTYPE;
   C_RESULT    CLOB;
   V_FILE_NAME VARCHAR2(200);
   V_PATH      VARCHAR2(200);
   V_WS_RESULT VARCHAR2(32767);
   cur  sys_refcursor;
 BEGIN
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPaymentItem',
           p_step => 'INPUT PARAMS',
           p_info => 'p_snapshot_dt:'||p_snapshot_dt);
   v_file_name := 'CCPI' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
              '.xml';
   EXECUTE IMMEDIATE Q'~alter session set nls_numeric_characters='. '~';


   open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_PAYMENTITEM',pMask=>' ,"[COL_NAME]"',pExclude=>'PROCESS_KEY,FILE_ID')||
   Q'~  FROM DM.V$CC_PAYMENTITEM~'; --instead of ,"[COL_NAME]" as "[col_name]"


      INXML   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'ITEM',
                                  p_root_tag => 'ITEMS');
   IF INXML IS NULL THEN
        INXML   := XMLTYPE('<ITEMS>EMPTY</ITEMS>');
        return 'PaimentItem dosn''t contains data';
   END IF ;
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPaymentItem',
           p_step => 'generate PaymentItem.xml finished',
           p_info => 'p_snapshot_dt:'||p_snapshot_dt);

       dbms_xslprocessor.clob2file(INXML.getClobVal(),'CC_OUT',v_file_name,NLS_CHARSET_ID('AL32UTF8'));

       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CC2PaymentItem',
           p_step => v_file_name||' saved',
           p_info => 'p_snapshot_dt:'||p_snapshot_dt);

 --  C_RESULT := '<?xml version="1.0" Encoding="utf-8"?>' || CHR(13) ||RESULT.GETCLOBVAL();
              -- REPLACE(RESULT.GETCLOBVAL(),'quot;','"');

if cfg.getParam('crosys_transfer_protocol') like '%soap%' /*or cfg.getParam('crosys_transfer_protocol') is null*/ then
   V_WS_RESULT:=DM.PKG_HTTP.WSSavePayment(IN_XML => INXML,p_fileType =>'PaymentItems',p_fileName =>v_file_name);

       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPaymentItem',
           p_step => v_file_name||' sent;WSSavePayment',
           p_info => V_WS_RESULT);
else
  V_WS_RESULT:='WS PamentItems dosn''t call';
end if;



    EXECUTE IMMEDIATE Q'~alter session set nls_numeric_characters=', '~';

  RETURN V_WS_RESULT;
 END;
FUNCTION SEND2CCPayment(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN CLOB AS
   --RESULT      XMLTYPE;
   C_RESULT    CLOB;
   V_FILE_NAMEp VARCHAR2(200);
   V_FILE_NAME VARCHAR2(200);
   V_PATH      VARCHAR2(200);
   V_WS_RESULT varchar2(4000);
   V_WS_ALL_RESULT CLOB;
   n_Result number:=1;
   cur  sys_refcursor;
   l_time_point date;
   cursor c is select contract_key, payment_item_key, payment_num, plan_pay_dt_orig, pay_dt_orig, overdue_days, plan_amt, pre_pay, fact_pay_amt, after_pay,off_schedule,rownum rn from DM.V$CC_PAYMENT a;
   type cl is table of c%rowtype ;
   cPayment tPayments;
   vButchSize number:=cfg.getParam('payment_batch_size');-- 170000;--0;
   vPaymentCount number;
 BEGIN

       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPayment',
           p_step => 'INPUT PARAMS',
           p_info => 'p_snapshot_dt:'||p_snapshot_dt);
   v_file_namep := 'Payment[i]_' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
              '.xml';
     if cfg.getParam('payment_scope')='delta' then
        CDCPayment;
     end if;

   EXECUTE IMMEDIATE Q'~alter session set nls_numeric_characters='. '~';

       l_time_point:=sysdate;
  -- select a.*,rownum rn bulk collect into cPayment from DM.V$CC_PAYMENT a;
   /*open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_PAYMENT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT')||
   ' FROM DM.V$CC_PAYMENT where snapshot_dt=:B1 and rownum<1000' using trunc(p_snapshot_dt); --instead of "[COL_NAME]" as "[col_name]"
   */

   if cfg.getParam('cache_payment') ='Y' then

   --open cur for 'select dm.tPayment(contract_key, payment_item_key, payment_num, plan_pay_dt_orig, pay_dt_orig, overdue_days, plan_amt, pre_pay, fact_pay_amt, after_pay,rownum) bulk collect into cPayment FROM DM.V$CC_PAYMENT where snapshot_dt=:B1 and rownum<1000' using trunc(p_snapshot_dt); --instead of "[COL_NAME]" as "[col_name]"

   --fetch cur bulk collect into cPayment;
  select dm.tPayment(contract_key, payment_item_key, payment_num, plan_pay_dt_orig, pay_dt_orig, overdue_days, plan_amt, pre_pay, fact_pay_amt, after_pay,off_schedule,rownum) bulk collect into cPayment FROM DM.V$CC_PAYMENT where snapshot_dt=trunc(p_snapshot_dt)
 ;-- and rownum<=1; --2600000;
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPayment',
           p_step => 'cPayment collection load '||cPayment.count||' rows',
           p_info => (sysdate-l_time_point)*24*60*60||' sec');
       l_time_point:=sysdate;
       vPaymentCount:=cPayment.count;
   else
     select nvl(max(rown),0) into vPaymentCount from v$cc_payment where snapshot_dt=trunc(p_snapshot_dt);
   end if;
   if vPaymentCount=0 then
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPayment',
           p_step => 'datamart hasn''t rows for snapshot_dt '||V_WS_ALL_RESULT,
           p_info => (sysdate-l_time_point)*24*60*60||' sec');
       l_time_point:=sysdate;
        V_WS_ALL_RESULT:='No rows!';

        RETURN V_WS_ALL_RESULT;

   end if;
   for i in 1.. ceil(vPaymentCount/vButchSize)   loop
   if cfg.getParam('cache_payment') ='Y' then
      open cur for select contract_key, payment_item_key, payment_num, plan_pay_dt_orig, pay_dt_orig, overdue_days, plan_amt, pre_pay, fact_pay_amt, after_pay from table(cPayment) where rown between (i-1)*vButchSize+1 and vButchSize*i ;
   elsif cfg.getParam('payment_scope')='full' then
      open cur for 'select '||getColList(pTable=>'DM.V$CC_PAYMENT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT,ROWN')||
   ' FROM DM.V$CC_PAYMENT p where snapshot_dt=:B1 and rown between :RSTART and :REND ' using trunc(p_snapshot_dt),(i-1)*vButchSize+1,vButchSize*i; --instead of "[COL_NAME]" as "[col_name]"
   else
      open cur for 'select '||getColList(pTable=>'DM.V$CC_PAYMENT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT,ROWN')||
   ' FROM DM.V$CC_PAYMENT p where p.contract_key in (select contract_key from dm.cdc$pay c,dm.cdc$pay_snapshot s where c.snapshot_dt=s.snapshot_dt and s.send_dt=date''0000-01-01'' ) and snapshot_dt=:B1 and rown between :RSTART and :REND ' using trunc(p_snapshot_dt),(i-1)*vButchSize+1,vButchSize*i; --instead of "[COL_NAME]" as "[col_name]"

   end if;
      INXML   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'PAYMENT',
                                  p_root_tag => 'PAYMENTS');
   IF INXML IS NULL THEN
        V_WS_ALL_RESULT:=V_WS_ALL_RESULT||'Nothing to Do!';
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPayment',
           p_step => 'Didn''t generate xml '||V_WS_ALL_RESULT,
           p_info => (sysdate-l_time_point)*24*60*60||' sec');
       l_time_point:=sysdate;

        RETURN V_WS_ALL_RESULT;
   END IF ;
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPayment',
           p_step => 'Butch:'||i||' generate xml finished',
           p_info => (sysdate-l_time_point)*24*60*60||' sec');
       l_time_point:=sysdate;

if cfg.getParam('crosys_transfer_protocol') like '%file%' /*or cfg.getParam('crosys_transfer_protocol') is null*/ then
       v_file_name:=replace(v_file_namep,'[i]',i);
       dbms_xslprocessor.clob2file(INXML.getClobVal(),'CC_OUT',v_file_name,NLS_CHARSET_ID('AL32UTF8'));
       --dbms_xslprocessor.clob2file(INXML.getClobVal(),'CC_OUT',v_file_name,NLS_CHARSET_ID('CL8MSWIN1251'));
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPayment',
           p_step => i||' xml file saved',
           p_info => (sysdate-l_time_point)*24*60*60||' sec');
       l_time_point:=sysdate;
--else
end if;


    if cfg.getParam('crosys_transfer_protocol') like '%soap%' /*or cfg.getParam('crosys_transfer_protocol') is null*/ then
       V_WS_RESULT:=DM.PKG_HTTP.WSSavePayment(IN_XML => INXML,p_fileType =>'PaymentData',p_fileName =>v_file_name,p_encode=>'Y');
       if V_WS_RESULT not like '%result="AllOk"%' then n_Result:=n_Result*0; end if;
       V_WS_ALL_RESULT:=V_WS_ALL_RESULT||chr(13)||V_WS_RESULT;
           dm.u_log(p_proc => 'DM.PKG_CC.SEND2CCPayment',
               p_step => v_file_name||' xml file sent n_result:'||n_result,
               p_info => (sysdate-l_time_point)*24*60*60||' sec'||' with result:'||V_WS_RESULT);
           l_time_point:=sysdate;
    else
      V_WS_RESULT:='WS doesn''t call';
    end if;

    end loop;

   if n_result=1 then
     --execute immediate 'truncate table dm.cdc$pay';
     update  dm.cdc$pay_snapshot set send_dt=sysdate where send_dt=date'0000-01-01';
     commit;
   end if;

    EXECUTE IMMEDIATE Q'~alter session set nls_numeric_characters=', '~';

  RETURN V_WS_ALL_RESULT;
 END;

FUNCTION SEND2CC(INXML OUT XMLTYPE,p_snapshot_dt date default trunc(sysdate)) RETURN VARCHAR2 AS
   --RESULT      XMLTYPE;
   V_WS_RESULT VARCHAR2(32767);
 BEGIN
       dm.u_log(p_proc => 'DM.PKG_CC.SEND2CC',
           p_step => 'INPUT PARAMS',
           p_info => 'p_snapshot_dt:'||p_snapshot_dt);
  if ','||cfg.getParam('crosys_transfer_entity')||',' like '%,contract,%' then
    V_WS_RESULT := chr(13)||'Contract:'||dm.pkg_cc.send2cccontract(inxml => inxml,
                                       p_snapshot_dt => p_snapshot_dt);
  end if;
  if ','||cfg.getParam('crosys_transfer_entity')||',' like '%,paymentitem,%' then

    V_WS_RESULT := V_WS_RESULT||chr(13)||'PaymentItems:'||dm.pkg_cc.send2ccPaymentItem(inxml => inxml,
                                       p_snapshot_dt => p_snapshot_dt);
  end if;
  if ','||cfg.getParam('crosys_transfer_entity')||',' like '%,payment,%' then
      V_WS_RESULT := V_WS_RESULT||chr(13)||'Payment:'||dm.pkg_cc.send2ccPayment(inxml => inxml,
                                       p_snapshot_dt => p_snapshot_dt);
  end if;
  RETURN V_WS_RESULT;
 END;


end PKG_CC ;
/

