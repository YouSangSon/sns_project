# Docker 로컬 개발 환경 가이드

Docker Compose를 사용하여 SNS App의 전체 백엔드 인프라를 로컬에서 실행하는 가이드입니다.

## 📋 목차

1. [개요](#개요)
2. [사전 준비](#사전-준비)
3. [빠른 시작](#빠른-시작)
4. [서비스 설명](#서비스-설명)
5. [사용 방법](#사용-방법)
6. [트러블슈팅](#트러블슈팅)

---

## 📖 개요

Docker Compose를 사용하면 다음 서비스를 한 번에 실행할 수 있습니다:

- **PostgreSQL**: 메인 데이터베이스
- **pgAdmin**: 데이터베이스 관리 UI
- **Redis**: 캐싱 (선택사항)
- **Mock API Server**: JSON Server 기반 Mock API

### 장점

- ✅ **일관된 환경**: 팀원 모두 동일한 환경
- ✅ **빠른 설정**: 한 줄 명령어로 모든 서비스 시작
- ✅ **격리**: 로컬 환경을 오염시키지 않음
- ✅ **쉬운 정리**: 컨테이너 삭제로 깔끔하게 제거

---

## 🔧 사전 준비

### 1. Docker 설치

**macOS**:
```bash
brew install --cask docker
```

**Windows**: [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop) 다운로드

**Linux (Ubuntu)**:
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### 2. Docker 설치 확인

```bash
docker --version
docker-compose --version
```

### 3. Docker 실행 확인

```bash
docker ps
```

---

## 🚀 빠른 시작

### 1. 모든 서비스 시작

프로젝트 루트 디렉토리에서:

```bash
# 백그라운드로 모든 서비스 시작
docker-compose up -d

# 로그 확인 (선택사항)
docker-compose logs -f
```

### 2. 서비스 상태 확인

```bash
docker-compose ps
```

다음과 같이 표시됩니다:

```
NAME               COMMAND                  SERVICE     STATUS      PORTS
sns-postgres       "docker-entrypoint.s…"   postgres    running     0.0.0.0:5432->5432/tcp
sns-pgadmin        "/entrypoint.sh"         pgadmin     running     0.0.0.0:5050->80/tcp
sns-redis          "docker-entrypoint.s…"   redis       running     0.0.0.0:6379->6379/tcp
sns-mock-api       "docker-entrypoint.s…"   mock-api    running     0.0.0.0:8080->8080/tcp
```

### 3. Flutter 앱 실행

서비스가 실행 중이면 Flutter 앱을 실행:

```bash
cd flutter_app
flutter run -d chrome
```

### 4. 서비스 중지

```bash
# 서비스 중지 (컨테이너는 유지)
docker-compose stop

# 서비스 중지 및 컨테이너 삭제
docker-compose down

# 서비스, 컨테이너, 볼륨 모두 삭제 (데이터 초기화)
docker-compose down -v
```

---

## 🛠️ 서비스 설명

### 1. PostgreSQL (포트: 5432)

메인 데이터베이스 서버

**접속 정보**:
```
Host: localhost
Port: 5432
Database: snsdb
Username: postgres
Password: postgres
```

**psql로 접속**:
```bash
docker exec -it sns-postgres psql -U postgres -d snsdb
```

**데이터베이스 초기화**:
```bash
# init.sql 스크립트가 자동 실행됨
# 수동 실행이 필요한 경우:
docker exec -i sns-postgres psql -U postgres -d snsdb < supabase/init.sql
```

### 2. pgAdmin (포트: 5050)

웹 기반 데이터베이스 관리 도구

**접속**:
```
URL: http://localhost:5050
Email: admin@example.com
Password: admin
```

**PostgreSQL 서버 추가**:
1. pgAdmin 접속
2. "Add New Server" 클릭
3. 다음 정보 입력:
   - General > Name: `SNS Database`
   - Connection > Host: `postgres` (Docker 네트워크 내부 이름)
   - Connection > Port: `5432`
   - Connection > Username: `postgres`
   - Connection > Password: `postgres`
4. "Save" 클릭

### 3. Redis (포트: 6379)

캐싱 서버 (선택사항)

**접속 확인**:
```bash
docker exec -it sns-redis redis-cli ping
# 응답: PONG
```

**Redis CLI 접속**:
```bash
docker exec -it sns-redis redis-cli
```

### 4. Mock API Server (포트: 8080)

JSON Server 기반 REST API Mock 서버

**엔드포인트**:
```
GET    http://localhost:8080/users
GET    http://localhost:8080/users/1
GET    http://localhost:8080/posts
GET    http://localhost:8080/posts/1
POST   http://localhost:8080/posts
PUT    http://localhost:8080/posts/1
DELETE http://localhost:8080/posts/1
```

**테스트**:
```bash
# 사용자 목록 조회
curl http://localhost:8080/users

# 게시물 목록 조회
curl http://localhost:8080/posts

# 새 게시물 생성
curl -X POST http://localhost:8080/posts \
  -H "Content-Type: application/json" \
  -d '{"user_id":"1","caption":"Test post","image_urls":[]}'
```

**Mock 데이터 수정**:
`mock-server/db.json` 파일을 편집한 후:
```bash
docker-compose restart mock-api
```

---

## 💻 사용 방법

### 환경 설정

Flutter 앱이 Docker 서비스에 연결되도록 설정:

**`flutter_app/config/dev.yaml`**:
```yaml
api:
  base_url: http://localhost:8080  # Mock API 사용

# 또는 실제 백엔드 서버 사용 시
# base_url: http://localhost:3000
```

### 개발 워크플로우

1. **아침에 시작**:
```bash
docker-compose up -d
```

2. **개발 중**:
```bash
# 로그 모니터링
docker-compose logs -f postgres

# 특정 서비스만 재시작
docker-compose restart mock-api
```

3. **작업 종료**:
```bash
# 서비스 중지 (데이터 유지)
docker-compose stop

# 또는 완전히 정리
docker-compose down
```

### 특정 서비스만 실행

```bash
# PostgreSQL만 실행
docker-compose up -d postgres

# PostgreSQL + pgAdmin
docker-compose up -d postgres pgadmin

# Mock API만 실행
docker-compose up -d mock-api
```

---

## 🔍 트러블슈팅

### 1. 포트 충돌 오류

**증상**:
```
Error: Bind for 0.0.0.0:5432 failed: port is already allocated
```

**원인**: 로컬에 이미 PostgreSQL이 실행 중

**해결**:
```bash
# macOS
brew services stop postgresql

# Linux
sudo systemctl stop postgresql

# Windows
# 서비스 관리자에서 PostgreSQL 중지
```

또는 `docker-compose.yml`에서 포트 변경:
```yaml
ports:
  - "5433:5432"  # 5432 -> 5433으로 변경
```

### 2. 컨테이너가 시작되지 않음

**확인**:
```bash
# 로그 확인
docker-compose logs postgres

# 컨테이너 상태 확인
docker-compose ps
```

**해결**:
```bash
# 컨테이너 재생성
docker-compose down
docker-compose up -d
```

### 3. 데이터베이스 초기화 필요

**전체 초기화**:
```bash
# 모든 볼륨 삭제 (데이터 손실!)
docker-compose down -v

# 재시작
docker-compose up -d
```

### 4. pgAdmin 접속 불가

**확인**:
```bash
# pgAdmin 로그 확인
docker-compose logs pgadmin

# 컨테이너 재시작
docker-compose restart pgadmin
```

브라우저 캐시 삭제 후 재접속

### 5. Mock API 서버 오류

**Mock 데이터 형식 확인**:
```bash
# db.json 문법 검사
cat mock-server/db.json | python -m json.tool
```

**재시작**:
```bash
docker-compose restart mock-api
docker-compose logs -f mock-api
```

---

## 📊 유용한 명령어

### Docker Compose

```bash
# 서비스 시작
docker-compose up -d

# 서비스 중지
docker-compose stop

# 서비스 삭제
docker-compose down

# 로그 보기
docker-compose logs -f [service_name]

# 서비스 재시작
docker-compose restart [service_name]

# 서비스 상태 확인
docker-compose ps

# 실행 중인 컨테이너에 접속
docker-compose exec postgres bash
```

### Docker

```bash
# 모든 컨테이너 보기
docker ps -a

# 모든 이미지 보기
docker images

# 디스크 사용량 확인
docker system df

# 사용하지 않는 리소스 정리
docker system prune -a

# 볼륨 목록
docker volume ls

# 특정 볼륨 삭제
docker volume rm sns_project_postgres_data
```

---

## 📝 고급 설정

### 커스텀 환경 변수

`docker-compose.override.yml` 생성:

```yaml
version: '3.8'

services:
  postgres:
    environment:
      POSTGRES_PASSWORD: my_secure_password

  mock-api:
    ports:
      - "8081:8080"
```

### 데이터 백업

```bash
# PostgreSQL 백업
docker exec sns-postgres pg_dump -U postgres snsdb > backup.sql

# 복원
docker exec -i sns-postgres psql -U postgres snsdb < backup.sql
```

### 프로덕션 유사 환경

`.env` 파일 생성:

```env
POSTGRES_PASSWORD=strong_password_here
PGADMIN_DEFAULT_PASSWORD=admin_password_here
```

`docker-compose.yml` 수정:

```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

---

## 🎯 Best Practices

### 1. 데이터 영속성

개발 중 데이터를 유지하려면 볼륨을 삭제하지 마세요:

```bash
# ✅ 좋은 예: 컨테이너만 삭제
docker-compose down

# ❌ 나쁜 예: 볼륨까지 삭제 (데이터 손실!)
docker-compose down -v
```

### 2. 리소스 관리

사용하지 않을 때는 서비스를 중지:

```bash
docker-compose stop
```

### 3. 정기적인 정리

```bash
# 일주일에 한 번
docker system prune -a
```

---

## 📚 추가 자료

- [로컬 개발 환경 가이드](./DEVELOPMENT.md)
- [Mock 서버 가이드](./MOCK_SERVER.md)
- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 문서](https://docs.docker.com/compose/)

---

**Happy Dockerizing! 🐳**
