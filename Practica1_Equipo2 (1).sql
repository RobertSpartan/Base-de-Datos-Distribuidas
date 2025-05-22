
---------------------------------------------------------- P R A C T I C A   1 ---------------------------------------------------------------

--INTEGRANTES EQUIPO 2--
--OCAMPO CABRERA ASAEL
--ROBERT ROA KARLA GUADALUPE
--SANCHEZ VILLAGRANA OSMAR ROBERTO
----------------------------------------------------------------------------------------------------------------------------------------------


use Covid_Hist;


/*********************************************************************************************************************************************
 Número 1. Listar el top 5 de las entidades con más casos confirmados por cada uno de los años registrados en la base de datos.
 
 Requisitos:
	Se usó la tabla datoscovid, filtrando solo casos confirmados (CLASIFICACION_FINAL = 1, 2, 3). También se utilizó 
	cat_entidades para obtener los nombres de las entidades. Se empleó YEAR(FECHA_INGRESO) para agrupar los datos y una 
	subconsulta para seleccionar las cinco entidades con más casos por año.
 
 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL: Filtra casos confirmados (1: asociación clínica-epidemiológica, 2: comité de dictaminación, 
	3: laboratorio).
	ENTIDAD_RES: Clave de la entidad donde se registró el caso.
	FECHA_INGRESO: Fecha de registro del caso.
	Total_casos: Número de casos confirmados por entidad y año.	
 
 Responsable de la consulta.
	Responsable de la consulta:	Ocampo Cabrera Asael
 
 Comentarios: 
	Se utilizaron instrucciones vistas en clase como COUNT (), JOIN, WHERE para seleccionar el top 5. Sin embargo, 
	esta vez se hizo uso de YEAR () para filtrar el año de una fecha la consulta deseada.

***************************/
-- VISTA 
go
create view casos_estado as
	select year(FECHA_INGRESO) as Año, ENTIDAD_RES, count(*) as Total_casos
		from datoscovid
		where CLASIFICACION_FINAL in ('1', '2', '3') 
		group by year(FECHA_INGRESO), ENTIDAD_RES;
go

--CONSULTA
	select v.Año, e.entidad as Estado, v.total_casos as Confrimados
	from casos_estado v
	join cat_entidades e on v.entidad_res = e.clave
	where (select count(*)
			from casos_estado v2
			where v2.Año = v.Año and v2.total_casos > v.total_casos) < 5
	order by v.Año, v.total_casos desc;


/*********************************************************************************************************************************************
 Número 2. Listar el municipio con más casos confirmados recuperados por estado y por año. 

 Requisitos:
	Se empleó la tabla datoscovid, filtrando solo casos confirmados (CLASIFICACION_FINAL = 1, 2, 3). Se utilizó 
	YEAR(FECHA_INGRESO) para agrupar los datos por año y MUNICIPIO_RES para contar casos a nivel municipal. 
	Se realizó una subconsulta con MAX() para seleccionar el municipio con más casos por estado y año.

 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL: Filtra casos confirmados (1: asociación clínica epidemiológica, 2: comité de dictaminación, 
	3: laboratorio).
	ENTIDAD_RES: Clave de la entidad donde se registró el caso.
	MUNICIPIO_RES: Clave del municipio donde se registró el caso.
	FECHA_INGRESO: Fecha en que se registró el caso.
	total_casos: Número de casos confirmados por municipio, entidad y año.	

 Responsable de la consulta.
	Ocampo Cabrera Asael

 Comentarios: 
	Al igual que en otras consultas, se hizo uso de múltiples instrucciones vistas previamente en clase, sin embargo, 
	se hizo uso de YEAR () filtrar el año de una fecha en nuestra consulta.

********************************/
-- VISTA 
go
create view casos_municipio as
select year(FECHA_INGRESO) as Año, ENTIDAD_RES, municipio_res, count(*) as total_casos
from datoscovid
where CLASIFICACION_FINAL in (1, 2, 3)
group by year(FECHA_INGRESO), ENTIDAD_RES, MUNICIPIO_RES;
go

