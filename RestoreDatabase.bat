docker-compose exec sql-dev /opt/mssql-tools/bin/sqlcmd -U sa -P c0dingbl0cks! -H localhost -q "RESTORE DATABASE [ContosoRetailDW] FROM  DISK = N'/var/opt/mssql/data/ContosoRetailDW.bak' WITH  FILE = 1,  MOVE N'ContosoRetailDW2.0' TO N'/var/opt/mssql/data/ContosoRetailDW.mdf',  MOVE N'ContosoRetailDW2.0_log' TO N'/var/opt/mssql/data/ContosoRetailDW.ldf',  NOUNLOAD,  STATS = 5"