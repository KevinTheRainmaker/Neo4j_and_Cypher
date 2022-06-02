## Reading Data from Neo4j

Neo4j가 기본으로 제공하는 그래프 데이터베이스인 Movie DBMS에서 Person과 Movie 두 개체를 이용해 다음과 같은 내용을 Cypher 질의 언어로 추출하는 방법에 대해서 알아보자.

<img width="70%" alt="image" src="https://user-images.githubusercontent.com/76294398/171582038-94ffbc4a-7121-4158-b7ce-770649526521.png">

- 그래프로부터 노드 추출하기
  - 특정 label을 가진 노드 추출하기
  - property value로 추출 값 필터링하기
  - property value 리턴하기
- graph pattern 이용해서 그래프 노드 및 관계 추출
- 쿼리 필터링
