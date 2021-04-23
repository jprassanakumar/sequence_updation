CREATE OR REPLACE FUNCTION fix_sequence(tableName text, columnName text,sequenceName text)
RETURNS BOOLEAN AS $$
DECLARE
    nextValue int;
    expectedNextValue int;
BEGIN
    SELECT nextval(sequenceName) INTO nextValue;
    EXECUTE 'SELECT COALESCE(MAX(' || columnName || ') + 1, 1) FROM ' || tableName INTO expectedNextValue;
	RAISE NOTICE 'seq values %, next: % , seq: %', nextValue, expectedNextValue,sequenceName;
    IF nextValue < expectedNextValue THEN
        EXECUTE 'SELECT setval(''' || sequenceName || ''', ' || expectedNextValue || ', false)';
        RETURN true;
    ELSE
        RETURN false;
    END IF;
exception when others then 
	RAISE NOTICE 'seq values %, next: % , seq: %', nextValue, expectedNextValue,sequenceName;
	RETURN false;
END;
$$ LANGUAGE plpgsql VOLATILE;


#Exceute this after creating function
SELECT 
    table_name || '_' || column_name || '_seq' AS Sequence,fix_sequence(table_name, column_name, table_name || '_' || column_name || '_seq') AS ResetResult
FROM information_schema.columns
WHERE column_default LIKE 'nextval%';
