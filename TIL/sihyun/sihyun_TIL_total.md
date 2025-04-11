### **유효성 체크를 위한 Validation API 사용**

- Hibernate
    - Java에서 db관련 어플리케이션 개발할 때 Java의 어떠한 객체를 데이터베이스 엔티티하고 매핑하기 위해서 사용되는 프레임워크
- @Valid
    - 컨트롤러를 통해 입력되는 값의 유효성 검사(조건 검사) 어놉
    
    ```java
    @Data
    @AllArgsConstructor
    public class User {
        private Integer id;
    
        @Size(min = 2, message = "Name은 두 글자 이상 입력해 주세요.")
        private String name;
    
        @Past(message = "등록일은 미래 날짜를 입력하실 수 없습니다.")
        private Date joinDate;
    }
    
    public class CustomizedResponseEntityExceptionHandler
        @Override
        protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
            ExceptionResponse exceptionResponse =
                    new ExceptionResponse(new Date(), "Validation failed", ex.getBindingResult().toString());
    
            return new ResponseEntity(exceptionResponse, HttpStatus.BAD_REQUEST);
        }
    ```
    

### **다국어 처리를 위한 Internationalization 구현 방법**

- 하나의 출력값을 여러가지 언어로 표시해주는 기능
- 우리가 제공하려고 하는 언어별로, 문자값을 미리 가지고 있을 때 지역 코드 또는 언어 설정에 따라 적절한 언어가 표시되는 방식을 얘기함
- 해당 언어/지역 코드 존재하지 않을시 기본값으로 설정되어 있는 값이 보여지게 됨
- 웹브라우저 기본 언어 설정이 영어라면 영어 메시지, 한국어면 한국어 메시지 띄움
- 다국어 처리 단순히 특정 컨트롤러에서만 처리되는 것이 아니라 프로젝트 전반에 걸쳐 적용시켜야 될 것이기 대문에 다국어 처리에 필요한 빈 자체를 스부 어플리케이션 클래스에 등록할 것, 스부 초기화 될 때 메모리에 등록, 사용할 수 있도록 하겠다.

