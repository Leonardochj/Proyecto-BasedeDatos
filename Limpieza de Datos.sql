## CURSOR MOVIES
DROP PROCEDURE IF EXISTS TablaMovie;

DELIMITER $$
CREATE PROCEDURE TablaMovie()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE Movindex INT;
DECLARE Movbudget BIGINT;
DECLARE Movhomepage VARCHAR(1000);
DECLARE MovidMovie INT;
DECLARE Movkeywords TEXT;
DECLARE Movoriginal_language VARCHAR(255);
DECLARE Movoriginal_title VARCHAR(255) ;
DECLARE Movoverview TEXT;
DECLARE Movpopularity DOUBLE;
DECLARE Movrelease_date VARCHAR(255);
DECLARE Movrevenue BIGINT;
DECLARE Movruntime DOUBLE;
DECLARE Movstatus VARCHAR(255);
DECLARE Movtagline VARCHAR(255);
DECLARE Movtitle VARCHAR(255);
DECLARE Movvote_average DOUBLE;
DECLARE Movvote_count INT;
DECLARE nameDirector VARCHAR(255);

DECLARE Director_nameDirector varchar(255);
DECLARE Director_nameStatus varchar(255);
DECLARE Director_nameOriginal_language varchar(255);

 -- Declarar el cursor
DECLARE CursorMovie CURSOR FOR
    SELECT `index`,budget,homepage,id,keywords,original_language,original_title,overview,popularity,release_date,revenue,runtime, `status`,
		tagline,title,vote_average,vote_count,director FROM movie_dataset;
        
 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

 -- Abrir el cursor
OPEN CursorMovie;
CursorMovie_loop: LOOP
    FETCH CursorMovie INTO Movindex,Movbudget,Movhomepage,MovidMovie,Movkeywords,Movoriginal_language,Movoriginal_title,Movoverview,
    Movpopularity,Movrelease_date,Movrevenue,Movruntime,Movstatus,Movtagline,Movtitle,Movvote_average,Movvote_count,nameDirector;
    
    -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorMovie_loop;
    END IF;
    IF nameDirector IS NULL THEN
    SET nameDirector = '';
    END IF;
    
    SELECT `name` INTO Director_nameDirector FROM directorCURSOR WHERE directorCURSOR.name = nameDirector;
    SELECT `name` INTO Director_nameStatus FROM statusCURSOR WHERE statusCURSOR.name = Movstatus;
    SELECT `name` INTO Director_nameOriginal_language FROM original_languageCURSOR WHERE original_languageCURSOR.name = Movoriginal_language;
    
    INSERT INTO MovieCURSOR (`index`,budget,homepage,id,keywords,original_language,original_title,overview,popularity,release_date,revenue,runtime, `status`,
		tagline,title,vote_average,vote_count,director)
    VALUES (Movindex,Movbudget,Movhomepage,MovidMovie,Movkeywords,Director_nameOriginal_language,Movoriginal_title,Movoverview,
    Movpopularity,Movrelease_date,Movrevenue,Movruntime,Director_nameStatus,Movtagline,Movtitle,Movvote_average,Movvote_count,Director_nameDirector);

END LOOP;
CLOSE CursorMovie;
END $$
DELIMITER ;

CALL TablaMovie ();

DROP TABLE IF EXISTS MovieCURSOR;

CREATE TABLE MovieCURSOR (
    `index` int,
    budget bigint,
    homepage varchar(1000),
    id int PRIMARY KEY,
    keywords TEXT,
    original_language varchar(255),
    original_title varchar(255),
    overview TEXT,
    popularity double,
    release_date varchar(255),
    revenue bigint,
    runtime double,
    `status` varchar(255),
    tagline varchar(255),
    title varchar(255),
    vote_average double,
    vote_count int,
    director varchar(255),
    FOREIGN KEY (original_language) REFERENCES original_languageCURSOR(name),
    FOREIGN KEY (status) REFERENCES statusCURSOR(name),
    FOREIGN KEY (director) REFERENCES directorCURSOR(name)
);

DROP TABLE IF EXISTS MovieCURSOR;
SELECT COUNT(*) FROM MovieCursor;
SELECT * FROM MovieCursor;
SELECT * FROM MovieCursor;



## CURSOR STATUS
USE Movies2023;

DROP PROCEDURE IF EXISTS TablaStatus;

DELIMITER $$
CREATE PROCEDURE TablaStatus()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE nameStatus VARCHAR(100);

 -- Declarar el cursor
DECLARE CursorStatus CURSOR FOR
    SELECT DISTINCT CONVERT(status USING UTF8MB4) AS names from movie_dataset;
    
 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

 -- Abrir el cursor
OPEN CursorStatus;
CursorStatus_loop: LOOP
    FETCH CursorStatus INTO nameStatus;
    
-- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorStatus_loop;
    END IF;
    IF nameStatus IS NULL THEN
        SET nameStatus = '';
    END IF;
    SET @_oStatement = CONCAT('INSERT INTO statusCURSOR (name) VALUES (\'',
	nameStatus,'\');');
    PREPARE sent1 FROM @_oStatement;
    EXECUTE sent1;
    DEALLOCATE PREPARE sent1;

END LOOP;
CLOSE CursorStatus;
END $$
DELIMITER ;

CALL TablaStatus();

DROP TABLE IF EXISTS statusCURSOR;

CREATE TABLE statusCURSOR (
	name varchar(255) PRIMARY KEY
);
SELECT * FROM statusCURSOR;


## CURSOR PRODUCTION COUNTRIES
USE Movies2023;

DROP PROCEDURE IF EXISTS TablaProduction_countries;

DELIMITER $$
CREATE PROCEDURE TablaProduction_countries ()

BEGIN

 DECLARE done INT DEFAULT FALSE ;
 DECLARE jsonData json ;
 DECLARE jsonId varchar(250) ;
 DECLARE jsonLabel varchar(250) ;
 DECLARE resultSTR LONGTEXT DEFAULT '';
 DECLARE i INT;
 
 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT JSON_EXTRACT(CONVERT(production_countries USING UTF8MB4), '$[*]') FROM movie_dataset ;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;
  
 -- Abrir el cursor
 OPEN myCursor  ;
 drop table if exists production_countriesTem;
    SET @sql_text = 'CREATE TABLE production_countriesTem ( iso_3166_1 varchar(2), nameCountry VARCHAR(100));';
    PREPARE stmt FROM @sql_text;	
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 cursorLoop: LOOP
  FETCH myCursor INTO jsonData;
  
  -- Controlador para buscar cada uno de los arrays
    SET i = 0;
    
  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;
  
  WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO
  SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].iso_3166_1')), '') ;
  SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
  SET i = i + 1;
  
  SET @sql_text = CONCAT('INSERT INTO production_countriesTem VALUES (', REPLACE(jsonId,'\'',''), ', ', jsonLabel, '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    
  END WHILE;
  
 END LOOP ;
 
 select distinct * from production_countriesTem;
    INSERT INTO production_countriesCURSOR
    SELECT DISTINCT iso_3166_1, nameCountry
    FROM production_countriesTem;
    drop table if exists production_countriesTem;
 CLOSE myCursor ;
 
END$$
DELIMITER ;

call TablaProduction_countries();

SELECT * FROM production_countriesCURSOR;

CREATE TABLE production_countriesCURSOR (
	iso_3166_1 varchar(2) PRIMARY KEY,
    name varchar(100)
);
DROP TABLE IF EXISTS production_countriesCURSOR;
SELECT COUNT(*) FROM production_countriesCURSOR;


## CURSOR DIRECTOR
USE Movies2023;

DROP PROCEDURE IF EXISTS TablaDirector;

DELIMITER $$
CREATE PROCEDURE TablaDirector()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE nameDirector VARCHAR(100);

 -- Declarar el cursor
DECLARE CursorDirector CURSOR FOR
    SELECT DISTINCT CONVERT(director USING UTF8MB4) AS names from movie_dataset;
    
 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

 -- Abrir el cursor
OPEN CursorDirector;
CursorDirector_loop: LOOP
    FETCH CursorDirector INTO nameDirector;
    
-- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorDirector_loop;
    END IF;
    IF nameDirector IS NULL THEN
        SET nameDirector = '';
    END IF;
    SET @_oStatement = CONCAT('INSERT INTO directorCURSOR (name) VALUES (\'',
	REPLACE(REPLACE(nameDirector, '\'', '\\\''), '\\u', '\\\\u')
    ,'\');');
    PREPARE sent1 FROM @_oStatement;
    EXECUTE sent1;
    DEALLOCATE PREPARE sent1;

END LOOP;
CLOSE CursorDirector;
END $$
DELIMITER ;

CALL TablaDirector();

DROP TABLE IF EXISTS directorCURSOR;

CREATE TABLE directorCURSOR (
	name varchar(255) PRIMARY KEY
);
SELECT * FROM directorCURSOR WHERE name LIKE '%Roland%';


## CURSOR ORIGINAL LANGUAGE
USE Movies2023;

DROP PROCEDURE IF EXISTS TablaOriginalLanguage;

DELIMITER $$
CREATE PROCEDURE TablaOriginalLanguage()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE nameOL VARCHAR(100);

 -- Declarar el cursor
DECLARE CursorOL CURSOR FOR
    SELECT DISTINCT original_language AS names from movie_dataset;
    
 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

 -- Abrir el cursor
OPEN CursorOL;
CursorOL_loop: LOOP
    FETCH CursorOL INTO nameOL;
    
-- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorOL_loop;
    END IF;
    IF nameOL IS NULL THEN
        SET nameOL = '';
    END IF;
    SET @_oStatement = CONCAT('INSERT INTO original_languageCURSOR (name) VALUES (\'',
	nameOL,'\');');
    PREPARE sent1 FROM @_oStatement;
    EXECUTE sent1;
    DEALLOCATE PREPARE sent1;

END LOOP;
CLOSE CursorOL;
END $$
DELIMITER ;

CALL TablaOriginalLanguage();

DROP TABLE IF EXISTS original_languageCURSOR;

CREATE TABLE original_languageCURSOR (
	name varchar(255) PRIMARY KEY
);
SELECT * FROM original_languageCURSOR;


## CURSOR PRODUCTION COMPANIES
USE Movies2023;

DROP PROCEDURE IF EXISTS TablaProduction_companies;

DELIMITER $$
CREATE PROCEDURE TablaProduction_companies ()

BEGIN

 DECLARE done INT DEFAULT FALSE ;
 DECLARE jsonData json ;
 DECLARE jsonId varchar(250) ;
 DECLARE jsonLabel varchar(250) ;
 DECLARE resultSTR LONGTEXT DEFAULT '';
 DECLARE i INT;
 
 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT JSON_EXTRACT(CONVERT(production_companies USING UTF8MB4), '$[*]') FROM movie_dataset ;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;
  
 -- Abrir el cursor
 OPEN myCursor  ;
 drop table if exists production_companietem;
    SET @sql_text = 'CREATE TABLE production_companieTem ( id int, nameCom VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 cursorLoop: LOOP
  FETCH myCursor INTO jsonData;
  
  -- Controlador para buscar cada uno de los arrays
    SET i = 0;
    
  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;
  
  WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO
  SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].id')), '') ;
  SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
  SET i = i + 1;
  
  SET @sql_text = CONCAT('INSERT INTO production_companieTem VALUES (', REPLACE(jsonId,'\'',''), ', ', jsonLabel, '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    
  END WHILE;
  
 END LOOP ;
 
 select distinct * from production_companieTem;
    INSERT INTO production_companiesCURSOR
    SELECT DISTINCT id, nameCom
    FROM production_companieTem;
    drop table if exists production_companieTem;
 CLOSE myCursor ;
 
END$$
DELIMITER ;

call TablaProduction_companies();

CREATE TABLE production_companiesCURSOR (
	id INT PRIMARY KEY,
    name varchar(100)
);

DROP TABLE production_companiesCURSOR;

SELECT * FROM production_companiesCURSOR;
SELECT COUNT(*) FROM production_companiesCURSOR;


## CURSOR SPOKEN LANGUAGES
USE Movies2023;

DROP PROCEDURE IF EXISTS TablaSpokenLanguages;

DELIMITER $$
CREATE PROCEDURE TablaSpokenLanguages ()

BEGIN

 DECLARE done INT DEFAULT FALSE ;
 DECLARE jsonData json ;
 DECLARE jsonId varchar(250) ;
 DECLARE jsonLabel varchar(250) ;
 DECLARE resultSTR LONGTEXT DEFAULT '';
 DECLARE i INT;
 
 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT JSON_EXTRACT(CONVERT(spoken_languages USING UTF8MB4), '$[*]') FROM movie_dataset ;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;
 drop table if exists spokenLanguagesTem;
    SET @sql_text = 'CREATE TABLE spokenLanguagesTem ( iso_639_1 varchar(2), nameLang VARCHAR(100));';
    PREPARE stmt FROM @sql_text;	
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 cursorLoop: LOOP
  FETCH myCursor INTO jsonData;
  
  -- Controlador para buscar cada uno de los arrays
    SET i = 0;
    
  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;
  
  WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO
  SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].iso_639_1')), '') ;
  SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
  SET i = i + 1;
  
  SET @sql_text = CONCAT('INSERT INTO spokenLanguagesTem VALUES (', REPLACE(jsonId,'\'',''), ', ', jsonLabel, '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    
  END WHILE;
  
 END LOOP ;
 
 select distinct * from spokenLanguagesTem;
    INSERT INTO spoken_languagesCURSOR
    SELECT DISTINCT iso_639_1, nameLang
    FROM spokenLanguagesTem;
    drop table if exists spokenLanguagesTem;
 CLOSE myCursor ;
 
END$$
DELIMITER ;

call TablaSpokenLanguages();

SELECT * FROM spoken_languagesCURSOR;

CREATE TABLE spoken_languagesCURSOR (
	iso_639_1 varchar(2) PRIMARY KEY,
    name varchar(100)
);

DROP TABLE IF EXISTS spoken_languagesCURSOR;

SELECT COUNT(*) FROM spoken_languagesCURSOR;
