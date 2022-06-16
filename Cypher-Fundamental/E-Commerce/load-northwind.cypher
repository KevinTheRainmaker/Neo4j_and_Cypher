// Products
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/products.csv" AS row
CREATE (n:Product)
SET n = row,
n.unitPrice = toFloat(row.unitPrice),
n.unitsInStock = toInteger(row.unitsInStock), 
n.unitsOnOrder = toInteger(row.unitsOnOrder),
n.reorderLevel = toInteger(row.reorderLevel), 
n.discontinued = (row.discontinued <> "0")

// Categories
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/categories.csv"
CREATE (n:Category)

// Suppliers
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/suppliers.csv"
CREATE (n:Supplier)

// Orders
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/orders.csv" AS row
CREATE (n:Order)
SET n = row,
n.shipVia = toInteger(row.shipVia),
n.freight = toFloat(row.freight)

// Customers
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/customers.csv"
CREATE (n:Customer)

// Order Details - as Realtionship
LOAD CSV WITH HEADERS 
FROM "https://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.productID = row.productID 
AND o.orderID = row.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity)