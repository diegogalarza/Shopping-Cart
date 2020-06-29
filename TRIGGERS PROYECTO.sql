




CREATE OR REPLACE FUNCTION HOLI() RETURNS TRIGGER AS $$
	BEGIN
		#FALTA CONDICIONAL DEL PUNTO A
		IF Tarjeta.saldo <= 0 THEN
			RAISE NOTICE 'Usted no tiene saldo disponible\n';

		ELSIF Turno.hora_final < current_timestamp 
		AND Turno.dia_turno != current_date THEN
			RAISE NOTICE 'No se puede registrar la venta\n';
		END IF;
	END; $$ LANGUAGE 'plpgsql';

CREATE TRIGGER HOLI2 BEFORE INSERT ON Turno FOR EACH ROW
EXCECUTE PROCEDURE HOLI();