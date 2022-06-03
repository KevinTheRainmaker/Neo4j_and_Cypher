## Traversing Relationships

### Finding Relationships

앞서 우리는 `MATCH` 구문으로 특정 노드를 추출하는 방법을 알아보았다. 이번엔 여기에 관계를 나타내는 구문을 추가해서 관계 탐색을 진행해보도록 하겠다.

```sql
MATCH (p:Person {name: 'Tom Hanks'})-[:ACTED_IN]->(m)
RETURN m.title
```

<img width="90%" alt="image" src="https://user-images.githubusercontent.com/76294398/171769489-b75ba654-45bd-4b6d-af97-d95fc5f6ea22.png">

<br>

위 쿼리문을 통해 Tom Hanks가 연기한 영화의 이름을 추출할 수 있다.

현재 우리가 사용하고 있는 데이터에는 Person과 Movie 레이블만 존재하므로 위와 같이 진행해도 무방하지만, Person과 ACTED_IN으로 연결된 개체의 레이블이 여러 개일 때, 가령 Drama와 Movie일 때, 다음과 같은 방법으로 타겟 레이블을 설정할 수 있다.

```sql
MATCH (p:Person {name: 'Tom Hanks'})-[:ACTED_IN]->(m:Movie)
RETURN m.title
```

물론 방향만 잘 명시하면 쿼리 내 개체 순서는 중요하지 않다.

```sql
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person {name: 'Tom Hanks'})
RETURN m.title
```
