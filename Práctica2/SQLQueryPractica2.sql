use PracticaPE
---------------------------------------------------------- P R A C T I C A   2 ---------------------------------------------------------------

--INTEGRANTES EQUIPO 2--
--OCAMPO CABRERA ASAEL
--ROBERT ROA KARLA GUADALUPE
--SANCHEZ VILLAGRANA OSMAR ROBERTO
----------------------------------------------------------------------------------------------------------------------------------------------

-- 2. COPIAR TABLAS DE BASE DE DATOS ADVENTUREWORKS2022 A LA NUEVA BASE DE DATOS
-- Copiar Tabla SalesOrderHeader
select* into order_header
from AdventureWorks2022.Sales.SalesOrderHeader

select *
from order_header

-- Copiar Tabla SalesOrderDetail
select* into order_detail
from AdventureWorks2022.Sales.SalesOrderDetail

select* 
from order_detail

-- Copiar Tabla Customer
select* into customer
from AdventureWorks2022.Sales.Customer

select* 
from customer

-- Copiar Tabla SalesTerritory
select* into territory
from AdventureWorks2022.Sales.SalesTerritory

select* 
from territory

-- Copiar Tabla Product
select* into products
from AdventureWorks2022.Production.Product

select* 
from products

-- Copiar Tabla ProductCategory
select* into product_cat
from AdventureWorks2022.Production.ProductCategory

select* 
from product_cat

-- Copiar Tabla ProductSubcategory
select* into product_subcat
from AdventureWorks2022.Production.ProductSubcategory

select* 
from product_subcat

-- Copiar Tabla Person
select BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion
into person
from AdventureWorks2022.Person.Person;

select* 
from person


/*********************************************************************************************************************************************
 Número 1: a) Listar el producto más vendido de cada una de las categorías registradas en la base de datos. 

 Requisitos:
- El índice sugerido es:
CREATE NONCLUSTERED INDEX IDX_OrderDetail_Composite ON order_detail (ProductID, SalesOrderID) INCLUDE (OrderQty);
- Ejecutar la consulta con CTE para calcular el total vendido por producto y categoría.
- Obtener el producto con mayor venta dentro de cada categoría.

 Significado de los valores de los catálogos.
•	ProductCategoryID: Identificador único de cada categoría de producto.
•	Categoria: Nombre descriptivo de la categoría.
•	ProductID: Identificador único del producto.
•	Producto: Nombre descriptivo del producto.
•	TotalVendido: Suma total de la cantidad vendida por producto.

 Responsable de la consulta: Robert Roa Karla Guadalupe
	
 Comentarios: 
	La creación del índice mejora significativamente el rendimiento, evitando escaneos completos en order_detail.
	La consulta usa varias uniones y agregaciones para determinar el producto líder en ventas por categoría.
	El uso del índice compuesto y columnas incluidas permite acelerar la suma y el agrupamiento de los datos.

********************************/
create nonclustered index IDX_OrderDetail_Composite
on order_detail (ProductID, SalesOrderID) include (OrderQty);
	
WITH ProductoVentas as (
		select pc.ProductCategoryID, pc.Name as Categoria, p.ProductID, p.Name as Producto,
		sum(od.OrderQty) as TotalVendido
		from order_detail od
		inner join products p on od.ProductID = p.ProductID
		inner join product_subcat psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
		inner join product_cat pc on psc.ProductCategoryID = pc.ProductCategoryID
		group by pc.ProductCategoryID, pc.Name, p.ProductID, p.Name),
MaxVentasPorCategoria as (select ProductCategoryID, max(TotalVendido) as MaxVendido 
							from ProductoVentas
							group by ProductCategoryID)
select pv.Categoria, pv.Producto, pv.TotalVendido
from ProductoVentas pv
inner join MaxVentasPorCategoria mvpc 
on pv.ProductCategoryID = mvpc.ProductCategoryID 
and pv.TotalVendido = mvpc.MaxVendido
order by pv.Categoria;
	

