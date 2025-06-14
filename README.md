# Afiliados - Affiliate Management System

## Overview
Application for affiliates management, their dues, receipts and event participation, with AI agent for query information in natural language.

## Technology Stack
This project uses modern technologies for efficient development and deployment:

- **Backend**: ASP.NET Core RESTful API (.NET 9.0)
- **Frontend**: React with TypeScript, Material-UI
- **Database**: SQL Server with Flyway migrations
- **Infrastructure**: Azure Cloud, managed with Terraform
- **CI/CD**: GitHub Actions
- **AI Integration**: OpenAI API for natural language processing

## Getting Started

### Backend
```powershell
cd backend
# To run the API
dotnet run
```

### Frontend
```powershell
cd frontend
# Install dependencies
npm install
# To start the React app
npm start
```

---

## Key Features

- **Affiliate Management**: Complete CRUD operations for affiliate information
- **Dues Management**: Track and manage affiliate membership dues and payments
- **Receipt Generation**: Automated receipt generation for payments
- **Event Management**: Track participation of affiliates in various events
- **AI-Powered Queries**: Natural language interface for querying affiliate data
- **Role-Based Access**: Different permission levels for administrators and standard users
- **Reporting**: Generate detailed reports on affiliates, dues, and events
- **Notifications**: Automated notifications for dues payments and upcoming events

---

## Database Management with Flyway

This project uses Flyway to manage database schema migrations.
For detailed instructions on how to set up and use Flyway, refer to the file:
`backend/db/README.md`

SQL migration scripts are located in `backend/db/migration/`.

---

## Infrastructure Deployment with Terraform

This project uses Terraform to define and deploy infrastructure on Azure.
Terraform scripts are located in the `iac/terraform/` folder.
For detailed instructions on how to set up and use Terraform, refer to the file:
`iac/terraform/README.md`

---

## CI/CD Pipelines

This project uses GitHub Actions for continuous integration and deployment. The following workflows are available:

1. **Infrastructure Deployment (Terraform)**: Deploys Azure infrastructure when changes are pushed to the `iac/terraform/` directory.
2. **Database Migrations (Flyway)**: Applies database migrations when changes are pushed to the `backend/db/migration/` directory.
3. **Backend API (.NET)**: Builds and deploys the ASP.NET Core API when changes are pushed to the `backend/` directory.
4. **Frontend (React)**: Builds and deploys the React application when changes are pushed to the `frontend/` directory.

GitHub Actions workflow files are located in the `.github/workflows/` directory.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
