---
title: "Golang Deep Dive: Concurrency, Runtime & Architecture"
date: 2023-12-23T09:40:49+07:00
draft: false
categories: ["Programming Languages"]
tags: ["Golang", "Concurrency", "Goroutines", "Memory", "Hexagonal Architecture", "Interview"]
---

In-depth technical notes on Go concurrency, memory management, garbage collection internals, performance profiling, hexagonal architecture, and design patterns.

---

# Concurrency & Channels

## Channel Types

### 1. Unbuffered Channel
- **Behavior**: An unbuffered channel has zero capacity (`make(chan int)`).
- **Synchronization**: Requires both sender and receiver to be ready at the exact same moment. Send blocks until a receiver is ready, and receive blocks until a sender is ready.
- **Use Case**: Strict point-to-point synchronization between goroutines.

### 2. Buffered Channel
- **Behavior**: Has a fixed buffer capacity (`make(chan int, 10)`).
- **Synchronization**: The sender does not block until the buffer is full. The receiver does not block until the buffer is empty.
- **Use Case**: Rate limiting, work queuing, smoothing out bursts between producer and consumer.

```go
// Example: Concurrency throttle using buffered channel
func processTasks(tasks []Task, concurrencyLimit int) {
    sem := make(chan struct{}, concurrencyLimit)

    for _, task := range tasks {
        sem <- struct{}{} // Acquire token
        go func(t Task) {
            defer func() { <-sem }() // Release token
            t.Execute()
        }(task)
    }
}
```

---

# Concurrency Patterns

## 1. Fan-Out, Fan-In
- **Fan-Out**: Multiple goroutines read from the same channel to parallelize work across CPU cores.
- **Fan-In**: A multiplexer goroutine reads from multiple worker channels and consolidates output into a single channel.

```go
package main

import (
    "fmt"
    "sync"
)

func worker(id int, jobs <-chan int, results chan<- int) {
    for job := range jobs {
        results <- job * 2
    }
}

func main() {
    const numWorkers = 3
    jobs := make(chan int, 5)
    results := make(chan int, 5)

    var wg sync.WaitGroup

    // Fan-Out: Spawn worker pool
    for i := 1; i <= numWorkers; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            worker(id, jobs, results)
        }(i)
    }

    // Fan-In: Close results once all workers complete
    go func() {
        wg.Wait()
        close(results)
    }()

    // Send jobs
    for i := 1; i <= 5; i++ {
        jobs <- i
    }
    close(jobs)

    // Collect results
    for result := range results {
        fmt.Println("Result:", result)
    }
}
```

## 2. Worker Pool Pattern
Distributes tasks across a bounded set of long-lived worker goroutines:

```go
package main

import (
    "fmt"
    "sync"
)

func worker(id int, jobs <-chan int, wg *sync.WaitGroup) {
    defer wg.Done()
    for job := range jobs {
        fmt.Printf("Worker %d executed job %d\n", id, job)
    }
}

func main() {
    const numWorkers = 3
    jobs := make(chan int, 10)
    var wg sync.WaitGroup

    for i := 1; i <= numWorkers; i++ {
        wg.Add(1)
        go worker(i, jobs, &wg)
    }

    for j := 1; j <= 5; j++ {
        jobs <- j
    }
    close(jobs)
    wg.Wait()
}
```

## 3. Pipeline Pattern
Data flows through a chain of stages connected by channels:

```go
package main

import "fmt"

func generator(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}

func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            out <- n * n
        }
    }()
    return out
}

func main() {
    pipeline := square(generator(1, 2, 3, 4, 5))
    for res := range pipeline {
        fmt.Println(res)
    }
}
```

---

# Goroutines & The Go Runtime Scheduler

## Goroutines vs OS Threads

| Metric | Goroutine | OS Thread |
| :--- | :--- | :--- |
| **Initial Memory** | ~2 KB (dynamically resizes up to 1 GB) | ~1 MB – 8 MB (fixed stack) |
| **Creation Overhead** | Extremely fast (user-space allocation) | Slower (requires kernel system call) |
| **Context Switch Cost**| Very fast (~few nanoseconds, no kernel trap) | Slower (~1-2 microseconds, TLB flushes) |
| **Scheduling** | Cooperative M:N scheduler in Go runtime | Preemptive 1:1 scheduler in OS kernel |

## The GMP Scheduler Model

Go uses an **M:N Scheduler** mapping $M$ goroutines onto $N$ OS threads:

