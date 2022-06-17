## Real-time Recommendation using Northwind

### Load CSVs for Northwind

Northwind Dataset에는 다음과 같은 테이블이 존재하며, ERD 모델링은 다음과 같다.

여기서 우리는 Suppliers, Products, Categories, Orders, Order Details, Customers 테이블만을 사용할 예정이며, 이 중 Order Detail의 경우 Orders 테이블과 Products 테이블 사이 Relationship을 만드는데에 사용될 것이다.

<br>

![image](https://user-images.githubusercontent.com/76294398/173993649-bfc41904-8c26-4e92-b680-f67afe4c5e8a.png)

<br>

각 데이터셋은 Neo4j 공식 홈페이지에서 다운로드가 가능하며, <a href='https://github.com/KevinTheRainmaker/Neo4j_and_Cypher/blob/main/Cypher-Fundamental/E-Commerce/load-northwind.cypher'>이곳</a>에 작성된 쿼리문들을 사용하여 다운로드할 수도 있다. 해당 쿼리를 실행시키면 Node 1,035개(6 labels)와 Relationship 3,139개(4 types)를 로드할 수 있다.

<br>

![image](https://user-images.githubusercontent.com/76294398/174000481-71640047-dde2-4f6e-9f77-067774fca622.png)

<br>

여기서 우리는 '고객'에게 '상품'을 '추천'하는 기능에 초점을 맞출 것이므로, 가장 중요하게 볼 부분은 (Customer)-[:PURCHAESD]->(Order)-[:ORDERS]->(Product)이다.

<br>

### Popular Products

데이터셋 내에서 가장 인기 있는 상품을 찾으려면 '상품'이 '고객'에 의해 '주문'된 횟수를 살피면 된다. 따라서 쿼리는 다음과 같이 작성된다.

```sql
MATCH
(c:Customer)-[:PURCHASED]->(o:Order)
-[:ORDERS]->(p:Product)
RETURN
c.companyName,
p.productName,
count(o) as order_counts
ORDER BY order_counts DESC
LIMIT 5
```

![image](https://user-images.githubusercontent.com/76294398/174002209-14bb3dbb-d16e-4820-b7f6-4e4a23a21652.png)

<br>

위 쿼리에서는 companyName 또한 추출하였는데, 이는 가지고 있는 데이터셋 내에 고객 정보가 있는 경우만을 카운팅하여 오류를 줄이기 위해 설정한 것으로, 모든 데이터가 수집되고 관리되는 실서비스에서는 제외하기도 한다.

<br>

### Content Based Recommendations

고객의 주문 내역을 바탕으로 추천을 수행하는 가장 쉬운 방법 중 하나인 Content Based Recommendation을 진행해보자. 고객 ID 'ANTON'이 구매하지 않은 상품 중, 과거 ANTON이 구매한 상품의 카테고리를 가지는 상품을 추출해보자.

```sql
MATCH
(cust:Customer)-[:PURCHASED]->(o:Order)
-[:ORDERS]->(p:Product)
<-[:ORDERS]-(o2:Order)-[:ORDERS]->(p2:Product)-[:PART_OF]->(c:Category)
<-[:PART_OF]-(p)
WHERE cust.customerID = 'ANTON'
AND
NOT((cust)-[:PURCHASED]->(:Order)-[:ORDERS]->(p2))
RETURN
cust.companyName,
p.productName as has_purchased,
p2.productName as has_also_purchased,
collect(c.categoryName) as categories,
count(DISTINCT o2) as occurences
ORDER BY occurences DESC
LIMIT 5
```

![image](https://user-images.githubusercontent.com/76294398/174006342-79f8b153-5799-40d6-b507-d42fa767682a.png)

<br>

### Collaborative Filtering

Collaborative Filtering은 다른 고객의 피드백을 바탕으로 Content Based Recommendation을 하는 방식이라 할 수 있다. 이러한 피드백을 얻기 위해 여기서는 order_count를 이용해 rating을 생성한 후 활용하도록 하겠다.

이를 위해 k-NN 알고리즘을 사용할 수 있다. 각 아이템은 유사도를 기반으로 grouping 된다.

다음 쿼리문을 이용해 rating relationship을 생성하도록 하자.

```sql
MATCH
(c:Customer)-[:PURCHASED]->(o:Order)-[:ORDERS]->(p:Product)
WITH c, count(p) as total
    MATCH (c)-[:PURCHASED]->(o:Order)-[:ORDERS]->(p:Product)
    WITH c, total, p, count(o)*1.0 as orders
    MERGE (c)-[rated:RATED]->(p)
    ON CREATE SET rated.rating = orders/total
    ON MATCH SET rated.rating = orders/total
    WITH
    c.companyName as company,
    p.productName as product,
    orders, total,
    rated.rating as rating
    ORDER BY rating DESC
    RETURN company, product, orders, total, rating
    LIMIT 10
```

<br>

이로 인해 (Customer)-[:RATED]->(Product) 관계가 생성되었다.

<br>

점수는 0~1 사이 점수로, 현재 데이터에서는 0.5가 최대치인 것으로 나타났다.

<br>

![image](https://user-images.githubusercontent.com/76294398/174014767-a6ac39e2-40e3-440e-a567-5260dc563aa1.png)

<br>

이렇게 생성된 rating을 기반으로 두 고객의 선호도를 비교해보도록 하자.
아래 쿼리문을 이용하면 고객 ID ANTON인 고객이 rating한 상품에 대해 다른 고객이 rating한 점수차를 확인할 수 있다.

```sql
MATCH
(c1:Customer {customerID: 'ANTON'})-[r1:RATED]->(p:Product)
<-[r2:RATED]-(c2:Customer)
RETURN
c1.customerID, c2.customerID,
p.productName,
r1.rating, r2.rating,
CASE WHEN
r1.rating < r2.rating
THEN r2.rating-r1.rating
ELSE r1.rating-r2.rating
END AS difference
ORDER BY difference ASC
LIMIT 15
```

이제 위에서 얻은 점수 차이를 이용하면 고객간 코사인 유사도 점수를 relationship으로 생성할 수 있다.

```sql
MATCH
(c1:Customer)-[r1:RATED]->(p:Product)
<-[r2:RATED]-(c2:Customer)
WITH
    SUM(r1.rating*r2.rating) as dot_product,
    SQRT(REDUCE(x=0.0, a IN COLLECT(r1.rating) | x + a^2)) as r1_length,
    SQRT(REDUCE(y=0.0, b IN COLLECT(r2.rating) | y + b^2)) as r2_length,
    c1, c2
MERGE (c1)-[s:SIMILALITY]-(c2)
SET s.similarity = dot_product / (r1_length * r2_length)
```

그럼 ANTON과 비슷한 고객을 상위 10명 추출해보자.

```sql
MATCH
(me:Customer {customerID:'ANTON'})-[r:SIMILALITY]->(them:Customer)
RETURN
me.companyName AS customer_1,
them.companyName AS customer_2,
toInteger(r.similarity*100) AS sim_score
ORDER BY r.similarity DESC
```

<br>

![image](https://user-images.githubusercontent.com/76294398/174029273-8a4f19b3-e254-4414-829e-a5cb9562e38e.png)

<br>

이제 위 결과를 바탕으로 추천을 수행해보자.

```sql
WITH 1 as neighbours
MATCH (me:Customer)-[:SIMILALITY]->(c:Customer)-[r:RATED]->(p:Product)
WHERE me.customerID = 'ANTON'
AND NOT ( (me)-[:RATED]->(p) )
WITH p,
COLLECT(r.rating)[0..neighbours] as ratings,
COLLECT(c.companyName)[0..neighbours] as customers
WITH p, customers,
REDUCE(s=0,i in ratings | s+i) / SIZE(ratings)  as recommendation
ORDER BY recommendation DESC
WITH p, customers, toFloat(recommendation) AS score
RETURN
p.productName as product,
customers,
round(1000 * score)/10 as score
LIMIT 10
```

위 쿼리를 통해 ANTON과 유사한 사용자가 평가한(주문한) 상품 중 ANTON이 평가하지 않은 상품들을 검색하였다. 이렇게 추출된 사용자들의 rating을 평균 내어 recommendation이라는 변수로 작성 후 이를 높은 순으로 추출하였다.

<br>

![image](https://user-images.githubusercontent.com/76294398/174207942-c8889b41-2aa9-4910-9631-c182bde2db57.png)

<br>

여기서 최상단 neighbours 변수를 1이 아닌 수로 변경하면 더 깊은 탐색이 가능하다.

<br>

![image](https://user-images.githubusercontent.com/76294398/174208210-36a4cff6-9344-46f1-8f87-a3e542089e7e.png)

<br>
