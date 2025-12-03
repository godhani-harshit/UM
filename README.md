# UM API (User Management)

This is a production-ready FastAPI project structure for a User Management system with authentication, role-based access, and Azure AD integration.

## 🚀 Features
- Modular structure (core, models, schemas, services, utils)
- SQLModel with async database support
- Environment-based configuration
- Ready for Alembic migrations
- CORS & middleware setup
- Docker and Azure pipeline ready

## 🧩 Setup
```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## 📁 Environment Variables (.env)
- `DATABASE_URL`
- `DEBUG`
- `PROJECT_NAME`
- `SECRET_KEY`

## 🧱 Structure
```
app/
 ├── core/ - config, db, and security
 ├── models/ - database models
 ├── schemas/ - Pydantic schemas
 ├── services/ - business logic
 ├── api/v1/ - routers
 ├── utils/ - helpers and validators
 └── dependencies/ - shared dependencies
```

## 🧪 Health Check
GET `/health`
