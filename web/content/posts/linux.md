---
title: "Linux"
date: 2023-11-12T22:53:02+07:00
draft: true
---

# Processes
## Concept
- A running instance of a program is called a process and it runs in its own memory space. Each time you execute a command, a new process starts.
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