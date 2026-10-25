---
title: "Linux & Operating System Internals"
date: 2023-11-12T22:53:02+07:00
draft: false
categories: ["Computer Science"]
tags: ["Linux", "Operating Systems", "Processes", "Threads", "Memory"]
---

# Operating System Internals & Linux

## Table of Contents
- [Processes](#processes)
  - [Process Concept](#process-concept)
  - [Process States & Types](#process-states--types)
- [Threads](#threads)
  - [Process vs Thread](#process-vs-thread)
- [Context Switching](#how-cpu-runs-a-thread-or-process-on-a-cpu)
- [Memory Management (Stack vs Heap, Virtual Memory)](#memory-management)
- [Cron & Scheduling](#cron)
- [Storage & Mount Disk](#mount-disk)
- [Essential Linux Troubleshooting Commands](#essential-linux-troubleshooting-commands)

---

# Processes

## Process Concept
- A running instance of a program is called a process and it runs in its own memory space. Each time you execute a command, a new process starts. An active process also includes the resources the program needs to run. These resources are managed by the operating system (heap, stack, process registers, program counter, file descriptors).
- Each process has its own isolated virtual memory address space. One process cannot corrupt the memory space of another process without IPC mechanisms (pipes, sockets, shared memory).
- A process is an active entity, whereas a program (the compiled binary on disk) is passive.
- A new process is created by system calls (e.g. `fork()` followed by `execve()`).

### Process Properties:
- **PID (Process ID)**: Unique positive integer identifying the process.
- **PPID (Parent Process ID)**: The PID of the process that spawned it.
- **User / UID & Group / GID**: Identifies security privileges.
- **Priority & Nice Value**: Nice value ranges from -20 (highest priority) to +19 (lowest priority, default 0). Lower nice value means higher CPU share.
- **File Descriptors (FD)**: Standard Streams: `0` (stdin), `1` (stdout), `2` (stderr).

## Process States & Types
- **Process States**:
  - `R` (Running / Runnable): Waiting in the run queue or executing on CPU.
  - `S` (Interruptible Sleep): Waiting for an event/resource (e.g. I/O or network).
  - `D` (Uninterruptible Sleep): Usually waiting on disk I/O; cannot be killed with `kill -9`.
  - `Z` (Zombie / Defunct): Terminated, but exit status has not been reaped by parent.
  - `T` (Stopped / Traced): Stopped by signal (e.g. `Ctrl+Z` or debugger).

- **Types of Processes**:
  - **Parent Process**: A process that creates one or more child processes using `fork()`.
  - **Child Process**: Process created by a parent. Inherits environment and file descriptors.
  - **Daemon Process**: A background service that runs independently of a controlling terminal, usually ending in 'd' (e.g. `systemd`, `sshd`, `crond`).
  - **Zombie (Defunct)**: A terminated child process that remains in the process table because the parent hasn't called `wait()` or `waitpid()` to read its exit code. Zombies consume process table slots. If table fills up, no new processes can be created.
  - **Orphan Process**: A child process whose parent exited before the child finished. Orphan processes are immediately adopted by PID 1 (`systemd` / `init`), which reaps them when they terminate.

---

# Threads

## Process vs Thread
- A **Thread** is a lightweight unit of execution within a process. A process has at least one thread (the main thread).
- **Shared Resources**: Threads within the same process share:
  - Address space (Code segment, Data segment, Heap).
  - Open file descriptors, sockets, signals.
- **Private Resources**: Each thread has its own:
  - Stack (local variables, function call frames).
  - Registers & Program Counter (PC).
  - Thread ID (TID).
- **Risk**: Because threads share memory, race conditions and deadlocks can occur without proper synchronization (Mutex, Semaphores). A crashing thread (e.g. segfault) typically terminates the entire process.

---

# How CPU Runs a Thread or Process on a CPU

## Context Switching
- When the OS scheduler decides to stop running one task and start running another, a **Context Switch** occurs.
- **Workflow**:
  1. Save state of current running task (registers, stack pointer, program counter, CPU flags).
  2. Update scheduler data structures and accounting info.
  3. Load saved state of the next task into CPU registers.
  4. Flush / reload CPU caches and memory translation tables if switching between different processes.
- **Process vs Thread Context Switch Overhead**:
  - **Process switch is expensive**: Requires flushing the TLB (Translation Lookaside Buffer) and switching virtual memory page tables (`CR3` register in x86). This causes CPU cache misses.
  - **Thread switch is lightweight**: Since threads share the same address space and memory mappings, the TLB does not need to be flushed. Only CPU registers and the stack pointer are switched.

---

# Memory Management

## Stack vs Heap
- **Stack**:
  - Memory allocated contiguously for local variables and function execution frames.
  - Very fast allocation/deallocation (just moving stack pointer).
  - Managed automatically by compiler / runtime.
  - Fixed size limit per thread; exceeding it causes **Stack Overflow**.
- **Heap**:
  - Memory dynamically allocated at runtime (`malloc` in C, `new` / escape to heap in Go).
  - Slower allocation (requires memory allocator / free-list search).
  - Managed manually or by Garbage Collector (GC).
  - Prone to memory fragmentation and memory leaks.

## Virtual Memory & Paging
- Applications interact with **Virtual Addresses**, not physical RAM directly.
- The **MMU (Memory Management Unit)** translates virtual addresses to physical addresses using **Page Tables**.
- Memory is managed in fixed-size blocks called **Pages** (typically 4 KB).
- **Page Fault**: Occurs when a program accesses a page that is not currently mapped into physical RAM (e.g. swapped out to disk or lazily allocated). The kernel fetches the page from disk into RAM.

---

# Cron & Scheduling

## Cron
- The `cron` daemon runs scheduled jobs defined in crontabs (`/etc/crontab` or `crontab -e`).
- Format: `minute hour day_of_month month day_of_week command`
  ```
  * * * * * command (runs every minute)
  0 2 * * * backup.sh (runs at 02:00 every day)
  ```
- Limitation: If the system is powered off during the scheduled time, the job is **missed**.

## Anacron
- Unlike `cron`, `anacron` is designed for machines that are not running 24/7 (like laptops or desktops).
- It executes missed periodic jobs (daily, weekly, monthly) when the system boots back up.

---

# Storage & Mount Disk

## Filesystem & Inodes
- **Inode (Index Node)**: Data structure storing file metadata (file size, permissions, owner, timestamps, pointer to data blocks). Crucially, inodes do NOT store the filename (the directory entry maps filename to inode).
- If disk runs out of inodes (`df -i` shows 100%), you cannot create new files even if there is free disk space (`df -h`).

## Mounting Disks
- `lsblk`: List block storage devices.
- `fdisk -l` / `parted`: View partition tables.
- `mkfs.ext4 /dev/sdb1`: Format partition with filesystem.
- `mount /dev/sdb1 /data`: Mount storage to directory.
- `/etc/fstab`: Configuration file for persistent mounts on boot.

---

# Essential Linux Troubleshooting Commands

| Command | Purpose |
| :--- | :--- |
| `top` / `htop` | Real-time view of running processes, CPU, and RAM usage. |
| `ps aux --sort=-%cpu \| head -10` | Show top 10 CPU-consuming processes. |
| `ps aux --sort=-%mem \| head -10` | Show top 10 memory-consuming processes. |
| `free -m` | Display free and used memory (buffers/cache). |
| `vmstat 1` | Report virtual memory statistics, I/O wait (`wa`), system interrupts. |
| `iostat -xz 1` | Check disk I/O bottlenecks and `%util`. |
| `lsof -i :8080` | Find which process is listening on port 8080. |
| `ss -tulpn` / `netstat -tulpn` | Show listening network sockets and associated PIDs. |
| `df -h` & `df -i` | Check disk space and inode availability. |
| `journalctl -u service_name -f` | View systemd service logs in real time. |
| `strace -p <PID>` | Trace system calls and signals of a live process. |
