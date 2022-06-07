## Creating Nodes and Relationships

### Creating nodes

Cypher 질의 언어를 이용해서 그래프에 노드를 생성하는 방법에 대해 알아보자.

마찬가지로 Movie Database를 사용할 예정이며 여기에 배우 노드와 영화 노드를 추가해보도록 하자.

패턴 추가에는 `MERGE` 구문을 사용하며 해당 구문 뒤에 우리가 원하는 패턴을 명시하는 방식으로 진행된다. 보통 single node를 명시하거나 두 노드 사이 relationship을 명시하는 형태를 가진다.

```sql
MERGE (p:Person {name: 'Michael Cain'})
```

![image](https://user-images.githubusercontent.com/76294398/172304630-12b2e84e-13d4-4e3c-872b-6f145fb76c42.png)

<br>

위 질의문을 통해 Person 레이블을 가지며 Michael Cain이라는 name 프로퍼티를 가지는 노드를 추가하였다.

다음을 통해 추가된 노드를 확인할 수 있다.

```sql
MERGE (p:Person {name:'Micael Cain'})
RETURN p
```

\* 노드 추가 시 `MERGE` 대신 `CREATE`를 사용할 수도 있다. `CREATE`를 이용하면 Primary Key에 대한 검사를 진행하지 않기 때문에 더 빠르게 노드를 생성할 수 있다는 장점이 있다. 하지만 중복 등을 허용하지 않고자 할 경우에는 `MERGE`를 사용하는 것이 바람직하다.

<br>

### Creating Relationships

기존의 두 개의 노드 사이 관계를 생성하는 방법에 대해 알아보도록 하자.

노드를 생성할 때 `MERGE`를 사용했던 것처럼, 두 노드 사이의 관계를 생성할 때도 `MERGE`를 사용할 수 있다.

관계를 생성할 때는 먼저 서로 잇고자 하는 두 개의 노드를 referencing해야 하며, 관계의 특성을 명시해줘야 한다. 필수적으로 들어가야 할 관계 특성은 다음과 같다.

- Type
- Direction

예를 들어, 다음 구문을 이용하면 다음 구문을 이용해서 기존의 두 노드를 조회하고 관계를 생성할 수 있다.

```sql
MATCH (p:Person {name: 'Michael Cain'})
MATCH (m:Movie {title: 'The Dark Knight'})
MERGE (p)-[:ACTED_IN]->(m)
```

위 구문에 의해 생성된 관계는 다음 구문으로 확인할 수 있다.

```sql
MATCH (p:Person {name: 'Michael Cain'})-[:ACTED_IN]-(m:Movie {title: 'The Dark Knight'})
RETURN p, m
```

![image](https://user-images.githubusercontent.com/76294398/172308217-1b69df1f-3280-4661-ab15-a7f037af968a.png)

<br>

당연한 이야기이지만, 조회 시 관계 방향성을 잘못 설정하면 결과가 리턴되지 않는다.

![image](https://user-images.githubusercontent.com/76294398/172308514-e84f6e5c-f872-458d-9428-9fdf6ed2f8a1.png)

<br>

다만 조회 시에는 방향성을 설정하지 않아도 볼 수는 있다.

<br>

### Execute multiple Cypher clauses

여러 개의 `MERGE` 구문을 연결하여 하나의 Cypher 쿼리처럼 작성할 수 있다.

```sql
MERGE (p:Person {name: 'Katie Holmes'})
MERGE (m:Movie {title: 'The Dark Knight'})
RETURN p,m
```

![image](https://user-images.githubusercontent.com/76294398/172305981-356bef83-07e8-456f-b057-e3804f1510e5.png)

<br>

위 구문을 통해 Person 노드와 Movie 노드를 생성하고 하나의 쿼리문처럼 p와 m을 한번에 반환하였다.

<br>

또한 다음과 같이 관계 또한 한번에 설정할 수도 있다. 아래 쿼리문은 두 개의 노드와 그 사이 관계를 한 블럭 내에서 수행한다.

```sql
MERGE (p:Person {name: 'Chadwick Boseman'}) -- R.I.P. to Boseman
MERGE (m:Movie {title: 'Black Panther'})
MERGE (p)-[:ACTED_IN]-(m)
```

<br>

다음 방식을 사용하면 `MERGE` 구문 하나로 수행할 수도 있다.

```sql
MERGE (p:Person {name: 'Emily Blunt'})-[:ACTED_IN]->(m:Movie {title: 'A Quiet Place'})
RETURN p, m
```

![image](https://user-images.githubusercontent.com/76294398/172309934-95fb5a5e-ee6f-4d1b-a388-78916577d56b.png)

<br>

### Check your understanding

![image](https://user-images.githubusercontent.com/76294398/172306542-d4a24653-8303-4e10-96aa-5ea473f55d34.png)

![image](https://user-images.githubusercontent.com/76294398/172310352-3e9b910a-390f-4a6e-8d59-6da2e124b92b.png)

![image](https://user-images.githubusercontent.com/76294398/172310424-ce26648f-671e-427d-9521-ecf09d13dc72.png)

<br>