--CONSULTA
select V.año, e.entidad, v.municipio_res, v.total_casos
from casos_municipio v
join cat_entidades e on v.entidad_res = e.clave
where v.total_casos = (select max(total_casos)
						from casos_municipio v2
						where v2.año = v.año and v2.entidad_res = v.entidad_res)
order by e.entidad asc;


/*********************************************************************************************************************************************
 Número 3. Listar el porcentaje de casos confirmados en cada una de las siguientes morbilidades a nivel nacional: 
		   diabetes, obesidad e hipertensión.

 Requisitos:
	Se utilizó la tabla principal datoscovid para contar los casos confirmados (CLASIFICACION_FINAL en 1, 2, 3) en 
	personas con diabetes, obesidad e hipertensión. Se creó una vista llamada casos_morbilidades, donde se cuentan 
	los casos para cada morbilidad y el total de casos confirmados. Posteriormente, la consulta calcula el porcentaje 
	de cada morbilidad dividiendo el número de casos por el total y multiplicando por 100, redondeando el resultado 
	a dos decimales.
 
 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL (1, 2, 3): Indica que un caso está confirmado.
	SI_NO:() Define si la persona tiene diabetes, obesidad o hipertensión, teniendo (1 = Sí, 2 = No, 97 = No aplica, 
	98 = Se ignora, 99 = No especificado).
	total_casos: Cantidad total de casos confirmados a nivel nacional.
	Porcentajes calculados: Representan el porcentaje de personas con cada morbilidad respecto al total de casos confirmados.


 Responsable de la consulta.
	Ocampo Cabrera Asael

 Comentarios: 
	Para esta consulta se hizo uso de CASE WHEN para dar condiciones de selección en nuestra vista, además, se implementó 
	el uso de ROUND () para hacer el redondeo del total de los porcentajes de nuestra consulta y CAST () para mejorar la 
	precisión y presentación de los resultados, al hacer uso de decimales.

**************************************/
-- VISTA 
go
create view casos_morbilidades as
select 
    count(case when diabetes = 1 then 1 end) as casos_diabetes,
    count(case when obesidad = 1 then 1 end) as casos_obesidad,
    count(case when hipertension = 1 then 1 end) as casos_hipertension,
    count(case when tabaquismo = 1 then 1 end) as casos_tabaquismo,
    count(*) as total_casos
from datoscovid
where CLASIFICACION_FINAL in ('1','2', '3');
go

--CONSULTA
select  
    cast(round((casos_diabetes * 100.0 / total_casos), 2) as decimal(10,2)) as porcentaje_diabetes,
    cast(round((casos_obesidad * 100.0 / total_casos), 2) as decimal(10,2)) as porcentaje_obesidad,
    cast(round((casos_hipertension * 100.0 / total_casos), 2) as decimal(10,2)) as porcentaje_hipertension
from casos_morbilidades;


