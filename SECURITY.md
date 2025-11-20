# 보안 가이드 (Security Guide)

이 문서는 SNS 프로젝트의 보안 베스트 프랙티스와 구현 가이드입니다.

## 목차

1. [인증 및 인가](#인증-및-인가)
2. [API 보안](#api-보안)
3. [프론트엔드 보안](#프론트엔드-보안)
4. [백엔드 보안](#백엔드-보안)
5. [데이터 보안](#데이터-보안)
6. [네트워크 보안](#네트워크-보안)
7. [민감 정보 관리](#민감-정보-관리)
8. [파일 업로드 보안](#파일-업로드-보안)
9. [Rate Limiting](#rate-limiting)
10. [보안 헤더](#보안-헤더)
11. [CORS 설정](#cors-설정)
12. [로깅 및 모니터링](#로깅-및-모니터링)
13. [보안 체크리스트](#보안-체크리스트)
14. [취약점 대응](#취약점-대응)

---

## 인증 및 인가

### JWT (JSON Web Token) 보안

#### 현재 구현 (shared/api/apiClient.ts)

```typescript
// ✅ 현재 구현된 보안 기능
- JWT 토큰 기반 인증
- Access Token + Refresh Token 분리
- 자동 토큰 갱신 (Axios Interceptor)
- 토큰 만료 시 자동 재로그인
```

#### 개선 필요 사항

**1. Access Token 만료 시간 단축**

```typescript
// 백엔드 (Kotlin/Spring Boot)
// ⚠️ 현재: 1시간 → ✅ 권장: 15분
@Value("\${jwt.access-token-validity}")
private val accessTokenValidity: Long = 900000 // 15분 (밀리초)

@Value("\${jwt.refresh-token-validity}")
private val refreshTokenValidity: Long = 604800000 // 7일
```

**2. Refresh Token Rotation (사용 후 무효화)**

```kotlin
// RefreshToken 사용 시 새로운 Refresh Token 발급
fun refreshAccessToken(refreshToken: String): TokenResponse {
    // 1. 기존 Refresh Token 검증
    validateRefreshToken(refreshToken)

    // 2. 새로운 토큰 쌍 발급
    val newAccessToken = generateAccessToken(userId)
    val newRefreshToken = generateRefreshToken(userId)

    // 3. 기존 Refresh Token 블랙리스트 등록 (무효화)
    blacklistToken(refreshToken)

    return TokenResponse(newAccessToken, newRefreshToken)
}
```

**3. Token Storage 보안**

```typescript
// ❌ 나쁜 예: LocalStorage에 토큰 저장 (XSS 공격에 취약)
localStorage.setItem('token', token);

// ✅ 권장: HttpOnly Cookie 사용 (백엔드)
@PostMapping("/login")
fun login(@RequestBody request: LoginRequest, response: HttpServletResponse) {
    val tokens = authService.login(request)

    // Refresh Token을 HttpOnly Cookie에 저장
    val cookie = Cookie("refreshToken", tokens.refreshToken).apply {
        isHttpOnly = true  // JavaScript에서 접근 불가
        secure = true      // HTTPS만 허용
        maxAge = 604800    // 7일
        path = "/api/auth/refresh"
        sameSite = "Strict" // CSRF 방지
    }
    response.addCookie(cookie)

    // Access Token만 응답 바디로 전달
    return ResponseEntity.ok(tokens.accessToken)
}
```

**4. 토큰 블랙리스트 (로그아웃 시)**

```kotlin
// Redis를 사용한 토큰 블랙리스트
@Service
class TokenBlacklistService(
    private val redisTemplate: RedisTemplate<String, String>
) {
    fun blacklistToken(token: String, expirationTime: Duration) {
        redisTemplate.opsForValue().set(
            "blacklist:$token",
            "revoked",
            expirationTime
        )
    }

    fun isBlacklisted(token: String): Boolean {
        return redisTemplate.hasKey("blacklist:$token")
    }
}
```

### 비밀번호 보안

**1. 비밀번호 해싱 (BCrypt)**

```kotlin
// ✅ Spring Security의 BCrypt 사용
@Configuration
class SecurityConfig {
    @Bean
    fun passwordEncoder(): PasswordEncoder {
        return BCryptPasswordEncoder(12) // strength: 12 (권장)
    }
}

// 비밀번호 저장
val hashedPassword = passwordEncoder.encode(rawPassword)
```

**2. 비밀번호 정책 (프론트엔드 검증)**

```typescript
// shared/utils/validation.ts
export const PASSWORD_POLICY = {
  minLength: 8,
  maxLength: 128,
  requireUppercase: true,
  requireLowercase: true,
  requireNumbers: true,
  requireSpecialChars: true,
};

export function validatePassword(password: string): {
  isValid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  if (password.length < PASSWORD_POLICY.minLength) {
    errors.push(`최소 ${PASSWORD_POLICY.minLength}자 이상이어야 합니다`);
  }

  if (!/[A-Z]/.test(password)) {
    errors.push('대문자를 포함해야 합니다');
  }

  if (!/[a-z]/.test(password)) {
    errors.push('소문자를 포함해야 합니다');
  }

  if (!/[0-9]/.test(password)) {
    errors.push('숫자를 포함해야 합니다');
  }

  if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    errors.push('특수문자를 포함해야 합니다');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}
```

**3. 비밀번호 재설정 (이메일 토큰)**

```kotlin
// 비밀번호 재설정 토큰 생성 (1회용, 1시간 유효)
fun generatePasswordResetToken(email: String): String {
    val token = UUID.randomUUID().toString()
    val expiresAt = LocalDateTime.now().plusHours(1)

    // Redis에 저장
    redisTemplate.opsForValue().set(
        "password-reset:$token",
        email,
        Duration.ofHours(1)
    )

    // 이메일 발송
    sendPasswordResetEmail(email, token)

    return token
}

// 토큰 검증 및 비밀번호 변경
fun resetPassword(token: String, newPassword: String) {
    val email = redisTemplate.opsForValue().get("password-reset:$token")
        ?: throw InvalidTokenException()

    // 비밀번호 변경
    updatePassword(email, newPassword)

    // 토큰 무효화
    redisTemplate.delete("password-reset:$token")
}
```

### 다중 인증 (MFA) - 옵션

```kotlin
// TOTP (Time-based One-Time Password) 구현
@Service
class MfaService {
    fun generateSecret(): String {
        return Base32().encodeToString(
            SecureRandom().generateSeed(20)
        )
    }

    fun verifyCode(secret: String, code: String): Boolean {
        val totp = TimeBasedOneTimePasswordGenerator()
        return totp.validate(secret, code)
    }
}
```

---

## API 보안

### 1. HTTPS 강제 사용

```kotlin
// Spring Boot - HTTPS 리다이렉트
@Configuration
class SecurityConfig : WebSecurityConfigurerAdapter() {
    override fun configure(http: HttpSecurity) {
        http
            .requiresChannel()
            .anyRequest()
            .requiresSecure() // HTTPS 강제
    }
}
```

### 2. API 인증 미들웨어

```kotlin
// JWT 검증 필터
@Component
class JwtAuthenticationFilter(
    private val jwtTokenProvider: JwtTokenProvider,
    private val blacklistService: TokenBlacklistService
) : OncePerRequestFilter() {

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val token = extractToken(request)

        if (token != null) {
            // 1. 블랙리스트 체크
            if (blacklistService.isBlacklisted(token)) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Token revoked")
                return
            }

            // 2. 토큰 검증
            if (jwtTokenProvider.validateToken(token)) {
                val authentication = jwtTokenProvider.getAuthentication(token)
                SecurityContextHolder.getContext().authentication = authentication
            }
        }

        filterChain.doFilter(request, response)
    }
}
```

### 3. 권한 기반 접근 제어 (RBAC)

```kotlin
// 권한 체크 애노테이션
@PreAuthorize("hasRole('USER')")
@GetMapping("/posts")
fun getPosts(): List<Post>

@PreAuthorize("hasRole('ADMIN')")
@DeleteMapping("/users/{userId}")
fun deleteUser(@PathVariable userId: String)

@PreAuthorize("@postService.isOwner(#postId, authentication.principal.id)")
@DeleteMapping("/posts/{postId}")
fun deletePost(@PathVariable postId: String)
```

### 4. SQL Injection 방지

```kotlin
// ❌ 나쁜 예: String Concatenation
fun findUserByEmail(email: String): User {
    val sql = "SELECT * FROM users WHERE email = '$email'" // SQL Injection 취약
    return jdbcTemplate.queryForObject(sql, UserRowMapper())
}

// ✅ 좋은 예: Prepared Statement
fun findUserByEmail(email: String): User {
    val sql = "SELECT * FROM users WHERE email = ?"
    return jdbcTemplate.queryForObject(sql, UserRowMapper(), email)
}

// ✅ 더 좋은 예: JPA/Hibernate
interface UserRepository : JpaRepository<User, String> {
    fun findByEmail(email: String): User?
}
```

### 5. 입력 검증

```kotlin
// DTO 검증
data class CreatePostRequest(
    @field:NotBlank(message = "Caption cannot be blank")
    @field:Size(max = 2200, message = "Caption must be less than 2200 characters")
    val caption: String,

    @field:Size(max = 10, message = "Maximum 10 images allowed")
    val imageUrls: List<String>,

    @field:Pattern(regexp = "^[a-zA-Z0-9 ,]*$", message = "Invalid location format")
    val location: String?
)

// Controller
@PostMapping("/posts")
fun createPost(@Valid @RequestBody request: CreatePostRequest): Post {
    return postService.createPost(request)
}
```

---

## 프론트엔드 보안

### 1. XSS (Cross-Site Scripting) 방지

**React/Next.js는 기본적으로 XSS 방어**

```typescript
// ✅ React는 자동으로 이스케이프 처리
function PostCaption({ caption }: { caption: string }) {
  return <p>{caption}</p>; // 안전
}

// ❌ 위험: dangerouslySetInnerHTML 사용 시
function UnsafeHTML({ html }: { html: string }) {
  return <div dangerouslySetInnerHTML={{ __html: html }} />; // XSS 위험
}

// ✅ HTML 새니타이징 라이브러리 사용
import DOMPurify from 'dompurify';

function SafeHTML({ html }: { html: string }) {
  const sanitized = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}
```

**URL 검증**

```typescript
// 사용자 입력 URL 검증
function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    // HTTPS만 허용
    return parsed.protocol === 'https:';
  } catch {
    return false;
  }
}

// 외부 링크 안전하게 열기
function ExternalLink({ href, children }: { href: string; children: React.ReactNode }) {
  if (!isValidUrl(href)) {
    return <span>{children}</span>;
  }

  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer" // 보안 필수
    >
      {children}
    </a>
  );
}
```

### 2. CSRF (Cross-Site Request Forgery) 방지

```kotlin
// Spring Boot - CSRF 토큰
@Configuration
class SecurityConfig : WebSecurityConfigurerAdapter() {
    override fun configure(http: HttpSecurity) {
        http
            .csrf()
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
    }
}
```

```typescript
// 프론트엔드 - CSRF 토큰 전송
import axios from 'axios';

axios.interceptors.request.use((config) => {
  const csrfToken = getCookie('XSRF-TOKEN');
  if (csrfToken) {
    config.headers['X-XSRF-TOKEN'] = csrfToken;
  }
  return config;
});
```

### 3. Content Security Policy (CSP)

```typescript
// Next.js - next.config.js
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: `
      default-src 'self';
      script-src 'self' 'unsafe-eval' 'unsafe-inline' https://trusted-cdn.com;
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      font-src 'self' data:;
      connect-src 'self' https://api.yourapp.com;
      frame-ancestors 'none';
    `.replace(/\s{2,}/g, ' ').trim()
  },
  {
    key: 'X-Frame-Options',
    value: 'DENY'
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff'
  },
  {
    key: 'Referrer-Policy',
    value: 'strict-origin-when-cross-origin'
  },
  {
    key: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=()'
  }
];

module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: securityHeaders,
      },
    ];
  },
};
```

### 4. 민감 정보 노출 방지

```typescript
// ❌ 나쁜 예: 콘솔 로그에 민감 정보
console.log('User logged in:', { email, password }); // 절대 금지

// ✅ 좋은 예: 프로덕션에서 로그 제거
if (process.env.NODE_ENV === 'development') {
  console.log('User logged in:', { email, userId });
}

// ❌ 나쁜 예: 에러 메시지에 민감 정보
throw new Error(`Failed to login with email: ${email} and password: ${password}`);

// ✅ 좋은 예: 일반적인 에러 메시지
throw new Error('Invalid credentials');
```

---

## 백엔드 보안

### 1. 입력 검증 및 새니타이징

```kotlin
// 이메일 검증
@Email(message = "Invalid email format")
private lateinit var email: String

// HTML 새니타이징
import org.jsoup.Jsoup
import org.jsoup.safety.Safelist

fun sanitizeHtml(input: String): String {
    return Jsoup.clean(input, Safelist.basic())
}

// 파일 경로 검증 (Path Traversal 방지)
fun isValidFilePath(path: String): Boolean {
    val normalized = Paths.get(path).normalize().toString()
    return !normalized.contains("..") && normalized.startsWith("/uploads/")
}
```

### 2. Rate Limiting

```kotlin
// Bucket4j를 사용한 Rate Limiting
@Configuration
class RateLimitConfig {

    @Bean
    fun rateLimiter(): RateLimiter {
        return RateLimiterRegistry.of(
            RateLimiterConfig.custom()
                .limitRefreshPeriod(Duration.ofMinutes(1))
                .limitForPeriod(100) // 분당 100 요청
                .timeoutDuration(Duration.ofSeconds(0))
                .build()
        ).rateLimiter("api")
    }
}

// Controller
@RestController
class PostController(private val rateLimiter: RateLimiter) {

    @GetMapping("/posts")
    fun getPosts(): List<Post> {
        // Rate Limit 체크
        rateLimiter.executeSupplier {
            postService.getPosts()
        }
    }
}
```

**IP 기반 Rate Limiting**

```kotlin
@Component
class IpRateLimitFilter : OncePerRequestFilter() {

    private val limiters = ConcurrentHashMap<String, RateLimiter>()

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val ip = request.remoteAddr
        val limiter = limiters.computeIfAbsent(ip) {
            RateLimiter.of("ip-$ip", RateLimiterConfig.custom()
                .limitForPeriod(1000) // 시간당 1000 요청
                .limitRefreshPeriod(Duration.ofHours(1))
                .build()
            )
        }

        if (!limiter.acquirePermission()) {
            response.sendError(429, "Too Many Requests")
            return
        }

        filterChain.doFilter(request, response)
    }
}
```

### 3. 로깅 및 감사 (Audit Trail)

```kotlin
// 중요 작업 로깅
@Service
class AuditService {

    fun logSecurityEvent(
        userId: String,
        action: String,
        resource: String,
        result: String,
        ipAddress: String
    ) {
        val auditLog = AuditLog(
            userId = userId,
            action = action,
            resource = resource,
            result = result,
            ipAddress = ipAddress,
            timestamp = LocalDateTime.now()
        )

        auditLogRepository.save(auditLog)

        // 의심스러운 활동 감지
        if (result == "FAILED") {
            detectSuspiciousActivity(userId, action)
        }
    }
}

// 사용 예
@PostMapping("/login")
fun login(@RequestBody request: LoginRequest, httpRequest: HttpServletRequest): TokenResponse {
    try {
        val tokens = authService.login(request)

        auditService.logSecurityEvent(
            userId = request.email,
            action = "LOGIN",
            resource = "AUTH",
            result = "SUCCESS",
            ipAddress = httpRequest.remoteAddr
        )

        return tokens
    } catch (e: Exception) {
        auditService.logSecurityEvent(
            userId = request.email,
            action = "LOGIN",
            resource = "AUTH",
            result = "FAILED",
            ipAddress = httpRequest.remoteAddr
        )
        throw e
    }
}
```

### 4. 예외 처리 (정보 노출 방지)

```kotlin
// ❌ 나쁜 예: 상세한 에러 메시지
@ExceptionHandler(Exception::class)
fun handleException(e: Exception): ResponseEntity<ErrorResponse> {
    return ResponseEntity.status(500).body(
        ErrorResponse(
            message = e.message, // 스택 트레이스, DB 정보 등 노출 위험
            stackTrace = e.stackTrace.toString()
        )
    )
}

// ✅ 좋은 예: 일반적인 에러 메시지
@ExceptionHandler(Exception::class)
fun handleException(e: Exception): ResponseEntity<ErrorResponse> {
    // 내부 로깅
    logger.error("Internal error", e)

    // 클라이언트에는 일반적인 메시지만
    return ResponseEntity.status(500).body(
        ErrorResponse(
            code = "INTERNAL_ERROR",
            message = "An unexpected error occurred"
        )
    )
}
```

---

## 데이터 보안

### 1. 데이터베이스 암호화

**민감한 필드 암호화**

```kotlin
// JPA Entity Listener를 사용한 자동 암호화
@Entity
class User(
    @Id
    val userId: String,

    val email: String,

    @Convert(converter = EncryptedStringConverter::class)
    val phoneNumber: String?, // 암호화된 전화번호

    @Convert(converter = EncryptedStringConverter::class)
    val address: String? // 암호화된 주소
)

// 암호화 컨버터
@Converter
class EncryptedStringConverter : AttributeConverter<String, String> {

    private val cipher = Cipher.getInstance("AES/GCM/NoPadding")
    private val secretKey = getSecretKey() // KMS나 환경변수에서 로드

    override fun convertToDatabaseColumn(attribute: String?): String? {
        if (attribute == null) return null
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)
        val encrypted = cipher.doFinal(attribute.toByteArray())
        return Base64.getEncoder().encodeToString(encrypted)
    }

    override fun convertToEntityAttribute(dbData: String?): String? {
        if (dbData == null) return null
        cipher.init(Cipher.DECRYPT_MODE, secretKey)
        val decrypted = cipher.doFinal(Base64.getDecoder().decode(dbData))
        return String(decrypted)
    }
}
```

**Database-level Encryption (TDE)**

```yaml
# application.yml - MySQL 연결 시 SSL 사용
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/sns_db?useSSL=true&requireSSL=true
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

### 2. PII (개인 식별 정보) 마스킹

```kotlin
// API 응답에서 민감 정보 마스킹
data class UserResponse(
    val userId: String,
    val username: String,
    val email: String,

    @JsonIgnore // JSON 응답에서 제외
    val phoneNumber: String?,

    val maskedEmail: String = maskEmail(email),
    val maskedPhone: String? = phoneNumber?.let { maskPhone(it) }
)

fun maskEmail(email: String): String {
    val parts = email.split("@")
    val local = parts[0]
    val masked = if (local.length > 2) {
        local.substring(0, 2) + "***"
    } else {
        "***"
    }
    return "$masked@${parts[1]}"
}

fun maskPhone(phone: String): String {
    return phone.replaceRange(3, phone.length - 4, "****")
}
```

### 3. 데이터 접근 제어

```kotlin
// 본인 데이터만 조회 가능
@GetMapping("/users/{userId}")
fun getUser(
    @PathVariable userId: String,
    @AuthenticationPrincipal currentUser: User
): UserResponse {
    // 본인 또는 관리자만 조회 가능
    if (userId != currentUser.userId && !currentUser.isAdmin) {
        throw ForbiddenException("You don't have permission to view this user")
    }

    return userService.getUser(userId)
}
```

---

## 네트워크 보안

### 1. HTTPS 강제 (HSTS)

```kotlin
// Spring Security - HSTS 헤더
@Configuration
class SecurityConfig : WebSecurityConfigurerAdapter() {
    override fun configure(http: HttpSecurity) {
        http
            .headers()
            .httpStrictTransportSecurity()
            .includeSubDomains(true)
            .maxAgeInSeconds(31536000) // 1년
    }
}
```

### 2. CORS 설정

```kotlin
// CORS 설정 (특정 Origin만 허용)
@Configuration
class CorsConfig : WebMvcConfigurer {

    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/api/**")
            .allowedOrigins(
                "https://yourapp.com",
                "https://www.yourapp.com"
            )
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(true)
            .maxAge(3600)
    }
}
```

### 3. API Gateway / Reverse Proxy

```nginx
# Nginx 설정 예시
server {
    listen 443 ssl http2;
    server_name api.yourapp.com;

    # SSL 인증서
    ssl_certificate /etc/ssl/certs/yourapp.crt;
    ssl_certificate_key /etc/ssl/private/yourapp.key;

    # SSL 프로토콜 및 암호화 스위트
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # 보안 헤더
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 민감 정보 관리

### 1. 환경 변수 사용

```bash
# .env 파일 (절대 Git에 커밋하지 말 것!)
DB_USERNAME=admin
DB_PASSWORD=super_secret_password
JWT_SECRET=your_jwt_secret_key_here
AWS_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

```kotlin
// application.yml
spring:
  datasource:
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}

jwt:
  secret: ${JWT_SECRET}
```

### 2. Secrets Management (프로덕션)

**AWS Secrets Manager**

```kotlin
@Configuration
class SecretsConfig {

    @Bean
    fun secretsManager(): AWSSecretsManager {
        return AWSSecretsManagerClientBuilder.standard()
            .withRegion("us-east-1")
            .build()
    }

    fun getSecret(secretName: String): String {
        val request = GetSecretValueRequest()
            .withSecretId(secretName)

        val result = secretsManager().getSecretValue(request)
        return result.secretString
    }
}
```

**HashiCorp Vault**

```kotlin
@Configuration
class VaultConfig {

    @Bean
    fun vaultTemplate(): VaultTemplate {
        val endpoint = VaultEndpoint.create("vault.yourapp.com", 8200)
        endpoint.setScheme("https")

        val authentication = TokenAuthentication(vaultToken)
        return VaultTemplate(endpoint, authentication)
    }
}
```

### 3. API 키 보호

```typescript
// ❌ 나쁜 예: 클라이언트에서 API 키 노출
const API_KEY = "sk_live_51Hxxx..."; // 절대 금지!

// ✅ 좋은 예: 서버사이드에서만 사용
// Next.js API Route
export async function POST(req: Request) {
  const apiKey = process.env.SECRET_API_KEY; // 서버에서만 접근
  const response = await fetch('https://api.service.com', {
    headers: {
      'Authorization': `Bearer ${apiKey}`
    }
  });
  return response;
}
```

---

## 파일 업로드 보안

### 1. 파일 유형 검증

```kotlin
@Service
class FileUploadService {

    private val allowedMimeTypes = setOf(
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp",
        "video/mp4",
        "video/quicktime"
    )

    private val allowedExtensions = setOf(
        "jpg", "jpeg", "png", "gif", "webp", "mp4", "mov"
    )

    fun validateFile(file: MultipartFile) {
        // 1. MIME Type 검증
        if (file.contentType !in allowedMimeTypes) {
            throw InvalidFileTypeException("Invalid file type: ${file.contentType}")
        }

        // 2. 확장자 검증
        val extension = file.originalFilename?.substringAfterLast('.', "")?.lowercase()
        if (extension !in allowedExtensions) {
            throw InvalidFileTypeException("Invalid file extension: $extension")
        }

        // 3. 파일 크기 검증
        if (file.size > 50 * 1024 * 1024) { // 50MB
            throw FileSizeLimitExceededException("File size exceeds 50MB")
        }

        // 4. Magic Bytes 검증 (실제 파일 형식 확인)
        if (!verifyMagicBytes(file)) {
            throw InvalidFileTypeException("File content does not match extension")
        }
    }

    private fun verifyMagicBytes(file: MultipartFile): Boolean {
        val bytes = file.bytes

        // JPEG
        if (bytes.size >= 2 && bytes[0] == 0xFF.toByte() && bytes[1] == 0xD8.toByte()) {
            return true
        }

        // PNG
        if (bytes.size >= 8 &&
            bytes[0] == 0x89.toByte() &&
            bytes[1] == 0x50.toByte() &&
            bytes[2] == 0x4E.toByte() &&
            bytes[3] == 0x47.toByte()) {
            return true
        }

        // 기타 형식...
        return false
    }
}
```

### 2. 파일명 새니타이징

```kotlin
fun sanitizeFilename(filename: String): String {
    // 1. UUID로 새 파일명 생성 (권장)
    val extension = filename.substringAfterLast('.', "")
    return "${UUID.randomUUID()}.$extension"

    // 또는

    // 2. 원본 파일명 새니타이징
    return filename
        .replace(Regex("[^a-zA-Z0-9._-]"), "_") // 특수문자 제거
        .take(255) // 길이 제한
}
```

### 3. 안티바이러스 스캔

```kotlin
// ClamAV를 사용한 바이러스 스캔
@Service
class AntivirusService {

    private val clamAvClient = ClamAVClient("localhost", 3310)

    fun scanFile(file: MultipartFile): ScanResult {
        val result = clamAvClient.scan(file.inputStream)

        if (result is ScanResult.VirusFound) {
            // 로그 기록
            logger.warn("Virus detected: ${result.virusName}")

            // 파일 삭제
            throw VirusDetectedException("File contains malware: ${result.virusName}")
        }

        return result
    }
}
```

### 4. 파일 저장 위치 분리

```kotlin
// 업로드 파일을 별도 도메인/CDN에 저장
@Configuration
class StorageConfig {

    @Value("\${aws.s3.bucket}")
    private lateinit var bucketName: String

    fun uploadFile(file: MultipartFile): String {
        val filename = sanitizeFilename(file.originalFilename!!)
        val key = "uploads/${LocalDate.now()}/$filename"

        // S3에 업로드
        s3Client.putObject(
            PutObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .contentType(file.contentType)
                .build(),
            RequestBody.fromBytes(file.bytes)
        )

        // CDN URL 반환
        return "https://cdn.yourapp.com/$key"
    }
}
```

---

## Rate Limiting

### API별 Rate Limit 설정

```kotlin
// 엔드포인트별 다른 제한
@Configuration
class RateLimitConfig {

    fun getRateLimiter(endpoint: String): RateLimiter {
        return when (endpoint) {
            "/api/auth/login" -> RateLimiter.of("login",
                RateLimiterConfig.custom()
                    .limitForPeriod(5) // 5분당 5회
                    .limitRefreshPeriod(Duration.ofMinutes(5))
                    .build()
            )

            "/api/posts" -> RateLimiter.of("posts",
                RateLimiterConfig.custom()
                    .limitForPeriod(100) // 분당 100회
                    .limitRefreshPeriod(Duration.ofMinutes(1))
                    .build()
            )

            else -> RateLimiter.of("default",
                RateLimiterConfig.custom()
                    .limitForPeriod(1000) // 시간당 1000회
                    .limitRefreshPeriod(Duration.ofHours(1))
                    .build()
            )
        }
    }
}
```

---

## 보안 헤더

### 모든 보안 헤더 설정

```kotlin
@Configuration
class SecurityHeadersConfig : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity) {
        http.headers()
            // XSS 보호
            .xssProtection()
            .block(true)
            .and()

            // Content Type Sniffing 방지
            .contentTypeOptions()
            .and()

            // Clickjacking 방지
            .frameOptions()
            .deny()
            .and()

            // HSTS
            .httpStrictTransportSecurity()
            .includeSubDomains(true)
            .maxAgeInSeconds(31536000)
            .and()

            // Referrer Policy
            .referrerPolicy(ReferrerPolicyHeaderWriter.ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN)
            .and()

            // Permissions Policy
            .permissionsPolicy()
            .policy("camera=(), microphone=(), geolocation=()")
    }
}
```

---

## CORS 설정

### 프로덕션 CORS 설정

```kotlin
@Configuration
class CorsConfig : WebMvcConfigurer {

    @Value("\${app.allowed-origins}")
    private lateinit var allowedOrigins: List<String>

    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/api/**")
            .allowedOrigins(*allowedOrigins.toTypedArray())
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("Authorization", "Content-Type", "X-CSRF-TOKEN")
            .exposedHeaders("Authorization", "X-Total-Count")
            .allowCredentials(true)
            .maxAge(3600)
    }
}
```

```yaml
# application-prod.yml
app:
  allowed-origins:
    - https://yourapp.com
    - https://www.yourapp.com
    - https://m.yourapp.com
```

---

## 로깅 및 모니터링

### 1. 보안 이벤트 로깅

```kotlin
@Service
class SecurityLogger {

    private val logger = LoggerFactory.getLogger(javaClass)

    fun logAuthenticationSuccess(userId: String, ip: String) {
        logger.info("SECURITY: User $userId logged in from $ip")
    }

    fun logAuthenticationFailure(email: String, ip: String) {
        logger.warn("SECURITY: Failed login attempt for $email from $ip")
    }

    fun logSuspiciousActivity(userId: String, activity: String, ip: String) {
        logger.error("SECURITY: Suspicious activity detected - User: $userId, Activity: $activity, IP: $ip")

        // 알림 전송
        alertService.sendSecurityAlert(userId, activity, ip)
    }

    fun logDataAccess(userId: String, resource: String, action: String) {
        logger.info("AUDIT: User $userId performed $action on $resource")
    }
}
```

### 2. 실시간 모니터링

```kotlin
// 의심스러운 활동 패턴 감지
@Service
class ThreatDetectionService {

    private val failedAttempts = ConcurrentHashMap<String, MutableList<LocalDateTime>>()

    fun detectBruteForce(email: String): Boolean {
        val attempts = failedAttempts.getOrPut(email) { mutableListOf() }

        // 5분 이내 시도만 카운트
        val recentAttempts = attempts.filter {
            it.isAfter(LocalDateTime.now().minusMinutes(5))
        }

        // 5분 동안 5회 이상 실패 시 차단
        if (recentAttempts.size >= 5) {
            logger.warn("SECURITY: Brute force attack detected for $email")
            return true
        }

        attempts.add(LocalDateTime.now())
        return false
    }
}
```

---

## 보안 체크리스트

### 배포 전 필수 확인사항

#### 인증/인가
- [ ] JWT Secret이 강력하고 환경변수로 관리됨
- [ ] Access Token 만료 시간이 적절함 (15분 권장)
- [ ] Refresh Token이 HttpOnly Cookie에 저장됨
- [ ] 로그아웃 시 토큰 블랙리스트 처리
- [ ] 비밀번호가 BCrypt로 해싱됨 (strength 10+)
- [ ] 비밀번호 정책 적용 (8자 이상, 대소문자/숫자/특수문자)
- [ ] Rate Limiting 적용 (로그인: 5분당 5회)

#### API 보안
- [ ] 모든 API가 HTTPS를 통해 제공됨
- [ ] CORS가 특정 Origin만 허용하도록 설정됨
- [ ] SQL Injection 방지 (Prepared Statement 사용)
- [ ] 입력 검증 (@Valid 애노테이션 사용)
- [ ] API Rate Limiting 적용
- [ ] 에러 응답에 민감 정보 미포함

#### 프론트엔드
- [ ] XSS 방지 (dangerouslySetInnerHTML 사용 시 DOMPurify)
- [ ] CSRF 토큰 적용
- [ ] Content Security Policy 헤더 설정
- [ ] 외부 링크에 rel="noopener noreferrer"
- [ ] 프로덕션 빌드에서 console.log 제거
- [ ] API 키가 클라이언트에 노출되지 않음

#### 데이터 보안
- [ ] 민감한 데이터 암호화 (전화번호, 주소 등)
- [ ] Database 연결에 SSL 사용
- [ ] PII 데이터 마스킹 처리
- [ ] 백업 데이터 암호화

#### 파일 업로드
- [ ] 파일 유형 검증 (MIME Type + Magic Bytes)
- [ ] 파일 크기 제한 (50MB)
- [ ] 파일명 새니타이징
- [ ] 안티바이러스 스캔
- [ ] CDN/별도 도메인에 저장

#### 네트워크
- [ ] HTTPS 강제 (HSTS 헤더)
- [ ] 보안 헤더 설정 (X-Frame-Options, CSP 등)
- [ ] TLS 1.2+ 사용
- [ ] 불필요한 포트 차단

#### 모니터링
- [ ] 보안 이벤트 로깅
- [ ] 실패한 로그인 시도 추적
- [ ] 의심스러운 활동 알림
- [ ] 정기적인 보안 로그 검토

#### 의존성 관리
- [ ] 최신 보안 패치 적용
- [ ] 취약한 라이브러리 제거
- [ ] Dependabot/Snyk 설정
- [ ] 정기적인 의존성 업데이트

---

## 취약점 대응

### 1. 취약점 보고 정책

**보안 취약점 발견 시 연락처:**
- 이메일: security@yourapp.com
- 보안 페이지: https://yourapp.com/security

**Responsible Disclosure:**
```markdown
# 보안 취약점 보고 정책

## 보고 방법
보안 취약점을 발견하신 경우, 다음 정보와 함께 security@yourapp.com으로 연락해주세요:

1. 취약점 유형
2. 영향 범위
3. 재현 단계
4. PoC (Proof of Concept)

## 대응 프로세스
1. **24시간 이내**: 수신 확인
2. **7일 이내**: 초기 평가 및 심각도 분류
3. **30일 이내**: 패치 개발 및 배포
4. **90일 이내**: 공개 (합의 하에)

## Bug Bounty (옵션)
심각한 취약점 발견 시 보상 프로그램 운영
```

### 2. 보안 패치 프로세스

```bash
# 긴급 보안 패치 배포
git checkout -b security-patch-CVE-2024-xxxxx
# 패치 적용
git commit -m "security: Fix CVE-2024-xxxxx - SQL Injection in user search"
git push origin security-patch-CVE-2024-xxxxx

# 즉시 프로덕션 배포
# 사용자에게 긴급 업데이트 안내
```

### 3. 정기 보안 점검

```bash
# 의존성 취약점 스캔
npm audit
npm audit fix

# OWASP Dependency Check
./gradlew dependencyCheckAnalyze

# Static Code Analysis
./gradlew sonarqube

# Container 스캔 (Trivy)
trivy image yourapp:latest
```

---

## 참고 자료

### 보안 표준 및 가이드
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

### 도구
- [Snyk](https://snyk.io/) - 의존성 취약점 스캔
- [OWASP ZAP](https://www.zaproxy.org/) - 웹 애플리케이션 보안 테스팅
- [Burp Suite](https://portswigger.net/burp) - 보안 테스팅
- [Trivy](https://github.com/aquasecurity/trivy) - 컨테이너 보안 스캔

### Spring Security
- [Spring Security Reference](https://docs.spring.io/spring-security/reference/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

**⚠️ 주의사항**

1. **절대 Git에 커밋하지 말 것:**
   - 비밀번호, API 키
   - 프라이빗 키
   - 데이터베이스 크리덴셜
   - .env 파일

2. **정기 보안 점검:**
   - 주 1회: 의존성 취약점 스캔
   - 월 1회: 보안 로그 검토
   - 분기 1회: 전체 보안 감사

3. **보안은 지속적인 프로세스입니다.**
   - 새로운 취약점에 대한 지속적인 학습
   - 보안 패치 즉시 적용
   - 보안 문화 구축
