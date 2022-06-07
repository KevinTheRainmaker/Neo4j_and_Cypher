## Writing data to Neo4j

Neo4j가 기본으로 제공하는 그래프 데이터베이스인 Movie DBMS에서 Person과 Movie 두 개체에 대하여 내용을 Cypher 질의 언어로 생성 및 수정하는 방법에 대해서 알아보자.

<img width="70%" alt="image" src="https://user-images.githubusercontent.com/76294398/171582038-94ffbc4a-7121-4158-b7ce-770649526521.png">

- `MERGE`로 그래프에 노드 생성
- `MERGE`로 그래프에 관계 생성
- 그래트 내 노드와 관계에 대한 CRUD 구현
- 그래프 내 정보에 종속되는 `conditional MERGE` 수행
- 그래프 내 노드 및 관계 삭제
