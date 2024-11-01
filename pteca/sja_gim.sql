-- Crear la base de datos sja_gim
create database sja_gim;
use sja_gim;

-- Crear tabla Rol
create table Rol
(
    IdRol int not null auto_increment,
    DescripcionRol varchar(45) not null,
    primary key (IdRol)
);

-- Crear tabla Estado
create table Estado
(
    IdEstado int not null auto_increment,
    DescripcionEstado varchar(45) not null,
    primary key (IdEstado)
);

-- Crear tabla Usuario
create table Usuario
(
    IdUsuario int not null auto_increment,
    NombreUsuario varchar(45) not null,
    Apellido varchar(45) not null,
    Correo varchar(100) not null,
    Clave varchar(200) not null,
    PalabraClave varchar(200) not null,
    Rol_IdRol int not null,
    Estado_idEstado int not null,
    primary key (IdUsuario),
    foreign key (Rol_IdRol) references Rol (IdRol) on update cascade ,
    foreign key (Estado_idEstado) references Estado (IdEstado) on update cascade 
);

-- Crear tabla Categoria
create table Categoria
(
    IdCategoria int not null auto_increment,
    DescripcionCategoria varchar(45) not null,
    primary key (IdCategoria)
);

-- Crear tabla Unidad_Medida
create table Unidad_Medida
(
    IdUnidadMedida int not null auto_increment,
    UnidadMedida varchar(45) not null,
    primary key (IdUnidadMedida)
);

-- Crear tabla Producto_Materia_Prima
create table Producto_Materia_Prima
(
    IdProductoMateriaPrima int not null auto_increment,
    NombreProducto varchar(45) not null,
    DescripcionProductoMateriaPrima varchar(45) not null,
    IdCategoria int not null,
    IdUnidadMedida int not null,
    primary key (IdProductoMateriaPrima),
    foreign key (IdCategoria) references Categoria (IdCategoria),
    foreign key (IdUnidadMedida) references Unidad_Medida (IdUnidadMedida) ON DELETE CASCADE
);

-- Crear tabla Motivo
CREATE TABLE Motivo
(
    IdMotivo INT NOT NULL AUTO_INCREMENT,
    DescripcionMovimiento VARCHAR(45) NOT NULL,
    PRIMARY KEY (IdMotivo)
);

-- Crear tabla Movimiento
CREATE TABLE Movimiento
(
    IdMovimiento INT NOT NULL AUTO_INCREMENT,
    FechaMovimiento DATETIME,
    SolicitanteEquipo varchar(90) NOT NULL,
    CorreoSolicitante varchar(100) NOT NULL UNIQUE,
    TelefonoSolicitante varchar(10) NOT NULL,
    CantidadProducto INT NOT NULL,
    IdMotivo INT NOT NULL,
    IdProductoMateriaPrima INT NOT NULL,
    IdUsuario INT NOT NULL,
    TipoMovimiento ENUM('Entrada', 'Salida') NOT NULL,
    PRIMARY KEY (IdMovimiento),
    FOREIGN KEY (IdMotivo) REFERENCES Motivo (IdMotivo) ON UPDATE CASCADE ,
    FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario) ON UPDATE CASCADE ,
    FOREIGN KEY (IdProductoMateriaPrima) REFERENCES Producto_Materia_Prima (IdProductoMateriaPrima) ON DELETE CASCADE
);

-- Crear tabla Existencias
CREATE TABLE IF NOT EXISTS Existencias
(
    IdExistencias INT NOT NULL AUTO_INCREMENT,
    CantidadExistencias INT NOT NULL CHECK (CantidadExistencias >= 0),
    PuntoCompraProducto INT NOT NULL,
    FechaUltimaModificacion DATETIME NOT NULL,
    IdProductoMateriaPrima INT NOT NULL,
    PRIMARY KEY (IdExistencias, IdProductoMateriaPrima),
    FOREIGN KEY (IdProductoMateriaPrima) REFERENCES Producto_Materia_Prima (IdProductoMateriaPrima) ON DELETE CASCADE
);


-- Crear tabla Reportes
CREATE TABLE Reportes
(
    IdReporte INT NOT NULL AUTO_INCREMENT,
    IdProductoMateriaPrima INT NOT NULL,
    TotalVendido INT NOT NULL,
    PRIMARY KEY (IdReporte),
    FOREIGN KEY (IdProductoMateriaPrima) REFERENCES Producto_Materia_Prima (IdProductoMateriaPrima)
);

