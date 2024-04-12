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
## Rabbitmq exchanges && binding
- Direct Exchange:
    + Each message is routed to one or more queues whose binding key exactly matches the routing key of the message
- Fanout Exchange:
    + Routes messages to all queues bound to the exchange, regardless of the routing key.
- Topic Exchange
    + Routes messages to queues based on wildcard matches between the routing key of the message and the routing patterns specified when the queue was bound to the exchange.
- Headers Exchange:
    - Routes messages based on message header attributes rather than routing keys.
- Binding:
Binding is the link between an exchange and a queue. It defines the relationship between the exchange and the queue, including the routing key or pattern used for routing messages from the exchange to the queue.
## Kafka  zero copy
- Zero copy is a technique used in computer systems to transfer data between different memory locations or devices without the need for unnecessary copying of data. In essence, zero copy eliminates the intermediate step of copying data from one buffer to another, reducing CPU overhead, memory usage, and improving overall system performance.

- Traditional Copying: In traditional data transfer operations, when data needs to be moved from one memory location to another or from a storage device to memory, the data is typically copied from the source buffer to an intermediate buffer, and then to the destination buffer.
This process involves multiple memory copy operations, which consume CPU cycles and memory bandwidth.
- Zero Copy: 
    + With zero copy, instead of copying data from the source buffer to an intermediate buffer and then to the destination buffer, the data is transferred directly from the source to the destination without intermediate copying.
    + This is achieved by leveraging operating system features such as scatter-gather I/O, memory-mapped I/O, or direct memory access (DMA).
    + The source and destination buffers are mapped to the same physical memory or are accessible by the same I/O controller, allowing data to be transferred directly between them without involving the CPU.
    + Zero copy reduces CPU overhead, memory usage, and latency, resulting in improved performance and efficiency, especially in scenarios where large amounts of data need to be transferred quickly, such as network communication, file I/O, or inter-process communication.
Zero copy is widely used in various systems and applications, including networking (e.g., TCP/IP stack), file systems (e.g., file read/write operations), database systems, and high-performance computing. It enables efficient data transfer and improves system scalability, particularly in high-throughput environments.

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
# Transactional Outbox pattern
- A service command typically needs to create/update/delete aggregates in the database and send messages/events to a message broker.

# Event Sourcing
-  Event sourcing persists the state of a business entity such an Order or a Customer as a sequence of state-changing events. Whenever the state of a business entity changes, a new event is appended to the list of events. Since saving an event is a single operation, it is inherently atomic. The application reconstructs an entity’s current state by replaying the events.

# Deployment Strategies
- Recreate Deployment Strategy
    + we stop and then recreate the application
- Blue-Green Deployment
    + The original, old version is called blue environment, and the new updated version is called green environment.Now, both environments are running our application, but the users are still using the old version
- Rolling Update
    + Firstly, we create a new instance that runs the updated version. 
    + After this, we remove one from the instances that run the old version
- Canary Deployment
    + only a small part of the users receive the update
- A/B Testing
    + This process deploys the update to a subset of users, just like canary deployments. However, A/B testing is mainly about getting feedback from the users about our changes
- Shadow Deployment
    + Shadow deployment is similar to blue-green deployment in the sense that it uses two identical environments