- **G (Goroutine)**: Represents the goroutine, its stack, program counter, and state (`_Gwaiting`, `_Grunnable`, `_Grunning`).
- **M (Machine / OS Thread)**: An actual operating system thread managed by the OS kernel.
- **P (Processor / Logical Context)**: Represents the resources required to execute Go code (runqueue, memory cache). The count of P equals `GOMAXPROCS`.

```
+---+        +---+
| P | <----> | M | (executes G)
+---+        +---+
  |
  +-- Local Run Queue: [ G1, G2, G3 ]
  |
Global Run Queue: [ G4, G5, G6 ]
```

### Key Scheduling Mechanisms:
1. **Work Stealing**: If a processor $P$ exhausts its local runqueue, it attempts to steal half the runqueue from another $P$. If all are empty, it checks the global runqueue.
2. **Syscall Hand-off**: When a goroutine performs a blocking OS system call, $M$ detaches from $P$. Another thread ($M$) takes over $P$ to keep executing other ready goroutines.
3. **Preemption (Non-cooperative)**: Since Go 1.14, the runtime uses OS signals (`SIGURG`) to preempt long-running loops without function calls.

---

# Memory Management & Escape Analysis

## Stack vs Heap in Go

- **Stack**:
  - Allocated per goroutine. Starts at 2 KB and grows dynamically by doubling contiguous memory.
  - Allocation is $O(1)$ (just moving stack pointer).
  - Cleaned up automatically upon function return with zero GC overhead.
- **Heap**:
  - Global memory for values whose lifespan cannot be determined at compile time or exceeds function return.
  - Requires GC tracking; subject to heap fragmentation and GC pauses.

## Escape Analysis
The compiler determines whether a variable can safely remain on the stack or must "escape" to the heap:

- **Causes of Heap Escape**:
  - Returning a pointer to a local variable from a function.
  - Storing values in `interface{}` / `any` (e.g. `fmt.Println(x)` causes `x` to escape).
  - Slices or arrays whose size is dynamic or too large for stack limits.
  - Variables captured by closures that outlive their declaring scope.

```bash
# Check compiler escape analysis decisions:
go build -gcflags="-m -m" main.go
```

---

# Garbage Collection (GC) Internals

Go uses a concurrent, tri-color mark-and-sweep garbage collector:

## Tri-Color Mark-and-Sweep Stages
1. **White**: Unvisited objects (candidates for reclamation).
2. **Grey**: Discovered objects whose referenced children have not yet been evaluated.
3. **Black**: Visited objects whose references have all been evaluated (guaranteed live).

```
Roots (Stack/Globals) ---> [ Grey ] ---> [ White ]
                              |
                     [ Evaluated: Turns Black ]
```

### Execution Phases:
1. **Sweep Termination (STW - tiny)**: Stop-The-World pause (~microseconds) to set up write barrier.
2. **Marking (Concurrent)**: Background workers mark live objects while the application continues executing. Uses **Write Barrier** to catch pointer mutations during concurrent marking.
3. **Mark Termination (STW - tiny)**: Brief pause to complete marking and flush remaining barriers.
4. **Sweeping (Concurrent)**: Reclaims white memory blocks and returns them to the memory allocator.

## Tuning Garbage Collection:
- `GOGC` (Default 100): Triggers GC when heap grows by 100% since last GC. Increasing `GOGC=200` reduces GC frequency at the expense of higher RAM usage.
- `GOMEMLIMIT` (Go 1.19+): Soft memory ceiling preventing OOM crashes in memory-constrained environments (e.g. Kubernetes containers).

---

# Profiling & Diagnosing Memory Leaks

## Exposing `pprof` in Go Applications

```go
package main

import (
    "log"
    "net/http"
    _ "net/http/pprof" // Registers pprof HTTP handlers
)

func main() {
    go func() {
        log.Println(http.ListenAndServe("localhost:6060", nil))
    }()
    // Application business logic
}
```

## Analyzing Memory & CPU Profiles

```bash
# Inspect live heap allocation:
go tool pprof http://localhost:6060/debug/pprof/heap

# Inspect CPU consumption over a 30-second sampling window:
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# Launch interactive web UI visualization:
go tool pprof -http=:8080 heap.pprof
```

### Common Memory Leak Scenarios in Go:
- **Abandoned Goroutines (Goroutine Leaks)**: Goroutine blocked on receiving from an unbuffered channel that never receives data.
- **Slice Pinning**: Slicing a tiny substring/slice from a massive array/file pins the whole underlying array in memory.
- **Unclosed Resources**: Forgetting `resp.Body.Close()` or unreleased `time.Ticker` instances.

---

# Context Package

The `context` package controls cancellation signals, deadlines, and request-scoped metadata across goroutines:

