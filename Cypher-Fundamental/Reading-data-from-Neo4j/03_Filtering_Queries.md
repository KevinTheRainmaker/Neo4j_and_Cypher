## Filtering Queries

앞서 우리는 `WHERE` 구문으로 필터링을 수행하는 방법에 대해 알아보았다.

```sql
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.released = 2008 OR m.released = 2009
RETURN p, m
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171771351-d943dd87-386f-43fb-b456-6a280957d39c.png">

<br>

위와 같은 방식으로 2008년과 2009년에 릴리즈된 영화와 배우에 대한 정보들을 가져올 수 있다.

이처럼 필터링은 쿼리문 작성에 필수적인 요소 중 하나이다.
필터링하는 방법을 좀더 자세히 알아보도록 하자.

<br>

### Filtering by node labels

노드의 프로퍼티를 이용해서 필터링을 하는 방식은 기본적으로 다음과 같다.

```sql
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.title='The Matrix'
RETURN p.name
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171771851-e35e9bb0-9230-4914-9bd8-1f364d668c39.png">

<br>

위 구문은 `WHERE` 구문에 `AND`를 넣는 방식을 이용하면 다음과 같이도 표현할 수 있다.

```sql
MATCH (p)-[:ACTED_IN]->(m)
WHERE p:Person AND m:Movie AND m.title='The Matrix'
RETURN p.name
```

<br>

### Filtering using ranges

필터링 조건에 범위를 지정할 수도 있다. 다음 쿼리문을 통해 2000년과 2003년 사이 릴리즈된 영화의 배우들을 질의해보자.

```sql
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE 2000 <= m.released <= 2003
RETURN p.name, m.title, m.released
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171772358-f406d86f-2656-4c16-a2b3-562f84abf533.png">

<br>

### Filtering by existence of a property

간혹 노드나 관계에 요청하는 프로퍼티 값이 존재하지 않는 경우도 있다. 이럴 때, 해당 프로퍼티가 존재하는 경우에만 값을 추출하고 싶다면 다음과 같은 방법을 사용할 수 있다.

```sql
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name='Jack Nicholson' AND m.tagline IS NOT NULL
RETURN m.title, m.tagline
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171772727-53976653-4765-4c31-90be-b2fa239747e2.png">

<br>

위 쿼리문을 통해, Jack Nicholson이 연기한 영화 중 tagline 속성이 있는 영화만 추출하였다. 데이터베이스 내 Jack Nicholson이 배우로 등장하는 영화는 5편이지만, 그중 한 편은 tagline이 없어 추출에서 배제되었음을 확인할 수 있다.

<br>

### Filtering by partial strings

Cypher에서는 `WHERE` 절에서 사용할 수 있는 string-related keyword를 지원한다. `STARTS WITH`, `ENDS WITH`, `CONTAINS`를 이용하여 수행할 수 있다.

```sql
MATCH (p:Person)-[:ACTED_IN]->()
WHERE p.name STARTS WITH 'Michael'
RETURN p.name
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171776284-78fd0d18-6ca5-440d-8df1-4f384cd9bb4d.png">

<br>

위 쿼리를 이용해 배우 중 First name이 Michael인 사람을 추출했다.

여기서 주의할 점은, 이러한 string test는 case-sensitive 하다는 점인데, 이로 인한 혼동을 방지하기 위해 `toLower()`이나 `toUpper()` 함수를 함께 사용하는 것을 권장한다.

```sql
MATCH (p:Person)-[:ACTED_IN]->()
WHERE toLower(p.name) STARTS WITH 'michael'
RETURN p.name
```

<br>

### Filtering by patterns in the graph

그래프의 프로퍼티 패턴을 이용해 필터링을 수행할 수도 있다.

다음 쿼리문은 영화를 Wrote하였지만, 그 영화를 Direct하지는 않은 사람의 이름과 영화 제목을 추출하는 쿼리이다.

```sql
MATCH (p:Person)-[:WROTE]->(m:Movie)
WHERE NOT exists( (p)-[:DIRECTED]->(m) )
RETURN p.name, m.title
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171777483-8d868b90-3c9a-4f28-ab02-f149fcf628a5.png">

<br>

### Filtering using lists

하나의 조건에 대하여 여러 값을 조건 값으로 걸고자 할 때는 list를 사용할 수 있다. 이때는 `WHERE`문 내에 `IN`을 사용하여 수행한다.

```sql
MATCH (p:Person)
WHERE p.born IN [1965, 1970, 1975]
RETURN p.name, p.born
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171778592-aa8d8458-d6e0-4a8f-a64e-a0d2cacfa3e9.png">

<br>

기존 리스트와 비교하는 방식으로도 사용이 가능하다. 대표적인 사용법으로는 프로퍼티 중 리스트로 되어있는 값을 확인하여 추출하는 방법이 있다.

```sql
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE  'Neo' IN r.roles AND m.title='The Matrix'
RETURN p.name, r.roles
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171778887-e7df0ee0-b6de-4eaf-8143-9866c643e94f.png">

<br>

### What properties does a node or relationship have?

간혹 노드나 관계가 가진 프로퍼티가 무엇인지 잊어버리는 경우가 있다. 또는 특정 대상이 가진 프로퍼티가 무엇인지 알고 싶은 경우도 있을 것이다. 이럴 때 사용할 수 있는 함수가 바로 `keys()` 함수이다.

```sql
MATCH (p:Person)
RETURN p.name, keys(p)
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171788288-62390e96-f717-43ef-b0d1-162385a71ee4.png">

<br>

`keys()` 함수는 해당 노드의 모든 프로퍼티를 list 형태로 반환한다.

<br>

### What properties exist in the graph?

위의 경우를 확장시켜서, 그래프 내 정의된 모든 프로퍼티를 알고 싶다면 다음 쿼리를 실행시키면 된다.

```sql
CALL db.propertyKeys()
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171788583-e17f5960-1665-4fb7-b06e-d181fdbb2bb0.png">

<br>

### Check your understanding

![image](https://user-images.githubusercontent.com/76294398/171788813-b76c6528-66c6-4106-a873-3e6f428408a9.png)

![image](https://user-images.githubusercontent.com/76294398/171788879-6b0dd714-6251-4cd5-b975-9deb9bd01cfb.png)

<br>
