---
title: "Database & Message Brokers: SQL, NoSQL & Queues"
date: 2023-11-12T22:53:02+07:00
draft: false
categories: ["Database"]
tags: ["SQL", "MySQL", "PostgreSQL", "Redis", "Kafka", "RabbitMQ", "Database"]
---

Comprehensive notes on Relational Databases (SQL), In-Memory Caching (Redis), and Distributed Message Brokers (Kafka & RabbitMQ) for technical interviews and system architecture design.

---

# Relational Databases (SQL)

## SQL vs NoSQL

### ACID Properties in Relational Databases
- **Atomicity**: All operations in a transaction succeed or fail together. If any operation fails, the entire transaction is rolled back. (e.g. transfer money from Account A to Account B).
- **Consistency**: Any transaction brings the database from one valid state to another, strictly obeying all schema rules, constraints, triggers, and cascades.
- **Isolation**: Concurrent execution of transactions yields the same state that would have been obtained if transactions were executed sequentially.
- **Durability**: Once a transaction commits, its changes survive power outages, crashes, or server restarts (written to disk/WAL).

### Decision Matrix: When to Choose What?

| Criteria | SQL (Relational) | NoSQL (Document/KV/Column) |
| :--- | :--- | :--- |
| **Data Schema** | Structured, fixed schema, typed | Dynamic, flexible, unstructured or semi-structured |
| **Queries** | Complex joins, aggregations, subqueries | Key lookups, document retrieval, range scans |
| **Consistency** | Strong consistency (ACID) | Eventual consistency (BASE theorem) |
| **Scaling** | Vertical scaling (Scale-up), Read replicas, Sharding | Horizontal scaling (Scale-out) built into architecture |
| **Ideal For** | Financial systems, order management, ERP | Real-time big data, user feeds, telemetry, caching |

---

## MySQL vs PostgreSQL

### Architecture & MVCC (Multi-Version Concurrency Control)
- **MySQL (InnoDB)**:
  - Performs exceptionally well in write-heavy, high-concurrency environments.
  - InnoDB uses **Undo Logs** to store older row versions. Updates are made in-place on data pages, keeping main tables lean and preventing table bloat.
  - Undo logs are purged in the background by a dedicated purge thread once no active transaction needs them.
- **PostgreSQL**:
  - Handles complex analytical queries, window functions, and rich data types (JSONB, GIS, arrays) better than MySQL.
  - Updates create a **new tuple** in the main table data block while leaving the old tuple marked as dead.
  - Requires **VACUUM / Autovacuum** to clean dead tuples. Under heavy write workloads, this can cause table bloat and higher disk I/O.

---

## DELETE vs TRUNCATE

| Feature | DELETE | TRUNCATE |
| :--- | :--- | :--- |
| **Operation Type** | DML (Data Manipulation Language) | DDL (Data Definition Language) |
| **Logging** | Row-by-row logging in Undo/Redo logs | Minimal logging (deallocates data pages) |
| **Speed** | Slow for large datasets | Extremely fast |
| **WHERE Clause** | Supported (can delete specific rows) | Not supported (removes all table data) |
| **Space Reclamation**| Leaves space allocated; may cause fragmentation | Reclaims all allocated storage and index pages |
| **Triggers** | Fires row-level `DELETE` triggers | Does not fire delete triggers |
| **Rollback** | Can be rolled back inside a transaction | Can be rolled back in PostgreSQL; cannot in MySQL |

---

## Transaction Isolation Levels

When multiple transactions run concurrently, isolation levels dictate which anomalies are prevented:

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read | Default In |
| :--- | :---: | :---: | :---: | :--- |
| **Read Uncommitted** | Permitted | Permitted | Permitted | None |
| **Read Committed** | Prevented | Permitted | Permitted | **PostgreSQL**, Oracle, SQL Server |
| **Repeatable Read** | Prevented | Prevented | Prevented (InnoDB via Next-Key Lock) | **MySQL (InnoDB)** |
| **Serializable** | Prevented | Prevented | Prevented | None (Highest overhead) |

### Concurrency Anomalies Explained:
- **Dirty Read**: Transaction A reads data modified by Transaction B before Transaction B commits. If B rolls back, A's data was invalid.
- **Non-Repeatable Read**: Transaction A reads a row. Transaction B updates that row and commits. Transaction A re-reads the row and gets different values.
- **Phantom Read**: Transaction A queries rows matching a condition (`WHERE age > 20`). Transaction B inserts new rows matching that condition and commits. Transaction A re-runs the query and sees new "phantom" rows.

---

## Database Locks: Shared, Exclusive & Update Locks

### 1. Read Lock (Shared Lock - S)
- **Purpose**: Allows multiple transactions to read a resource simultaneously.
- **Behavior**: Multiple transactions can hold shared locks on the same row/table. No transaction can acquire an exclusive write lock until all shared locks are released.

