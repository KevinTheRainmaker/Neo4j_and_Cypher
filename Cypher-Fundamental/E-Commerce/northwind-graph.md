## Northwind Graph

Northwind는 Supplier로부터 공급되는 다양한 Category의 음식 Product를 판매한다.

다음 표는 세 개체군 Suppliers, Products, Categories가 가지는 프로퍼티를 나타내며, PK는 **굵을 글씨**로, FK는 *이탤릭체*로 나타내었다.

<br>

| Suppliers      | Products        | Categories     |
| -------------- | --------------- | -------------- |
| **SupplierID** | **ProductID**   | **CategoryID** |
| CompanyName    | ProductName     | CategoryName   |
| ContactName    | _SupplierID_    | Description    |
| Address        | _CategoryID_    | Picture        |
| City           | QuantityPerUnit |                |
| Region         | UnitsInStock    |                |
| PostalCode     | UnitsOnOrder    |                |
| Country        | ReorderLevel    |                |
| Phone          | Discontinued    |                |
| Fax            |                 |                |
| HomePage       |                 |

<br>

### Product Catalog

먼저 CSV 형태의 Product catalog 테이블을 그래프로 load해보도록 하자.

![image](https://user-images.githubusercontent.com/76294398/173306492-deb19044-4171-41d5-b101-c71779b79387.png)

CSV 데이터는 위와 같은 형태로 이루어져있으며 해당 데이터는 Neo4j 공식 홈페이지에 올라와있다.

```sql
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/products.csv" AS row
CREATE (n:Product)
SET n = row,
n.unitPrice = toFloat(row.unitPrice),
n.unitsInStock = toInteger(row.unitsInStock), n.unitsOnOrder = toInteger(row.unitsOnOrder),
n.reorderLevel = toInteger(row.reorderLevel), n.discontinued = (row.discontinued <> "0")
```

해당 작업을 수행하면 Product 개체 77개가 노드로서 생성된다.

<br>

![image](https://user-images.githubusercontent.com/76294398/173309073-cf0e4d78-4104-489a-bc0a-c0043d9d966e.png)

마찬가지로 Category 개체와 Supplier 개체도 그래프 형태로 load하자.

다음 쿼리로 인해 로드되는 개체의 수는 Category 8개, Supplier 29개로 총 37개이다.

<br>

```sql
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/categories.csv" AS row
CREATE (n:Category)
SET n = row
```

```sql
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/suppliers.csv" AS row
CREATE (n:Supplier)
SET n = row
```

![image](https://user-images.githubusercontent.com/76294398/173309748-e4c2f581-18eb-4e99-897a-5db947a82ac4.png)

<br>

이렇게 로드된 개체의 프로퍼티 중 PK에는 index를 설정하도록 하겠다.

<br>

```sql
CREATE INDEX ON :Product(productID)
```

```sql
CREATE INDEX ON :Category(categoryID)
```

```sql
CREATE INDEX ON :Supplier(supplierID)
```

### Product Catalog Graph

Product, Category, Supplier는 서로 FK를 통해 관계를 가진다.

Category와 Supplier의 PK는 모두 Product에서 FK로 사용되고 참조된다.

Cypher에서는 그래프의 추출을 패턴을 이용해서 하는데, 이때 참조하는 프로퍼티들의 연결 패턴을 이용할 수 있다.

다음 쿼리를 이용하면 Category의 PK인 categoryID를 기준으로 Product를 참조할 수 있으며, 이를 이용해 Product에서 Category로 이어지는 PART_OF라는 Relationship을 생성할 수 있다.

```sql
MATCH (p:Product),(c:Category)
WHERE p.categoryID = c.categoryID
CREATE (p)-[:PART_OF]->(c)
```

![image](https://user-images.githubusercontent.com/76294398/173311234-39207ab9-8d8c-4bd0-91bf-db682055b997.png)

SQL에서 관계를 추출하기 위해서는 매번 join을 통해 수행했어야 했지만, 그래프에서는 최초 한 번만 참조하여 관계를 생성하면 그 다음부터는 별도의 참조 없이 추출이 가능하다.

같은 방법으로, Supplier의 PK인 supplierID를 기준으로 Supplier에서 Product로 이어지는 관계 SUPPLIES를 생성해보자.

```sql
MATCH (p:Product),(s:Supplier)
WHERE p.supplierID = s.supplierID
CREATE (s)-[:SUPPLIES]->(p)
```

![image](https://user-images.githubusercontent.com/76294398/173312078-b53dbeb9-2d90-4bc0-8a9e-b77243219963.png)

<br>

### Query using patterns

그래프 데이터를 질의할 때는 패턴을 기준으로 질의를 수행한다. 몇 가지 쿼리문을 통해 이를 수행해보자.

```sql
MATCH
(s:Supplier)-[:SUPPLIES]->(p:Product)-[:PART_OF]->(c:Category)
RETURN
s.companyName as Company,
p.productName as Product,
collect(distinct c.categoryName) as Categories
```

![image](https://user-images.githubusercontent.com/76294398/173500942-d63ce4f0-46de-40ee-bab1-7e5ad54a7894.png)

위 쿼리문을 사용하면 Supplier부터 Product를 거쳐 Category까지 가는 패턴에서 필요한 내용들을 추출할 수 있다. 관계를 명시할 수도 있고, 예제 데이터처럼 A 개체에서 B 개체로 이어지는 관계가 한 종류만 있는 경우 생략도 가능하다.
또한 collect를 사용하면 여러 개의 데이터를 하나의 리스트로 묶을 수도 있다.

<br>

이번엔 다음 쿼리를 이용해서 Product의 Category가 Produce인 상품을 공급하는 Supplier의 companyName을 추출해보자.

```
MATCH
(s:Supplier)-->(p:Product)-->(c:Category)
WHERE c.categoryName = 'Produce'
RETURN
DISTINCT s.companyName as ProduceSuppliers
```

이때 해당 패턴을 만족하는 Path가 여러 개일 경우, 즉 Produce Category를 가진 Product를 공급하는 Supplier가 동일 엔드포인트로 가는 방법이 여러 개일 경우 중복 추출이 있을 수 있다. 따라서 DISTINCT를 이용해 이를 방지한다.

![image](https://user-images.githubusercontent.com/76294398/173502794-67e77d69-4859-4ba1-9ac4-781097ed3813.png)

<br>

### Customer Order Graph

Northwind의 ERD 모델을 보면 Order과 Order Detail이 존재한다. Order는 Customer의 PK인 Customer ID를 FK로 이용하며, Order의 PK인 Oreder ID는 Order Detail에서 FK로 사용되어 Product와의 Join 테이블 역할을 수행한다. 즉 Order Detail은 Order의 일부로, Order과 Product를 연결하는 역할을 한다.

<br>

| Orders         | Order Details |
| -------------- | ------------- |
| **OrderID**    | _OrderID_     |
| _CustomerID_   | _ProductID_   |
| _EmployeeID_   | UnitPrice     |
| OrderDate      | Quantity      |
| RequiredDate   | Discount      |
| ShippedDate    |               |
| ShipVia        |               |
| Freight        |               |
| ShipName       |               |
| ShipAddress    |               |
| ShipCity       |               |
| ShipRegion     |               |
| ShipPostalCode |               |
| ShipCountry    |               |

<br>

먼저 Orders를 노드로 로드한 후 Oreder Detail를 Product와 Order를 잇는 relationships로써 로드하도록 하겠다. 즉, 위 표의 OrderDetails의 프로퍼티는 관계 ORDERS의 프로퍼티가 된다.

```sql
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/orders.csv" AS row
CREATE (n:Order)
```

```sql
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/customers.csv" AS row
CREATE (n:Customer)
```

```sql
MATCH (c:Customer), (o:Order)
WHERE c.customerID = o.customerID
CREATE (c)-[:PURCHASED]->(o)
```

![image](https://user-images.githubusercontent.com/76294398/173510092-ce933cfe-b32d-4fee-ae43-1beddb78e4db.png)

<br>

```sql
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.productID = row.productID AND o.orderID = row.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity)
```

```sql
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.productID = row.productID AND o.orderID = row.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity)
```

![image](https://user-images.githubusercontent.com/76294398/173507430-e2d784ff-29c2-4c96-bff6-6cd090a0f0c7.png)

<br>

이제 이렇게 로드한 데이터에서 패턴을 이용한 질의를 수행해보도록 하자.

다음 쿼리문은 Produce 카테고리를 가진 프로덕트를 주문한 사람의 이름과 해당 프로덕트가 총 구매된 개수를 추출한다.

```sql
MATCH
(cust:Customer)-[:PURCHASED]->(:Order)-[o:ORDERS]->(p:Product),
(p)-[:PART_OF]->(c:Category {categoryName:"Produce"})
RETURN DISTINCT
cust.contactName as CustomerName,
SUM(o.quantity) AS TotalProductsPurchased
```

![image](https://user-images.githubusercontent.com/76294398/173510598-4c4650fa-2b8d-4310-9f52-915a7848b7b1.png)

<br>
