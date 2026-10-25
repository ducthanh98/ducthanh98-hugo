---
title: "Computer Networking Fundamentals for Interviews"
date: 2024-01-10T10:00:00+07:00
draft: false
categories: ["Computer Science"]
tags: ["Networking", "TCP/IP", "HTTP", "DNS", "TLS", "gRPC", "WebSockets"]
---

# Computer Networking Fundamentals

## Table of Contents
- [OSI 7 Layers vs TCP/IP Model](#osi-7-layers-vs-tcpip-model)
- [TCP vs UDP](#tcp-vs-udp)
- [TCP 3-Way Handshake & 4-Way Teardown](#tcp-3-way-handshake--4-way-teardown)
  - [3-Way Handshake (Connection Establishment)](#3-way-handshake)
  - [4-Way Teardown (Connection Termination)](#4-way-teardown)
  - [The TIME_WAIT State](#the-time_wait-state)
- [HTTP Evolution: HTTP/1.1 vs HTTP/2 vs HTTP/3](#http-evolution)
- [HTTPS & SSL/TLS Handshake](#https--ssltls-handshake)
- [What Happens When You Type a URL in Your Browser?](#what-happens-when-you-type-a-url)
- [API Protocols: REST vs gRPC vs WebSockets](#api-protocols-rest-vs-grpc-vs-websockets)
- [Load Balancing: Layer 4 vs Layer 7](#load-balancing-layer-4-vs-layer-7)

---

# OSI 7 Layers vs TCP/IP Model

| OSI Layer | TCP/IP Layer | Common Protocols / Devices | Data Unit |
| :--- | :--- | :--- | :--- |
| **7. Application** | **Application** | HTTP, HTTPS, DNS, SSH, SMTP, gRPC | Messages / Data |
| **6. Presentation** | Application | TLS/SSL, JSON, XML, JPEG, Protobuf | Data |
| **5. Session** | Application | RPC, Sockets, NetBIOS | Data |
| **4. Transport** | **Transport** | TCP, UDP, QUIC | **Segment** (TCP) / **Datagram** (UDP) |
| **3. Network** | **Internet** | IP (IPv4, IPv6), ICMP, Routers | **Packet** |
| **2. Data Link** | **Network Access** | Ethernet, MAC addressing, Switches | **Frame** |
| **1. Physical** | Network Access | Cables, Fiber, NIC, Radio waves | **Bits** |

---

# TCP vs UDP

| Feature | TCP (Transmission Control Protocol) | UDP (User Datagram Protocol) |
| :--- | :--- | :--- |
| **Connection** | Connection-oriented (Handshake required) | Connectionless |
| **Reliability** | Guaranteed delivery (retransmission of lost packets) | Best-effort (packets may be lost or disordered) |
| **Ordering** | In-order delivery guaranteed (sequence numbers) | No order guaranteed |
| **Flow & Congestion Control** | Built-in (Sliding window, Slow start, Congestion avoidance) | None |
| **Header Overhead** | 20 - 60 bytes | 8 bytes |
| **Speed** | Slower (due to acknowledgments & handshakes) | Fast and low latency |
| **Use Cases** | Web (HTTP/HTTPS), File transfer (FTP/SFTP), Emails, Database connections | Real-time gaming, Video streaming, VoIP, DNS queries |

---

# TCP 3-Way Handshake & 4-Way Teardown

## 3-Way Handshake
Establishes a reliable TCP connection between Client and Server:

```
Client                                  Server
  |                                       |
  | -------- 1. SYN (seq=x) ------------> |  (Client sends SYN, state -> SYN_SENT)
  |                                       |  (Server receives SYN, state -> SYN_RCVD)
  | <------- 2. SYN-ACK (seq=y, ack=x+1) -|  (Server replies with SYN + ACK)
  |                                       |  (Client receives SYN-ACK, state -> ESTABLISHED)
  | -------- 3. ACK (ack=y+1) ----------> |  (Client confirms ACK)
  |                                       |  (Server receives ACK, state -> ESTABLISHED)
```

- **SYN Flood Attack**: Attacker sends massive SYN requests without replying to SYN-ACK, exhausting the server's backlog queue.
  - *Mitigation*: Enable **SYN Cookies** (`net.ipv4.tcp_syncookies = 1`), rate limiting, firewalls.

## 4-Way Teardown
Gracefully closes a TCP connection:

```
Client                                  Server
  |                                       |
  | -------- 1. FIN (seq=u) ------------> |  (Client initiates close, state -> FIN_WAIT_1)
  | <------- 2. ACK (ack=u+1) ----------- |  (Server acknowledges FIN, state -> CLOSE_WAIT)
  |                                       |  (Client receives ACK, state -> FIN_WAIT_2)
  |                                       |  [Server finishes pending data transmission]
  | <------- 3. FIN (seq=w) ------------- |  (Server sends FIN, state -> LAST_ACK)
  | -------- 4. ACK (ack=w+1) ----------> |  (Client sends ACK, state -> TIME_WAIT)
  |                                       |  (Server closes immediately)
  |  [Waits 2 * MSL (typically 60s)]      |
  v  State -> CLOSED                      |
```

## The TIME_WAIT State
- **Why is TIME_WAIT necessary?**
  1. To ensure the final ACK reached the other end. If the ACK was lost, the server retransmits its FIN, and the client in TIME_WAIT can resend the ACK.
  2. To allow lingering duplicate packets from this connection to expire in the network before a new connection reuses the same port/IP tuple.
- **Problem**: In high-throughput microservices, thousands of short-lived connections can exhaust ephemeral ports due to sockets lingering in TIME_WAIT.
- **Solution**: Use HTTP Connection Keep-Alive / connection pooling; reuse sockets (`net.ipv4.tcp_tw_reuse = 1`).

---

# HTTP Evolution

| Version | Transport Protocol | Key Features & Advantages | Key Drawbacks |
| :--- | :--- | :--- | :--- |
| **HTTP/1.1** (1997) | TCP | Persistent connections (Keep-Alive), chunked transfer. | **Head-of-Line (HoL) Blocking** at application layer. Only 1 request/response per connection at a time. |
| **HTTP/2** (2015) | TCP | **Multiplexing** (multiple requests in single TCP connection via streams), Binary protocol, Header Compression (HPACK), Server Push. | **TCP Head-of-Line Blocking**: If 1 packet is lost, the entire TCP connection stalls until retransmitted. |
| **HTTP/3** (2022) | **QUIC** (over **UDP**) | Eliminates TCP HoL blocking (streams are independent in QUIC), 0-RTT connection resumption, Built-in encryption (TLS 1.3), Connection Migration across Wi-Fi/4G. | High CPU usage on legacy middleboxes; UDP packets blocked on some restrictive firewalls. |

---

# HTTPS & SSL/TLS Handshake

HTTPS encrypts HTTP traffic by wrapping it inside **TLS (Transport Layer Security)**:

```
Client                                                Server
  |                                                     |
  | --- 1. ClientHello (TLS version, Ciphers, Nonce) -> |
  |                                                     |
  | <-- 2. ServerHello (Selected Cipher, Server Nonce)- |
  | <-- 3. Certificate (Signed by CA with Public Key) - |
  | <-- 4. ServerKeyExchange (Diffie-Hellman params) -- |
  | <-- 5. ServerHelloDone ---------------------------- |
  |                                                     |
  |  [Client validates Certificate chain against Root CAs]
  | --- 6. ClientKeyExchange (DH params or Pre-Master) ->|
  | --- 7. ChangeCipherSpec & Finished (Encrypted) ----> |
  |                                                     |
  | <-- 8. ChangeCipherSpec & Finished (Encrypted) ---- |
  |                                                     |
  | <======== Application Data Encrypted with =========>|
  | <======== Symmetric Session Key (AES-GCM) ========> |
```

- **Asymmetric Encryption**: Used during handshake to authenticate server identity and securely negotiate symmetric session keys.
- **Symmetric Encryption**: Used for subsequent data transfer because it is significantly faster than asymmetric encryption.

---

# What Happens When You Type a URL in Your Browser?

1. **DNS Lookup**:
   - Check Browser Cache -> OS Cache (`/etc/hosts`) -> Local Router Cache -> ISP Resolver (Recursive DNS).
   - If not found: Root Server (`.`) -> TLD Server (`.com`) -> Authoritative Name Server (`example.com`).
2. **TCP Handshake**: Client initiates 3-way handshake with target IP address on port 443 (HTTPS) or port 80.
3. **TLS Handshake**: Negotiates encryption keys, validates SSL certificate.
4. **HTTP Request**: Browser sends `GET / HTTP/2` request with headers (Host, User-Agent, Accept).
5. **Server Processing**: Reverse proxy (Nginx) terminates TLS, forwards request to application microservice, queries database/cache, returns HTML payload.
6. **Browser Rendering**: Browser receives HTTP response, parses HTML to build DOM Tree, parses CSS to build CSSOM Tree, combines into Render Tree, computes Layout, Paints pixels to screen, and executes JavaScript.

---

# API Protocols: REST vs gRPC vs WebSockets

| Aspect | REST (HTTP/1.1 or HTTP/2) | gRPC (HTTP/2) | WebSockets |
| :--- | :--- | :--- | :--- |
| **Data Format** | JSON (Text-based, larger payload) | Protocol Buffers (Binary, compact) | Text (JSON) or Binary |
| **Communication** | Request / Response (Stateless) | Unary, Server Streaming, Client Streaming, Bidirectional Streaming | Full-Duplex, Persistent, Stateful connection |
| **Performance** | Moderate (JSON serialization overhead) | Very High (Low CPU, minimal network overhead) | High (Minimal header overhead after handshake) |
| **Typing & Contract** | OpenAPI / Swagger (optional) | Strict schema (`.proto` file with auto-generated client stubs) | Custom protocol required |
| **Best Used For** | Public APIs, Browser-to-Backend | **Internal Microservices communication**, High-throughput RPC | Real-time chat, Live financial tickers, Gaming |

---

# Load Balancing: Layer 4 vs Layer 7

## Layer 4 Load Balancing (Transport Layer)
- Operates at TCP/UDP level.
- Routes traffic based on IP address and port without inspecting message content or headers.
- **Pros**: Blazing fast, minimal CPU overhead.
- **Cons**: Cannot inspect HTTP headers, cookies, or URL paths.
- **Examples**: AWS NLB (Network Load Balancer), Linux IPVS, HAProxy (mode tcp).

## Layer 7 Load Balancing (Application Layer)
- Operates at HTTP/HTTPS level.
- Inspects path (`/api/v1/orders`), headers (Authorization, Host), cookies, query strings.
- **Pros**: Intelligent routing, SSL/TLS termination, rate limiting, path-based routing.
- **Cons**: Higher CPU and latency overhead due to decrypting and buffering payloads.
- **Examples**: AWS ALB (Application Load Balancer), Nginx, Traefik, Envoy Proxy.
