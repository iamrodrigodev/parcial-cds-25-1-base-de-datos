CREATE DATABASE IF NOT EXISTS FabiaNatura;
USE FabiaNatura;

-- Tabla de Personas
CREATE TABLE IF NOT EXISTS Personas (
    dni CHAR(8) NOT NULL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    apellido_paterno VARCHAR(20) NOT NULL,
    apellido_materno VARCHAR(20) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Teléfonos de Personas
CREATE TABLE IF NOT EXISTS Telefonos_Personas (
    telefono CHAR(9) NOT NULL PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Direcciones de Personas
CREATE TABLE IF NOT EXISTS Direcciones_Personas (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    direccion VARCHAR(100),
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Empleados
CREATE TABLE IF NOT EXISTS Empleados (
    cod_empleado INT AUTO_INCREMENT PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    contraseña VARCHAR(30),
    es_administrador BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Roles
CREATE TABLE IF NOT EXISTS Roles (
    cod_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Vendedores
CREATE TABLE IF NOT EXISTS Vendedores (
    cod_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    cod_empleado INT NOT NULL,
    cod_rol INT,
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON UPDATE CASCADE,
    FOREIGN KEY (cod_rol) REFERENCES Roles(cod_rol) ON UPDATE CASCADE
);

-- Especialidades
CREATE TABLE IF NOT EXISTS Especialidades (
    cod_especialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_especialidad VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Asesores
CREATE TABLE IF NOT EXISTS Asesores (
    cod_asesor INT AUTO_INCREMENT PRIMARY KEY,
    cod_empleado INT NOT NULL,
    experiencia INT NOT NULL,
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON UPDATE CASCADE
);

-- Asesores_Especialidades
CREATE TABLE IF NOT EXISTS Asesores_Especialidades (
    cod_asesor INT NOT NULL,
    cod_especialidad INT NOT NULL,
    PRIMARY KEY (cod_asesor, cod_especialidad),
    FOREIGN KEY (cod_asesor) REFERENCES Asesores(cod_asesor) ON UPDATE CASCADE,
    FOREIGN KEY (cod_especialidad) REFERENCES Especialidades(cod_especialidad) ON UPDATE CASCADE
);

-- Clientes
CREATE TABLE IF NOT EXISTS Clientes (
    dni CHAR(8) NOT NULL PRIMARY KEY,
    tipo_cliente ENUM('regular', 'frecuente') NOT NULL DEFAULT 'regular',
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Contratos
CREATE TABLE IF NOT EXISTS Contratos (
    cod_contrato INT AUTO_INCREMENT PRIMARY KEY,
    cod_empleado INT NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    salario_men FLOAT NOT NULL,
    observaciones TEXT,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON UPDATE CASCADE
);

-- Proveedores
CREATE TABLE IF NOT EXISTS Proveedores (
    ruc CHAR(11) NOT NULL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Teléfonos de Proveedores
CREATE TABLE IF NOT EXISTS Telefonos_Proveedores (
    ruc CHAR(11) NOT NULL,
    telefono CHAR(15) NOT NULL PRIMARY KEY,
    FOREIGN KEY (ruc) REFERENCES Proveedores(ruc) ON UPDATE CASCADE
);

-- Categorías
CREATE TABLE IF NOT EXISTS Categorias (
    cod_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Líneas
CREATE TABLE IF NOT EXISTS Lineas (
    cod_linea INT AUTO_INCREMENT PRIMARY KEY,
    ruc CHAR(11),
    nombre_linea VARCHAR(100) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ruc) REFERENCES Proveedores(ruc) ON UPDATE CASCADE
);

-- Productos
CREATE TABLE IF NOT EXISTS Productos (
    cod_producto INT AUTO_INCREMENT PRIMARY KEY,
    cod_categoria INT,
    cod_linea INT,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    precio_compra FLOAT NOT NULL,
    precio_venta FLOAT NOT NULL,
    stock INT NOT NULL,
    estado ENUM('disponible', 'agotado') NOT NULL DEFAULT 'disponible',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cod_categoria) REFERENCES Categorias(cod_categoria) ON UPDATE CASCADE,
    FOREIGN KEY (cod_linea) REFERENCES Lineas(cod_linea) ON UPDATE CASCADE
);

-- Facturas
CREATE TABLE IF NOT EXISTS Facturas (
    cod_factura INT AUTO_INCREMENT PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    cod_vendedor INT NOT NULL,
    cod_asesor INT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dni) REFERENCES Clientes(dni) ON UPDATE CASCADE,
    FOREIGN KEY (cod_vendedor) REFERENCES Vendedores(cod_vendedor) ON UPDATE CASCADE,
    FOREIGN KEY (cod_asesor) REFERENCES Asesores(cod_asesor) ON UPDATE CASCADE
);

-- Detalles de Facturas
CREATE TABLE IF NOT EXISTS Detalle_Facturas (
    cod_factura INT NOT NULL,
    cod_producto INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (cod_factura, cod_producto),
    FOREIGN KEY (cod_factura) REFERENCES Facturas(cod_factura) ON UPDATE CASCADE,
    FOREIGN KEY (cod_producto) REFERENCES Productos(cod_producto) ON UPDATE CASCADE
);