### 2. Write Lock (Exclusive Lock - X)
- **Purpose**: Modifies or deletes data (`UPDATE`, `DELETE`, `INSERT`).
- **Behavior**: Only one transaction can hold an exclusive lock. No other transaction can read (with lock) or modify the data until the write lock is released.

### 3. Update Lock (U)
- **Purpose**: Used during hybrid read-then-write operations to prevent deadlocks.
- **Behavior**: Multiple readers can read, but only one transaction can hold an update lock. When ready to update, it upgrades to an exclusive lock.

---

## Optimistic vs Pessimistic Locking & Deadlocks

### Optimistic Locking
- Does not lock rows on read. Instead, tracks a `version` number or `updated_at` timestamp.
- When saving:
  ```sql
  UPDATE accounts 
  SET balance = balance - 100, version = version + 1 
  WHERE id = 1 AND version = 3;
  ```
- If rows affected is `0`, another transaction updated the record concurrently. The application retries the operation.
- **Best for**: Low-conflict, high-throughput read workloads.

### Pessimistic Locking
- Explicitly locks the row at read time using `SELECT ... FOR UPDATE`.
- Prevents other transactions from acquiring locks until the transaction completes.
- **Best for**: High-conflict transactions (e.g. inventory reservation during flash sales).

### Deadlock Handling Strategies
- **Lock Ordering**: Ensure all transactions access tables and rows in the exact same deterministic order.
- **Keep Transactions Short**: Minimize long-running business logic while locks are active.
- **Timeout & Retry**: Configure deadlock detection (`innodb_lock_wait_timeout`) and retry failed transactions with exponential backoff.

---

## SQL Query Execution Order

Understanding the logical query processing order helps optimize indexes and query structure:

```
1. FROM        (Evaluate table joins, subqueries, CROSS/LEFT/INNER JOIN)
2. ON          (Apply join conditions)
3. WHERE       (Filter rows based on predicates)
4. GROUP BY    (Aggregate rows into groups)
5. HAVING      (Filter aggregated groups)
6. SELECT      (Evaluate expressions, projections, aliases)
7. DISTINCT    (Eliminate duplicate rows)
8. ORDER BY    (Sort result set by specified columns)
9. LIMIT/OFFSET(Paginate and constrain output row count)
```

> **Tip**: You cannot reference a `SELECT` column alias inside a `WHERE` clause because `WHERE` executes before `SELECT`.

---

## Indexing Strategies

### 1. B-Tree Index (Default in InnoDB & Postgres)
- Self-balancing tree keeping data sorted in $O(\log N)$ time.
- Highly efficient for exact lookups (`=`), range queries (`BETWEEN`, `<`, `>`), and sorting (`ORDER BY`).
- Keys are sorted lexicographically; queries must satisfy the **Leftmost Prefix Rule** for multi-column indexes.

### 2. Composite (Multi-Column) Index
- Covers queries filtering across multiple fields:
  ```sql
  CREATE INDEX idx_user_status_created ON users (status, created_at);
  ```
- Works for queries on `(status)` and `(status, created_at)`, but will **not** be used for queries filtering only on `(created_at)`.

### 3. Partial Index (PostgreSQL)
- Indexes only a specific subset of rows matching a predicate:
  ```sql
  CREATE INDEX idx_active_users ON users (email) WHERE is_active = TRUE;
  ```
- Saves substantial disk space and write I/O by ignoring archived or inactive records.

### 4. Hash Index
- Maps hash values directly to rows with $O(1)$ lookups.
- Only supports exact equality checks (`=`), does **not** support range queries (`<`, `>`) or sorting. Supported in MySQL Memory engine and Postgres.

---

## Partitioning

Splits large tables into smaller, manageable chunks within the same database instance:

```sql
-- 1. Range Partitioning by Year
CREATE TABLE sales (
    id INT NOT NULL,
    sale_date DATE NOT NULL,
    amount DECIMAL(10, 2)
) PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 2. List Partitioning by Category
CREATE TABLE products (
    id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(100)
) PARTITION BY LIST (category_id) (
    PARTITION p_electronics VALUES IN (1, 2, 3),
    PARTITION p_fashion VALUES IN (4, 5, 6),
    PARTITION p_others VALUES IN (DEFAULT)
);

-- 3. Hash Partitioning for Even Data Distribution
CREATE TABLE logs (
    id INT NOT NULL,
    log_text TEXT
) PARTITION BY HASH (id) PARTITIONS 4;
```

---

## Sharding

Horizontal scaling across **multiple physical database servers**:
- **Range-Based Sharding**: Shard 1 stores IDs 1–1,000,000; Shard 2 stores 1,000,001–2,000,000.
  - *Risk*: Hotspots on newer ranges.
- **Hash-Based Sharding**: Shard = `hash(user_id) % num_shards`.
  - *Risk*: Resharding requires migrating data unless Consistent Hashing is used.
- **Directory-Based Sharding**: A lookup service maps shard keys to physical database endpoints.
- **Geo-Sharding**: Route data based on user country to reduce latency and comply with data residency laws (GDPR).

