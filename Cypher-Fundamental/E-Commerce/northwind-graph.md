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