- 구현
    - 메인에 localResolver 구현
    - @RequestHeader
        - 사용시 HTTP요청의 헤더 값을 메소드의 파라미터에 쉽게 연결할 수 있음
        - 클라이언트가 서버에 요청할 떄 여러가지 정보를 함께 보낼 수 있는데, 그 중에 하나가 헤더, 그 정보를 메소드 내에서 바로 변수로 받을 수 있게 해줌
    - 빈 등록
        
        ```java
        package ssafy.com.myrestfulservice;
        
        @SpringBootApplication
        public class MyRestfulServiceApplication {
        
        	public static void main(String[] args) {
        		SpringApplication.run(MyRestfulServiceApplication.class, args);
        	}
        
        	@Bean
        	public LocaleResolver localeResolver() {
        		SessionLocaleResolver localeResolver = new SessionLocaleResolver();
        		localeResolver.setDefaultLocale(Locale.US);
        		return localeResolver;
        	}
        }
        ```
        
    - 스프링 컨텍스트가 기동이 되었을 때 localeResolver가 메모리에 빈으로 등록될 것, 등록된 값을 컨트롤러에서 생성자 주입을 통해 사용
        - 주입이란?
            - 스프링 컨텍스트에 의해서 기동이 될 때 해당하는 인스턴스를 미리 만들어 놓고 메모리에 등록한다고 하였는데, 미리 등록되어진 다른 스프링의 빈을 가지고 와서 현재 있는 클래스에서 사용할 수 있도록, 객체를 생성하지 않더라도 참조할 수 있는 형태로 받아오는 것
    - yaml파일에서 spring message 받아올 경로 지정
    
    ```java
    spring:
      message:
        basename: messages
    ```
    
    - resources 밑에다가 messages.properties 기본 설정 언어 파일 생성
        - messages_kr.properties , messages_jp.properties 등 다른 언어 설정 파일도 생성
        - 각국의 언어에 맞는 글 쓰기
    
    ```java
    greeting.message=안녕하세요
    ```
    
    - 포스트맨으로 테스트, 헤더 값 변경하여 테스트하면 타국 언어 나옴
        
        ![](https://blogfiles.pstatic.net/MjAyNTAxMTRfMTYz/MDAxNzM2ODA2NTc0MTg0.EItmmsNdCqHqweLwumjG8CobLyPXdEjrsHmFwX3qHNAg.q5OhQeGPLpHLHBDRmtv3rfHQ9uAmVxw98HwlTqhMJsIg.PNG/image.png?type=w1)
        
        - 위와 같이 사용하고 싶다면 무조건 properties에 언어 설정 파일 생성이 끝나있어야 함
        
        - 인텔리제이 인코딩 설정 방법(각 폴더 유형별로)

![](https://blogfiles.pstatic.net/MjAyNTAxMTRfMTE3/MDAxNzM2ODA2ODcyMzcz.vvKkTg1deUs89c0Gkj4b_IEVopmcafjAlY0WnVHdRC8g.3TqFKtjbNsmeEc4bPnOBuDrokRRG1W-v0j_fnVb7ELEg.PNG/image.png?type=w1)

### **Response 데이터 형식 변환 - XML format**

- Postman의 Headers값에 'Accept'를 application/xml로 변경시(코드상에서 바꾸는 것이 아니라 요청할 수 있는 header값에서 xml 포맷이라고 요청시) 결과값이 xml데이터로 변경

![](https://blogfiles.pstatic.net/MjAyNTAxMTRfMTY0/MDAxNzM2ODIzODYwNzU4.GljAvy2xGGV4bkM9tBlbCKlTqEbqg63nxh6AR3YBrnIg.LE6qwnsmfyhIuniTCv6tItWsQ4Tacr04AS1iWYTkrzAg.PNG/image.png?type=w1)

### **Response 데이터 제어를 위한 Filtering**

- 비밀번호, 주민번호와 같이 숨기고자 하는 값을 도메인 클래스의 변수마다 @JsonIgnore 어놉을 활용해 필터링 처리 함
    
    ![](https://blogfiles.pstatic.net/MjAyNTAxMTRfODUg/MDAxNzM2ODI0MDcwMTY1.D168mLS35y3GHnv7jiL0UCxGgf4ltXWfDsxFvkIBGS8g.Q0M1lNXlpWkFxk-Jmct1Rc8VhCiKQ9v2tjl95ZZR6LQg.PNG/image.png?type=w1)
    

- 이는 @JsonIgnoreProperties(value = {}) 어놉을 활용하여 일괄 처리가 가능함
    - @JsonIgnoreProperties(value = {"password", "ssn"})
    
    ![](https://blogfiles.pstatic.net/MjAyNTAxMTRfMTc0/MDAxNzM2ODI0Mjc1NTMy.tKtkzf5nkMezP2o8tOAi-9lfo9m-vaR3YcbgPqkjD7og.GzbKTfIEtiaAoTjIh13tjBUN2Ts_cekcmunVD4_Lg5sg.PNG/image.png?type=w1)
    

**프로그래밍으로 제어하는 Filtering - 개별 사용자 조회**

여기서 Admin 설정

- @JsonFilter("")
    - @JsonIgnoreProperties(value = {}) 이것과 비슷한 역할, 하지만 하나하나 수정 안해도 돼서 오케이

### 프로그래밍으로 제어하는 Filtering - 개별 사용자 조회

```java
@GetMapping("/users/{id}")
public MappingJacksonValue retrieveUser(@PathVariable int id) {
    User user = service.findOne(id);
    AdminUser adminUser = new AdminUser();

    if (user == null) {
        throw new UserNotFoundException(String.format("ID[%s] not found", id));
    } else {
        BeanUtils.copyProperties(user, adminUser);
    }

    SimpleBeanPropertyFilter filter = SimpleBeanPropertyFilter
            .filterOutAllExcept("id", "name", "joinDate", "ssn");

    FilterProvider filters = new SimpleFilterProvider().addFilter("UserInfo", filter);

    MappingJacksonValue mapping = new MappingJacksonValue(adminUser);
    mapping.setFilters(filters);

    return mapping;
}
```

- 리턴타입 MappingJacksonValue
    - 일반적인 객체(User, AdminUser)가 아닌 필터링이 적용된 객체를 JSON 형태로 전달하기 위함
    - Jackson(스프링에서 사용하는 JSON 변환 라이브러리)을 통한 직렬화 과정에서 특정 필드만 노출/숨기거나 할 수 있는 동적 필터링 기능 활용 가능
    → 자바 객체를 JSON 형식으로 변환하는 과정을 의미
- BeanUtils.copyProperties(user, adminUser);
    - user 필드를 adminUser로 복사함
    - user에 담긴 id, name, joinDate 등의 정보가 adminUser에 옮겨짐
- SimpleBeanPropertyFilter.filterOutAllExcept(”id”, "name", "joinDate", "ssn")
    - SimpleBeanPropertyFilter는 Jackson 라이브러리가 제공하는 속성 필터
    - filterOutAllExcept(…)는 지정된 필드 외에는 모두 제외한다는 의미
    - ”id”, "name", "joinDate", "ssn"만 응답에 포함, 그 외의 필드는 응답에서 제외
- FilterProvider filters = new SimpleFilterProvider().addFilter(”UserInfo”, filter);
    - SimpleFilterProvider는 여러 개의 필터를 등록할 수 있는 컨테이너 역할을 함
    - “UserInfo”라는 이름의 필터에 방금 만든 filter(노출 허용 필드가 지정된 필터)를 등록
    - 이 “UserInfo”라는 이름은 해당 객체 클래스에서 @JsonFilter(”UserInfo”)와 같은 애너테이션으로 연결되는 이름일 가능성이 큼(ex: @JsonFilter(”UserInfo”) )
- MappingJacksonValue mapping = new MappingJacksonValue(adminUser);
    - JSON으로 직렬화할 대상 객체(adminUser)를 MappingJacksonValue에 감쌈
- mapping.setFilters(filters);
    - mapping에 우리가 만든 filters를 등록, 이 객체를 JSON 변환할 때 필터가 동작하도록 설정

### 프로그래밍으로 제어하는 Filtering - 전체 사용자 조회

```java
@GetMapping("/users")
public MappingJacksonValue retrieveAllUsers() {
    List<User> users = service.findAll();
    List<AdminUser> adminUsers = new ArrayList<>();

    AdminUser adminUser = null;
    for (User user : users) {
        adminUser = new AdminUser();
        BeanUtils.copyProperties(user, adminUser);

        adminUsers.add(adminUser);
    }

    SimpleBeanPropertyFilter filter = SimpleBeanPropertyFilter
            .filterOutAllExcept("id", "name", "joinDate", "ssn");

    FilterProvider filters = new SimpleFilterProvider().addFilter("UserInfo", filter);

    MappingJacksonValue mapping = new MappingJacksonValue(adminUsers);
    mapping.setFilters(filters);

    return mapping;
}
```

### Version 관리 - URI를 이용한 버전관리

- Request parameter를 활용한 버전관리
    - 매핑
        
        ```java
        @GetMapping(value = "/users/{id}", params = "version=1")
        ```
        
    - postman 테스트
        
        ```java
        http://localhost:8088/admin/users/1?version=1
        ```
        

- Header versioning를 활용한 버전관리
    - 매핑
        
        ```java
        @GetMapping(value = "/users/{id}", headers ="X-API-VERSION=1")
        ```
        
    - 찾아본 결과, 꼭 ‘X-API-VERSION’ 이런 형식이 아니여도 됨, 백엔드에 작성하는 것과 포스트맨에 작성하는 값이 통일되기만 하면 됨
    - postman 테스트
        
        ![image.png](attachment:53d8213e-a31d-4b9b-becb-4cdfce528c3c:image.png)
        

- mime-type or accept header를 활용한 버전관리
    - 매핑
        
        ```java
        @GetMapping(value = "/users/{id}", produces = "application/vnd.company.appv1+json")
        ```
        
    - postman 테스트
        
        ![image.png](attachment:e2e8af4a-ce2f-409b-b319-ee721b636f39:image.png)

-------


### Level3 단계의 REST API 구현을 위한 HATEOAS 적용

- 리소스 + 하이퍼링크 함께 반환하는 것

```java
    @GetMapping("/users/{id}")
    public EntityModel<User> retrieveUser(@PathVariable int id) {
        User user = service.findOne(id);

        if (user == null) {
            throw new UserNotFoundException(String.format("ID[%s] not found", id));
        }

        EntityModel entityModel = EntityModel.of(user);

        WebMvcLinkBuilder linTo = linkTo(methodOn(this.getClass()).retrieveAllUsers());
        entityModel.add(linTo.withRel("all-users")); // all-users -> https://localhost:8088/users
        return entityModel;
    }
```

- **사용자 정보 반환 : EntityModel<User>**
    - Spring HATEOAS에서 제공하는 클래스 중 하나
    - 실제 리소스 객체(여기서는 `User`)에 링크 정보(hyperlinks)를 함께 보관할 수 있도록 도와줌
    - 이렇게 반환하면, 스프링이 JSON으로 직렬화할 때 `_links` 섹션을 포함하여 응답 본문이 구성될 수 있도록 해줌
- **링크 생성 : WebMvcLinkBuilder.linkTo(...)**
    - **linkTo(methodOn(UserController.class).retrieveAllUsers())**
        - methodOn(…)은 메서드 레퍼런스를 통해 “UserController”의 retrieveAllUsers()가 어떤 경로로 매핑되어 있는지 찾아내는 역할을 함
        - 즉, 내부적으로 스프링이 ‘/users’라는 uri를 구성해 줌
    - **.withRel(”all-users”)**
        - 링크 관계(rel)를 “all-users”로 지정함
        - 이는 최종 JSON에 `_links.all-users.href` 형태로 링크가 들어갈 수 있음을 의미
    - **entityModel.add(...)**
        - EntityModel<User>에 해당 링크 정보를 추가함
        - 결과적으로, 클이 GET /users/{id}를 호출했을 때, 응답 JSON 안에 “all-users”링크가 포함됨
- postman 결과
    
    ```java
    {
        "id": 1,
        "name": "셔니",
        "joinDate": "2025-02-26T02:20:55.253+00:00",
        "_links": {
            "all-users": {
                "href": "http://localhost:8088/users"
            }
        }
    }
    ```
    

### Swagger Documentation 구현 - Spring Boot 3.1 사용

오류 개터져서 안함 버전 이슈인듯

### Spring Security를 이용한 인증처리

```java
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-security</artifactId>
	<version>3.0.2</version>
</dependency>
```

- pom.xml에 위와 같은 설정 추가하고 프로젝트 시작하면 임시 비밀번호 생성됨, 터미널 창에서 확인 가능
    
    ![image.png](attachment:e3ae1fa1-a138-4ac9-b5a8-850ae2432381:image.png)
    
- security 설정한 이후에 postman에서 전체 인원 조회하려고 하면 401 unauthorized 뜸
    
    ![image.png](attachment:b10e279f-a554-46da-82fe-2f80ad725611:image.png)
    
    - Basic Auth, username은 기본 설정인 user, password에 터미널에 뜬 비번 넣어주면 됨

### API 사용을 위한 사용자 인증 처리 구현

```java
package ssafy.com.myrestfulservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;

@Configuration
public class SecurityConfig {
    @Bean
    UserDetailsService userDetailService() {
        InMemoryUserDetailsManager userDetailsManager = new InMemoryUserDetailsManager();

        UserDetails newUser = User.withUsername("user")
                .password(passwordEncoder().encode("password"))
                .authorities("read")
                .build();

        userDetailsManager.createUser(newUser);
        return userDetailsManager;
    }

    @Bean
    BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

- 내가 지정한 아이디, 비밀번호를 사용하려면 위와 같은 설정을 해야 함.
- @Configuration
    - 이 클래스가 Spring의 설정 클래스임을 나타냄. 즉, 이 클래스 안에 정의된 @Bean 메소드들이 Spring Application Context에 의해 관리될 빈(Bean)으로 등록됨.
- `password(passwordEncoder().encode("password"))`는 `"password"`라는 문자열을 `BCryptPasswordEncoder`를 사용하여 암호화, 즉 사용자가 제공한 평문 비밀번호를 암호화하여 저장하게 됨
- `userDetailsManager.createUser(newUser)`는 `newUser`를 `userDetailsManager`에 등록함
- `userDetailsManager`는 메모리 내에서 사용자 정보를 관리하며, 이 정보는 애플리케이션이 종료될 때까지 유지됨
- 현재 이 코드에서는 DB에 저장하는 방식이 아니라, **메모리 내에서** 사용자 정보를 관리, 비밀번호는 메모리 내에서 BCrypt로 암호화되어 사용자가 로그인할 때 비교됨


-------

### Java Persistence API의 개요

- ORM(Object Relational Mapping)
    - 객체를 관계형db에 있는 데이터와 자동으로 연결해주는 작업
- JPA(Java Persistence API)
    - 자바 ORM 기술에 대한 API 표준 명세
    - 자바 어플리케이션에서 관계형 db를 사용하는 방식을 정의한 인터페이스(약속)
    - EntityManager를 통해 CRUD 처리
- Hibernate
    - JPA 의 구현체, 인터페이스를 직접 구현한 라이브러리
    - 생산성, 유지보수, 비종속성
- Spring Data JPA
    - Spring Module
    - JPA를 추상화한 Repository 인터페이스 제공

### JPA 사용을 위한 Dependency 추가와 Entity 설정

- pom.xml 추가
    
    ```java
    		<dependency>
    			<groupId>com.h2database</groupId>
    			<artifactId>h2</artifactId>
    			<scope>runtime</scope>
    		</dependency>
    ```
    
- application.yml
    
    ```java
    spring:
      datasource:
        url: jdbc:h2:mem:testdb
        username: sa
      jpa:
        hibernate:
          ddl-auto: create-drop
        show-sql: true
        defer-datasource-initialization: true
      h2:
        console:
          enabled: true
          settings:
            web-allow-others: true
    ```
    
- user.java
    
    ```java
    @Entity
    @Table(name = "users")
    ```
    

### Spring Data JPA를 이용한 초기 데이터 생성

- resources - data.sql 파일
    
    ```java
    insert into users(id, join_date, name, password, ssn) values(111111, now(), 'User1', 'test111', '111111-9999999');
    insert into users(id, join_date, name, password, ssn) values(222222, now(), 'User2', 'test222', '222222-9999999');
    insert into users(id, join_date, name, password, ssn) values(333333, now(), 'User3', 'test333', '333333-9999999');
    ```
    
- 만약 Spring Security를 사용하는 상태에서 h2 사용하려고 하면 아래와 같은 설정을 해줘야 함(여기 실습에서는 SecurityConfig 없앤 상태에서 하기때문에 따로 설정할 것은 없음)
config - SecurityConfig.java
    
    ```java
    @Configuration
    public class SecurityConfig {
    	@Bean
    	UserDetailsService userDetailsService() {}
    	
    	@Bean
    	BCryptPasswordEncoder passwordEncoder() {
    		return new BCryptPasswordEncoder();
    	}
    	
    	@Bean
    	public WebSecurityCustomizer webSecurityCustomizer() {
    		return (web) -> web.ignoring().
    										requestMatchers(new AntPathRequestMatcher("/h2-console/**"));
    	}
    }
    	
    ```
    
    - `webSecurityCustomizer` 메서드는 `WebSecurityCustomizer` 인터페이스를 반환하는 메서드임. `WebSecurityCustomizer`는 Spring Security의 보안 설정을 커스터마이즈할 수 있도록 도와주는 구성 요소로, `web.ignoring()`는 보안 필터 체인에서 특정 요청을 무시하게 설정하는 역할을 함.

### JPA Service 구현을 위한 Controller, Repository 생성

- controller 생성
    
    ```java
    @RestController
    @RequestMapping("/jpa")
    @RequiredArgsConstructor
    public class UserJpaController {
    
        private final UserRepository userRepository;
    
        @GetMapping("/users")
        public List<User> retrieveAllUsers() {
            return userRepository.findAll();
        }
    }
    ```
    
- repository 패키지 생성 (repository - UserRepository)
    
    ```java
    @Repository
    public interface UserRepository extends JpaRepository<User, Integer> {
    }
    ```
    
    - 첫 번째 타입에 User, 두 번째 타입에는 User 객체의 Id값의 타입 기입

### 게시물 관리를 위한 Post Entity 추가와 초기 데이터 생성

- @ManyToOne(fetch = FetchType.LAZY), 지연로딩
    - 사용자 데이터를 조회할 때 데이터를 즉시 가져오는 것이 아니라 Post가 로딩되는 시점, 이것이 필요한 시점에 그때그때 가져오기 위한 설정
    - 지연로딩
        - 해당 엔티티를 실제로 사용할 때에야 연관된 객체를 조회하는 것
        - `Order` 엔티티에서 `Member`를 참조한다고 할 때, 코드를 통해 `Order.getMember()`를 호출하기 전까지는 데이터베이스에서 `Member` 정보를 조회하지 않음
        - 애플리케이션에서 불필요하게 연관 테이블의 데이터를 미리 로딩하지 않아도 되므로 성능을 향상시킬 수 있음
- @JsonIgnore
    - Jackson 라이브러리에서 사용되는 어노테이션으로, JSON 변환(직렬화/역직렬화) 시 특정 필드를 무시하도록 설정해주는 역할
    - Jackson이 이 필드는 무시해야 한다고 인식하여 JSON 데이터를 직렬화/역직렬화 모두에서 제외
    - 이 데이터가 화면에 보이지 않도록 지정하는 것
- @OneToMany(mappedBy = "user")
    - mappedBy 는 양방향 관계에서 연관 관계의 주체가 되는 필드를 지정하는 속성
    - mappedBy = “user”는 Post 엔티티에서 user라는 필드가 양방향 관계의 “주인”이라는 의미임. 즉, Post객체에서 User 객체를 참조하는 user 필드가 이 관계의 주체가 되어, User 객체에 의해 여러 Post가 연결된다는 것을 의미