/*********************************************************************************************************************************************
 Número 4. Listar los municipios que no tengan casos confirmados en todas las morbilidades: 
		   hipertensión, obesidad, diabetes, tabaquismo. 

 Requisitos:
	Se utilizó la tabla principal datoscovid, aplicando condiciones en la cláusula WHERE para excluir los casos 
	confirmados (CLASIFICACION_FINAL no en 1, 2, 3). Además, se filtraron registros donde todas las morbilidades 
	(diabetes, obesidad, hipertension, tabaquismo) sean iguales a 1, lo que indica que la persona padece esas 
	condiciones. Finalmente, se agruparon los resultados por entidad y municipio para identificar aquellos sin 
	casos confirmados bajo estos criterios.

 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL (1, 2, 3): Casos confirmados de COVID-19.
	SI_NO(): Indica si la persona tiene la morbilidad correspondiente, teniendo (1 = Sí, 2 = No, 97 = No aplica, 
	98 = Se ignora, 99 = No especificado). 
	ENTIDAD_RES y MUNICIPIO_RES: Representan el estado y el municipio del paciente, con sus claves disponibles en 
	los catálogos de entidades y municipios.

 Responsable de la consulta.
	Ocampo Cabrera Asael

 Comentarios: 
	Al igual que en varias consultas, se hizo uso de funciones previamente vistas en clase, en este caso se utilizó 
	funciones de agregación y filtrado los municipios sin casos confirmados en personas con todas las morbilidades
	mencionadas. 

*****************************************/
select distinct ENTIDAD_RES ,MUNICIPIO_RES as Municipio
from datoscovid
where CLASIFICACION_FINAL not in (1, 2, 3)
and diabetes = 1 and obesidad = 1 and hipertension = 1 and tabaquismo = 1
group by ENTIDAD_RES, MUNICIPIO_RES;


/*********************************************************************************************************************************************
 Número 5. Listar los estados con más casos recuperados con neumonía. 

 Requisitos:
	Se utilizó la tabla datoscovid para identificar los casos de pacientes con neumonía (neumonia = 1). La consulta 
	une esta tabla con el catálogo de entidades cat_entidades mediante la clave de entidad (ENTIDAD_UM = clave) 
	para obtener el nombre del estado. Se aplicó COUNT(*) para contar los casos de neumonía por estado y se usó 
	GROUP BY para agrupar los resultados por entidad. Finalmente, los resultados se ordenaron en orden descendente 
	según el número de casos de neumonía.

 Significado de los valores de los catálogos.
	neumonia: Indica si el paciente presentó neumonía.
	cat_entidades: Contiene la clave y el nombre de cada estado.
	ENTIDAD_UM: Representa la entidad donde se atendió al paciente.
	Total_con_neumonia: Cantidad de casos de neumonía recuperados por estado.

 Responsable de la consulta.
	Ocampo Cabrera Asael

 Comentarios: 
	Para esta consulta no se hizo uso de ninguna nueva función diferente a las previamente vistas en clase.

*********************************/
select e.entidad as Estado, count(*) as Total_con_neumonia
from datoscovid d
join cat_entidades e on d.ENTIDAD_UM = e.clave
where neumonia = 1
group by e.entidad
order by Total_con_neumonia desc;


/*********************************************************************************************************************************************
 Número 6. Listar el total de casos confirmados/sospechosos por estado en cada uno de los años registrados en la base de datos.
 
 Requisitos:
	Se utilizó la tabla datoscovid para obtener el número de casos confirmados (CLASIFICACION_FINAL en 1, 2, 3) 
	y sospechosos (CLASIFICACION_FINAL = 6). Se creó una vista llamada casos_confirmados_sospechosos, donde se agruparon
	los datos por año (FECHA_INGRESO) y estado (ENTIDAD_UM), calculando el total de casos por clasificación. 
	Posteriormente, se unió esta vista con el catálogo de entidades cat_entidades para obtener el nombre del estado y 
	se ordenaron los resultados en orden ascendente por año y estado.

 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL: Se utilizó (1, 2, 3) para casos confirmados de COVID-19, y (6) para casos sospechosos.
	FECHA_INGRESO: Fecha de ingreso del paciente al sistema de salud.
	ENTIDAD_UM: Representa la entidad donde se atendió al paciente.
	cat_entidades: Contiene la clave y el nombre de cada estado.
	Confirmados: Total de casos confirmados por estado y año.
	Sospechosos: Total de casos sospechosos por estado y año.

 Responsable de la consulta.
	Ocampo Cabrera Asael

 Comentarios:
	Al igual que en previas consultas, se hizo uso CASE WHEN para usar una condición en la selección de nuestra vista, 
	así como, YEAR () para filtrar por año una fecha de la consulta. 

******************************/
--VISTA--
go
create view casos_confirmados_sospechosos as
select year(FECHA_INGRESO) as año, ENTIDAD_UM as Estado,
		sum(case when CLASIFICACION_FINAL in (1, 2, 3) then 1 else 0 end) as Confirmados,
		sum(case when CLASIFICACION_FINAL = 6 then 1 else 0 end) as Sospechosos
