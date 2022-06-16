// Products
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/products.csv" AS pro
CREATE (p:Product)
SET p = pro,
p.unitPrice = toFloat(pro.unitPrice),
p.unitsInStock = toInteger(pro.unitsInStock), 
p.unitsOnOrder = toInteger(pro.unitsOnOrder),
p.reorderLevel = toInteger(pro.reorderLevel), 
p.discontinued = (pro.discontinued <> "0");

// Categories
LOAD CSV WITH HEADERS
FROM 'https://data.neo4j.com/northwind/categories.csv' AS cat
CREATE (c:Category);

// Suppliers
LOAD CSV WITH HEADERS 
FROM 'https://data.neo4j.com/northwind/suppliers.csv' AS sup
CREATE (s:Supplier);

// Orders
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/orders.csv" AS ord
CREATE (o:Order)
SET o = ord,
o.shipVia = toInteger(ord.shipVia),
o.freight = toFloat(ord.freight);

// Customers
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/customers.csv" AS cus
CREATE (cust:Customer);

// Order Details - as Realtionship
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/order-details.csv" AS det
MATCH (p:Product), (o:Order)
WHERE p.productID = det.productID 
AND o.orderID = det.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = det,
details.quantity = toInteger(det.quantity);