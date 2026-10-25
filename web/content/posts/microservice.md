---
title: "Microservices Architecture & Distributed System Design Patterns"
date: 2023-11-12T22:53:37+07:00
draft: false
categories: ["System Design"]
tags: ["Microservices", "System Design", "CQRS", "Saga", "Architecture", "Distributed Systems"]
---

Core architectural principles, decomposition strategies, distributed design patterns, resilience mechanisms, and deployment strategies for microservices systems.

---

# Monolith vs Microservices Architecture

| Criteria | Monolithic Architecture | Microservices Architecture |
| :--- | :--- | :--- |
| **Development** | Single codebase, straightforward local debugging | Multiple repositories/services, polyglot tech stacks |
| **Deployment** | Single unit deployment (all-or-nothing) | Independent, continuous deployments per service |
| **Scaling** | Vertical scaling or duplicate entire monolith | Horizontal, granular scaling based on resource needs |
| **Fault Isolation**| Low (a memory leak or crash impacts whole app) | High (failure in one service does not crash others) |
| **Complexity** | Low operational overhead; high codebase coupling | High operational complexity (distributed network overhead) |

---

# Microservice Decomposition Strategies

How to break down a domain into microservices:

1. **Domain-Driven Design (DDD) Bounded Contexts (Most Recommended)**:
   - Each Bounded Context corresponds to one microservice.
   - Each service has its own ubiquitous language and private data model.
2. **Business Capability**:
   - Align services with organizational capabilities (e.g. `OrderService`, `PaymentService`, `InventoryService`, `NotificationService`).
3. **Team Ownership & Autonomous Delivery**:
   - A single two-pizza team owns, deploys, and operates a service independently without cross-team dependencies.
4. **Change Velocity / Frequency of Deployment**:
   - Fast-changing modules (e.g. Promotion/Marketing engine, UI BFF) are decoupled from stable, low-churn cores (e.g. General Ledger).
5. **Resource & Scalability Profiles**:
   - Isolate CPU-bound tasks (Search service), GPU-bound tasks (Image/AI processing), and high-throughput I/O tasks (Notification dispatchers).

---

# Microservice Design Patterns

## 1. Database per Service
- Each service has its own private database. No other service can access it directly; all access is via public APIs or events.
- **Benefits**:
  - Loose coupling: Schema migrations in one service never break another.
  - Polyglot persistence: Use PostgreSQL for orders, MongoDB for catalogs, Redis for sessions, Neo4j for graphs.
- **Drawbacks**:
  - Distributed queries across services require API Composition or CQRS.
  - Distributed transactions require Saga patterns (no cross-DB 2PC).

## 2. Shared Database (Anti-Pattern / Migration Phase)
- Multiple services share a single database instance and schema.
- **Benefits**: Simple ACID transactions during initial migration from monolith.
- **Drawbacks**: Tight coupling at the schema layer; runtime lock contention on shared tables.

## 3. Command Query Responsibility Segregation (CQRS)

CQRS separates read and write operations into distinct models and data stores:

- **Command Model (Write)**:
  - Handles business validation, transactions, state mutations (`CreateOrderCommand`, `CancelOrderCommand`).
  - Optimized for write consistency and normalized data.
- **Query Model (Read)**:
  - Handles high-speed reads and aggregations (`GetOrderDetailsQuery`, `ListUserOrdersQuery`).
  - Uses denormalized views or search indexes (Elasticsearch / Redis / Read Replicas).

### Combining CQRS with Saga:
In real-world distributed transactions, individual steps in a Saga can be Commands or Queries:
1. `CheckStockQuery`: Read inventory to verify availability.
2. `CheckCustomerBalanceQuery`: Read customer account balance.
3. `CreateOrderCommand`: Write new order record with `PENDING` state.
4. `ReserveStockCommand`: Mutate inventory balance.
5. `ChargePaymentCommand`: Mutate customer account balance.

> **Key Takeaway**: Commands change system state; Queries read without side-effects. CQRS allows independent scaling of reads vs writes (e.g. 100:1 read-to-write ratio).

## 4. Saga Pattern (Distributed Transactions)

A Saga coordinates a series of local transactions across multiple services without distributed locks (CAP theorem):
- Each local transaction updates the service's database and publishes an event.
- If any step fails, the Saga executes **Compensating Transactions** that undo changes in reverse order.

```
Service A (Create Order) ---> Service B (Reserve Stock) ---> Service C (Process Payment: FAIL!)
                                      |                                  |
                                      v                                  v
Service A (Set Order Cancelled) <-- Compensating Action <-----------------
```

