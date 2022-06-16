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
