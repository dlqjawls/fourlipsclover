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