from datoscovid
group by year(FECHA_INGRESO), ENTIDAD_UM;
go

--CONSULTA
select c.año, e.entidad as Estado, c.Confirmados, c.Sospechosos
from casos_confirmados_sospechosos c
join cat_entidades e on c.Estado = e.clave
order by c.año asc, e.entidad asc;


/*********************************************************************************************************************************************
 Número 7. Para el año 2020 y 2021 cuál fue el mes con más casos registrados, confirmados, sospechosos, por estado registrado 
		   en la base de datos.

 Requisitos: 
	Se utilizó la tabla datoscovid para obtener el número de casos registrados, confirmados (CLASIFICACION_FINAL en 1, 2, 3) 
	y sospechosos (CLASIFICACION_FINAL = 6). Se creó la vista casos_por_mes, donde se agruparon los datos por año, mes y estado 
	(ENTIDAD_UM), calculando el total de casos para cada clasificación. Luego, se aplicó una consulta con RANK() en Max_casos, 
	que ordenó los meses de cada estado según el número de casos registrados en orden descendente. Finalmente, se filtraron los 
	registros con RANK() = 1, asegurando que solo se mostrara el mes con más casos por estado.

 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL: Se utilizó (1, 2, 3) para casos confirmados de COVID-19, y (6) para casos sospechosos.
	FECHA_INGRESO: Fecha de ingreso del paciente al sistema de salud.
	ENTIDAD_UM: Representa la entidad donde se atendió al paciente.
	cat_entidades: Contiene la clave y el nombre de cada estado.
	Registrados: Total de casos registrados en un mes por estado.
	Confirmados: Total de casos confirmados en un mes por estado.
	Sospechosos: Total de casos sospechosos en un mes por estado.
	mes: Mes del año en el que se registraron los casos.

 Responsable de la consulta.
	Asael Ocampo Cabrera

 Comentarios:
	Para esta consulta se hizo uso de la cláusula WITH previamente vista en clase, para ser referenciada en nuestra consulta 
	los valores de la tabla temporal creada. Así mismo, dentro de la misma cláusula se utilizó RANK() para la asignación de 
	rango en las filas y obtener los valores de rango deseados, y OVER(PARTITION BY) para particionar el conjunto de valores 
	y encontrar el mes con más casos por estado.

*****************************************/ 
-- VISTA 
go
create view casos_por_mes as
select year(FECHA_INGRESO) as año, month(FECHA_INGRESO) as mes, ENTIDAD_UM as Estado,
    count(*) as Registrados,
    count(case when CLASIFICACION_FINAL in ('1', '2', '3') then 1 end) as Confirmados,
    count(case when CLASIFICACION_FINAL = 6 then 1 end) as Sospechosos
from datoscovid
where year(FECHA_INGRESO) in (2020, 2021)
group by year(FECHA_INGRESO), month(FECHA_INGRESO), ENTIDAD_UM;
go

--CONSULTA
with Max_casos as (select c.año, c.mes, c.Estado, c.Registrados, c.Confirmados, c.Sospechosos,
						  rank() over (partition by c.año, c.Estado order by c.Registrados desc) as ranking
							  from casos_por_mes c)
select m.año, e.entidad as Estado, m.mes, m.Registrados, m.Confirmados, m.Sospechosos
from Max_casos m
join cat_entidades e on m.Estado = e.clave
where m.ranking = 1
order by e.entidad asc, m.año;


