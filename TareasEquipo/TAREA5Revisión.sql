--------------------------------- T A R E A  5  -  C O N S U L T A  D I N A M I C A ------------------------------------------------
-- Elimina el procedimiento si ya existe
DROP PROCEDURE IF EXISTS consultaDinamica;
GO

-- Crea el procedimiento dinámico mejorado
CREATE PROCEDURE consultaDinamica
(
    -- Parámetro para el nombre del servidor vinculado
    @ServidorVinculado NVARCHAR(128),
    
    -- Parámetro para definir la región (debe coincidir con parte del nombre de la tabla)
    @Region NVARCHAR(50),
    
    -- Parámetro para definir el tipo de clasificación
    @Clasificacion NVARCHAR(50),
    
    -- Otros parámetros para el cálculo
    @Diabetes INT,
    @Obesidad INT,
    @Hipertension INT
)
AS
BEGIN
    -- Declaración de las cadenas SQL dinámicas
    DECLARE @SQLString NVARCHAR(MAX);
    DECLARE @QueryInterna NVARCHAR(MAX);
    DECLARE @TablaRemota NVARCHAR(256);

    /*
     * LÓGICA MEJORADA:
     * Se determina la ruta completa de la tabla remota basándose en el servidor vinculado proporcionado.
     * Esto asume que el nombre de la tabla remota siempre sigue el formato: 'datoscovid_{nombre_de_region}'.
     */
    IF @ServidorVinculado = 'LS_KARLA_VPN'
        -- Formato para el servidor SQL Server de Karla: Base.Esquema.Tabla
        SET @TablaRemota = 'CovidHistorico_.dbo.datoscovid_' + @Region;
    ELSE IF @ServidorVinculado = 'MYSQLASAP3'
        -- Formato para el servidor MySQL: Base.Tabla (se convierte la región a minúsculas)
        SET @TablaRemota = 'covid_hist.datoscovid_' + LOWER(@Region);
    ELSE IF @ServidorVinculado = 'LS_ASA_VPN'
        -- Formato para el servidor SQL Server de Asa: Base.Esquema.Tabla
        SET @TablaRemota = 'Covid_Hist.dbo.datoscovid_' + @Region;
    ELSE
    BEGIN
        -- Si el servidor no es válido, se lanza un error y se detiene la ejecución.
        RAISERROR('El servidor vinculado "%s" no tiene una configuración predefinida en este procedimiento.', 16, 1, @ServidorVinculado);
        RETURN;
    END

    -- Se construye la consulta que se ejecutará dentro de OPENQUERY
    SET @QueryInterna = 'SELECT * FROM ' + @TablaRemota;
    
    -- Se inicializa y construye la consulta dinámica principal
    SET @SQLString = N'SELECT ' +
                     N'CAST(ROUND((SUM(CASE WHEN diabetes = @Diabetes THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS DECIMAL(10,2)) AS porcentaje_diabetes, ' +
                     N'CAST(ROUND((SUM(CASE WHEN obesidad = @Obesidad THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS DECIMAL(10,2)) AS porcentaje_obesidad, ' +
                     N'CAST(ROUND((SUM(CASE WHEN hipertension = @Hipertension THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS DECIMAL(10,2)) AS porcentaje_hipertension ' +
                     N'FROM (' +
                        -- Se utiliza OPENQUERY con el servidor y la consulta interna definidos dinámicamente
                        'SELECT * FROM openquery([' + @ServidorVinculado + '], ''' + REPLACE(@QueryInterna, '''', '''''') + ''') ' +
                        'WHERE CLASIFICACION_FINAL IN (@Clasificacion)' +
                     N') AS Datos';
    
    -- Imprime la consulta para depuración (opcional)
    PRINT @SQLString;

    -- Ejecuta la consulta dinámica pasando los parámetros de forma segura
    EXEC sp_executesql @SQLString,
                       N'@Clasificacion NVARCHAR(50), @Diabetes INT, @Obesidad INT, @Hipertension INT',
                       @Clasificacion, @Diabetes, @Obesidad, @Hipertension;
END;
GO

-- Ejemplo de ejecución del nuevo procedimiento:
EXEC consultaDinamica
    @ServidorVinculado = 'LS_KARLA_VPN',  -- Se especifica el servidor vinculado
    @Region = 'Noroeste',              -- La región determina la tabla a consultar en ese servidor
    @Clasificacion = '1',
    @Diabetes = 1,
    @Obesidad = 1,
    @Hipertension = 1;
GO
