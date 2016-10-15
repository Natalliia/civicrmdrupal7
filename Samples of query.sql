/* Change Box Data
RSI_API_CHG_BOX_DATA*/
--5 CHANGE_BOX_DATA
-- Sample scripts:

 insert into RS_API_CHG_BOX_DATA (ID_RECORD, REPORT_ID, REPORT_NAME, LOAD_DATE, API_EXCEPTION_ID, CORP, HOUSE, CUST, IS_API_PROCESSING_FLAG)
values (1, :id_stg_rep, :rep_name, sysdate, (select max(API_EXCEPTION_ID)+1 from SMCD_RS_API_CHG_BOX_DATA), :corp, :house, :cust, 'Y');

insert into SMART_API_UPLOAD_STATUS (ID_SMART_API, REPORT_ID, REPORT_NAME, EXCEPTION_COUNT, KOM_UPLOAD_DATE, KOM_UPLOAD_STATUS, SMART_PROCESSING_STATUS)
values(1, :id_stg_rep, :rep_name, 1,  sysdate, 'UPLOADED', 'IN QUEUE');

DECLARE

 tcorp        number(5);    
 thouse       varchar2(6); 
 tcust        varchar2(2);
 stg_rep      number; 
 rep_name     varchar(200);
 api_fl       varchar(1)    := 'Y';  
 api_opr      varchar(3)    := '444';
 cnt          number; 

BEGIN

  cnt       := 1;
  tcorp     := 7801; 
  
  stg_rep   := 901;   
  rep_name  := 'RS 1 - Post 30 Day iO Home Delivery with Analog Box';
 -- stg_rep   := 5;   
 -- rep_name  := 'Change Box Data';
  
  
    FOR h in 1..1 LOOP      -- HOUSE cycle
    
      thouse   := lpad(to_char( 125*100+h),6);   

      FOR i in 1..1 LOOP    --  CUST cycle
  
        tcust  := lpad(i, 2);
        
        insert into M_CUSTMASTER (PARTITION, CORP, HOUSE, CUST, FNAME, LNAME, RPHON, BPHONE, CTYPE, STAT, RAREACD, HOLD, CINFO, CLASS, CYCLE) 
        values (11, tcorp, thouse, tcust, 'FNAME', 'LASTNAME', '1134567', '1234567890', 1, 6, 631, 0, '', '', 'A' );
         
        insert into RS_API_CHG_BOX_DATA (ID_RECORD, REPORT_ID, REPORT_NAME, API_EXCEPTION_ID, CORP, HOUSE, CUST, LOAD_DATE, TRANS_DATE, 
        IS_API_PROCESSING_FLAG, OUTLET, BNUMB, RETRNRSN, LOC, BRGPPV, BRGEMG, 
        EVTCPBL, NVODCAPABLE, CONTACT_SOURCE_ID, CONTACT_REASON_1, CONTACT_COMMENT, FILENAME, EMAIL_ID, API_OPR, CUSTLEVELPIN)
        
        values (nvl((select max (ID_RECORD)+1 from RS_API_CHG_BOX_DATA), 1), stg_rep, rep_name, nvl((select max(API_EXCEPTION_ID)+cnt from SMCD_RS_API_CHG_BOX_DATA), cnt), 
        tcorp, thouse, tcust, sysdate, sysdate+2, 
        api_fl, 1, 'C5H1944956AN01', ' ', ' ', ' ', ' ',
        --tcorp, thouse, tcust, sysdate, sysdate+2, api_fl, 1, 'C5H1944956AN01', 'X', 'Z', 'N', 'N', 'N', 'N', 'INBD', 18, 
         ' ', ' ', ' ', ' ', 'Change Box Data', 'rs_api_001_upload_20140807162824_69201.csv', 'yali', api_opr, ' ');
                
        cnt := cnt+1;        
      
      END LOOP;
      
    END LOOP;
    
  insert into SMART_API_UPLOAD_STATUS (ID_SMART_API, EXCEPTION_COUNT, REPORT_ID, REPORT_NAME, KOM_UPLOAD_DATE, KOM_UPLOAD_STATUS, SMART_PROCESSING_STATUS)
  values (nvl ((select max(ID_SMART_API)+1 from SMART_API_UPLOAD_STATUS), 1), (select COUNT(*) from RS_API_CHG_BOX_DATA where REPORT_ID = stg_rep), stg_rep, 
  rep_name, sysdate, 'UPLOADED', 'IN QUEUE');
      
END;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- check data before upload (time interval configured on Application Options)

 select * from SMART_API_UPLOAD_STATUS where trunc(KOM_UPLOAD_DATE) = trunc(sysdate) order by 1 desc;
 select * from RS_API_CHG_BOX_DATA where trunc(LOAD_DATE) = trunc(sysdate);

-----------------------------------------------------------------------------------------------------------------------------------------------
-- check data after upload - will return results if NEW exceptions were created today, check by report and accounts

 select 
 r.id_staging_report, 
 R.DISPLAY_NAME report, 
 ES.DISPLAY_NAME status, 
 STG.API_EXCEPTION_ID, 
 STG.ID_EXCEPTION, 
 a.corp, 
 a.house, 
 a.CUST, 
 E.ADDED_DATE 
 from SMCD_RS_API_CHG_BOX_DATA STG
 join exceptions E on E.ID_EXCEPTION = STG.ID_EXCEPTION
 left join EXCEPTION_STATUSES ES on E.ID_EXCEPTION_STATUS = ES.ID_EXCEPTION_STATUS
 join REPORTS R on R.ID_REPORT = E.ID_REPORT
 join ACCOUNTS a on a.ID_ACCOUNT = E.ID_ACCOUNT
where TRUNC(E.ADDED_DATE) = TRUNC(sysdate)
  order by r.id_staging_report, a.corp, a.house, a.CUST;
  
-------------------------------------------------------------------------------------------------------------------

--Reports:

select id_report, id_staging_report, display_name from reports
where id_staging_table = (select id_staging_table from staging_tables where name like '%RS_API_CHG_BOX_DATA')
and enabled = 'Y'
order by id_report;