# Spring Boot REST API

Enterprise-grade REST API built with Spring Boot, PostgreSQL, JWT authentication, and OpenAPI documentation.

## 🚀 Quick Start

### Prerequisites

- Java 17+
- Maven 3.9+
- Docker & Docker Compose (for local PostgreSQL)

### Local Development

```bash
# Start PostgreSQL with Docker Compose
docker-compose up db

# Run the application
mvn spring-boot:run

# Or run with Maven wrapper (if available)
./mvnw spring-boot:run
```

The API will be available at: `http://localhost:8080`

### Using Docker Compose

```bash
# Build and start all services (DB + API)
docker-compose up --build

# Stop services
docker-compose down

# Remove volumes
docker-compose down -v
```

## 📚 API Documentation

Once the application is running, access the interactive API documentation:

- **Swagger UI**: `http://localhost:8080/swagger-ui/index.html`
- **OpenAPI JSON**: `http://localhost:8080/v3/api-docs`

## 🔐 Authentication

### Register a new user

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"very-strong-password"}'
```

### Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"very-strong-password"}'
```

Response includes an `accessToken` which should be used in subsequent requests.

### Access protected endpoints

```bash
curl -X GET http://localhost:8080/api/items \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 🧪 Testing

### Run all tests

```bash
mvn test
```

### Run specific test

```bash
mvn test -Dtest=AuthFlowIT
```

### Run with coverage

```bash
mvn test jacoco:report
```

## 🏗️ Architecture

### Technology Stack

- **Spring Boot 3.2.5** - Application framework
- **Spring Security** - Authentication & authorization
- **Spring Data JPA** - Database access layer
- **PostgreSQL 16** - Relational database
- **Flyway** - Database migrations
- **JWT (jjwt 0.11.5)** - Token-based authentication
- **BCrypt** - Password hashing
- **SpringDoc OpenAPI** - API documentation
- **Testcontainers** - Integration testing

### Project Structure

```
spring-boot-api/
├── src/
│   ├── main/
│   │   ├── java/com/example/app/
│   │   │   ├── AppApplication.java          # Main application class
│   │   │   ├── common/                      # Common utilities
│   │   │   │   └── ApiExceptionHandler.java # Global exception handling
│   │   │   ├── item/                        # Item domain
│   │   │   │   ├── Item.java               # Item entity
│   │   │   │   ├── ItemRepository.java     # Item repository
│   │   │   │   └── ItemController.java     # Item REST controller
│   │   │   ├── security/                    # Security infrastructure
│   │   │   │   ├── JwtService.java         # JWT token service
│   │   │   │   ├── JwtAuthFilter.java      # JWT authentication filter
│   │   │   │   └── SecurityConfig.java     # Security configuration
│   │   │   └── user/                        # User domain
│   │   │       ├── User.java               # User entity
│   │   │       ├── UserRepository.java     # User repository
│   │   │       ├── AuthController.java     # Authentication endpoints
│   │   │       └── dto/                    # Data Transfer Objects
│   │   │           ├── RegisterRequest.java
│   │   │           └── UserResponse.java
│   │   └── resources/
│   │       ├── application.yml              # Application configuration
│   │       └── db/migration/                # Flyway migrations
│   │           ├── V1__bootstrap.sql        # Initial schema
│   │           └── V2__items.sql            # Items table
│   └── test/
│       └── java/com/example/app/
│           ├── security/
│           │   └── JwtServiceTest.java      # JWT service unit test
│           └── user/
│               └── AuthFlowIT.java          # Auth integration test
├── Dockerfile                               # Container image definition
├── docker-compose.yml                       # Local development environment
└── pom.xml                                  # Maven dependencies
```

## 🔧 Configuration

### Environment Variables

- `SPRING_DATASOURCE_URL` - Database connection URL
- `SPRING_DATASOURCE_USERNAME` - Database username
- `SPRING_DATASOURCE_PASSWORD` - Database password
- `APP_JWT_SECRET` - JWT signing secret (min 32 characters)

### Application Properties

See `src/main/resources/application.yml` for default configuration.

## 🛡️ Security Features

- **JWT Authentication**: Stateless token-based auth with 12-hour expiry
- **BCrypt Password Hashing**: Secure password storage
- **Role-based Access Control**: USER and ADMIN roles
- **CSRF Protection**: Disabled for REST API (using JWT)
- **Input Validation**: Jakarta Bean Validation
- **SQL Injection Protection**: JPA parameterized queries

## 📊 Database Migrations

Migrations are managed by Flyway and executed automatically on startup.

### Creating a new migration

1. Create a new SQL file in `src/main/resources/db/migration/`
2. Follow naming convention: `V{version}__{description}.sql`
3. Example: `V3__add_user_profile.sql`

## 🔍 API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login and get JWT token

### Items (Authenticated)

- `GET /api/items` - List user's items
- `POST /api/items` - Create new item
- `DELETE /api/items/{id}` - Delete item

## 🚀 Building for Production

```bash
# Build JAR
mvn clean package

# Run JAR
java -jar target/app-0.0.1-SNAPSHOT.jar

# Or build Docker image
docker build -t spring-boot-api .
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host:5432/appdb \
  -e SPRING_DATASOURCE_USERNAME=app \
  -e SPRING_DATASOURCE_PASSWORD=secret \
  -e APP_JWT_SECRET=your-production-secret \
  spring-boot-api
```

## 📝 Best Practices Implemented

✅ **Security First**: JWT, BCrypt, CSRF protection, input validation
✅ **Clean Architecture**: Domain-driven design with clear separation
✅ **Database Migrations**: Version-controlled schema changes
✅ **Comprehensive Testing**: Unit and integration tests with Testcontainers
✅ **API Documentation**: Auto-generated OpenAPI/Swagger docs
✅ **Error Handling**: Global exception handler with consistent responses
✅ **Docker Support**: Containerized application and development environment
✅ **Production Ready**: Health checks, logging, and configuration management

## 🤝 Contributing

1. Follow the existing code structure and patterns
2. Add tests for new features
3. Update API documentation if adding new endpoints
4. Run tests before committing: `mvn test`

## 📞 Support

For issues or questions, refer to the main project documentation.
