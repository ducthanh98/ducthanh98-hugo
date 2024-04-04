---
title: "Microservice"
date: 2023-11-12T22:53:37+07:00
draft: false
---
# Queue
## What
- RabbitMQ employs a push model and prevents overwhelming users via the consumer configured prefetch limit. This model is an ideal approach for low-latency messaging. It also functions well with the RabbitMQ queue-based architecture. Think of RabbitMQ as a post office, which receives, stores, and delivers mail, whereas RabbitMQ accepts, stores, and transmits binary data messages.
- Kafka employs a “pull-based” approach, letting users request message batches from specific offsets. Users can leverage message batching for higher throughput and effective message delivery.
## Use cases
- Kafka is best used for streaming from A to B without resorting to complex routing, but with maximum throughput
- Use RabbitMQ with long-running tasks, reliably running background jobs, and communication/integration between and within applications.

# Shared database
- Use a (single) database that is shared by multiple services
- Benefits
    + A developer uses familiar and straightforward ACID transactions to enforce data consistency
    + A single database is simpler to operate
- Drawbacks
    + Development time coupling - a developer working on, for example, the OrderService will need to coordinate schema changes with the developers of other services that access the same tables. This coupling and additional coordination will slow down development.
    + Runtime coupling - because all services access the same database they can potentially interfere with one another. For example, if long running CustomerService transaction holds a lock on the ORDER table then the OrderService will be blocked.
    + Single database might not satisfy the data storage and access requirements of all services.

# Database per services
- Different services have different data storage requirements. For some services, a relational database is the best choice. Other services might need a NoSQL database such as MongoDB, which is good at storing complex, unstructured data, or Neo4J, which is designed to efficiently store and query graph data.
- Benefits
    + ensure that the services are loosely coupled. Changes to one service’s database does not impact any other services.
    + Each service can use the type of database that is best suited to its needs. For example, a service that does text searches could use ElasticSearch. A service that manipulates a social graph could use Neo4j.
- Drawback
    + Implementing business transactions that span multiple services is not straightforward. Distributed transactions are best avoided because of the CAP theorem. Moreover, many modern (NoSQL) databases don’t support them.
    + Implementing queries that join data that is now in multiple databases is challenging.
    + Complexity of managing multiple SQL and NoSQL databases

# Command Query Responsibility Segregation (CQRS)
- Benefits
    + Supports multiple denormalized views that are scalable and performant
    + Improved separation of concerns = simpler command and query models
    + Necessary in an event sourced architecture
- Drawbacks
    + Increased complexity
    + Potential code duplication
    + Replication lag/eventually consistent views
# Saga
- A saga is a sequence of local transactions. Each local transaction updates the database and publishes a message or event to trigger the next local transaction in the saga. If a local transaction fails because it violates a business rule then the saga executes a series of compensating transactions that undo the changes that were made by the preceding local transactions.
- There are two ways of coordination sagas:
    + Choreography - each local transaction publishes domain events that trigger local transactions in other services
    + Orchestration - an orchestrator (object) tells the participants what local transactions to execute
- Benefits
    + It enables an application to maintain data consistency across multiple services without using distributed transactions
- Drawbacks
    + The programming model is more complex. For example, a developer must design compensating transactions that explicitly undo changes made earlier in a saga.