---

# In-Memory & NoSQL (Redis)

## Overview & Core Data Structures
Redis is an in-memory, key-value data store capable of sub-millisecond responses:
- **Strings**: Text, JSON payloads, counters (`INCR`, `DECR`).
- **Lists**: Linked lists / quicklists, perfect for queues (`LPUSH`, `RPOP`).
- **Hashes**: Field-value mappings representing objects (`HSET`, `HGETALL`).
- **Sets**: Unique unordered items; union/intersection operations (`SADD`, `SINTER`).
- **Sorted Sets (ZSet)**: Sets ordered by floating-point score, ideal for leaderboards and rate limiters (`ZADD`, `ZRANGEBYSCORE`).
- **Streams & Pub/Sub**: Real-time event streaming and pub/sub message distribution.

### Rate Limiting Algorithms in Redis:
- **Token Bucket**: Tokens are continuously refilled at a fixed rate; each request consumes 1 token.
- **Leaky Bucket**: Requests enter a queue and are processed at a steady, fixed rate to smooth out traffic spikes.

---

## High Availability: Sentinel vs Cluster

![Redis Sentinel vs Cluster](redis.png)

| Aspect | Redis Sentinel | Redis Cluster |
| :--- | :--- | :--- |
| **Architecture** | Master-Replica with Sentinel monitoring nodes | Multi-Master distributed architecture |
| **Primary Goal** | High Availability & Auto-failover | High Availability + **Horizontal Sharding** |
| **Data Partitioning** | No (Every node contains the entire dataset) | Yes (Data split across 16,384 hash slots) |
| **Max Capacity** | Bound by the RAM of a single master | Distributed across all master nodes |

---

## Consistent Hashing & 16,384 Hash Slots
Redis Cluster avoids master bottlenecking by dividing the keyspace into **16,384 hash slots**:
1. **Hashing Keys**:
   $$\text{Slot} = \text{CRC16}(\text{key}) \pmod{16384}$$
2. **Hash Tags**: Wrapping part of a key in `{...}` ensures related keys land on the same slot:
   - `user:{1001}:profile` and `user:{1001}:orders` will share the same slot.
3. **Smart Client Routing**:
   - Clients cache the node-to-slot mapping.
   - If a client contacts the wrong node, the node responds with a `MOVED <slot> <ip:port>` redirection.

---

## Persistence: AOF vs RDB

| Feature | AOF (Append-Only File) | RDB (Redis Database Snapshot) |
| :--- | :--- | :--- |
| **Mechanism** | Logs every write command sequentially to disk | Creates a point-in-time binary snapshot of memory |
| **Data Loss Window** | Very low (1 sec with `appendfsync everysec`) | Higher (minutes between scheduled snapshots) |
| **File Size** | Larger (command log) | Compact, optimized binary dump |
| **Recovery Speed** | Slower (replays all commands) | Very fast (loads memory snapshot directly) |
| **Best Practice** | **Use both**: RDB for fast restarts and disaster backups; AOF for minimal data loss. |

---

# Message Brokers (Kafka & RabbitMQ)

## Architectural Comparison

| Feature | Apache Kafka | RabbitMQ |
| :--- | :--- | :--- |
| **Architecture** | Distributed append-only commit log | Smart broker / Dumb consumer message queue |
| **Message Consumption** | **Pull Model** (Consumers poll by offset) | **Push Model** (Broker pushes messages to workers) |
| **Throughput** | Ultra-high (millions of msgs/sec via batching & Zero-Copy) | Moderate to high (tens of thousands msgs/sec) |
| **Message Retention** | Messages persist on disk after consumption (configurable retention) | Messages are deleted immediately upon ACK |
| **Routing Flexibility** | Topic / Partition based | Complex routing (Direct, Fanout, Topic, Headers exchanges) |
| **Message Ordering** | Strictly ordered **within a single partition** | Ordered in queue until dead-letter/requeue |

### Real-world Decision Guide:
- **Choose Kafka**: When you need audit log history, event streaming, replayability, or high-throughput analytics (e.g. tracking order lifecycles or financial transaction feeds).
- **Choose RabbitMQ**: When you need complex routing rules, priority queues, and granular task distributions (e.g. email notifications, image processing background workers).

---

## Messaging Models: Push vs Pull

### Push Model (e.g. RabbitMQ)
- Broker pushes messages to consumers as soon as they arrive.
- **Pros**: Immediate delivery, ultra-low latency, no client polling overhead.
- **Cons**: Consumers can suffer from buffer overflow or backpressure if message volume exceeds consumption speed. (Mitigated via `basic.qos` prefetch limit).

### Pull Model (e.g. Kafka)
- Consumers poll the broker for batches of messages at their own pace.
- **Pros**: Natural flow control, backpressure resistance, ideal for batching and maximizing I/O efficiency.
- **Cons**: Potential polling latency if messages are sparse (mitigated using long-polling timeouts).
