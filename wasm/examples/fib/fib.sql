CREATE OR REPLACE FUNCTION sql_fib (n integer) RETURNS decimal AS $$ 
DECLARE
    counter bigint := 1; 
    i decimal := 0;
    j decimal := 1;
BEGIN
    IF (n <= 1) THEN
        RETURN n;
    END IF; 

    WHILE counter <= n LOOP
        counter := counter + 1; 
        SELECT j, i + j INTO i, j;
    END LOOP; 

    RETURN i;
END;
$$ LANGUAGE plpgsql;