```go
// 1. Timeout propagation
ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
defer cancel()

req, _ := http.NewRequestWithContext(ctx, "GET", "https://api.example.com/data", nil)
resp, err := http.DefaultClient.Do(req)

// 2. Cancellation listener in worker
select {
case <-ctx.Done():
    return ctx.Err() // context.Canceled or context.DeadlineExceeded
case data := <-ch:
    process(data)
}
```

---

# Arrays vs Slices, Defer & Recover

## Arrays vs Slices

| Aspect | Array | Slice |
| :--- | :--- | :--- |
| **Size** | Fixed at compile time (`[5]int`) | Dynamically sized (`[]int`) |
| **Pass by Value** | Entire array is copied in function arguments | Slice header (Pointer, Len, Cap) is copied (24 bytes) |
| **Growth** | Cannot grow | Appended via `append()`; doubles capacity under 256 elements |

## Defer, Panic & Recover
- `defer` pushes function calls onto a LIFO stack executed when surrounding function returns.
- `recover()` intercepts panics inside deferred functions to prevent process termination:

```go
func SafeExecute() {
    defer func() {
        if r := recover(); r != nil {
            log.Printf("Recovered from panic: %v\n", r)
        }
    }()
    // Code that might panic (e.g. nil pointer dereference)
}
```

---

# Testing & Mocking in Go

## Table-Driven Testing Pattern
Standard idiom in Go for readable and comprehensive unit testing:

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -2, -3},
        {"zero case", 0, 5, 5},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

## Mocking Tools in Go Ecosystem:
- `testify/mock`: Flexible mock objects and assertions.
- `sqlmock`: Simulates database interactions without requiring a real SQL connection.
- `httptest`: Mocks inbound HTTP requests and outbound HTTP servers.
- `testcontainers-go`: Spins up real Docker containers (Postgres, Redis, Kafka) for integration tests.

---

# Hexagonal Architecture & Dependency Injection

Hexagonal architecture (Ports & Adapters) isolates core business logic from database, transport, and external framework details:

```
myapp/
├── cmd/
│   └── server/main.go              # Composition root / Dependency wiring
├── internal/
│   ├── core/
│   │   ├── domain/user.go          # Pure domain models
│   │   ├── ports/repositories.go   # Inbound & Outbound interfaces
│   │   └── services/user_svc.go    # Application business logic
│   └── adapters/
│       ├── postgres/repo.go        # Secondary adapter (Outbound DB)
│       └── http/handler.go         # Primary adapter (Inbound REST)
```

## Dependency Injection with Google Wire

```go
// models
type User struct {
    ID   int
    Name string
}

type Repository interface {
    FindUser(id int) (*User, error)
}

type UserRepository struct{}
func (r *UserRepository) FindUser(id int) (*User, error) {
    return &User{ID: id, Name: "John Doe"}, nil
}

type UserService struct {
    repo Repository
}
func NewUserService(repo Repository) *UserService {
    return &UserService{repo: repo}
}

// wire.go (Code generation configuration)
// +build wireinject

func InitializeUserService() *UserService {
    wire.Build(NewUserService, wire.Bind(new(Repository), new(*UserRepository)), &UserRepository{})
    return nil
}
```

---

# API Protocols: REST vs GraphQL vs gRPC

| Feature | REST | GraphQL | gRPC |
| :--- | :--- | :--- | :--- |
| **Data Format** | JSON (Text) | JSON (Text) | Protocol Buffers (Binary) |
| **Transport** | HTTP/1.1 or HTTP/2 | HTTP/1.1 or HTTP/2 | **HTTP/2 exclusively** |
| **Typing** | Optional (OpenAPI) | Strongly Typed Schema | Strict Protobuf IDL contract |
| **Data Fetching** | Fixed endpoints (risk of over/under-fetching) | Client defines exact fields requested | Method-based RPC |
| **Streaming** | Server-Sent Events / WebSockets | Subscriptions | Native unary & bidirectional streaming |
| **Best For** | Public APIs, Browser clients | Complex frontend dashboards | **Internal Microservice communication** |

---

# Git Workflow: Merge vs Rebase

## Git Merge
- Creates a 3-way **Merge Commit** tying two branch histories together.
- **Pros**: Non-destructive; completely preserves historical context and branch lifecycles.
- **Cons**: Clutters commit history with frequent `Merge branch 'main' into feature` commits.

## Git Rebase
- Re-applies your local feature branch commits sequentially on top of the target base branch.
- **Pros**: Produces a clean, strictly linear project commit history.
- **Cons**: Rewrites commit SHA hashes; **never rebase public shared branches**.