/*********************************************************************************************************************************************
 Número 8. Listar el municipio con menos defunciones en el mes con más casos confirmados con neumonía en los años 
		  2020 y 2021.

 Requisitos:
    Crear una consulta que identifique el municipio con menos defunciones en el mes con más casos confirmados 
	de COVID-19 con neumonía en los años 2020 y 2021.
 
 Significado de los valores de los catálogos.
    CLASIFICACION_FINAL IN ('1', '2', '3'): Filtra los casos confirmados de COVID-19 según el catálogo cat_clasificacion_final.
    NEUMONIA = 1: Indica que el caso confirmado presentó neumonía.
    FECHA_INGRESO: Fecha de ingreso del caso.
    FECHA_DEF: Fecha de defunción del caso (no nula para considerar defunciones).
    MUNICIPIO_RES: Municipio de residencia del paciente.
    anio: Año de ingreso del caso.
    mes: Mes de ingreso del caso.
    total_casos: Total de casos confirmados con neumonía por mes y año.
    total_defunciones: Total de defunciones por municipio, mes y año.

 Responsable de la consulta.
   Sánchez Villagrana Osmar Roberto

 Comentarios:
    - Se utilizaron subconsultas con WITH para identificar el mes con más casos confirmados con neumonía por año y luego 
	encontrar el municipio con menos defunciones en ese mes.
     La función ROW_NUMBER() se utilizó para asignar un número único a cada mes dentro de cada año, ordenado por el número de casos en orden
      descendente. Esto permitió identificar el mes con más casos (el que tiene ROW_NUMBER = 1) para cada año.
     La función RANK() se utilizó para asignar un rango a cada municipio dentro de cada año y mes, ordenado por el número de defunciones en
      orden ascendente. Esto permitió identificar los municipios con menos defunciones (los que tienen RANK = 1) en el mes con más casos.
     se aplican funciones de ventana (ROW_NUMBER y RANK) para ordenar y filtrar los resultados de manera eficiente.
    En la consulta se ocupa SELECT, JOIN, GROUP BY, ORDER BY, los cuales son temas vistos en clase.
*********************************************************************************************************************************************/
with mesconmascasos as ( select year(fecha_ingreso) as anio, month(fecha_ingreso) as mes, count(*) as total_casos
    from datoscovid
    where clasificacion_final in ('1', '2', '3') and neumonia = 1 and year(fecha_ingreso) in (2020, 2021)
    group by year(fecha_ingreso), month(fecha_ingreso)), rankedmeses as (select anio, mes, total_casos, 
																			row_number() over (partition by anio order by total_casos desc) as rank
																		 from mesconmascasos), municipioscondefunciones as (select year(fecha_ingreso) as anio, 
																															month(fecha_ingreso) as mes, municipio_res, 
																															count(*) as total_defunciones
																															from datoscovid
	where clasificacion_final in ('1', '2', '3') and neumonia = 1 and year(fecha_ingreso) in (2020, 2021) and fecha_def is not null
    group by year(fecha_ingreso), month(fecha_ingreso), municipio_res), rankedmunicipios as (
    select m.anio, m.mes, m.municipio_res, m.total_defunciones,  rank() over (partition by m.anio, m.mes 
	order by m.total_defunciones asc) as rank
    from municipioscondefunciones m
    join rankedmeses r on m.anio = r.anio and m.mes = r.mes
    where r.rank = 1)
    select r.anio, r.mes, r.municipio_res, r.total_defunciones
    from rankedmunicipios r
    where r.rank = 1
    order by r.anio, r.mes, r.municipio_res;


