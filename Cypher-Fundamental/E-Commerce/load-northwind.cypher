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
CREATE (c:Category)
SET c = cat;

// Suppliers
LOAD CSV WITH HEADERS 
FROM 'https://data.neo4j.com/northwind/suppliers.csv' AS sup
CREATE (s:Supplier)
SET s = sup;

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
CREATE (cust:Customer)
SET cust = cus;

// Order Details - as Realtionship
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/order-details.csv" AS det
MATCH (p:Product), (o:Order)
WHERE p.productID = det.productID 
AND o.orderID = det.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = det,
details.quantity = toInteger(det.quantity);

// Create index on PK: Products, Cateegories, Suppliers
CREATE INDEX ON :Product(productID);

CREATE INDEX ON :Category(categoryID);

CREATE INDEX ON :Supplier(supplierID);

CREATE INDEX ON :Order(orderID);

CREATE INDEX ON :Customer(customerID);

// Products to Categories: PART_OF
MATCH (p:Product),(c:Category)
WHERE p.categoryID = c.categoryID
CREATE (p)-[:PART_OF]->(c);

// Products to Suppliers: SUPPLIES
MATCH (p:Product),(s:Supplier)
WHERE p.supplierID = s.supplierID
CREATE (s)-[:SUPPLIES]->(p);

// Customers to Orders: PURCHASED
MATCH (c:Customer), (o:Order)
WHERE c.customerID = o.customerID
CREATE (c)-[:PURCHASED]->(o);