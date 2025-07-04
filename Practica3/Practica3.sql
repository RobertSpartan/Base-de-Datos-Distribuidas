------------------------------- P R A C T I C A  3 ---------------------------------
--NODO KARLA ROBERT
-----------------TABLAS DE REGIONES PARTICIONADAS EN SQL--------------------------
--Script SQL de cada base de datos por región: 
select * into datoscovid_Noroeste
from CovidHistorico_.dbo.datoscovid
where ENTIDAD_RES in (02, 03, 26, 25, 08, 10)

select * into datoscovid_Noreste
from CovidHistorico_.dbo.datoscovid
where ENTIDAD_RES in (05, 19, 28)

select * into datoscovid_Occidente
from CovidHistorico_.dbo.datoscovid
where ENTIDAD_RES in (18, 14, 06, 16)


------------------------Consultas de Mis Tablas--------------------
select*
From dbo.datoscovid_Noroeste

select*
From dbo.datoscovid_Noreste

select*
From dbo.datoscovid_Occidente



------------------------Prueba conexión Linked Servers--------------------
select * 
from  openquery ([MYSQLASAP3],'select * from covid_hist.datoscovid_sureste')

select * 
from  openquery ([LS_ASA_VPN],'select * from Covid_Hist.dbo.datoscovid_Oriente')

select * 
from  openquery ([LS_KARLA_VPN],'select * from Covid_Hist.dbo.datoscovid_Occidente')




--Script SQL de las consultas distribuidas

--Consulta 3

