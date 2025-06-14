# Application Architecture Design

## 1. Solution Proposal and Technological Architecture

To build a robust, scalable, and modern application, the following technology stack and architecture is proposed:

*   **Backend**: **ASP.NET Core Web API (.NET 9.0)**
    *   **Language**: C#
    *   **Framework**: ASP.NET Core
    *   **Why**: High performance, cross-platform, excellent Azure integration, extensive ecosystem, and mature development tools. Ideal for building secure and efficient RESTful APIs.
*   **Frontend**: **React (with TypeScript)**
    *   **Language**: TypeScript/JavaScript
    *   **Library**: React
    *   **Why**: Popular, component-based, large community, ideal for interactive and dynamic Single Page Applications (SPAs). TypeScript adds static typing for greater robustness.
*   **Database**: **Azure SQL Database**
    *   **Type**: PaaS (Platform as a Service) relational database.
    *   **Why**: Fully managed, scalable, secure, with automatic backups and high availability. Perfect for structured data like contact information.

**Application Architecture:**

The application will follow an N-tier architecture, commonly decoupled:

1.  **Presentation Layer (Frontend - React)**:
    *   Web user interface for administrators to manage affiliate information (CRUD: Create, Read, Update, Delete).
    *   Reusable components for forms, data tables, and navigation.
    *   Communication with the Backend API through HTTP requests (RESTful).
    *   Can be hosted on Azure App Service or Azure Static Web Apps.

2.  **Business Logic and API Layer (Backend - ASP.NET Core Web API)**:
    *   RESTful endpoints for all operations on affiliates (e.g., `GET /api/affiliates`, `POST /api/affiliates`, `PUT /api/affiliates/{id}`, `DELETE /api/affiliates/{id}`).
    *   Data validation.
    *   Business logic (e.g., specific rules for affiliations, youth organization, etc.).
    *   Authentication and authorization (could integrate with Azure AD for administrator users).
    *   Interaction with the data access layer.
    *   Hosted on Azure App Service.

3.  **Data Access Layer (Entity Framework Core)**:
    *   We will use Entity Framework Core as an ORM (Object-Relational Mapper) to interact with Azure SQL Database from the .NET backend.
    *   Definition of data models that map to database tables.

4.  **Persistence Layer (Database - Azure SQL Database)**:
    *   Will store affiliate information.

## 2. Data Model

### Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    AFFILIATES ||--o{ DUES : has
    AFFILIATES ||--o{ RECEIPTS : receives
    AFFILIATES ||--o{ EVENT_PARTICIPATION : participates
    EVENTS ||--o{ EVENT_PARTICIPATION : includes
    
    AFFILIATES {
        int person_id PK
        varchar affiliate_number UK
        varchar dni UK
        nvarchar first_name
        nvarchar last_name
        date affiliate_date
        nvarchar email
        bit online_registration
        bit nngg
        varchar gender
        nvarchar nationality
        date birth_date
        varchar mobile_phone
        nvarchar street_address
        nvarchar city
        nvarchar province
        datetime2 created_at
        datetime2 updated_at
    }
    
    DUES {
        int due_id PK
        int person_id FK
        decimal amount
        date due_date
        varchar due_type
        varchar payment_status
        date payment_date
        datetime2 created_at
        datetime2 updated_at
    }
    
    RECEIPTS {
        int receipt_id PK
        varchar receipt_code UK
        int person_id FK
        decimal amount
        date issue_date
        date payment_date
        varchar payment_method
        varchar status
        datetime2 created_at
        datetime2 updated_at
    }
    
    EVENTS {
        int event_id PK
        nvarchar event_name
        datetime2 event_date
        nvarchar location
        int max_participants
        bit active
        datetime2 created_at
        datetime2 updated_at
    }
    
    EVENT_PARTICIPATION {
        int participation_id PK
        int event_id FK
        int person_id FK
        datetime2 registration_date
        varchar attendance_status
        datetime2 created_at
        datetime2 updated_at
    }
    
    EXCEL_COLUMN_MAPPINGS {
        int mapping_id PK
        varchar source_table
        nvarchar excel_column_name
        varchar db_column_name
        int column_order
        varchar data_type
        bit is_required
        datetime2 created_at
        datetime2 updated_at
    }
```

### Data Model Description

The data model has been updated to support complete management of affiliates and their interactions with the organization:

1. **Affiliates**: Main table that stores the personal information of affiliates, including contact information, residence details, and affiliation data.

2. **Dues**: Records the dues/fees that each affiliate must pay, including amounts, due dates, and payment statuses.

3. **Receipts**: Maintains a record of payments made by affiliates, with detailed transaction information.

4. **Events**: Stores information about events organized by the organization.

5. **Event Participation**: Relational table that records which affiliates participate in which events.

6. **Excel Column Mappings**: Facilitates data import from Excel files by preserving the relationship between original column names and database field names.

The model is designed to support both daily affiliate management and automated import processes from Excel files. Fields are normalized and use English names to facilitate development, while maintaining a record of the original Spanish names for reference.

For detailed documentation of each table and its fields, please refer to the [Database Schema Document](DATABASE_SCHEMA.md).
