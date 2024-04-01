---
title: "Golang"
date: 2023-12-23T09:40:49+07:00
draft: true
---

# Garbage collection
```
The garbage collector, or GC, is a system designed specifically to identify and free dynamically allocated memory.

Go uses a garbage collection algorithm based on tracing and the Mark and Sweep algorithm. During the marking phase, the garbage collector marks data actively used by the application as live heap(It first marks all live objects by traversing the object graph, starting from the roots). Then, during the sweeping phase, the GC traverses all the memory not marked as live and reuses it. 

The garbage collector’s work is not free, as it consumes two important system resources: CPU time and physical memory.

The memory in the garbage collector consists of the following:
- Live heap memory (memory marked as “live” in the previous garbage collection cycle)
- New heap memory (heap memory not yet analyzed by the garbage collector)
- Memory is used to store some metadata, which is usually insignificant compared to the first two entities.
The CPU time consumption by the garbage collector is related to its working specifics. There are garbage collector implementations called “stop-the-world” that completely halt program execution during garbage collection. In the case of Go, the garbage collector is not fully “stop-the-world” and performs most of its work, such as heap marking, in parallel with the application execution.
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