SELECT
    
    CAST(ROUND((SUM(CASE WHEN diabetes = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS DECIMAL(10,2)) AS porcentaje_diabetes,
    CAST(ROUND((SUM(CASE WHEN obesidad = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS DECIMAL(10,2)) AS porcentaje_obesidad,
    CAST(ROUND((SUM(CASE WHEN hipertension = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS DECIMAL(10,2)) AS porcentaje_hipertension
FROM (
    -- Región Noroeste
    SELECT TOP 10* FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Noroeste')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    UNION ALL
    -- Región Noreste
    SELECT TOP 10* FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Noreste')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    UNION ALL
    -- Región Occidente
    SELECT TOP 10* FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Occidente')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    UNION ALL
    -- Región Sureste
    SELECT TOP 10* FROM openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.datoscovid_sureste')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    UNION ALL
    -- Región Suroeste
    SELECT TOP 10* FROM openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.datoscovid_suroeste')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    UNION ALL
    -- Región Oriente
    SELECT TOP 10* FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Oriente')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    UNION ALL
    -- Región Centrosur
    SELECT TOP 10* FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Centrosur')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    UNION ALL
    -- Región Centronorte
    SELECT TOP 10* FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Centronorte')
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
) AS Datos


-- Consulta 4
SELECT DISTINCT ENTIDAD_RES, MUNICIPIO_RES AS Municipio
FROM (
    -- Región Noroeste
    SELECT top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Noroeste')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
    UNION ALL
    -- Región Noreste
    SELECT top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Noreste')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
    UNION ALL
    -- Región Occidente
    SELECT  top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Occidente')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
    UNION ALL
    -- Región Sureste
    SELECT top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.datoscovid_sureste')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
    UNION ALL
    -- Región Suroeste
    SELECT top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.datoscovid_suroeste')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
    UNION ALL
    -- Región Oriente
    SELECT top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Oriente')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
    UNION ALL
    -- Región Centrosur
    SELECT top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Centrosur')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
    UNION ALL
    -- Región Centronorte
    SELECT top 10 ENTIDAD_RES, MUNICIPIO_RES
    FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Centronorte')
    WHERE CLASIFICACION_FINAL NOT IN (1, 2, 3)
      AND diabetes = 1
      AND obesidad = 1
      AND hipertension = 1
      AND tabaquismo = 1
) AS Datos
GROUP BY ENTIDAD_RES, MUNICIPIO_RES;

-- Consulta 5
WITH NeumoniaPorEstado AS (
    -- Región Noroeste
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Noroeste') d
    JOIN openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
    UNION ALL
    -- Región Noreste
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Noreste') d
    JOIN openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
    UNION ALL
    -- Región Occidente
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.datoscovid_Occidente') d
    JOIN openquery([LS_KARLA_VPN], 'SELECT * FROM CovidHistorico_.dbo.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
    UNION ALL
    -- Región Sureste
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.datoscovid_sureste') d
    JOIN openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
    UNION ALL
    -- Región Suroeste
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.datoscovid_suroeste') d
    JOIN openquery([MYSQLASAP3], 'SELECT * FROM covid_hist.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
    UNION ALL
    -- Región Oriente
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Oriente') d
    JOIN openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
    UNION ALL
    -- Región Centrosur
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Centrosur') d
    JOIN openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
    UNION ALL
    -- Región Centronorte
    SELECT e.entidad AS Estado, COUNT(*) AS Total_con_neumonia
    FROM openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.datoscovid_Centronorte') d
    JOIN openquery([LS_ASA_VPN], 'SELECT * FROM Covid_Hist.dbo.cat_entidades') e ON d.ENTIDAD_UM = e.clave
    WHERE d.neumonia = 1
    GROUP BY e.entidad
)
SELECT Estado, SUM(Total_con_neumonia) AS Total_con_neumonia
FROM NeumoniaPorEstado
GROUP BY Estado
ORDER BY Total_con_neumonia DESC;

-- Consulta 7
WITH Max_casos AS (
    -- Región Noroeste
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([LS_KARLA_VPN], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM CovidHistorico_.dbo.datoscovid_Noroeste')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM

    UNION ALL

    -- Región Noreste
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([LS_KARLA_VPN], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM CovidHistorico_.dbo.datoscovid_Noreste')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM

    UNION ALL

    -- Región Occidente
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([LS_KARLA_VPN], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM CovidHistorico_.dbo.datoscovid_Occidente')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM

    UNION ALL

    -- Región Sureste
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([MYSQLASAP3], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM covid_hist.datoscovid_sureste')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM

    UNION ALL

    -- Región Suroeste
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([MYSQLASAP3], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM covid_hist.datoscovid_suroeste')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM

    UNION ALL

    -- Región Oriente
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([LS_ASA_VPN], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM Covid_Hist.dbo.datoscovid_Oriente')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM

    UNION ALL

    -- Región Centrosur
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([LS_ASA_VPN], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM Covid_Hist.dbo.datoscovid_Centrosur')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM

    UNION ALL

    -- Región Centronorte
    SELECT
        YEAR(FECHA_INGRESO) AS año,
        MONTH(FECHA_INGRESO) AS mes,
        ENTIDAD_UM AS Estado,
        COUNT(*) AS Registrados,
        COUNT(CASE WHEN CLASIFICACION_FINAL IN ('1', '2', '3') THEN 1 END) AS Confirmados,
        COUNT(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 END) AS Sospechosos,
        RANK() OVER (PARTITION BY YEAR(FECHA_INGRESO), ENTIDAD_UM ORDER BY COUNT(*) DESC) AS ranking
    FROM openquery([LS_ASA_VPN], 'SELECT FECHA_INGRESO, ENTIDAD_UM, CLASIFICACION_FINAL FROM Covid_Hist.dbo.datoscovid_Centronorte')
    WHERE YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_UM
)
SELECT TOP 10
    m.año,
    e.entidad AS Estado,
    m.mes,
    m.Registrados,
    m.Confirmados,
    m.Sospechosos
FROM Max_casos m
JOIN OPENQUERY([MYSQLASAP3], 'SELECT clave, entidad FROM covid_hist.cat_entidades') e 
 ON m.Estado = e.clave
WHERE m.ranking = 1
ORDER BY e.entidad ASC, m.año;



