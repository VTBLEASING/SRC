create or replace package dm.PKG_CC_TST is
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


 FUNCTION xml2tab(p_xml IN XMlType, p_table_name IN VARCHAR2) Return NUMBER;






  PROCEDURE HrrXMLGen(x_XML        IN OUT XMLType,
                      p_sql        VARCHAR2,
                      p_tag        VARCHAR2,
                      p_tag_parent VARCHAR2 DEFAULT 'ROOT');

  PROCEDURE UnionXML(x_XML IN OUT XMLType, p_XML IN XMLType);

   FUNCTION XmlGen(p_sql      IN VARCHAR2,
                  p_row_tag  Varchar2,
                  p_root_tag Varchar2 default null) RETURN XMLTYPE;
   Function GENCCFILE(p_snapshot_dt date default trunc(sysdate)) return varchar2;
   Function GENCCPAYMENT(p_snapshot_dt date default trunc(sysdate)) return varchar2 ;

end;
/

create or replace package body dm.PKG_CC_TST is
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
            vResult:=vResult||replace(replace(pMask,'[COL_NAME]',i.column_name),'[UNDEF]',vUndef);
   -- vResult:=
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
    qryCtx   := DBMS_XMLGEN.newContext(c_sql);
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




 Function GENCCFILE(p_snapshot_dt date default trunc(sysdate)) return varchar2 AS
   result      XMLTYPE;
   c_result    CLOB;
   v_file_name varchar2(200);
   v_path      varchar2(200);
   cur  sys_refcursor;

 BEGIN
   open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_CONTRACT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT')||
   '  FROM DM.V$CC_CONTRACT where snapshot_dt=:B1' using trunc(p_snapshot_dt);
   execute immediate Q'~alter session set nls_numeric_characters='. '~';

 /*result   := xmlgen(p_sql      => 'SELECT * FROM DM.V$CC_CONTRACT',
                                  p_row_tag  => 'contract',
                                  p_root_tag => 'package');*/
      result   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'contract',
                                  p_root_tag => 'package');
   c_result := '<?xml version="1.0" encoding="utf-8"?>' || chr(13) ||result.getClobVal();
              -- replace(result.getClobVal(),'&quot;','"');
   -- Call the procedure
   v_file_name := 'CCCONTRACT' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
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


 Function GENCCPAYMENT(p_snapshot_dt date default trunc(sysdate)) return varchar2 AS
   result      XMLTYPE;
   c_result    CLOB;
   v_file_name varchar2(200);
   v_path      varchar2(200);
   cur  sys_refcursor;

 BEGIN
   open cur for 'select '
   ||getColList(pTable=>'DM.V$CC_PAYMENT',pMask=>' ,"[COL_NAME]"',pExclude=>'SNAPSHOT_DT')||
   '  FROM DM.V$CC_PAYMENT where snapshot_dt=:B1' using trunc(p_snapshot_dt);
   execute immediate Q'~alter session set nls_numeric_characters='. '~';

 /*result   := xmlgen(p_sql      => 'SELECT * FROM DM.V$CC_CONTRACT',
                                  p_row_tag  => 'contract',
                                  p_root_tag => 'package');*/
      result   := xmlgen(c_sql      => cur,
                                  p_row_tag  => 'payment',
                                  p_root_tag => 'package');
   c_result := '<?xml version="1.0" encoding="utf-8"?>' || chr(13) ||result.getClobVal();
              -- replace(result.getClobVal(),'&quot;','"');
   -- Call the procedure
   v_file_name := 'CCCPAYMENT' || case when p_snapshot_dt=trunc(sysdate) then to_char(sysdate, 'yyyy_mm_dd_hh24_mi') else to_char(p_snapshot_dt, 'yyyy_mm_dd_hh24_mi') end ||
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


end PKG_CC_TST ;
/

