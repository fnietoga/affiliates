# Database Schema Documentation

This document describes the structure of the database for the Affiliates Management Application.

## Tables Overview

The database consists of the following primary tables:

1. **affiliates** - Contains personal and affiliation information
2. **dues** - Tracks membership dues/fees for affiliates
3. **receipts** - Records payment receipts
4. **events** - Master table of organization events
5. **event_participation** - Records affiliate participation in events
6. **excel_column_mappings** - Maps Excel columns to database fields for importing data

## Detailed Table Descriptions

### affiliates

Stores the main information about each affiliate.

| Column              | Type           | Description                                   | Original Excel Column             |
|---------------------|----------------|-----------------------------------------------|----------------------------------|
| person_id           | INT            | Primary key identifying the affiliate         | D.P. - ID Persona                |
| affiliate_number    | VARCHAR(50)    | Unique number assigned to affiliate           | Afiliado - N. Afiliado          |
| affiliate_date      | DATE           | Date when the person became an affiliate      | Afiliado - Fecha Afiliacion     |
| online_registration | BIT            | Whether registered online (1) or not (0)      | Afiliado - Alta Online          |
| nngg                | BIT            | Youth organization membership                 | Afiliado - NNGG                 |
| notes               | NVARCHAR(MAX)  | General notes about the affiliate             | Afiliado - Notas                |
| participation       | NVARCHAR(MAX)  | Participation notes                           | Afiliado - Participacion        |
| affiliate_type      | VARCHAR(50)    | Type of affiliate                             | Afiliado - Tipo Afiliado        |
| guarantor1_dni      | VARCHAR(20)    | ID number of the first guarantor              | Aval 1 Dni                      |
| guarantor2_dni      | VARCHAR(20)    | ID number of the second guarantor             | Aval 2 Dni                      |
| postal_code         | VARCHAR(10)    | Postal code of residence                      | D. Residencia - C.P.            |
| street_address      | NVARCHAR(255)  | Street address                                | D. Residencia - Direccion       |
| stair               | VARCHAR(10)    | Stair identifier                              | D. Residencia - Escalera        |
| letter              | VARCHAR(10)    | Apartment letter                              | D. Residencia - Letra           |
| city                | NVARCHAR(100)  | City of residence                             | D. Residencia - Localidad       |
| street_number       | VARCHAR(20)    | Street number                                 | D. Residencia - Número          |
| floor               | VARCHAR(10)    | Floor number                                  | D. Residencia - Piso            |
| gate                | VARCHAR(10)    | Gate or portal identifier                     | D. Residencia - Portal          |
| province            | NVARCHAR(100)  | Province                                      | D. Residencia - Provincia       |
| road_type           | VARCHAR(50)    | Type of road (street, avenue, etc.)           | D. Residencia - Via             |
| last_name           | NVARCHAR(100)  | Last name                                     | D.P. - Apellidos                |
| first_name          | NVARCHAR(100)  | First name                                    | D.P. - Nombre                   |
| dni                 | VARCHAR(20)    | National identification number                | D.P. - Dni                      |
| email               | NVARCHAR(255)  | Email address                                 | D.P. - Email                    |
| education           | NVARCHAR(255)  | Education level                               | D.P. - Estudios                 |
| profession          | NVARCHAR(255)  | Professional occupation                       | D.P. - Profesión                |
| birth_date          | DATE           | Date of birth                                 | D.P. - Fecha Nacimiento         |
| nationality         | NVARCHAR(100)  | Nationality                                   | D.P. - Nacionalidad             |
| gender              | VARCHAR(20)    | Gender                                        | D.P. - Sexo                     |
| mobile_phone        | VARCHAR(20)    | Mobile phone number                           | D.P. - Telefono Movil           |
| phone               | VARCHAR(20)    | Home phone number                             | D.P. - Telefono                 |
| work_phone          | VARCHAR(20)    | Work phone number                             | D.P. - Telefono trabajo         |
| created_at          | DATETIME2      | Record creation timestamp                     | N/A                             |
| updated_at          | DATETIME2      | Record last update timestamp                  | N/A                             |

**Indexes:**
- `IX_affiliates_dni` - Index on the DNI field
- `IX_affiliates_affiliate_number` - Index on the affiliate number
- `IX_affiliates_last_first_name` - Composite index on last name + first name

### dues

Tracks the membership dues/fees for each affiliate.

| Column          | Type           | Description                               |
|-----------------|----------------|-------------------------------------------|
| due_id          | INT            | Primary key auto-incremented              |
| person_id       | INT            | Foreign key to affiliates                 |
| amount          | DECIMAL(10,2)  | Amount of the due/fee                     |
| due_date        | DATE           | Date when the due is applicable           |
| due_type        | VARCHAR(50)    | Type of due/fee                           |
| payment_status  | VARCHAR(50)    | Status of payment (e.g., Pending, Paid)   |
| payment_date    | DATE           | Date when payment was made (if any)       |
| created_at      | DATETIME2      | Record creation timestamp                 |
| updated_at      | DATETIME2      | Record last update timestamp              |

