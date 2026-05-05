---
name: skill-dotnet-development
description: ".NET development — SqlFactory, ASP.NET Core, health endpoints, schema auto-upgrade, OpenTelemetry"
type: development
tags: ["dotnet", "csharp", "aspnet", "sqlfactory"]
---

# .NET Development

## Database Access — SqlFactory ONLY

- **MANDATORY**: all .NET applications use **SqlFactory** for database access.
- NuGet package: `SqlFactory` (published on nuget.org).
- Source repository: `REPOSITORY/net/SqlFactory`.
- **NEVER** use Dapper, Entity Framework, EF Core, or raw ADO.NET directly in application code.
- When modifying an existing .NET app that uses Dapper or EF: **migrate to SqlFactory** as part of the modification. Run all tests to verify correctness after migration.
- Supported engines: SQLite, PostgreSQL, MySQL, MSSQL.

## Health Endpoints (Mandatory)

Every .NET service MUST expose:

- `/healthz` — liveness probe (returns 200 if process is alive)
- `/readyz` — readiness probe (checks all dependencies: DB connection, external services, message brokers)

Implementation:
```csharp
builder.Services.AddHealthChecks()
    .AddCheck("database", () => /* SqlFactory connection test */)
    .AddCheck("dependencies", () => /* external service checks */);
```

## Startup Schema Auto-Upgrade (Mandatory)

On every application startup, before serving traffic:

1. Connect to configured database via SqlFactory.
2. Read schema version from `__schema_version` table (create if missing, treat as v0).
3. Compare against required version in code.
4. **If behind**: apply pending migrations in order, each in its own transaction. Log: `migration_id`, `from_version`, `to_version`, `duration_ms`, `status`.
5. **If equal**: proceed normally.
6. **If ahead (downgrade)**: FAIL FAST with clear error. Never run against a newer schema.

Safety:
- Backup before migration (mandatory for SQLite, advisory for server engines).
- Abort on failure, roll back transaction, emit actionable error.
- Never partially start with inconsistent schema.

Observability:
- Expose schema version via `/readyz` endpoint.
- Log upgrade status at INFO level.

## Migrations

- Embedded in the application (not external SQL files).
- Each migration: idempotent where possible, wrapped in transaction.
- Naming: sequential number + description (e.g., `V003_AddUserPreferences`).
- Migration class pattern:

```csharp
public interface IMigration
{
    int Version { get; }
    string Description { get; }
    Task Up(ISqlFactory db);
    Task Down(ISqlFactory db); // optional, for rollback
}
```

## Build Targets

- **Containerized applications**: build for Linux x64 (`linux-x64`).
- **Exception**: LLMRouter — always build for macOS.
- **Console/desktop applications**: build 3 platforms (macOS, Windows x64, Linux x64), portable/self-contained.

## OpenTelemetry Instrumentation

- Metrics: request duration, error rate, active connections, custom business metrics.
- Traces: distributed tracing with correlation IDs across services.
- Logs: structured JSON format (Serilog with OpenTelemetry sink).
- Exporters: OTLP (configurable endpoint).

## Configuration Architecture

- All configuration stored in database (Rule 27). Never in appsettings.json for app-specific settings.
- Hot reload: periodic refresh from DB (configurable interval TTL). React to config save triggers immediately.
- Cache config in memory with TTL + on-write invalidation.
- REST API for all config, protected by token/OIDC.
- Admin dashboard for config management (if app has UI).

## REST API Standards

- All config options exposed via authenticated REST API.
- Write operations protected by secret token or OIDC.
- Every write endpoint: validate input (type, range, enum, format).
- Return clear validation error messages (field + reason + expected format).
- API versioning: URL path (e.g., `/api/v1/`).

## Project Structure

```
src/
  AppName/
    Program.cs
    Migrations/
    Services/
    Controllers/
    Models/
data/
  app.db              # Default SQLite database
tests/
  AppName.Tests/
Dockerfile
docker-compose.yml
```
