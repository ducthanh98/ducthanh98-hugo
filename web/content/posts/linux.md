---
title: "Linux"
date: 2023-11-12T22:53:02+07:00
draft: true
---

# Processes
## Concept
- A running instance of a program is called a process and it runs in its own memory space. Each time you execute a command, a new process starts. An active processs also includes the resources the program needs to run. These resources are are managed by the operating system(heap, process registers, program counters)
- Each process has its own memory adress space and one process cannot corrupt the memory space of another process. 

-  A process is an active entity as opposed to a program, which is considered to be a passive entity.
-  A new process is created only when running an executable file (not when running Shell builtin commands).
- Process properties:
    + PID (Process ID) - a unique positive integer number 
    + User
    + Group
    + Priority / Nice
- Type of Processes:
+ Parent
+ Child
+ Daemon
+ Zombie (defunct): a terminated child process that remains in the system's process table while waiting for its parent process to collect its exit status
+ Orphan: A process whose parent process no more exists i.e. either finished or terminated without waiting for its child process to terminate 
## Thread
- A Thread is a unit of execution within a process. A process has at least  one thread. It is called the main thread. 
- Each has it own stack and it is possible to communicate between threads using shared memory space. However, a misheaving thread can bring down the entire process
## How CPU run a thread or process on a CPU
- This is handled by context switching. When one process is switched out of the CPU so another process can run
- The operating system stores the state of the current running process so the process can be retored and resume execution at a later point
- In then restores the previously state of other process and resumes execution of that process.
- Context switching is really expensive. It involves saving and loading of registers, switching out memory of pages and updating various kernal data structures.
- Switching execution between threads also requires context switching but it's faster because there are few state to track and there is no need to switch out virtual memory pages which is one of the most expensive operations during a context switch.
- Some other mechanisms: fiber or coroutine
# Cron
## Anacron: 
# Mount disk
