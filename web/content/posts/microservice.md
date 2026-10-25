---
title: "Microservices Architecture & Distributed System Design Patterns"
date: 2023-11-12T22:53:37+07:00
draft: false
categories: ["System Design"]
tags: ["Microservices", "System Design", "CQRS", "Saga", "Architecture", "Distributed Systems"]
---

# Monolith vs Microservices Architecture
## Monolithic Architecture
Pros:
    - Simpler to develop and deploy: Single codebase, fewer moving parts.
    - Easier testing: End-to-end tests are straightforward.
    - Lower operational overhead: One unit to manage and deploy.
Cons:
   -  Limited scalability: Scaling requires scaling the entire app.
    - Harder to maintain: As the app grows, managing the codebase becomes difficult.
    - Tight coupling: Changes in one part can affect the entire system.
## Microservices Architecture
Pros:
    - Independent scalability: Scale each service based on need.
    - Technology flexibility: Use different tech stacks for different services.
    - Fault isolation: Failures in one service don't affect others.
Cons:
    - Increased complexity: More services to manage and coordinate.
    - Higher resource overhead: More resources due to running multiple services.
    - Complex testing: Requires integration testing for multiple services.


# Queue
## What
- RabbitMQ employs a push model. This model is an ideal approach for low-latency messaging. It also functions well with the RabbitMQ queue-based architecture. Think of RabbitMQ as a post office, which receives, stores, and delivers mail, whereas RabbitMQ accepts, stores, and transmits binary data messages.
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

# Microservice Design Pattern

## Shared database
- Use a (single) database that is shared by multiple services
- Benefits
    + A developer uses familiar and straightforward ACID transactions to enforce data consistency
    + A single database is simpler to operate
- Drawbacks
    + Development time coupling - a developer working on, for example, the OrderService will need to coordinate schema changes with the developers of other services that access the same tables. This coupling and additional coordination will slow down development.
    + Runtime coupling - because all services access the same database they can potentially interfere with one another. For example, if long running CustomerService transaction holds a lock on the ORDER table then the OrderService will be blocked.
    + Single database might not satisfy the data storage and access requirements of all services.

## Database per services
- Different services have different data storage requirements. For some services, a relational database is the best choice. Other services might need a NoSQL database such as MongoDB, which is good at storing complex, unstructured data, or Neo4J, which is designed to efficiently store and query graph data.
- Benefits
    + ensure that the services are loosely coupled. Changes to one service’s database does not impact any other services.
    + Each service can use the type of database that is best suited to its needs. For example, a service that does text searches could use ElasticSearch. A service that manipulates a social graph could use Neo4j.
- Drawback
    + Implementing business transactions that span multiple services is not straightforward. Distributed transactions are best avoided because of the CAP theorem. Moreover, many modern (NoSQL) databases don’t support them.
    + Implementing queries that join data that is now in multiple databases is challenging.
    + Complexity of managing multiple SQL and NoSQL databases

## Command Query Responsibility Segregation (CQRS)
- Command Query Responsibility Segregation (CQRS) is a design pattern that separates the read and write operations of an application into two distinct models. It is particularly useful in systems with complex domain logic or high scalability requirements
- Benefits
    + Simplifies code by splitting read and write logic, making maintenance easier.
    + Scalability: Enables independent scaling of read and write operations.
    + Performance: Optimizes reads with denormalized data structures and caching.
    + Flexibility: Allows different databases and querying mechanisms for reads and writes.
    + Event Sourcing: Supports event replay and auditability.
    + Security: Enables fine-grained access control.
- Drawbacks
    + Complexity: Adds overhead with two models and synchronization challenges.
    + Cost: Requires more development effort and infrastructure.
    + Eventual Consistency: Reads may lag behind writes.
    + Overkill: Not suitable for simple systems or where strict consistency is essential.

## Saga
- A saga is a sequence of local transactions. Each local transaction updates the database and publishes a message or event to trigger the next local transaction in the saga. If a local transaction fails because it violates a business rule then the saga executes a series of compensating transactions that undo the changes that were made by the preceding local transactions.
- There are two ways of coordination sagas:
    + Choreography - each local transaction publishes domain events that trigger local transactions in other services
    + Orchestration - an orchestrator (object) tells the participants what local transactions to execute
- Benefits
    + It enables an application to maintain data consistency across multiple services without using distributed transactions
- Drawbacks
    + The programming model is more complex. For example, a developer must design compensating transactions that explicitly undo changes made earlier in a saga.
## Transactional Outbox pattern
- A service command typically needs to create/update/delete aggregates in the database and send messages/events to a message broker.
## Api Composition
- API Composition is a pattern used in microservices architectures to handle the complexity of combining data from multiple services into a single response for the client


## Event Sourcing
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


==== 


