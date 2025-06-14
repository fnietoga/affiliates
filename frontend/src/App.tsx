import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link, NavLink } from 'react-router-dom';
import './App.css';

// Import Bootstrap components
import 'bootstrap/dist/js/bootstrap.bundle.min';

// Placeholder logo - replace with actual logo later
const logoUrl = 'https://afiliado.pp.es/static/img/pp-logo.png';

// Home component
const Home = () => {
  return (
    <div className="container">
      <h1 className="page-title">Welcome to the Affiliates Portal</h1>
      <div className="row">
        <div className="col-md-8">
          <div className="card">
            <div className="card-header">Contact Information Management</div>
            <div className="card-body">
              <h5 className="card-title">Manage your affiliates' contact information</h5>
              <p className="card-text">
                This platform allows you to efficiently manage and update the contact information
                of all affiliates. Access the complete database, make updates, and ensure all
                information is current and accurate.
              </p>
              <Link to="/affiliates" className="btn btn-primary">Access Database</Link>
            </div>
          </div>
        </div>
        <div className="col-md-4">
          <div className="card">
            <div className="card-header">Quick Actions</div>
            <div className="card-body">
              <div className="d-grid gap-2">
                <Link to="/affiliates/add" className="btn btn-accent mb-2">
                  <i className="fas fa-user-plus me-2"></i> Add New Affiliate
                </Link>
                <Link to="/affiliates/search" className="btn btn-primary mb-2">
                  <i className="fas fa-search me-2"></i> Search Affiliates
                </Link>
                <Link to="/reports" className="btn btn-secondary">
                  <i className="fas fa-chart-bar me-2"></i> View Reports
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// Affiliates List component
const AffiliatesList = () => {
  // Sample data - would be fetched from API in a real app
  const affiliates = [
    { id: 1, name: 'John Doe', email: 'john.doe@example.com', phone: '555-123-4567', city: 'Madrid' },
    { id: 2, name: 'Jane Smith', email: 'jane.smith@example.com', phone: '555-765-4321', city: 'Barcelona' },
    { id: 3, name: 'Carlos Rodriguez', email: 'carlos@example.com', phone: '555-987-6543', city: 'Valencia' },
  ];

  return (
    <div className="container">
      <h1 className="page-title">Affiliates Database</h1>
      <div className="card mb-4">
        <div className="card-header d-flex justify-content-between align-items-center">
          <span>Affiliates List</span>
          <Link to="/affiliates/add" className="btn btn-accent btn-sm">
            <i className="fas fa-plus me-1"></i> Add New
          </Link>
        </div>
        <div className="card-body">
          <div className="table-responsive">
            <table className="table table-hover">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Phone</th>
                  <th>City</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {affiliates.map(affiliate => (
                  <tr key={affiliate.id}>
                    <td>{affiliate.id}</td>
                    <td>{affiliate.name}</td>
                    <td>{affiliate.email}</td>
                    <td>{affiliate.phone}</td>
                    <td>{affiliate.city}</td>
                    <td>
                      <div className="btn-group btn-group-sm">
                        <button className="btn btn-primary">
                          <i className="fas fa-edit"></i>
                        </button>
                        <button className="btn btn-danger">
                          <i className="fas fa-trash"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

// Add Affiliate component
const AddAffiliate = () => {
  return (
    <div className="container">
      <h1 className="page-title">Add New Affiliate</h1>
      <div className="form-container">
        <form>
          <div className="row mb-3">
            <div className="col-md-6">
              <label htmlFor="firstName" className="form-label">First Name</label>
              <input type="text" className="form-control" id="firstName" />
            </div>
            <div className="col-md-6">
              <label htmlFor="lastName" className="form-label">Last Name</label>
              <input type="text" className="form-control" id="lastName" />
            </div>
          </div>

          <div className="row mb-3">
            <div className="col-md-6">
              <label htmlFor="email" className="form-label">Email</label>
              <input type="email" className="form-control" id="email" />
            </div>
            <div className="col-md-6">
              <label htmlFor="phone" className="form-label">Phone</label>
              <input type="tel" className="form-control" id="phone" />
            </div>
          </div>

          <div className="row mb-3">
            <div className="col-md-4">
              <label htmlFor="city" className="form-label">City</label>
              <input type="text" className="form-control" id="city" />
            </div>
            <div className="col-md-4">
              <label htmlFor="province" className="form-label">Province</label>
              <input type="text" className="form-control" id="province" />
            </div>
            <div className="col-md-4">
              <label htmlFor="postalCode" className="form-label">Postal Code</label>
              <input type="text" className="form-control" id="postalCode" />
            </div>
          </div>

          <div className="row mb-3">
            <div className="col-12">
              <label htmlFor="address" className="form-label">Address</label>
              <input type="text" className="form-control" id="address" />
            </div>
          </div>

          <div className="d-flex justify-content-end gap-2">
            <Link to="/affiliates" className="btn btn-secondary">Cancel</Link>
            <button type="submit" className="btn btn-primary">Save</button>
          </div>
        </form>
      </div>
    </div>
  );
};

function App() {
  return (
    <Router>
      <div className="App">
        {/* Header */}
        <header className="header">
          <div className="container">
            <div className="d-flex justify-content-between align-items-center">
              <div>
                <img src={logoUrl} alt="Party Logo" className="header-logo" />
              </div>
              <div>
                <button className="btn btn-accent">
                  <i className="fas fa-user me-1"></i> Login
                </button>
              </div>
            </div>
          </div>
        </header>

        {/* Navigation */}
        <nav className="navbar navbar-expand-lg navbar-dark">
          <div className="container">
            <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
              <span className="navbar-toggler-icon"></span>
            </button>
            <div className="collapse navbar-collapse" id="navbarNav">
              <ul className="navbar-nav">
                <li className="nav-item">
                  <NavLink className={({isActive}) => isActive ? "nav-link active" : "nav-link"} to="/">Home</NavLink>
                </li>
                <li className="nav-item">
                  <NavLink className={({isActive}) => isActive ? "nav-link active" : "nav-link"} to="/affiliates">Affiliates</NavLink>
                </li>
                <li className="nav-item">
                  <NavLink className={({isActive}) => isActive ? "nav-link active" : "nav-link"} to="/reports">Reports</NavLink>
                </li>
              </ul>
            </div>
          </div>
        </nav>

        {/* Main Content */}
        <main className="main-content">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/affiliates" element={<AffiliatesList />} />
            <Route path="/affiliates/add" element={<AddAffiliate />} />
          </Routes>
        </main>

        {/* Footer */}
        <footer className="footer">
          <div className="container">
            <p className="mb-0">© 2025 Affiliates Portal - Contact Management System</p>
          </div>
        </footer>
      </div>
    </Router>
  );
}

export default App;
