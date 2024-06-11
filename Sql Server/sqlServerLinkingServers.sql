--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------ORACLE-----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.name = 'ExcelDB')
    EXEC sp_dropserver 'OracleDB', 'droplogins';
GO
-- Create the linked server
EXEC sp_addlinkedserver 
    @server = 'OracleDB', 
    @srvproduct = 'Oracle', 
    @provider = 'OraOLEDB.Oracle', 
    @datasrc = 'pd19'; 

-- Configure the linked server login
EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'OracleDB', 
    @useself = 'false', 
    @locallogin = NULL, 
    @rmtuser = 'SCOTT', 
    @rmtpassword = '12345';

-- Test the linked server
EXEC sp_testlinkedserver N'OracleDB';
SELECT * FROM OracleDB..SCOTT.EMPLOYEE;

--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------SQL SERVER-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

USE [master]  
GO 


IF EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.name = 'JORAM_PC')
    EXEC sp_dropserver 'JORAM_PC', 'droplogins';
GO
EXEC sp_addlinkedserver 
   @server=N'JORAM_PC', 
   @srvproduct=N'SQL Server'
GO
-- Set up security for the linked server
EXEC master.dbo.sp_addlinkedsrvlogin   
    @rmtsrvname = N'JORAM_PC',   
    @locallogin = NULL,   
    @useself = N'False',   
    @rmtuser = N'sa',   
    @rmtpassword = 'praktyka';
GO

-- Test the linked server connection
EXEC sp_testlinkedserver N'JORAM_PC';

SELECT name FROM [JORAM_PC].master.sys.databases;  
GO