1. CQRS (Command Query Responsibility Segregation)
CQRS là một mẫu thiết kế phân tách rõ ràng giữa hai loại hành động:

Command: Là các hành động thay đổi trạng thái của hệ thống. (Thực hiện ghi dữ liệu, cập nhật trạng thái, v.v.)
Query: Là các hành động chỉ đọc dữ liệu mà không thay đổi nó.
Mặc dù phân tách giữa Command và Query rất rõ ràng, trong thực tế, đôi khi trong một step (bước của một quy trình), bạn có thể sẽ cần thực hiện cả Command và Query. Ví dụ, trong quá trình tạo đơn hàng, bạn có thể truy vấn số lượng kho (Query) rồi thực hiện cập nhật số lượng kho và tạo đơn hàng (Command).

Command và Query là khái niệm dùng để phân tách logic. Không có một quy định nào bắt buộc mỗi bước phải chỉ có Command hoặc chỉ có Query, một số bước có thể bao gồm cả hai, tùy vào yêu cầu xử lý.
2. Saga Pattern
Saga Pattern giúp xử lý các giao dịch dài hoặc phức tạp, đặc biệt là trong các hệ thống phân tán, nơi một giao dịch không thể xử lý trong một bước duy nhất hoặc một giao dịch đơn lẻ.

Saga chia một giao dịch phức tạp thành nhiều bước nhỏ, mỗi bước tương ứng với một hành động cụ thể (có thể là command hoặc query).
Mỗi bước trong saga là một microtransaction, có thể hoàn thành và xử lý độc lập.
Nếu một bước thất bại, hệ thống sẽ có các bước bù đắp (compensating actions) để hủy bỏ hoặc khôi phục trạng thái ban đầu.
Sự Kết Hợp Giữa CQRS và Saga
Trong một Saga, các bước có thể là Command hoặc Query tùy vào mục đích của mỗi bước.
Ví dụ, kiểm tra kho là query vì bạn chỉ đọc dữ liệu để kiểm tra điều kiện.
Tạo đơn hàng là command vì bạn đang thay đổi trạng thái hệ thống (tạo một bản ghi đơn hàng mới).
Cập nhật kho và tài khoản khách hàng là command, vì bạn thay đổi số lượng sản phẩm và số dư tài khoản.
Trong CQRS với Saga:
Command được sử dụng trong các bước mà bạn cần thay đổi dữ liệu hoặc tạo mới.
Query được sử dụng trong các bước mà bạn cần đọc dữ liệu mà không thay đổi bất kỳ trạng thái nào.
Ví Dụ Về Quy Trình Tạo Đơn Hàng
Bước 1: Kiểm tra số lượng kho (CheckStockQuery).

Query: Kiểm tra xem sản phẩm có đủ số lượng không.
Nếu không đủ, có thể hủy toàn bộ quá trình.
Bước 2: Kiểm tra số dư tài khoản khách hàng (CheckCustomerBalanceQuery).

Query: Kiểm tra xem khách hàng có đủ tiền không.
Bước 3: Tạo đơn hàng (CreateOrderCommand).

Command: Tạo một đơn hàng mới, thay đổi trạng thái hệ thống.
Bước 4: Cập nhật kho (UpdateStockCommand).

Command: Cập nhật số lượng sản phẩm trong kho.
Bước 5: Cập nhật số dư tài khoản khách hàng (UpdateBalanceCommand).

Command: Trừ tiền từ tài khoản khách hàng.
Tóm Tắt Chính
CQRS giúp phân tách các hành động đọc và ghi dữ liệu, nhưng trong một bước quy trình, có thể sẽ có cả query và command (tùy vào mục đích của bước đó).
Saga Pattern giúp chia nhỏ một giao dịch dài thành các bước nhỏ hơn (microtransactions), mỗi bước có thể là query hoặc command. Nếu một bước thất bại, Saga sẽ sử dụng các hành động bù đắp để xử lý.
Điều Quan Trọng
Command là những hành động thay đổi dữ liệu.
Query là hành động chỉ đọc dữ liệu.
Saga sẽ giúp bạn chia nhỏ các giao dịch phức tạp, và mỗi bước trong Saga có thể là command hoặc query.





# devide-micro
- Dựa trên Domain / Business Capability (phổ biến nhất – chuẩn DDD)
- Dựa theo Team Ownership
    Một team có thể tự triển khai, tự vận hành 1 service mà không phụ thuộc team khác.
    Mỗi team sở hữu trọn vẹn một service.
- Dựa theo tần suất thay đổi
    Các module thay đổi nhiều thì nên tách riêng để:
    Deploy nhanh hơn
    Không ảnh hưởng các phần còn lại
    Ví dụ: UI service, Notification service tách riêng vì hay thay đổi.

- Dựa theo scalability
    Những phần cần scale độc lập nên tách riêng:
    Search service → cần CPU
    Image processing → cần GPU
    Notification → cần throughput cao
