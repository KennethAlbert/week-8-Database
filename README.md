# Library Management System Database

This SQL script sets up a comprehensive relational database for a Library Management System. It defines the structure, relationships, and indexes needed to manage library operations efficiently.

## Features

- **Members**: Stores library users with membership details and status.
- **Authors & Book_Authors**: Supports multiple authors per book via a junction table.
- **Publishers & Categories**: Organizes books by publisher and category, including hierarchical categories.
- **Books & Book_Copies**: Tracks book metadata and individual physical copies.
- **Loans & Reservations**: Manages book lending, due dates, reservations, and renewal history.
- **Fines**: Records penalties for late returns, lost, or damaged items.
- **Staff**: Maintains staff information for library employees.
- **Audit_Log**: Logs important changes for accountability and tracking.

## Relationships

- **One-to-Many**: Members to Loans, Publishers/Categories to Books, Books to Book_Copies.
- **Many-to-Many**: Books to Authors (via Book_Authors).
- **One-to-One**: Loans to Fines.
- **Foreign Keys**: Enforce data integrity between related tables.

## Indexes

Indexes are created on frequently queried columns (e.g., email, status, ISBN, due dates) to improve performance.

## Usage

Run this script in your SQL environment (e.g., MySQL Workbench, VS Code SQL extension) to create the database and all tables.

## Extensibility

You can add triggers, stored procedures, or views as needed for advanced operations.

---

**Note:** This schema is designed for extensibility and normalization, supporting typical library workflows such as lending, reservations, fines, and staff management.