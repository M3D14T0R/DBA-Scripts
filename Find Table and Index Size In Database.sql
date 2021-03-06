SELECT
	  DB_NAME() AS 'DatabaseName'
	, s.name AS 'SchemaName'
	, t.Name AS 'TableName'
	, t.create_date AS 'CreateDate'
	, CASE
		WHEN I.index_id = 0 THEN 'HEAP'
		ELSE i.Name
		END AS 'IndexName'
	, i.index_id AS 'IndexId'
	, MAX(ps.row_count) AS 'RowCount'
	, SUM(ps.reserved_page_count) * 8.0 / (1024) as 'SpaceInMB'
	, CASE
		WHEN MAX(ps.row_count) = 0 THEN 0
		ELSE (8 * 1024* SUM(ps.reserved_page_count)) / NULLIF(MAX(ps.row_count), 0)
		END AS 'Bytes/Row'
	, p.Data_compression_desc
FROM	sys.dm_db_partition_stats AS ps
	INNER JOIN sys.indexes AS i ON ps.object_id = i.object_id and ps.index_id = i.index_id
	INNER JOIN sys.tables AS t ON i.object_id = t.object_id
	INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
	INNER JOIN sys.partitions as p ON p.index_id = i.index_id and p.object_id = t.object_id
WHERE	t.is_ms_shipped = 0
GROUP BY s.name, t.Name, i.Name, i.index_id, t.create_date, p.Data_compression_desc
ORDER BY SchemaName, TableName, i.index_id, SpaceInMB DESC
OPTION(RECOMPILE);
