DROP TABLE Ciudad_P CASCADE;
DROP TABLE Usuario CASCADE;
DROP TABLE EntidadB CASCADE;
DROP TABLE TarjetaPago CASCADE;
DROP TABLE Estaciones CASCADE;
DROP TABLE Tarjeta CASCADE;
DROP TABLE Turno CASCADE;
DROP TABLE Uso CASCADE;
DROP TABLE Vendedor CASCADE;
DROP TABLE Venta CASCADE;
DROP TABLE Recargas CASCADE;


CREATE TABLE IF NOT EXISTS Ciudad_P(
	id_ciudad integer PRIMARY KEY CHECK (id_ciudad <=9999),
	nomb_ciudad varchar(25) NOT NULL
	);


CREATE TABLE IF NOT EXISTS Usuario (
	nombreUsr varchar(25) NOT NULL, 
	cedula_usr integer PRIMARY KEY, 
	dir_usr  varchar(35),
	tel_usr integer CHECK (tel_usr <=9999999),
	email  varchar(35),
	id_ciudad integer REFERENCES Ciudad_P(id_ciudad) NOT NULL CHECK(id_ciudad <=9999)
	);

CREATE TABLE IF NOT EXISTS TarjetaPago (
	id_tarjetaP integer PRIMARY KEY CHECK (id_tarjetaP <= 99999999), 
	tipo_tarjeP varchar(15) NOT NULL CHECK(tipo_tarjeP IN ('credito','debito')), 
	saldoPago  integer
	);

CREATE TABLE IF NOT EXISTS EntidadB (
	id_tarjetaP integer REFERENCES TarjetaPago(id_tarjetaP) CHECK (id_tarjetaP <= 99999999),
	nro_aprobacion  integer NOT NULL CHECK (nro_aprobacion <= 99999),
	id_entidad integer PRIMARY KEY CHECK (id_entidad <=99), 
	nombre_entidad varchar(15) NOT NULL 
	);


CREATE TABLE IF NOT EXISTS Estaciones (
	id_estacion integer PRIMARY KEY CHECK (id_estacion <= 999), 
	direccion_est varchar(25), 
	telef_est  integer CHECK (telef_est <= 9999999),
	id_ciudad integer REFERENCES Ciudad_P(id_ciudad) NOT NULL CHECK(id_ciudad <=9999)
	);

CREATE TABLE IF NOT EXISTS Tarjeta (
	id_tarjeta integer PRIMARY KEY CHECK (id_tarjeta <= 9999), 
	tipo_tarjeta varchar(15) NOT NULL CHECK(tipo_tarjeta IN ('recargable','unica')),
	saldo integer CHECK (saldo <= 99999999),
	cedula_usr integer REFERENCES Usuario(cedula_usr) CHECK (cedula_usr<= 99999999) 
	);

CREATE TABLE IF NOT EXISTS Vendedor (
	id_vendedor integer PRIMARY KEY CHECK (id_vendedor <= 99999), 
	nombreV varchar(35) NOT NULL, 
	dir_vend VARCHAR(35),
	id_ciudad integer REFERENCES Ciudad_P(id_ciudad) NOT NULL CHECK(id_ciudad <=9999),
	telef_vend integer CHECK (telef_vend <= 9999999)
	);

CREATE TABLE IF NOT EXISTS Turno (
	hora_inicio time without time zone,
	hora_final time without time zone,
	id_turno integer PRIMARY KEY CHECK (id_turno <= 999), 
	id_vendedor integer REFERENCES Vendedor(id_vendedor) NOT NULL CHECK(id_vendedor <= 99999), 
	id_estacion integer REFERENCES Estaciones(id_estacion) NOT NULL CHECK (id_estacion <= 999),
	dia_turno date
	);

CREATE TABLE IF NOT EXISTS Uso (
    id_uso integer PRIMARY KEY CHECK (id_uso <= 999), 
	id_estacion integer REFERENCES Estaciones(id_estacion) NOT NULL CHECK(id_estacion <= 999), 
	id_tarjeta integer REFERENCES Tarjeta(id_tarjeta) NOT NULL CHECK (id_tarjeta <= 9999),
	fecha_uso Date
	);