/*********************************************************************************************************************************************
 Número  9. Listar el top 3 de municipios con menos casos recuperados en el año 2021.

 Requisitos:
	Crear una consulta que identifique los tres municipios con menor cantidad de casos recuperados en el año 2021,
	utilizando una vista previa que agrupe los casos por municipio y año.

 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL IN (1,2,3): Filtra los casos confirmados de COVID-19 según el catálogo cat_clasificacion_final.
	ENTIDAD_RES: Clave de la entidad de residencia del paciente, relacionada con cat_entidades.
	MUNICIPIO_RES: Clave del municipio de residencia del paciente, relacionada con cat_municipios.
	FECHA_INGRESO: Fecha de ingreso del caso.
	total_casos: Total de casos confirmados en cada municipio y año.

 Responsable de la consulta.
	Robert Roa Karla Guadalupe

 Comentarios: 
	Se implementaron instrucciones vistas en clase, como JOIN para unir tablas y ORDER BY para ordenar los resultados. 
	Además, se utilizó la nueva instrucción IN (año, año) para filtrar los datos de años específicos, facilitando el 
	análisis de los casos negativos por estado.

********************************/ 
--VISTA--
go
create view casos_municipio as
select year(FECHA_INGRESO) as Año, ENTIDAD_RES, municipio_res, count(*) as total_casos
from datoscovid
where CLASIFICACION_FINAL in (1, 2, 3)
group by year(FECHA_INGRESO), ENTIDAD_RES, MUNICIPIO_RES;
go

--CONSULTA
select top 3 MUNICIPIO_RES as Municipio, total_casos as TotalCasos
from casos_municipio
where Año = 2021
order by total_casos asc;


/*********************************************************************************************************************************************
 Número 10. Listar el porcentaje de casos confirmado por género en los años 2020 y 2021.
 Requisitos:
    Crear una consulta que muestre el porcentaje de casos de COVID-19 confirmados (clasificación final 1, 2 o 3) 
	por año (2020 y 2021) y sexo, respecto al total general de casos en esos dos años.

 Significado de los valores de los catálogos.
    CLASIFICACION_FINAL IN ('1', '2', '3'): Filtra los casos confirmados de COVID-19 según el catálogo 
	cat_clasificacion_final.
    FECHA_INGRESO: Fecha de ingreso del caso.
    SEXO: Sexo del paciente.
    anio: Año de ingreso del caso.
    porcentaje: Porcentaje de casos por año y sexo respecto al total general.

 Responsable de la consulta.
    Sánchez Villagrana Osmar Roberto

 Comentarios:
	Se utilizó una subconsulta con WITH para obtener el total de casos generales en los años 2020 y 2021.
	Calculamos el porcentaje de casos por año y sexo utilizando una división y CAST para formatear el resultado con 15 decimales.
	En la consulta se utilizaron temas antes visto como Select, Join, Order By, Group by. Y no hubo la necesidad de implementar hasta 
	el momento una mejora para poder optimizar la consulta 

*********************************************************************************************************************************************/

with total_casos_generales as (
    select count(*) as total_casos_generales
    from datoscovid
    where clasificacion_final in ('1', '2', '3') and year(fecha_ingreso) in (2020, 2021)
)
select year(d.fecha_ingreso) as anio, d.sexo, cast(count(*) * 100.0 / t.total_casos_generales as decimal(18, 15)) as porcentaje
from datoscovid d
cross join total_casos_generales t
where d.clasificacion_final in ('1', '2', '3') and year(d.fecha_ingreso) in (2020, 2021)
group by year(d.fecha_ingreso), d.sexo, t.total_casos_generales
order by anio, sexo;


/*********************************************************************************************************************************************
 Número  11. Listar el porcentaje de casos hospitalizados por estado en el año 2020.
 
 Requisitos:
	Crear una consulta que calcule el porcentaje de pacientes hospitalizados por estado en el año 2020, 
	considerando únicamente aquellos registros con ingreso en dicho año.
	
 Significado de los valores de los catálogos.
	TIPO_PACIENTE = 2: Indica casos hospitalizados según el catálogo cat_tipo_paciente.
	 ENTIDAD_UM: Clave del estado donde se registró el caso, relacionada con cat_entidades.  
	 FECHA_INGRESO: Fecha de ingreso del paciente a la unidad médica. 
	 porcentaje_hospitalizados: Porcentaje de hospitalizados respecto al total de casos por estado.

	
 Responsable de la consulta.
	Robert Roa Karla Guadalupe
	
 Comentarios: 
	Se utilizó la función CASE dentro de COUNT para contar únicamente los casos hospitalizados (donde tipo_paciente = 2). 
	Además, se aplicó ROUND para redondear el porcentaje de hospitalizados a dos decimales y CAST para mostrar el resultado 
	con un formato decimal específico.

***********************************/ 
select e.entidad as Estado,
	cast(round((count(case when d.tipo_paciente = 2 then 1 end) * 100.0) / count(*), 2 ) as decimal(10,2)) as Porcentaje_Hospitalizados
