## Deleting Data

### Deleting a node

Person 노드를 생성한 후 이를 삭제해보도록 하자.

```sql
MERGE (p:Person {name: 'Jane Doe'})
```

노드를 삭제할 때는 먼저 `MATCH`문으로 retrieve한 후 해당 노드를 삭제하는 방식으로 진행된다.

```sql
MATCH (p:Person)
WHERE p.name = 'Jane Doe'
DELETE p
```

<br>

### Deleting a relationship

관계를 삭제할 때도 이와 비슷한 과정을 거친다. Person 노드 Jane Doe(다시 생성한다)와 Movie 노드 The Matrix 사이 관계를 설정하고, 이를 삭제해보도록 하자.

```sql
MATCH (m:Movie {title: 'The Matrix'})
MERGE (p:Person {name: 'Jane Doe'})
MERGE (p)-[:ACTED_IN]->(m)
RETURN p, m
```

![image](https://user-images.githubusercontent.com/76294398/172538437-8fcb595e-e3a3-4af3-974f-3416a095127e.png)

관계 삭제 시엔 패턴을 retrieve한 후 삭제하고자 하는 부분을 삭제하면 된다. 여기서는 노드는 그대로 두고 관계만 삭제해보도록 하겠다.

```sql
MATCH (p:Person {name:'Jane Doe'})-[r:ACTED_IN]->(m:Movie {title: 'The Matrix'})
DELETE r
RETURN p, m
```

![image](https://user-images.githubusercontent.com/76294398/172539244-ff6b9ea0-ee45-481d-890b-9b1b58dc1ed0.png)

만약 여기서 관계를 삭제하지 않고, 이와 연결된 노드를 삭제하면 어떻게 될까?

```sql
MATCH (p:Person {name: 'Jane Doe'})
MATCH (m:Movie {title: 'The Matrix'})
MERGE (p)-[:ACTED_IN]->(m)
RETURN p, m
```

```sql
MATCH (p:Person {name: 'Jane Doe'})
DELETE p
```

![image](https://user-images.githubusercontent.com/76294398/172539451-fcfe2d5c-d789-486b-a534-0447e4165ae4.png)

이 경우 위와 같이, `ConstraintValidationFailed` 에러가 발생한다.

<br>

### Deleting a node and its relationships

위에서 봤듯이, Neo4j는 relation이 걸려있는 노드에 대한 삭제를 제한한다. 이를 통해 홀로 떨어진 relationship (orphaned relationship)이 생기는 것을 방지한다.

그렇다면 관계가 있는 노드는 관계를 모두 삭제한 후 삭제해야할까? 그런 것은 아니다. 다음과 같은 질의문을 통해 관계를 `DETACH`하고 삭제를 진행할 수 있다.

```sql
MATCH (p:Person {name: 'Jane Doe'})
DETACH DELETE p
```

![image](https://user-images.githubusercontent.com/76294398/172540382-91b9ae40-6c14-4a03-ac7e-b4636e73cfc3.png)

만약 전체 노드와 관계를 한 번에 제거하고 싶다면 다음 쿼리문을 실행하면 된다. 다만 이 쿼리문은 되도록이면 사용하지 않을 것을 권장한다. 전체 데이터베이스를 삭제하는 경우는 거의 없을뿐만 아니라 전체를 조회 후 삭제하는 방식이기 때문에 큰 데이터베이스에 대해 수행할 경우 Out of Memory 에러를 발생시킬 수 있다.

```sql
MATCH (n)
DETACH DELETE n
```

<br>

### Deleting labels

최적의 퍼포먼스를 위해서는 노드 당 최소 1개의 레이블, 최대 4개의 레이블을 가지는 것이 좋다. 실습을 위해 다음 질의문을 이용해 Person 노드 Jane Doe를 생성하고 Developer 레이블을 추가해보자.

```sql
MERGE (p:Person {name: 'Jane Doe'})
RETURN p
```

```sql
MATCH (p:Person {name: 'Jane Doe'})
SET p:Developer
RETURN p
```

![image](https://user-images.githubusercontent.com/76294398/172542055-61bba9e9-21d2-4836-a6ff-3c6dbd923516.png)

이렇게 만들어진 레이블을 삭제해보자. 여기서는 `REMOVE`문을 사용하면 된다.

```sql
MATCH (p:Person {name: 'Jane Doe'})
REMOVE p:Developer
return p
```

![image](https://user-images.githubusercontent.com/76294398/172542288-1ff0ece4-55c9-409f-b248-6d58860d5281.png)

<br>

\* 그래프 내 레이블의 종류를 알고싶다면 다음 쿼리문을 사용하면 된다.

```sql
CALL db.labels()
```

![image](https://user-images.githubusercontent.com/76294398/172542571-894e12d6-f044-49ce-ba4f-455f79ccbade.png)

<br>

### Check your understanding

![image](https://user-images.githubusercontent.com/76294398/172542680-9cc68849-2355-43d4-be18-2ee265d5303d.png)

![image](https://user-images.githubusercontent.com/76294398/172542751-49d21556-21c7-4e03-a733-b6fd53827cb9.png)

<br>
