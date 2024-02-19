---
title: "Golang"
date: 2023-12-23T09:40:49+07:00
draft: true
---

# Garbage collection
```
In Go (Golang), automatic memory management is handled by a garbage collector. The garbage collector is responsible for reclaiming memory that is no longer in use, preventing memory leaks and allowing developers to focus on writing code without explicit memory deallocation.

Here are some key points about the garbage collector in Go:

1. Concurrency: Go's garbage collector is concurrent, meaning it runs concurrently with the application code. This concurrency helps in minimizing pauses and improving the overall performance of the application.

2. Tracing Garbage Collector: Go uses a tracing garbage collector. It works by tracing through the memory from the root objects (global variables, stack frames, etc.) to identify and mark objects that are still reachable (live objects). The unreachable objects are then considered garbage and can be safely deallocated.

3. Generational Garbage Collection: Go's garbage collector uses a generational garbage collection algorithm. It divides objects into multiple generations based on their age. Young objects are collected more frequently, while older objects are collected less frequently.

4. Mark and Sweep: The garbage collector follows a mark-and-sweep algorithm. It first marks all live objects by traversing the object graph, starting from the roots. After marking, it sweeps through the memory, deallocating memory occupied by unmarked (garbage) objects.

Memory Reclamation: The garbage collector reclaims memory by compacting the heap. It moves objects closer together, reducing fragmentation and improving memory utilization.

Tuning: Go provides some tunable parameters to adjust the garbage collector's behavior based on the application's needs. For example, you can adjust the size of the heap or the garbage collection latency.

GOMAXPROCS: The GOMAXPROCS environment variable or the runtime.GOMAXPROCS() function can be used to set the maximum number of CPUs that the Go runtime can use for garbage collection and other concurrent operations.
```

# Go routine
## Design pattern

1. Fan-Out, Fan-In:
Fan-Out: Launch a fixed number of goroutines to perform a task concurrently.
Fan-In: Combine the results from multiple goroutines into a single channel.
```
package main

import (
    "fmt"
    "sync"
)

func worker(id int, jobs <-chan int, results chan<- int) {
    for job := range jobs {
        fmt.Printf("Worker %d processing job %d\n", id, job)
        results <- job * 2
    }
}

func main() {
    const numWorkers = 3
    jobs := make(chan int, 5)
    results := make(chan int, 5)

    var wg sync.WaitGroup

    // Fan-Out: Launch workers
    for i := 1; i <= numWorkers; i++ {
        wg.Add(1)
        go func(i int) {
            defer wg.Done()
            worker(i, jobs, results)
        }(i)
    }

    // Fan-In: Combine results
    go func() {
        wg.Wait()
        close(results)
    }()

    // Send jobs to workers
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

2. Worker Pool:
Create a pool of workers (goroutines) to handle incoming tasks.
Use a channel to dispatch tasks to available workers.
```
package main

import (
    "fmt"
    "sync"
)

func worker(id int, jobs <-chan int, wg *sync.WaitGroup) {
    defer wg.Done()
    for job := range jobs {
        fmt.Printf("Worker %d processing job %d\n", id, job)
    }
}

func main() {
    const numWorkers = 3
    jobs := make(chan int, 5)

    var wg sync.WaitGroup

    // Create worker pool
    for i := 1; i <= numWorkers; i++ {
        wg.Add(1)
        go worker(i, jobs, &wg)
    }

    // Send jobs to workers
    for i := 1; i <= 5; i++ {
        jobs <- i
    }
    close(jobs)

    // Wait for all workers to finish
    wg.Wait()
}
```
3. Pipeline:
Compose a series of processing stages, each implemented by a goroutine.
Use channels to connect stages and pass data between them.
```
package main

import (
    "fmt"
)

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

func printer(in <-chan int) {
    for n := range in {
        fmt.Println(n)
    }
}

func main() {
    nums := []int{1, 2, 3, 4, 5}
    gen := generator(nums...)
    sqr := square(gen)

    // Consuming the results
    printer(sqr)
}
```