### Saga Coordination Approaches:
- **Choreography (Event-Driven)**:
  - Services emit events; other services listen and act autonomously.
  - *Best for*: Simple workflows (2-4 steps) without central bottlenecks.
- **Orchestration (Coordinator-Driven)**:
  - A dedicated Orchestrator service tells participants what local transactions to execute.
  - *Best for*: Complex workflows with branching, retries, and explicit state machines.

## 5. Transactional Outbox Pattern
- **Problem**: Dual-write failure. Updating a database and publishing a message to Kafka/RabbitMQ in two separate network calls cannot be atomically guaranteed. If the broker is unreachable, data is out of sync.
- **Solution**:
  1. Save business data and an Outbox message in the **same local database transaction**.
  2. A separate background poller or CDC worker (**Debezium** reading DB WAL/binlog) reads the Outbox table and publishes to Kafka reliably.

## 6. Event Sourcing
- Instead of storing just the current state of an entity, store the full chronological sequence of append-only events (`OrderCreated`, `PaymentAdded`, `OrderShipped`).
- State is reconstructed at any point in time by replaying events.
- Provides 100% complete audit trails and temporal state queries.

## 7. API Composition & API Gateway
- **API Gateway**: Single entry point for clients. Handles authentication, rate limiting, SSL termination, and request routing.
- **API Composition**: Combines data from multiple downstream microservices into a unified response for clients.

---

# Distributed System Resilience Patterns

When building distributed systems, failures are inevitable. These patterns guarantee fault tolerance and system stability:

## 1. Idempotency (Most Critical)
- Calling an operation multiple times produces the exact same side-effect as calling it once.
- **Implementation**:
  - Require an **Idempotency Key** (`order_id`, `client_request_token`).
  - Store request state in Redis or DB:
    ```sql
    INSERT INTO payments(id, amount, status) VALUES($id, $amount, 'COMPLETED')
    ON CONFLICT(id) DO NOTHING;
    ```
  - Essential for safe network retries and Kafka at-least-once message processing.

## 2. Circuit Breaker
Protects the caller and downstream dependencies from cascading failures:
- **Closed**: Requests flow normally. If failure rate exceeds threshold (e.g. 50% errors over 10s), trip to **Open**.
- **Open**: Fail immediately (Fast Fail). Do not call downstream; return cached data or fallback error.
- **Half-Open**: After a cooldown period, allow a small percentage of test requests through. If successful, reset to **Closed**; if failing, return to **Open**.
- *Tools*: Envoy, Istio, Resilience4j, Sony gobreaker.

## 3. Bulkhead Pattern
- Isolates resources (thread pools, goroutines, connection pools) across downstream dependencies so that one slow external dependency cannot exhaust all resources of the service.
- *Analogy*: Compartments in a ship hull — if one compartment floods, the ship still floats.

## 4. Backpressure
- When a consumer cannot keep up with the producer's data volume, backpressure signals the producer to slow down or wait.
- *Examples*: Bounded Go channels (`make(chan Job, 100)`), TCP sliding window, reactive streams.

## 5. Load Shedding
- When server CPU or memory approaches saturation, deliberately drop lower-priority traffic (HTTP `429 Too Many Requests` or `503 Service Unavailable`).
- *Principle*: Better to successfully serve 80% of users with low latency than crash and serve 0% to all.

## 6. Retry Policy with Exponential Backoff & Jitter
- **Exponential Backoff**: Gradually increase wait intervals between retries: $100\text{ms} \rightarrow 200\text{ms} \rightarrow 400\text{ms} \rightarrow 800\text{ms}$.
- **Full Jitter**: Add random variance to prevent the **Thundering Herd** problem where thousands of clients retry at the exact same millisecond.
- **Rule**: Only retry idempotent operations and transient network errors (`502`, `503`, `504`), never `4xx` client errors.

## 7. Timeouts
- Every remote network call MUST have explicit timeouts:
  - Connection Timeout (e.g. 1-2s).
  - Read/Write Timeout (e.g. 3-5s).
- *Rule*: Upstream timeout must be strictly greater than downstream timeout to avoid orphaned calls.

## 8. Rate Limiting
- Enforce usage quotas per client/IP to protect against DDoS, bugs, and API abuse.
- *Algorithms*: Token Bucket, Leaky Bucket, Sliding Window Counter (backed by Redis Cluster).

## 9. Eventual Consistency
- In microservices, distributed transactions are asynchronous. Data across services will not be immediately identical, but will converge and become consistent over time via events.

