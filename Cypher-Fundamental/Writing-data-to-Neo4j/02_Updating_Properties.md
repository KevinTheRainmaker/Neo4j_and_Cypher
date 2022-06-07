## Updating Properties

### Adding properties for a node or relationship

노드나 관계에 프로퍼티를 추가하는 방법에는 크게 두 가지가 있다.

1. `MERGE` 문에 inline으로 삽입

앞서 우리는 `MERGE`문을 사용하여 생성되는 노드의 PK를 설정하는 방법을 알아보았었다. 여기서는 추가 프로퍼티를 설정해보도록 하자.

```sql
MERGE (p:Person {name:'Michael Cain'})
MERGE (m:Movie {title:'Batman Begins'})
MERGE (p)-[:ACTED_IN {roles: ['Alfred Penny']}]->(m)
RETURN p,m
```

![image](https://user-images.githubusercontent.com/76294398/172319914-37e1b051-7a72-4e43-b9d1-fa53b772d501.png)

<br>

위 방식으로 관계에 roles를 설정해줄 수 있다. Person 노드인 Michael Cain은 이미 존재하던 노드이지만 Movie 노드 Batman Begins는 새로운 노드이다. 둘 사이 ACTED_IN 관계를 설정해주었는데, 여기서 roles라는 프로퍼티를 추가해주었다. 중요한 점은, 앞서 노드 프로퍼티를 설정해줄 때와 마찬가지로 JSON 형태의 표현법을 사용했다는 점이다.

<br>

2. `SET` 사용

프러퍼티 값을 설정해주기 위해 `SET` 키워드를 사용할 수도 있다. `MERGE`나 `MATCH`문을 사용할 때 `SET`을 이용해 프로퍼티를 명시하는 방식으로 사용한다.

```sql
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
SET r.roles = ['Alfred Penny'], r.year = 2008
RETURN p, r, m
```

![image](https://user-images.githubusercontent.com/76294398/172321624-0be9c20a-d957-4cab-a2f1-c0865e03bdff.png)

<br>

위 구문을 통해서 Person 노드 Michael Cain과 Movie 노드 The Dark Knight를 관계 ACTED_IN으로 연결했으며, `SET`을 이용해 프로퍼티 role과 year을 추가하였다. 이처럼 여러 개의 프로퍼티를 추가하는 것도 하나의 Cypher 블럭 안에서 수행 가능하며, 다음과 같은 형태로도 가능하다.

```sql
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
SET r = {roles: ['Alfred Penny'], year: 2008}
RETURN p, r, m
```

<br>

### Updating & Removing properties

`MATCH`를 통해 노드를 reference한 경우 `SET`을 이용한 프로퍼티 업데이트 또한 가능하다. 다음 구문을 통해 Michael Cain의 The Dark Knight에서의 roles를 업데이트 해보자.

```sql
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
SET r.roles = ['Mr. Alfred Penny']
RETURN p, r, m
```

![image](https://user-images.githubusercontent.com/76294398/172322932-f16b3c6b-546b-4c79-a9e1-481f9c184b83.png)

<br>

프로퍼티를 삭제하고 싶을 때는 `REMOVE` 키워드를 사용하면 된다.

```sql
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
REMOVE r.roles
RETURN p, r, m
```

![image](https://user-images.githubusercontent.com/76294398/172323703-2017351b-0879-492d-b03e-38fec9ef49ea.png)

<br>

또한 `SET`에서 특정 프로퍼티를 null로 설정함으로써 프로퍼티를 삭제할 수 있다.

```sql
MATCH (p:Person)
WHERE p.name = 'Gene Hackman'
SET p.born = null
RETURN p
```

![image](https://user-images.githubusercontent.com/76294398/172324107-116e14fd-12ce-4e1b-88d1-21828d300958.png)

### Check your understanding

![image](https://user-images.githubusercontent.com/76294398/172324746-549771ba-f5c2-492a-bc0b-37b84a6ca99d.png)

![image](https://user-images.githubusercontent.com/76294398/172324886-ec5215f5-782a-457c-a7e1-f40edebb89bb.png)

<br>
