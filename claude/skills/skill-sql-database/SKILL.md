---
name: skill-sql-database
description: "SQL database management — migrations, schema auto-upgrade, PostgreSQL, SQLite, optimization"
type: development
tags: ["sql", "database", "migrations", "postgresql", "sqlite"]
---

# SQL Database Management

### Safety

- Backup before migration (mandatory for SQLite, advisory for server engines).
- Abort on failure, roll back transaction, emit actionable error.
- Never partially start with inconsistent schema.

### Observability

- Expose schema version via health endpoint (`/readyz` or `/healthz`).
- Log upgrade status at INFO level on startup.

## Migration Design

- Migrations embedded in the application, not external SQL files.
- Each migration wrapped in a transaction.
- Naming: sequential version + description (e.g., `V003_AddUserPreferences`).
- Every migration should be **idempotent** where possible.
- Every migration should be **reversible** where possible (provide `Down` method).
- Never modify a previously released migration — always create a new one.

## Cross-Engine Migration

When migrating data between database engines:

- **Interactive progress**: table name, progress bar (%), elapsed time, ETA (minutes + clock time).
- **Batch processing**: process in configurable batch sizes to avoid memory exhaustion.
- **Per-table error tracking**: errors on one table do not abort others.
- **Schema detection**:
  - If target has all tables: offer **skip** or **overwrite** (with confirmation).
  - If partial: create only missing tables.
- Engine managers must be **generic** (e.g., `local_engine_manager.py`), not provider-specific.

## Connection Management

- **Connection pooling**: mandatory for server databases (PostgreSQL, MySQL, MSSQL).
- Pool size: configurable, sensible defaults (min: 2, max: 20).
- Connection timeout: configurable (default: 30s).
- Idle timeout: close connections idle > 5 minutes.
- Health check: validate connections before use.

## SQL Best Practices

- Parameterized queries ALWAYS (prevent SQL injection).
- Use indexes for frequently queried columns.
- Avoid `SELECT *` — specify columns explicitly.
- Use appropriate data types (don't store dates as strings).
- Foreign keys for referential integrity.
- Constraints (NOT NULL, UNIQUE, CHECK) for data integrity.
- Transactions for multi-statement operations.

## PostgreSQL Specifics

- Primary server database for the standard stack.
- Use `JSONB` for semi-structured data (not `JSON`).
- Partial indexes for filtered queries.
- `EXPLAIN ANALYZE` for query optimization.
- Connection via `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD` env vars.

## SQLite Specifics

- WAL mode enabled for concurrent reads.
- `PRAGMA journal_mode=WAL;`
- `PRAGMA busy_timeout=5000;`
- `PRAGMA synchronous=NORMAL;`
- `PRAGMA foreign_keys=ON;`
- File permissions: 600 (owner read/write only).

## SQL Scripts Directory

- SQL utility scripts stored in `SQL/` directory at repo root.
- Naming: `{number}_{description}.sql` (e.g., `001_initial_schema.sql`).
- These are reference/documentation — runtime migrations are embedded in the app.

## Schema Version Table

```sql
CREATE TABLE IF NOT EXISTS __schema_version (
    version INTEGER NOT NULL,
    migration_name TEXT NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration_ms INTEGER,
    status TEXT DEFAULT 'success',
    checksum TEXT
);
```
