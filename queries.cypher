MATCH (n) DETACH DELETE n;

// Expenses
CREATE
(gaelle:Person {name: "Gaëlle"}),
(gregory:Person {name: "Gregory"}),
(mathilde:Person {name: "Mathilde"}),
(michel:Person {name: "Michel"}),
(yann:Person {name: "Yann"}),
(gaelle)-[:SPENT {amount: 100}]->(gaelle),
(gregory)-[:SPENT {amount: 35}]->(gregory),
(mathilde)-[:SPENT {amount: 67}]->(mathilde),
(yann)-[:SPENT {amount: 85}]->(yann);

// Debts
MATCH (p:Person)
WITH toFloat(count(p)) AS GuestsCount
MATCH (s:Person)
MATCH (t:Person)
MATCH (s)-[r:SPENT]-(s)
WHERE s <> t
CREATE (t)-[:OWES_TO {amount: round(r.amount / GuestsCount * 100) / 100}]->(s);

// Avoid mutual debts
MATCH (s)-[r1:OWES_TO]->(t)
MATCH (t)-[r2:OWES_TO]->(s)
WHERE r1.amount - r2.amount > 0
// Create a new merged transaction...
CREATE (s)-[:OWES_TO {amount: round((r1.amount - r2.amount) * 100) / 100}]->(t)
// ...Then delete the previous ones
DELETE r1
DELETE r2;

// Sheet of debts
MATCH ()-[r:OWES_TO]->()
WITH
    startNode(r).name AS Debitor,
    endNode(r).name AS Creditor,
    r.amount AS Amount
RETURN Debitor, Amount, Creditor
ORDER BY Debitor, Amount;
