BEGIN
	DECLARE x  INT;
  DECLARE str  VARCHAR(255);
 
  SET x = 0;
 
  WHILE x  <= 11 DO
  insert into bot_img_label_r1000 SELECT * from bot_img_label_until_t2 t where t.type = x limit 1000;
  SET  x = x + 1; 
  END WHILE;

END