from datoscovid d
join cat_entidades e on d.entidad_um = e.clave
where year(d.FECHA_INGRESO) = 2020 
group by e.entidad
order by  porcentaje_hospitalizados desc;


/*********************************************************************************************************************************************
 Número  12. Listar total de casos negativos por estado en los años 2020 y 2021.

 Requisitos:
	Crear una vista que resuma el total de casos negativos por estado y año. Simplificando las consultas 
	enfocándose en casos negativos.

 Significado de los valores de los catálogos.
	CLASIFICACION_FINAL = 7: Indica casos negativos según el catálogo cat_clasificacion_final.
	ENTIDAD_UM: Clave del estado donde se registró el caso, relacionada con cat_entidades.
	anio: Año de ingreso del caso, extraído de FECHA_INGRESO.
	total_negativos: Número de casos negativos agrupados por estado y año.

 Responsable de la consulta.
	Robert Roa Karla Guadalupe
	
 Comentarios: 
	Se agregó la instrucción IN para filtrar los datos de los años 2020 y 2021, mientras que 
	las demás instrucciones utilizadas, como JOIN y ORDER BY, ya se habían visto previamente en clase.

***********************************/ 
-- VISTA 
go
create view casos_negativos_estado as
select year (FECHA_INGRESO) as anio, ENTIDAD_UM, count(*) as total_negativos
from datoscovid
where CLASIFICACION_FINAL = 7  
group by year(FECHA_INGRESO) , ENTIDAD_UM;
go

--CONSULTA
select cn.anio as Año, e.entidad as Estado,	cn.total_negativos as Total_Negativos
from casos_negativos_estado cn
join cat_entidades e on cn.entidad_um = e.clave
where cn.anio IN (2020, 2021)
order by e.entidad asc;


/*********************************************************************************************************************************************
 Número 13. Listar porcentajes de casos confirmados por género en el rango de edades de 20 a 30 años, de 31 a 40 años, 
			de 41 a 50 años, de 51 a 60 años y mayores a 60 años a nivel nacional.
 Requisitos:
    Crear una consulta que muestre el número total de casos de COVID-19 confirmados (clasificación final 3) por sexo y
	rango de edad, junto con el porcentaje que representan respecto al total general de casos. Utilizar una vista 
	previa (casos_genero_edad) que agrupe los casos por año, sexo y rango de edad.

 Significado de los valores de los catálogos.
    CLASIFICACION_FINAL =CLASIFICACION_FINAL IN (1, 2, 3): Filtra los casos confirmados de COVID-19 según el catálogo 
	cat_clasificacion_final.
	FECHA_INGRESO: Fecha de ingreso del caso.
    SEXO: Sexo del paciente.
    EDAD: Edad del paciente.
    rango_edad: Rango de edad del paciente (20-30, 31-40, 41-50, 51-60, 60+).
    total_casos: Total de casos confirmados por sexo y rango de edad.
    Porcentaje: Porcentaje de casos por sexo y rango de edad respecto al total general.

 Responsable de la consulta.
   Sánchez Villagrana Osmar Roberto

 Comentarios:
    Se creo una vista casos_genero_edad para agrupar los casos por año, sexo y rango de edad, utilizando la expresión 
	CASE para definir los rangos de edad
	Se realiza una consulta sobre esta vista para calcular el total de casos y el porcentaje por sexo y rango de edad
    Se utiliza una función de ventana SUM OVER para calcular el total general de casos y calcular el porcentaje.
    En la consulta se utilizaron temas antes visto como Select, Join, Order By, Group by. Y no hubo la necesidad de implementar hasta el
	momento una mejora para poder optimizar la consulta. 

*********************************************************************************************************************************************/

