## Merge Processing

### Customizing `MERGE` Behavior

`MERGE`문의 작동은 먼저 데이터 패턴을 그래프로부터 찾는 것으로 시작된다. 기존의 패턴이 찾아지면 조회만 하고 생성은 하지 않는다. 만약 패턴이 존재하지 않는다면 새로운 데이터를 생성하여 추가한다.

이 과정에 `ON CREATE SET` 혹은 `ON MATCH SET` 구문으로 동작 커스터마이징이 가능하다.

```sql
-- 찾거나, 만들거나
MERGE (p:Person {name:'McKenna Grace'})

-- 생성될 경우에만 createdAt 프로퍼티 설정
ON CREATE SET p.createdAt = datetime()

-- 데이터가 찾아져서 업데이트 되는 경우에만 updatedAt 프로퍼티 업데이트
ON MATCH SET p.updatedAt = datetime()

-- 위 과정과 무관하게 born 프로퍼티 설정
SET p.born = 2006

RETURN p
```

\* 주의) 여기서는 sql 문법을 사용해서 표기했기에 주석이 --로 달려있지만, Cypher 문법에서는 주석을 //로 표기한다.

![image](https://user-images.githubusercontent.com/76294398/172330993-8fcbb801-f505-4202-a8d7-2a4ea46caf74.png)

<br>

다음은 업데이트 된 경우이다. createdAt 프로퍼티는 수정이 되지 않고, updatedAt 프로퍼티가 생긴 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/76294398/172331303-3917a742-2919-4447-8458-ea69dcc571b6.png)

<br>

`ON CREATED SET`이나 `ON MATCH SET`에서도 콤마(,)로 구분하여 여러 개의 프로퍼티를 설정할 수 있다.

```sql
ON CREATE SET m.released = 2020, m.tagline = `A great ride!'
```

<br>

### Merging relationships

만약 우리가 Person 노드 Michael Cain과 Movie 노드 The Cider House Rules를 ACTED_IN 관계로 연결하고 싶다고 가정할 때, 다음과 같은 쿼리를 날리면 에러가 발생한다.

```sql
MERGE (p:Person {name: 'Michael Cain'})-[:ACTED_IN]->(m:Movie {title: 'The Cider House Rules'})
RETURN p, m
```

위 패턴은 데이터베이스 내에 존재하지 않아 새로운 Person 노드와 Movie 노드를 만들게 되지만, name을 PK로 두는 Person 노드 Micheal Cain이 이미 존재하기 때문에 unique constraints를 위반하게 되고 에러가 발생한다.

이를 방지하기 위해서는 다음과 같이 과정을 분할할 필요가 있다.

```sql
// Find or create a person with this name
MERGE (p:Person {name: 'Michael Cain'})

// Find or create a movie with this title
MERGE (m:Movie {title: 'The Cider House Rules'})

// Find or create a relationship between the two nodes
MERGE (p)-[:ACTED_IN]->(m)
```

이처럼 작성할 경우, 기존에 없던 노드인 Movie 노드와 ACTED_IN 관계만을 생성할 것이다.

### Check your understanding

![image](https://user-images.githubusercontent.com/76294398/172334347-259805f1-8781-43c7-9ef1-577fab3a8bd0.png)

![image](https://user-images.githubusercontent.com/76294398/172334465-299c4b94-dde8-4ca7-8f54-6e1724d21113.png)
