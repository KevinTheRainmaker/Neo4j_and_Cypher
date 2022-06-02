## Introduction to Cypher

### What is Cypher?

Cyper는 대표적인 그래프 질의 언어 중 하나이다. 그래프 데이터에 대해서 더 알고 싶다면 다음을 참조.

<a href='https://kevin-rain.tistory.com/category/ML%26DL/%EA%B7%B8%EB%9E%98%ED%94%84%20%EB%8D%B0%EC%9D%B4%ED%84%B0'>티스토리: 그래프 데이터</a>

우리는 그래프 데이터를 다룰 때 개체는 도형으로, 관계는 화살표로 그리는 경향이 있다. 이러한 경향성은 Cypher에서 pattern의 형태로 나타난다.

- 노드(Node)는 소괄호로 나타낸다.

  $\rightarrow$ ( )

- 노드 간의 관계(Relationship)는 대쉬 표시 두 개로 나타낸다.

  $\rightarrow$ (:Person) -- (:Movie)

- 관계에 방향(direction)이 있을 경우 < 나 > 로 뱡향을 표시한다.

  $\rightarrow$ (:Person) --> (:Movie)

- 관계의 타입(type)은 []를 대쉬 두 개 사이에 넣는 것으로 표현한다.

  $\rightarrow$ (:Person) -[:ACTED_IN]-> (:Movie)

- 여러 프로퍼티(property)를 나타내고자 할 때는 JSON과 비슷하게 표현할 수 있다.

  $\rightarrow$ {"born": 1964, "name": "Keanu Reeves"}

<br>

### How Cypher works?

Cypher는 데이터 내 pattern을 찾는 방식으로 동작한다. 이를 위해 우리는 `MATCH` 키워드를 사용할 것이다. 이는 SQL 구문에서 `FROM`과 비슷하다고 이해할 수 있다.

```sql
// Person label의 모든 데이터 찾기
MATCH (p:Person)
RETURN p
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171591236-201b8286-c573-45e4-a860-0b772ee20e09.png">

<br>

그렇다면 특정 프로퍼티를 가진 데이터만 추출하고자 할 경우 어떻게 하면 될까?

이 경우 레이블 뒤에 {}로 감싸진 프로퍼티 조건을 추가하면 된다.

```sql
// name 프로퍼티가 Tom Hanks인 데이터만 추출
MATCH (p:Person {name: 'Tom Hanks'})
RETURN p
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171592166-9dbb72dd-b8df-4e24-8b6f-10ecd43f7d4c.png">

<br>

이로써 Person label의 데이터 중 name 프로퍼티가 Tom Hanks인 데이터만 추출하였다. 여기서 Tom Hanks의 born 프로퍼티 값을 알고 싶으면 다음과 같이 수행하면 된다.

```sql
MATCH (p:Person {name: 'Tom Hanks'})
RETURN p.born
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171592601-38730e64-f44e-449a-874c-129e77cdd98e.png">

<br>

위 쿼리는 Tom Hanks 노드의 born 프로퍼티를 반환한다.

앞서 진행한 쿼리와 같은 결과를 얻기 위해, `WHERE` 구문을 사용할 수도 있다.

```sql
MATCH (p:Person)
WHERE p.name = 'Tom Hanks'
RETURN p.born
```

<br>

`WHERE` 구문을 이용해 쿼리 필터링을 수행할 경우 조건을 손쉽게 추가할 수 있기 때문에 좀더 복잡한 질의를 수행하고자 할 때 유용하다.

```sql
MATCH (p:Person)
WHERE p.name = 'Tom Hanks' OR p.name = 'Rita Wilson'
RETURN p.name, p.born
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171593923-1b12495c-c719-494a-8407-49e747d3dace.png">

<br>

### Check your understanding

![image](https://user-images.githubusercontent.com/76294398/171594217-a9d787f3-ed0c-409e-8e3f-323ff3d5b2ae.png)

![image](https://user-images.githubusercontent.com/76294398/171594469-b54594d6-3948-4067-9723-8b9d5dbefe8c.png)

![image](https://user-images.githubusercontent.com/76294398/171594625-d95e4a0d-27a5-4e4c-ac0d-776ac5fd787e.png)