CREATE TABLE IF NOT EXISTS Venta (
	id_tarjeta integer REFERENCES Tarjeta(id_tarjeta) NOT NULL CHECK(id_tarjeta <=9999),
	id_vendedor integer REFERENCES Vendedor(id_vendedor) NOT NULL CHECK(id_vendedor <=99999),
	fecha_venta Date, 
	id_estacion integer REFERENCES Estaciones(id_estacion) NOT NULL CHECK(id_estacion <=999),
	tipo_compra VARCHAR(15) NOT NULL CHECK(tipo_compra IN ('tarjeta','efectivo')),
	id_tarjetaP integer REFERENCES TarjetaPago(id_tarjetaP) NOT NULL CHECK(id_tarjetaP <=99999999),
    id_venta integer PRIMARY KEY CHECK (id_venta <= 999) 
	);

CREATE TABLE IF NOT EXISTS Recargas (
    id_recarga integer PRIMARY KEY CHECK (id_recarga <= 99),  
	tipo_recarga VARCHAR(15) NOT NULL CHECK(tipo_recarga IN ('Tarjeta','Efectivo')),
	valor_recarga integer  NOT NULL CHECK(valor_recarga <=99999),
	id_tarjeta integer REFERENCES Tarjeta(id_tarjeta) NOT NULL CHECK(id_tarjeta <=9999),
	id_turno integer REFERENCES Turno(id_turno) NOT NULL CHECK(id_turno <=999)
	);



\COPY Ciudad_P FROM Ciudad_P.csv WITH (delimiter ',', header, format csv);
\COPY Usuario FROM Usuario.csv WITH(delimiter ',', header, format csv);
\COPY TarjetaPago FROM TarjetaPago.csv WITH(delimiter ',', header, format csv);
\COPY EntidadB FROM EntidadB.csv WITH(delimiter ',', header, format csv);
\COPY Estaciones FROM Estaciones.csv WITH(delimiter ',', header, format csv);
\COPY Tarjeta FROM Tarjeta.csv WITH(delimiter ',', header, format csv);
\COPY Vendedor FROM Vendedor.csv WITH(delimiter ',', header, format csv);
\COPY Turno FROM Turno.csv WITH(delimiter ',', header, format csv);
\COPY Uso FROM Uso.csv WITH(delimiter ',', header, format csv);
\COPY Venta FROM Venta.csv WITH(delimiter ',', header, format csv);
\COPY Recargas FROM Recargas.csv WITH(delimiter ',', header, format csv);


#A)

#Recargas de vendedor
#select recargas.id_recarga, recargas.valor_recarga, vendedor.id_vendedor from recargas NATURAL JOIN turno NATURAL JOIN vendedor;

#Ventas de vendedor
#select venta.id_venta, tarjeta.id_tarjeta, vendedor.id_vendedor from venta NATURAL JOIN tarjeta NATURAL JOIN vendedor;


#select * from
#(select recargas.id_recarga, recargas.valor_recarga, vendedor.id_vendedor as id_vendedor from recargas NATURAL JOIN turno NATURAL JOIN vendedor) as a1
#FULL JOIN
#(select venta.id_venta, tarjeta.id_tarjeta, vendedor.id_vendedor as id_vendedor from venta NATURAL JOIN tarjeta NATURAL JOIN vendedor) as a2
#on a1.id_vendedor=a2.id_vendedor
#;


CREATE OR REPLACE FUNCTION Ident_seller (
	idV integer, dateV date
	) RETURNS TABLE
	(
		id_recarga integer,
		valor_recarga integer,
		id_vendedor integer,
		id_venta integer,
		id_tarjeta integer
	)
	AS $$
	BEGIN RETURN QUERY
	select * from
	(select recargas.id_recarga, recargas.valor_recarga, vendedor.id_vendedor as id_vendedor from recargas NATURAL JOIN turno NATURAL JOIN vendedor) as a1
	FULL JOIN
	(select venta.id_venta, tarjeta.id_tarjeta, vendedor.id_vendedor as id_vendedor, venta.fecha_venta as fecha_venta from venta NATURAL JOIN tarjeta NATURAL JOIN vendedor) as a2
	on a1.id_vendedor=a2.id_vendedor
	WHERE (idV=a2.id_vendedor AND dateV=a2.fecha_venta) OR (idV=a1.id_vendedor);
	END; $$
	LANGUAGE 'plpgsql';