- Dựa trên Bounded Context (DDD)

Một bounded context = 1 microservice.
Mỗi service có model dữ liệu riêng, không chia sẻ DB.

---

# Event-Driven Architecture vs Synchronous Microservices

## Traditional Synchronous Architecture
Relies on direct, blocking RPC or HTTP/REST calls between services (Service A calls Service B and waits for response before proceeding).

- **Pros**:
  - Easier to understand and debug: Linear execution flow and clear stack traces.
  - Straightforward error handling: Errors are immediately returned to the caller.
  - Strong data consistency: Synchronous calls make ACID and two-phase commits simpler.
- **Cons**:
  - Cascading failures: If downstream Service C fails, Service A and B may block and crash (Single Point of Failure).
  - Scalability bottleneck: High latency under peak load as threads wait on I/O.
  - Tight temporal coupling: All services must be available simultaneously.

## Event-Driven Architecture (EDA)
Components communicate asynchronously by publishing events to a message broker (Kafka, RabbitMQ, EventBridge). Consumers subscribe and react to events independently.

- **Pros**:
  - **High Scalability & Throughput**: Asynchronous processing allows services to process messages at their own pace without blocking.
  - **Loose Coupling**: Publishers have zero knowledge of consumers; new services can subscribe to events without modifying existing publishers.
  - **Fault Tolerance**: If a consumer service goes down, messages persist in the broker and are processed once the service recovers.
- **Cons**:
  - Complex debugging & tracing: Requires distributed tracing (OpenTelemetry, Jaeger).
  - Eventual consistency: Data takes time to sync across services; distributed rollback requires compensating transactions (Saga).
  - Message broker management overhead: Clustering, partition sizing, and monitoring dead-letter queues (DLQ).

## Practical Example: E-Commerce Order Flow
- **Synchronous Path**: When placing an order, synchronously call Inventory Service to reserve stock and Payment Service to charge credit card. Gives immediate feedback to the buyer.
- **Asynchronous Event Path**: Once payment succeeds, publish an `OrderPlaced` event. Downstream services independently consume this event:
  - `Notification Service` sends confirmation email/SMS.
  - `Loyalty Points Service` credits points to customer account.
  - `Warehouse/Shipping Service` generates shipping label and begins packaging.

---

# System Design Interview Framework & Checklist

When tackling a System Design interview, follow this 4-step framework:

## Step 1: Clarify Requirements (5-8 mins)
- **Functional Requirements**: What are the top 2-3 essential features the user must be able to perform? What is out of scope?
- **Non-Functional Requirements**:
  - Scalability: Daily Active Users (DAU), peak vs average traffic.
  - Availability vs Consistency (CAP Theorem trade-off): High availability (99.99%) or strict financial consistency?
  - Latency: p95 / p99 SLA (e.g. read latency < 50ms, write latency < 200ms).
  - Read/Write Ratio: Is the system read-heavy (e.g. Twitter 100:1) or write-heavy (e.g. IoT telemetry)?

## Step 2: Back-of-the-envelope Capacity Estimation (5 mins)
- **QPS Estimation**:
  $$\text{Average QPS} = \frac{\text{DAU} \times \text{Requests per user}}{86400 \text{ seconds}}$$
  $$\text{Peak QPS} = \text{Average QPS} \times 2 \text{ (or } 3\text{)}$$
- **Storage Estimation**:
  $$\text{Daily Storage} = \text{New records/day} \times \text{Size per record}$$
  Multiply by 365 days $\times$ 5 years retention, plus replication factor ($\times 3$).
- **Network Bandwidth**:
  $$\text{Bandwidth} = \text{QPS} \times \text{Average payload size}$$

## Step 3: High-Level Architecture (10-15 mins)
- Draw client (Mobile, Web) $\rightarrow$ DNS $\rightarrow$ CDN (static assets) $\rightarrow$ Load Balancer (ALB/Nginx).
- API Gateway: Handles authentication, SSL termination, rate limiting, and request routing.
- Microservices tier: Stateless application services.
- Data tier:
  - Primary Database (PostgreSQL / MySQL) with Read Replicas.
  - In-Memory Cache (Redis) in front of read replicas.
  - Message Queue / Event Bus (Kafka / RabbitMQ) for async tasks.
  - Object Storage (AWS S3) for images, videos, and documents.

## Step 4: Deep Dive & Bottlenecks (15-20 mins)
- **Database Scalability**: Index optimization (B-tree, covering indexes), partitioning, horizontal sharding by shard key.
- **Cache Strategy**: Cache-Aside, Write-Through, Cache Invalidation, handling Cache Penetration / Cache Stampede.
- **Resilience & Fault Tolerance**: Circuit breaker pattern, rate limiting, retry with exponential backoff and jitter, dead-letter queues.

