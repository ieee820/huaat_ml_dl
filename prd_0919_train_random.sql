BEGIN
	DECLARE x  INT;
  DECLARE str  VARCHAR(255);
 
  SET x = 0;
  truncate table bot_img_0919_trainset;
 
  WHILE x  <= 11 DO
  insert into bot_img_0919_trainset SELECT * FROM bot_img_filenames_until_t4 t where t.type = x ORDER BY RAND() LIMIT 0,9600;
  SET  x = x + 1; 
  END WHILE;

END