create or replace package dm.PKG_HTTP_SRC is

  -- Author  : VLADIMIR.ZANOZIN
  -- Created : 27-дек-17 27-дек-17 
  -- Purpose : for outbound http integration
  -- FUNCTION BASE64_ENCODE_BLOB(a_input BLOB) return RAW ;
  FUNCTION base64encode(p_blob IN BLOB)   RETURN CLOB;
  function WSCloadCreditContracts(in_xml xmltype) return varchar2;
end PKG_HTTP_SRC;
/

create or replace package body dm.PKG_HTTP_SRC is
function to_base64(t in varchar2) return varchar2 is
begin
    return utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(t)));
end to_base64;

function from_base64(t in varchar2) return varchar2 is
begin
    return utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(t)));
end from_base64;

FUNCTION base64encode(p_blob IN BLOB)
  RETURN CLOB
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/base64encode.sql
-- Author       : Tim Hall
-- Description  : Encodes a BLOB into a Base64 CLOB.
-- Last Modified: 09/11/2011
-- -----------------------------------------------------------------------------------
IS
  l_clob CLOB;
  l_step PLS_INTEGER := 12000; -- make sure you set a multiple of 3 not higher than 24573
BEGIN
  FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(p_blob) - 1 )/l_step) LOOP
    dbms_output.put_line('step i:'||i);
    l_clob := l_clob || UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.substr(p_blob, l_step, i * l_step + 1)));
  END LOOP;
  RETURN l_clob;
END;

/*
 FUNCTION BASE64_ENCODE_BLOB(a_input BLOB) return RAW as
     l_chunk_size integer := 57;
     l_offset integer := 1;
     l_tmp blob;
     l_result raw(100);
     l_chunk raw(100);
     l_chunk_b64 varchar2(200);
     amount number :=1;
begin
           
          return l_result;
     dbms_lob.createtemporary(l_tmp, false);
     while l_offset < dbms_lob.getlength(a_input)
     loop
          DBMS_LOB.read(a_input,l_chunk_size,l_offset,l_chunk);
          utl_encode.base64_encode(l_chunk)
         -- l_chunk := utl_raw.cast_to_raw(DBMS_LOB.SUBSTR(a_input,l_chunk_size,l_offset));
        --  l_chunk_b64 := utl_raw.cast_to_varchar2(utl_encode.base64_encode(l_chunk));
         -- dbms_lob.writeappend(l_tmp, length(l_chunk_b64), l_chunk_b64);
          --dbms_lob.writeappend(l_tmp, length(l_chunk_b64), l_chunk_b64);
          --l_offset := l_offset + l_chunk_size;
     end loop;
     l_result := l_tmp;
     dbms_lob.freetemporary(l_tmp);

     return l_result; 
end;
*/
  -- Private type declarations

  
  -- Private constant declarations


  -- Private variable declarations


  -- Function and procedure implementations
  function Encode(p_clob clob) return clob is
    l_clob   clob;
    l_len    number;
    l_pos    number := 1;
    l_buffer varchar2(32767);
    l_amount number := 48;-- 32767;
  begin
        --l_len := dbms_lob.getlength(p_clob);
        l_len:=length(p_clob);
        dbms_lob.createtemporary(l_clob, true);    
             
        while l_pos <= l_len loop  
            dbms_output.put_line('lpos:'||l_pos);     
            dbms_lob.read (p_clob, l_amount, l_pos, l_buffer);
            l_buffer := utl_encode.text_encode(l_buffer, encoding => utl_encode.base64);
            l_pos := l_pos + l_amount;
            dbms_lob.writeappend(l_clob, length(l_buffer), l_buffer);   
        --dbms_output.put_line();         
        end loop;
        
        return l_clob;
  end;

  function DEncode(p_clob clob) return clob is
    l_clob   clob;
    l_len    number;
    l_pos    number := 1;
    l_buffer varchar2(32767);
    l_amount number := 15000;-- 32767;
  begin
        --l_len := dbms_lob.getlength(p_clob);
        l_len:=length(p_clob);
        dbms_lob.createtemporary(l_clob, true);    
             
        while l_pos <= l_len loop  
            dbms_output.put_line('lpos:'||l_pos);     
            dbms_lob.read (p_clob, l_amount, l_pos, l_buffer);
            l_buffer := utl_encode.text_decode(l_buffer, encoding => utl_encode.base64);
            l_pos := l_pos + l_amount;
            dbms_lob.writeappend(l_clob, length(l_buffer), l_buffer);   
        --dbms_output.put_line();         
        end loop;
        
        return l_clob;
  end;


  function WSCloadCreditContracts(in_xml xmltype) return varchar2 is
   

  --l_file_location varchar2(400) := 'http://my.sharepoint.com/org/department/MY_DOC_LIBRARY/';
  --l_filename varchar2(256) := 'my-new-file.docx';
  --l_file_content blob;
 
 -- lco_ntlm_auth_domain constant varchar2(30) := 'VL';
  --lco_ntlm_auth_username constant varchar2(30) := 'Vladimir.Zanozin';
  --l number:=cfg.SetParam('crosys_soap_passwd',to_base64('vtb20181*'));
  lco_ntlm_auth_login constant varchar2(30) := cfg.getParam('crosys_soap_login');--'VL\Vladimir.Zanozin';
  lco_ntlm_auth_password constant varchar2(30) := from_base64(cfg.getParam('crosys_soap_passwd'));
  l_ntlm_auth_string varchar2(4000);   
 
  lco_web_service_url constant varchar2(400) := cfg.getParam('crosys_soap_url');
  lco_web_service_soap_action constant varchar2(400) := '"http://crosys.org/loadCreditContracts"';
 
  l_http_request utl_http.req;
  l_request_body clob;
  l_request_body_length number;
 
  l_http_response utl_http.resp;
  l_response_header_name varchar2(256);
  l_response_header_value varchar2(1024);
  l_response_body varchar2(32767);
 
  l_offset number := 1;
  l_amount number := 2000;
  l_buffer varchar2(2000);
  l_encode_xml clob;
  l_dencode_xml clob;
  x blob;