#B)

CREATE OR REPLACE FUNCTION list_turn (
	fventa date
	) RETURNS TABLE
	(
		id_vendedo integer,
		nombrev varchar(35)
	)
	AS $$
	BEGIN RETURN QUERY
	select vendedor.id_vendedor, vendedor.nombrev from turno NATURAL JOIN vendedor
	WHERE fventa=turno.dia_turno;
	END; $$
	LANGUAGE 'plpgsql';



#C)

#tarjeta INNER JOIN usuario USING (cedula_usr) 

#D)

#E)


#Cada turno con su respectivo vendedor
#select turno.id_turno, vendedor.id_vendedor


#F)

#Promedio de ventas de cada vendedor

#select
#vendedor.nombrev,
#vendedor.id_vendedor
#AVG(cosa.sum_valor_recarga)
#from
#(select
#	 turno.id_turno as id_turno,
#	 turno.id_vendedor as id_vendedor,
#	 SUM(recarga.valor_recargas) as sum_valor_recarga
#	 from recarga LEFT JOIN turno on recargas.id_turno=turno.id_turno
#	 group by turno.id_turno) as cosa
#LEFT JOIN
#vendedor
#on cosa.id_vendedor=vendedor.id_vendedor
#group by vendedor.id_vendedor;
	 


#Promedio de ventas de cada vendedor
#select vendedor.nombrev as nombrev, vendedor.id_vendedor as id_vendedor, AVG(cosa.sum_valor_recarga) as avg_recargas from (select turno.id_turno as id_turno, turno.id_vendedor as id_vendedor, SUM(recargas.valor_recarga) as sum_valor_recarga from recargas LEFT JOIN turno on recargas.id_turno=turno.id_turno group by turno.id_turno) as cosa LEFT JOIN vendedor on cosa.id_vendedor=vendedor.id_vendedor group by vendedor.id_vendedor;

#Promedio de ventas entre todos los vendedores
#select AVG(prompervend.avg_recargas) as avgtodos from (select vendedor.nombrev, vendedor.id_vendedor, AVG(cosa.sum_valor_recarga) as avg_recargas from (select turno.id_turno as id_turno, turno.id_vendedor as id_vendedor, SUM(recargas.valor_recarga) as sum_valor_recarga from recargas LEFT JOIN turno on recargas.id_turno=turno.id_turno group by turno.id_turno) as cosa LEFT JOIN vendedor on cosa.id_vendedor=vendedor.id_vendedor group by vendedor.id_vendedor) as prompervend;

#Vendedores que venden menos que el promedio
select promvend.nombrev, promvend.id_vendedor, promvend.avg_recargas from 
(select vendedor.nombrev as nombrev, vendedor.id_vendedor as id_vendedor, AVG(cosa.sum_valor_recarga) as avg_recargas from (select turno.id_turno as id_turno, turno.id_vendedor as id_vendedor, SUM(recargas.valor_recarga) as sum_valor_recarga from recargas LEFT JOIN turno on recargas.id_turno=turno.id_turno group by turno.id_turno) as cosa LEFT JOIN vendedor on cosa.id_vendedor=vendedor.id_vendedor group by vendedor.id_vendedor)
as promvend
,
(select AVG(prompervend.avg_recargas) as avgtodos from (select vendedor.nombrev, vendedor.id_vendedor, AVG(cosa.sum_valor_recarga) as avg_recargas from (select turno.id_turno as id_turno, turno.id_vendedor as id_vendedor, SUM(recargas.valor_recarga) as sum_valor_recarga from recargas LEFT JOIN turno on recargas.id_turno=turno.id_turno group by turno.id_turno) as cosa LEFT JOIN vendedor on cosa.id_vendedor=vendedor.id_vendedor group by vendedor.id_vendedor) as prompervend)
as promtodos
where promvend.avg_recargas<promtodos.avgtodos;


#G)