**Foreign Keys:**
- `FK_dues_affiliates` - References affiliates(person_id)

**Indexes:**
- `IX_dues_person_id` - Index on person_id for faster lookups

### receipts

Records payment receipts for affiliates.

| Column             | Type           | Description                            | Original Excel Column          |
|--------------------|----------------|----------------------------------------|-------------------------------|
| receipt_id         | INT            | Primary key auto-incremented           | N/A                           |
| receipt_code       | VARCHAR(50)    | Unique receipt identification code     | Recibo - Cod. Recibo          |
| person_id          | INT            | Foreign key to affiliates              | D.P. - Cod. Persona           |
| person_dni         | VARCHAR(20)    | Affiliate's DNI (redundant data)       | D.P. - Dni                    |
| person_last_name   | NVARCHAR(100)  | Last name (redundant data)             | D.P. - Apellidos              |
| person_first_name  | NVARCHAR(100)  | First name (redundant data)            | D.P. - Nombre                 |
| batch_number       | VARCHAR(50)    | Batch or remittance number             | Recibo - Remesa               |
| bank               | VARCHAR(100)   | Bank used for payment                  | Recibo - Banco                |
| issue_date         | DATE           | Date when receipt was issued           | Recibo - Fecha Emision        |
| payment_date       | DATE           | Date when payment was received         | Recibo - Fecha Pago           |
| payment_method     | VARCHAR(50)    | Method of payment                      | Recibo - Forma Pago           |
| amount             | DECIMAL(10,2)  | Payment amount                         | Recibo - Importe              |
| status             | VARCHAR(50)    | Status of the receipt                  | Recibo - Estado               |
| comments           | NVARCHAR(MAX)  | Additional notes or comments           | Recibo - Comentarios          |
| created_at         | DATETIME2      | Record creation timestamp              | N/A                           |
| updated_at         | DATETIME2      | Record last update timestamp           | N/A                           |

**Foreign Keys:**
- `FK_receipts_affiliates` - References affiliates(person_id)

**Indexes:**
- `IX_receipts_person_id` - Index on person_id for faster lookups
- `IX_receipts_receipt_code` - Index on receipt_code

### events

Contains information about organization events.

| Column           | Type           | Description                               |
|------------------|----------------|-------------------------------------------|
| event_id         | INT            | Primary key auto-incremented              |
| event_name       | NVARCHAR(255)  | Name of the event                         |
| event_description| NVARCHAR(MAX)  | Detailed description of the event         |
| event_date       | DATETIME2      | Date and time when event takes place      |
| location         | NVARCHAR(255)  | Physical location of the event            |
| max_participants | INT            | Maximum number of participants allowed    |
| active           | BIT            | Whether the event is active (1) or not (0)|
| created_at       | DATETIME2      | Record creation timestamp                 |
| updated_at       | DATETIME2      | Record last update timestamp              |

### event_participation

Records which affiliates participate in which events.

| Column            | Type           | Description                               |
|-------------------|----------------|-------------------------------------------|
| participation_id  | INT            | Primary key auto-incremented              |
| event_id          | INT            | Foreign key to events                     |
| person_id         | INT            | Foreign key to affiliates                 |
| registration_date | DATETIME2      | Date when affiliate registered for event  |
| attendance_status | VARCHAR(50)    | Status (Registered, Attended, No-show...) |
| comments          | NVARCHAR(MAX)  | Additional notes about participation      |
| created_at        | DATETIME2      | Record creation timestamp                 |
| updated_at        | DATETIME2      | Record last update timestamp              |

**Foreign Keys:**
- `FK_event_participation_events` - References events(event_id)
- `FK_event_participation_affiliates` - References affiliates(person_id)

**Constraints:**
- `UQ_event_person` - Unique constraint to prevent duplicate registrations

**Indexes:**
- `IX_event_participation_event_id` - Index on event_id
- `IX_event_participation_person_id` - Index on person_id

### excel_column_mappings

Maintains mapping between Excel columns and database fields for data import.

| Column             | Type            | Description                              |
|--------------------|-----------------|------------------------------------------|
| mapping_id         | INT             | Primary key auto-incremented             |
| source_table       | VARCHAR(50)     | Source table ('affiliates' or 'receipts')|
| excel_column_name  | NVARCHAR(255)   | Original Excel column name               |
| db_column_name     | VARCHAR(100)    | Corresponding database column name       |
| column_order       | INT             | Order of column in Excel                 |
| data_type          | VARCHAR(50)     | Data type (INT, VARCHAR, DATE, etc.)     |
| is_required        | BIT             | Whether field is required for import     |
| created_at         | DATETIME2       | Record creation timestamp                |
| updated_at         | DATETIME2       | Record last update timestamp             |

**Constraints:**
- `UQ_source_excel_column` - Enforces uniqueness of excel column names per source table