-- Vista del ejercicio 13:
go
create view casos_genero_edad as
select year(fecha_ingreso) as anio, sexo,
    case
        when edad between 20 and 30 then '20-30'
        when edad between 31 and 40 then '31-40'
        when edad between 41 and 50 then '41-50'
        when edad between 51 and 60 then '51-60'
        else '60+'
    end as rango_edad, count(*) as total_casos
from datoscovid
where clasificacion_final in (1, 2, 3)
group by year(fecha_ingreso), sexo,
    case
        when edad between 20 and 30 then '20-30'
        when edad between 31 and 40 then '31-40'
        when edad between 41 and 50 then '41-50'
        when edad between 51 and 60 then '51-60'
        else '60+'
    end;
go

-- Consulta del ejercicio 13:
select sexo, rango_edad, sum(total_casos) as total_casos, CAST(sum(total_casos) * 100.0 / sum(sum(total_casos)) over () as decimal(5,2)) as Porcentaje
from casos_genero_edad
group by sexo, rango_edad
order by sexo, rango_edad;


/*********************************************************************************************************************************************
 Número  14. Listar el rango de edad con más casos confirmados y que fallecieron en los años 2020 y 2021.
 
 Requisitos: 
	Se utilizó la tabla principal de la base de datos denominada datoscovid, aplicando un CASE para agrupar 
	las edades en rangos específicos, lo cual permitió analizar de forma detallada la distribución de los casos.

 Significado de los valores de los catálogos: 
	CLASIFICACION_FINAL IN (1, 2, 3): Filtra solo casos confirmados de acuerdo con el catálogo cat_clasificacion_final.
	FECHA_DEF: Fecha de defunción, usada para determinar casos fallecidos.
	rangoEdad: Categoriza la edad en grupos específicos.
	casosConfirmados: Total de casos confirmados por rango de edad.
	casosFallecidos: Total de fallecidos por rango de edad.

 Responsable de la consulta. 
	Robert Roa Karla Guadalupe

 Comentarios: 
	 Se utilizó CASE para organizar las edades en grupos específicos y facilitar el análisis. También se empleó TRY_CONVERT
	 para asegurar que las fechas estuvieran en el formato correcto y DATEPART para extraer el año de esos registros. 
	 Además, con LEFT JOIN se combinó la información de las tablas y con TOP 1 se seleccionó el grupo de edad con más 
	 fallecimientos. Tanto LEFT JOIN como TOP ya se habían visto en clase.

**************************************/ 
select top 1
    case 
        when B.edad between 20 and 30 then '20-30'
        when B.edad between 31 and 40 then '31-40'
        when B.edad between 41 and 50 then '41-50'
        when B.edad between 51 and 60 then '51-60'
        else '60+'
    end as rangoEdad,
    count(*) as casosConfirmados,
    sum(case when A.FECHA_DEF is not null then 1 else 0 end) as casosFallecidos
from datoscovid as B
left join (select ID_REGISTRO, FECHA_DEF
			from datoscovid
			where DATEPART(year, TRY_CONVERT(date, FECHA_DEF)) in (2020, 2021)) as A
on B.ID_REGISTRO = A.ID_REGISTRO
where B.CLASIFICACION_FINAL in (1, 2, 3)
group by 
    case 
        when B.edad between 20 and 30 then '20-30'
        when B.edad between 31 and 40 then '31-40'
        when B.edad between 41 and 50 then '41-50'
        when B.edad between 51 and 60 then '51-60'
        else '60+'
    end
order by casosFallecidos desc;