/*********************************************************************************************************************************************
 Número 2: b)  Listar el nombre de los clientes con más ordenes por cada uno de los territorios registrados en la base de datos.

 Requisitos:
- Índice compuesto en order_header (TerritoryID, CustomerID) con columna incluida SalesOrderID.
- Índice simple en customer (CustomerID).
- Índice compuesto en person (BusinessEntityID) con columnas incluidas FirstName, LastName.
- Índice compuesto en territory (TerritoryID) con columna incluida Name.

 Significado de los valores de los catálogos.
•	TerritoryID: Identificador único de territorio.
•	CustomerID: Identificador único de cliente.
•	SalesOrderID: Identificador único de orden de venta.
•	FirstName, LastName: Nombre y apellido del cliente.
•	Name: Nombre del territorio.

 Responsable de la consulta: Sánchez Villagrana Osmar Roberto
	

 Comentarios: 
	Los índices propuestos permiten acelerar la agrupación, conteo y unión de tablas.
	La consulta obtiene clientes con el mayor número de órdenes en cada territorio y muestra nombres completos y territorios.
	La inclusión de columnas en índices mejora el acceso y evita lecturas adicionales.

********************************/
-- Índice optimizado para la tabla order_header
create nonclustered index IDX_OrderHeader_Territory_Customer_Include
on order_header (TerritoryID, CustomerID)
include (SalesOrderID);
GO
-- Índice simple para customer
create nonclustered index IDX_Customer_CustomerID
on customer (CustomerID);
GO
-- Índice compuesto para person
create nonclustered index IDX_Person_BusinessEntityID_Include
on person (BusinessEntityID) include (FirstName, LastName);
GO
-- Índice compuesto para territory
create nonclustered index IDX_Territory_TerritoryID_Include 
on territory (TerritoryID) include (Name);
GO

with OrdenesPorCliente as (select soh.TerritoryID, soh.CustomerID, count(soh.SalesOrderID) as NumeroOrdenes
      from order_header soh
		group by soh.TerritoryID, soh.CustomerID), MaximoPorTerritorio as
		        (select TerritoryID, max(NumeroOrdenes) as MaxOrdenes
			            from OrdenesPorCliente
      group by TerritoryID)

select t.Name as Territorio, p.FirstName + ' ' + p.LastName as Cliente, opc.NumeroOrdenes
      from OrdenesPorCliente opc
           join MaximoPorTerritorio mpt on opc.TerritoryID = mpt.TerritoryID and opc.NumeroOrdenes = mpt.MaxOrdenes
                join customer c on opc.CustomerID = c.CustomerID
                     join person p on c.PersonID = p.BusinessEntityID
                          join territory t on opc.TerritoryID = t.TerritoryID
order by Territorio;

/*********************************************************************************************************************************************
 Número 3: c)  Listar los datos generales de las ordenes que tengan al menos los mismos productos de la orden con salesorderid =  43676.

 Requisitos:
- Crear un índice no clusterizado en la tabla order_detail sobre la columna SalesOrderID para acelerar búsquedas por orden.
- La consulta utiliza la cláusula NOT EXISTS anidada para filtrar órdenes que contienen todos los productos de la orden 43676.
- Se emplea la estructura de subconsultas para comprobar que no falte ningún producto de la orden base en las otras órdenes.

 Significado de los valores de los catálogos.
•	SalesOrderID: Identificador único de cada orden de venta.
•	ProductID: Identificador único de cada producto.
La consulta busca órdenes que sean un superconjunto de productos de una orden específica.	

 Responsable de la consulta: Asael Ocampo Cabrera
	
 Comentarios: 
	La creación del índice mejora el acceso a las filas correspondientes a cada orden, evitando escaneos completos de la tabla.
	La consulta puede ser costosa en tablas grandes debido a la naturaleza de NOT EXISTS anidado, pero el índice mitiga este impacto.
	Se recomienda mantener estadísticas actualizadas para un óptimo plan de ejecución.

********************************/

create nonclustered index IDX_OrderDetail_SalesOrderID
on order_detail(SalesOrderID);

select distinct Salesorderid
from Order_Detail as OD	
where not exists (select *
					from (select productid
					from Order_Detail 
					where salesorderid=43676) as P
					where not exists (select *
										from Order_Detail  as OD2
										where OD.salesorderid = OD2.salesorderid
										and (OD2.productid = P.productid)));