-- Trigger para actualizar existencias
DELIMITER //
CREATE TRIGGER tr_actualizar_existencias AFTER INSERT ON Movimiento
FOR EACH ROW
BEGIN
    DECLARE factor INT;

    IF NEW.TipoMovimiento = 'Entrada' THEN
        SET factor = 1;
    ELSE
        SET factor = -1;
    END IF;

    UPDATE Existencias
    SET CantidadExistencias = CantidadExistencias + (NEW.CantidadProducto * factor),
        FechaUltimaModificacion = CURRENT_DATE
    WHERE IdProductoMateriaPrima = NEW.IdProductoMateriaPrima;
END;
//
DELIMITER ;

-- Insertar datos de prueba en la tabla Rol
INSERT INTO Rol (DescripcionRol) VALUES
    ('Administrador'),
    ('Docente/Encargado');

-- Insertar datos de prueba en la tabla Estado
INSERT INTO Estado (DescripcionEstado) VALUES
    ('Activo'),
    ('Inactivo');

-- Insertar datos de prueba en la tabla Usuario
INSERT INTO Usuario (NombreUsuario, Apellido, Correo, Clave, PalabraClave, Rol_IdRol, Estado_idEstado) VALUES
    ('juan123', 'Pérez', 'juan@example.com', 'clave123','PAZ', 1, 1),
    ('ana456', 'López', 'ana@example.com', 'clave456','PAIS', 2, 2),
    ('carlos789', 'Gómez', 'J@E.com', 'a0aa2a69c1a92bd3343b37d1a900c980','CONTROL', 1, 1);

-- Insertar datos en la tabla Categoria
INSERT INTO Categoria (DescripcionCategoria) VALUES
('Cardio'),
('Fuerza'),
('Flexibilidad'),
('Recreación');

-- Insertar datos en la tabla Unidad_Medida
INSERT INTO Unidad_Medida (UnidadMedida) VALUES
('Metro'),
('Kilogramo'),
('Unidades');

-- Insertar datos en la tabla Producto_Materia_Prima
INSERT INTO Producto_Materia_Prima (NombreProducto, DescripcionProductoMateriaPrima, IdCategoria, IdUnidadMedida) VALUES 
('Cinta de Correr', 'Cinta para correr, ideal para ejercicios de cardio.', 1, 1), 
('Mancuernas', 'Mancuernas ajustables para entrenamiento de fuerza.', 2, 1), 
('Colchoneta', 'Colchoneta para ejercicios de flexibilidad y estiramiento.', 3, 1), 
('Bicicleta Estática', 'Bicicleta para entrenamientos de resistencia.', 1, 1), 
('Máquina de Pesas', 'Máquina multifuncional para entrenamiento de fuerza.', 2, 1);

-- Trigger para insertar automáticamente en Existencias después de INSERT en Producto_Materia_Prima
DELIMITER //
CREATE TRIGGER tr_insertar_existencias_after_insert AFTER INSERT ON Producto_Materia_Prima
FOR EACH ROW
BEGIN
    INSERT INTO Existencias (IdProductoMateriaPrima, CantidadExistencias, PuntoCompraProducto, FechaUltimaModificacion)
    VALUES (NEW.IdProductoMateriaPrima, 0, 50, CURRENT_DATE);
END;
//
DELIMITER ;

-- Insertar datos en la tabla Motivo
INSERT INTO Motivo (DescripcionMovimiento) VALUES
('Compra'),
('Prestamo'),
('Devolución');

-- Insertar datos en la tabla Movimiento
INSERT INTO Movimiento (FechaMovimiento, SolicitanteEquipo, CorreoSolicitante, TelefonoSolicitante, CantidadProducto, IdMotivo, IdProductoMateriaPrima, IdUsuario, TipoMovimiento) VALUES
('2023-01-15', 5, 1, 1, 1, 'Entrada'),
('2023-01-17', 3, 2, 2, 2, 'Salida');

-- Insertar datos en la tabla Existencias
INSERT INTO Existencias (CantidadExistencias, PuntoCompraProducto, FechaUltimaModificacion, IdProductoMateriaPrima) VALUES
(10, 5, '2023-01-17', 1), 
(8, 3, '2023-01-17', 2), 
(15, 7, '2023-01-17', 3), 
(5, 4, '2023-01-17', 4), 
(20, 2, '2023-01-17', 5);