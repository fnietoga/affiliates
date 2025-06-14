-- V1__Create_Database.sql
-- Script to create the complete database from scratch

-- Create the database (uncomment and adapt this if you need to create the database with Flyway)
-- CREATE DATABASE affiliates;
-- GO
-- USE affiliates;
-- GO

-- 1. Affiliates table
CREATE TABLE affiliates (
    person_id INT PRIMARY KEY,                    -- D.P. - ID Persona / D.P. - Cod. Persona (Person ID)
    affiliate_number VARCHAR(50) UNIQUE,          -- Afiliado - N. Afiliado (Affiliate Number)
    affiliate_date DATE,                          -- Afiliado - Fecha Afiliacion (Affiliation Date)
    online_registration BIT DEFAULT 0,            -- Afiliado - Alta Online (Online Registration)
    nngg BIT DEFAULT 0,                           -- Afiliado - NNGG (Youth Organization)
    notes NVARCHAR(MAX),                          -- Afiliado - Notas (Notes)
    participation NVARCHAR(MAX),                  -- Afiliado - Participacion (Participation)
    affiliate_type VARCHAR(50),                   -- Afiliado - Tipo Afiliado (Affiliate Type)
    guarantor1_dni VARCHAR(20),                   -- Aval 1 Dni (Guarantor 1 ID)
    guarantor2_dni VARCHAR(20),                   -- Aval 2 Dni (Guarantor 2 ID)
    postal_code VARCHAR(10),                      -- D. Residencia - C.P. (Postal Code)
    street_address NVARCHAR(255),                 -- D. Residencia - Direccion (Street Address)
    stair VARCHAR(10),                            -- D. Residencia - Escalera (Stair)
    letter VARCHAR(10),                           -- D. Residencia - Letra (Letter)
    city NVARCHAR(100),                           -- D. Residencia - Localidad (City)
    street_number VARCHAR(20),                    -- D. Residencia - Número (Street Number)
    floor VARCHAR(10),                            -- D. Residencia - Piso (Floor)
    gate VARCHAR(10),                             -- D. Residencia - Portal (Gate)
    province NVARCHAR(100),                       -- D. Residencia - Provincia (Province)
    road_type VARCHAR(50),                        -- D. Residencia - Via (Road Type)
    last_name NVARCHAR(100),                      -- D.P. - Apellidos (Last Name)
    first_name NVARCHAR(100),                     -- D.P. - Nombre (First Name)
    dni VARCHAR(20) UNIQUE,                       -- D.P. - Dni (National ID)
    email NVARCHAR(255),                          -- D.P. - Email (Email)
    education NVARCHAR(255),                      -- D.P. - Estudios (Education)
    profession NVARCHAR(255),                     -- D.P. - Profesión (Profession)
    birth_date DATE,                              -- D.P. - Fecha Nacimiento (Birth Date)
    nationality NVARCHAR(100),                    -- D.P. - Nacionalidad (Nationality)
    gender VARCHAR(20),                           -- D.P. - Sexo (Gender)
    mobile_phone VARCHAR(20),                     -- D.P. - Telefono Movil (Mobile Phone)
    phone VARCHAR(20),                            -- D.P. - Telefono
    work_phone VARCHAR(20),                       -- D.P. - Telefono trabajo (Work Phone)
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

-- 2. Dues table
CREATE TABLE dues (
    due_id INT IDENTITY(1,1) PRIMARY KEY,
    person_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    due_type VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'Pending',
    payment_date DATE,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_dues_affiliates FOREIGN KEY (person_id) REFERENCES affiliates(person_id)
);

-- 3. Receipts table
CREATE TABLE receipts (
    receipt_id INT IDENTITY(1,1) PRIMARY KEY,
    receipt_code VARCHAR(50) UNIQUE,              -- Recibo - Cod. Recibo (Receipt Code)
    person_id INT NOT NULL,                       -- D.P. - Cod. Persona (Person ID)
    person_dni VARCHAR(20),                       -- D.P. - Dni (National ID)
    person_last_name NVARCHAR(100),               -- D.P. - Apellidos (Last Name)
    person_first_name NVARCHAR(100),              -- D.P. - Nombre (First Name)
    batch_number VARCHAR(50),                     -- Recibo - Remesa (Batch Number)
    bank VARCHAR(100),                            -- Recibo - Banco (Bank)
    issue_date DATE,                              -- Recibo - Fecha Emision (Issue Date)
    payment_date DATE,                            -- Recibo - Fecha Pago (Payment Date)
    payment_method VARCHAR(50),                   -- Recibo - Forma Pago (Payment Method)
    amount DECIMAL(10,2) NOT NULL,                -- Recibo - Importe (Amount)
    status VARCHAR(50),                           -- Recibo - Estado (Status)
    comments NVARCHAR(MAX),                       -- Recibo - Comentarios (Comments)
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_receipts_affiliates FOREIGN KEY (person_id) REFERENCES affiliates(person_id)
);

-- 4. Events master table
CREATE TABLE events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    event_name NVARCHAR(255) NOT NULL,
    event_description NVARCHAR(MAX),
    event_date DATETIME2 NOT NULL,
    location NVARCHAR(255),
    max_participants INT,
    active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

-- 5. Event participation table
CREATE TABLE event_participation (
    participation_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL,
    person_id INT NOT NULL,
    registration_date DATETIME2 DEFAULT GETUTCDATE(),
    attendance_status VARCHAR(50) DEFAULT 'Registered', -- Status options: Registered, Attended, Cancelled, No-show
    comments NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_event_participation_events FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT FK_event_participation_affiliates FOREIGN KEY (person_id) REFERENCES affiliates(person_id),
    CONSTRAINT UQ_event_person UNIQUE (event_id, person_id)
);

-- 6. Excel column mappings table
CREATE TABLE excel_column_mappings (
    mapping_id INT IDENTITY(1,1) PRIMARY KEY,
    source_table VARCHAR(50) NOT NULL,           -- 'affiliates' or 'receipts'
    excel_column_name NVARCHAR(255) NOT NULL,    -- Original Excel column name
    db_column_name VARCHAR(100) NOT NULL,        -- Database column name
    column_order INT,                            -- Excel column order
    data_type VARCHAR(50),                       -- Data type
    is_required BIT DEFAULT 0,                   -- Whether required for import
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_source_excel_column UNIQUE (source_table, excel_column_name)
);

-- 7. Populate the column mapping table with member data
INSERT INTO excel_column_mappings (source_table, excel_column_name, db_column_name, column_order, data_type, is_required)
VALUES
-- Mappings for affiliates
('affiliates', 'D.P. - ID Persona', 'person_id', 1, 'INT', 1),
('affiliates', 'Afiliado - N. Afiliado', 'affiliate_number', 2, 'VARCHAR', 1),
('affiliates', 'Afiliado - Fecha Afiliacion', 'affiliate_date', 3, 'DATE', 1),
('affiliates', 'Afiliado - Alta Online', 'online_registration', 4, 'BIT', 0),
('affiliates', 'Afiliado - NNGG', 'nngg', 5, 'BIT', 0),
('affiliates', 'Afiliado - Notas', 'notes', 6, 'NVARCHAR', 0),
('affiliates', 'Afiliado - Participacion', 'participation', 7, 'NVARCHAR', 0),
('affiliates', 'Afiliado - Tipo Afiliado', 'affiliate_type', 8, 'VARCHAR', 0),
('affiliates', 'Aval 1 Dni', 'guarantor1_dni', 9, 'VARCHAR', 0),
('affiliates', 'Aval 2 Dni', 'guarantor2_dni', 10, 'VARCHAR', 0),
('affiliates', 'D. Residencia - C.P.', 'postal_code', 11, 'VARCHAR', 0),
('affiliates', 'D. Residencia - Direccion', 'street_address', 12, 'NVARCHAR', 0),
('affiliates', 'D. Residencia - Escalera', 'stair', 13, 'VARCHAR', 0),
('affiliates', 'D. Residencia - Letra', 'letter', 14, 'VARCHAR', 0),
('affiliates', 'D. Residencia - Localidad', 'city', 15, 'NVARCHAR', 0),
('affiliates', 'D. Residencia - Número', 'street_number', 16, 'VARCHAR', 0),
('affiliates', 'D. Residencia - Piso', 'floor', 17, 'VARCHAR', 0),
('affiliates', 'D. Residencia - Portal', 'gate', 18, 'VARCHAR', 0),
('affiliates', 'D. Residencia - Provincia', 'province', 19, 'NVARCHAR', 0),
('affiliates', 'D. Residencia - Via', 'road_type', 20, 'VARCHAR', 0),
('affiliates', 'D.P. - Apellidos', 'last_name', 21, 'NVARCHAR', 1),
('affiliates', 'D.P. - Nombre', 'first_name', 22, 'NVARCHAR', 1),
('affiliates', 'D.P. - Dni', 'dni', 23, 'VARCHAR', 1),
('affiliates', 'D.P. - Email', 'email', 24, 'NVARCHAR', 0),
('affiliates', 'D.P. - Estudios', 'education', 25, 'NVARCHAR', 0),
('affiliates', 'D.P. - Profesión', 'profession', 26, 'NVARCHAR', 0),
('affiliates', 'D.P. - Fecha Nacimiento', 'birth_date', 27, 'DATE', 0),
('affiliates', 'D.P. - Nacionalidad', 'nationality', 28, 'NVARCHAR', 0),
('affiliates', 'D.P. - Sexo', 'gender', 29, 'VARCHAR', 0),
('affiliates', 'D.P. - Telefono Movil', 'mobile_phone', 30, 'VARCHAR', 0),
('affiliates', 'D.P. - Telefono', 'phone', 31, 'VARCHAR', 0),
('affiliates', 'D.P. - Telefono trabajo', 'work_phone', 32, 'VARCHAR', 0);

-- 8. Populate the column mapping table with receipt data
INSERT INTO excel_column_mappings (source_table, excel_column_name, db_column_name, column_order, data_type, is_required)
VALUES
-- Mappings for receipts
('receipts', 'D.P. - Cod. Persona', 'person_id', 1, 'INT', 1),
('receipts', 'D.P. - Dni', 'person_dni', 2, 'VARCHAR', 0),
('receipts', 'D.P. - Apellidos', 'person_last_name', 3, 'NVARCHAR', 0),
('receipts', 'D.P. - Nombre', 'person_first_name', 4, 'NVARCHAR', 0),
('receipts', 'Recibo - Remesa', 'batch_number', 5, 'VARCHAR', 0),
('receipts', 'Recibo - Cod. Recibo', 'receipt_code', 6, 'VARCHAR', 1),
('receipts', 'Recibo - Banco', 'bank', 7, 'VARCHAR', 0),
('receipts', 'Recibo - Fecha Emision', 'issue_date', 8, 'DATE', 0),
('receipts', 'Recibo - Fecha Pago', 'payment_date', 9, 'DATE', 0),
('receipts', 'Recibo - Forma Pago', 'payment_method', 10, 'VARCHAR', 0),
('receipts', 'Recibo - Importe', 'amount', 11, 'DECIMAL', 1),
('receipts', 'Recibo - Estado', 'status', 12, 'VARCHAR', 0),
('receipts', 'Recibo - Comentarios', 'comments', 13, 'NVARCHAR', 0);

-- Indexes to improve performance
CREATE INDEX IX_affiliates_dni ON affiliates(dni);
CREATE INDEX IX_affiliates_affiliate_number ON affiliates(affiliate_number);
CREATE INDEX IX_affiliates_last_first_name ON affiliates(last_name, first_name);
CREATE INDEX IX_dues_person_id ON dues(person_id);
CREATE INDEX IX_receipts_person_id ON receipts(person_id);
CREATE INDEX IX_receipts_receipt_code ON receipts(receipt_code);
CREATE INDEX IX_event_participation_event_id ON event_participation(event_id);
CREATE INDEX IX_event_participation_person_id ON event_participation(person_id);