## 10. Message Deduplication
- Because distributed message brokers (Kafka, RabbitMQ) provide **at-least-once delivery**, duplicates will occur during network hiccups.
- Consumers must deduplicate messages using:
  - Unique message ID / transaction ID stored in a distributed deduplication store (Redis with TTL or DB unique constraint).

---

# Event-Driven Architecture vs Synchronous Microservices

## Traditional Synchronous Architecture
Relies on direct, blocking RPC or HTTP/REST calls between services (Service A calls Service B and waits for response before proceeding).

- **Pros**:
  - Linear execution flow and clear stack traces.
  - Straightforward error handling.
  - Strong data consistency.
- **Cons**:
  - Cascading failures: If downstream Service C fails, Service A and B may block and crash.
  - Scalability bottleneck: High latency under peak load as threads wait on I/O.

## Event-Driven Architecture (EDA)
Components communicate asynchronously by publishing events to a message broker (Kafka, RabbitMQ, EventBridge). Consumers subscribe and react to events independently.

- **Pros**:
  - **High Scalability & Throughput**: Asynchronous processing allows services to process messages without blocking.
  - **Loose Coupling**: Publishers have zero knowledge of consumers; new services can subscribe to events without modifying existing publishers.
  - **Fault Tolerance**: If a consumer service goes down, messages persist in the broker and are processed once the service recovers.
- **Cons**:
  - Complex debugging & tracing: Requires distributed tracing (OpenTelemetry, Jaeger).
  - Eventual consistency: Distributed rollback requires compensating transactions (Saga).

---

# Deployment Strategies

| Strategy | Description | Downtime | Risk | Rollback Speed |
| :--- | :--- | :---: | :---: | :---: |
| **Recreate** | Terminate old version completely, then boot new version | Yes | High | Slow |
| **Rolling Update** | Gradually replace old instances with new instances one by one | Zero | Low | Moderate |
| **Blue-Green** | Spin up complete new environment (Green); switch load balancer traffic | Zero | Very Low | Instant (switch LB) |
| **Canary** | Route a tiny fraction (e.g. 5%) of traffic to new version; monitor metrics | Zero | Minimal | Fast (adjust weights)|
| **A/B Testing** | Route users based on business rules to test feature conversion | Zero | Minimal | Instant |
| **Shadow** | Fork live production traffic to new version without returning responses to users | Zero | Zero | N/A |

---

# System Design Interview Framework & Checklist

When tackling a System Design interview, follow this 4-step framework:

## Step 1: Clarify Requirements (5-8 mins)
- **Functional Requirements**: Core 2-3 essential features. Clarify out-of-scope items.
- **Non-Functional Requirements**:
  - Scalability: Daily Active Users (DAU), peak vs average traffic.
  - Availability vs Consistency (CAP Theorem): 99.99% availability vs strict consistency.
  - Latency: p95/p99 SLAs (e.g. read < 50ms, write < 200ms).
  - Read/Write Ratio: Read-heavy (100:1) vs write-heavy.

## Step 2: Back-of-the-envelope Capacity Estimation (5 mins)
- **QPS Estimation**:
  $$\text{Average QPS} = \frac{\text{DAU} \times \text{Requests per user}}{86400 \text{ seconds}}$$
  $$\text{Peak QPS} = \text{Average QPS} \times 2 \text{ (or } 3\text{)}$$
- **Storage Estimation**:
  $$\text{Daily Storage} = \text{New records/day} \times \text{Size per record}$$
  Multiply by 365 days $\times$ 5 years retention $\times 3$ (replication).
- **Network Bandwidth**:
  $$\text{Bandwidth} = \text{QPS} \times \text{Average payload size}$$

## Step 3: High-Level Architecture (10-15 mins)
- Client $\rightarrow$ DNS $\rightarrow$ CDN $\rightarrow$ Load Balancer (ALB/Nginx).
- API Gateway: Authentication, rate limiting, routing.
- Microservices tier: Stateless application services.
- Data tier: Primary DB + Read Replicas + Redis Cache + Message Broker (Kafka) + S3 Object Storage.

## Step 4: Deep Dive & Bottlenecks (15-20 mins)
- **Database Scalability**: Indexing, partitioning, horizontal sharding.
- **Cache Strategy**: Cache-Aside, handling Cache Penetration / Cache Stampede.
- **Resilience**: Circuit breakers, rate limiters, retries with exponential backoff and jitter, dead-letter queues.