begin
  l_ntlm_auth_string := alexandria.ntlm_http_pkg.begin_request(
                          p_url => lco_web_service_url,
                          p_username => lco_ntlm_auth_login, --lco_ntlm_auth_domain || '\' || lco_ntlm_auth_username,
                          p_password => lco_ntlm_auth_password
                        );
  

 -- return 'a';
 x:=in_xml.getBlobVal(NLS_CHARSET_ID('UTF8'));
 l_encode_xml:=base64encode(x);
 --l_encode_xml:=to_base64(in_xml.getClobVal());
 --dbms_output.put_line(x) ;
 --return 'a';
  l_request_body :=
'<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:cros="http://crosys.org/">
   <soap:Header/>
   <soap:Body>
      <cros:loadCreditContracts>
         <!--Optional:-->
         <cros:FileName>contract.xml</cros:FileName>
         <!--Optional:-->
         <cros:FileBody><contract>'||l_encode_xml||'</contract></cros:FileBody>
     </cros:loadCreditContracts>
   </soap:Body>
</soap:Envelope>';
 
  l_request_body_length := dbms_lob.getlength(l_request_body);
 
  l_http_request := utl_http.begin_request(
                      url => lco_web_service_url,
                      method => 'POST',
                      http_version => 'HTTP/1.1'
                    );
  utl_http.set_header(l_http_request, 'User-Agent', 'Mozilla/4.0');
  utl_http.set_header(l_http_request, 'Content-Type', 'text/xml;charset=UTF-8');
  utl_http.set_header(l_http_request, 'SOAPAction', lco_web_service_soap_action);
  utl_http.set_header(l_http_request, 'Content-Length', l_request_body_length);
  utl_http.set_header(l_http_request, 'Transfer-Encoding', 'chunked');
  utl_http.set_header(l_http_request, 'Authorization', l_ntlm_auth_string);
 
  while l_offset < l_request_body_length loop
    dbms_lob.read(l_request_body, l_amount, l_offset, l_buffer);
    utl_http.write_text(l_http_request, l_buffer);
    l_offset := l_offset + l_amount;
  end loop;
 
  l_http_response := utl_http.get_response(l_http_request);
  dbms_output.put_line('Response> Status Code: ' || l_http_response.status_code);
  dbms_output.put_line('Response> Reason Phrase: ' || l_http_response.reason_phrase);
  dbms_output.put_line('Response> HTTP Version: ' || l_http_response.http_version);
 
  for i in 1 .. utl_http.get_header_count(l_http_response) loop
    utl_http.get_header(l_http_response, i, l_response_header_name, l_response_header_value);
  dbms_output.put_line('Response> ' || l_response_header_name || ': ' || l_response_header_value);
  end loop;
 
  utl_http.read_text(l_http_response, l_response_body, 32767);
  --dbms_output.put_line(l_response_body);
 
  if l_http_request.private_hndl is not null then
    utl_http.end_request(l_http_request);
  end if;
 
  if l_http_response.private_hndl is not null then
    utl_http.end_response(l_http_response);
  end if;
  return  l_response_body;
exception
  when others then
    if l_http_request.private_hndl is not null then
      utl_http.end_request(l_http_request);
    end if;
 
    if l_http_response.private_hndl is not null then
      utl_http.end_response(l_http_response);
    end if;
    raise_application_error(-20666,SQLERRM||dbms_utility.format_error_backtrace);
    --raise;
end;



--begin
  -- Initialization
--  <Statement>;
end PKG_HTTP_SRC;
/

