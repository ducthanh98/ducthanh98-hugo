---
title: "Amazon Solution Architect Professional Note"
date: 2022-11-28T22:58:35+07:00
draft: true
---

## Identify and Federation
### IAM:
    - Explicit DENY has precedence over ALOW
    - NotAction: explicit allow a FEW THING in there
    - Access Advisor: See permissions granted and when last accessed
    - Access analyzer: Analyze resources that are shared with external entity
### STS
    - When you assume a role, you give up your permissions and take the permissions assigned to the role and vice versa
### AWS Organization
    - Feature Mode:
        + Consolidated billing feature: 
            + Consolidated billing across all acounts - single payment method
            + Pricing benefits from aggregated usage
        + Invited accounts must approve enabling allf eatures
        + Ability to apply an SCP
        + Reserved Instances: All accounts can receive the benefits that are purchased by any another account. The payer can turn off reserved instance discount and savings plans discount sharing fr any accounts, including the payer
    - Service Control Policies:
        + SCP is applied to users and roles, service-linked role is not affected
        + Doesn't allow anything by default
        + Restrict access to certain service
        + You can restrict specific tags on AWS resources with AWS:TagKeys(Use either ForAllValues or ForAnyValues)
        + Use SCP to Deny A Region aws:RequestRegion
        + Use SCP to restrict creating resources without appropriate tags: 
            Null:{
                aws:RequestTag/xxx: true
            }
    - Tag Policies:
        + Ensure consistent tags, audit tagged resources
    - Opt out
        + AWS AI may use your content to continuous improvent
        + Attached to OG, OU, individual member
    - Backup policies
        + Enables you to create backup plan.
        + Attached to OG, OU, individual member
        + Immutable backup plans appear in Member accounts
### RAM
- Share with other account or your OG
- Avoid resource duplication
- Share route53: https://aws.amazon.com/vi/premiumsupport/knowledge-center/route-53-share-resolver-rules-with-ram/
- Sharing managed prefix list: https://docs.aws.amazon.com/vpc/latest/userguide/sharing-managed-prefix-lists.html
### Aws Control Tower
- Easy way to setup and govern a secure and compliant multi-account AWS environment
- Automate the setup of your new environment in a few click
    + Automate account provisioning and deployments
    + Enable you to create pre-approved baselines and config
    + Use AWS catalog to provision new acc
- Automate ongoing policy management using guardrails
    + Preventive: Using SCP
    + Detective: Using AWS Config
- Detect policy violations and remediate them
- Monitor compliant through dashboard
- Run on top AWS Organizations
## Security
### Cloud Trail
- Provide governance, compliance, audit for your AWS account
- Get history of event/API calls
- Put logs from CloudTrail to S3, CW Logs
- A trail can be applied to All Region or A Single Region
- If a resource is deleted in AWS, investigate CloudTrail first
- Management Event
    + Enabled by default, Seperate read and write event
- Data Event:
    + Not enabled by default
    + S3 activity, lambda function execution activity
- Insights: Detect unusual activity
- Retention: 
    + 90 days in CloudTrail
    + To keep event, log them to S3
- Use cases:
    + Delivery to S3: 
        * Enable versioning
        * MFA delete protection
        * S3 Lifecycle
        * S3 object lock
        * SSE-S3, SSE-KMS
        * Perform log file integrity validation
    + Multi account, region logging
        * Account A access to bucket B via cross account role and assume the role or edit the bucket policy
    + Alert for API calls: CW Logs -> Metric Filter -> CW Alarm -> SNS
    + Organizational Trail: Setup in management account 
    + React to events the fastest:
        * Overall, it may take up 15 min to deliver events
        *  Event Bridge: the fatest, most reactive way
        * CloudTrail Delivery in Cloudwatch Logs:  perform a metric filter to analyze
        * CloudTrail Delivery in S3: Delivered every 5 minutes
### KMS

- KMS Key Types:
    + Symmetric AES-256: 
        * Integrated with other services
        * Never access to KMS key unencrypted
    + Asymmetric(RSA & ECC key pairs): 
        * Used for encrypt/decrypt or sign/verify operations
        * Never access to private key unencrypted

- KMS Key Types:
    + Customer Managed Key: 
        * Can handle
        * Rotation policy
        * Add a key policy and audit
        * Leverage for envelope encryption
    * AWS Managed Key
        * Used by AWS service(s3,ebs,redshift)
        * Automatically roated every 1 years
        * View key policy and audit
    * AWS Owned Key
        * Used and managed by aws
- AWS Key Material Origin
    + AWS_KMS: Created and Managed by AWS
    + EXTERNAL: 
        * Import the material into KMS and managing outside
        * Manually rotate
        * Must be AES-256 symmetric(asymmetric is NOT supported)
    + AWS_CLOUDHSM: 
        * Direct control over HSM
        * HSM must validated at FIPS 140-2 Level 3(KSM must validated at FIPS 140-2 Level 2)
- AWS KMS Multi-Region
    + Same key ID, material,... but they're NOT global
    + Each key is managed INDEPENDENTLY
    + Use cases: DR, Global DB, Active-active applications that span multi-region
### SSM Paramter Store
- Version tracking
- security through IAM
- notification with Amazon EventBridge
- Serverless, scalable, durable
- Type:
    + Standard: 4kb, no parameter policies
    + Advanced: 8kb, 0.05%/ parameter
- Parameter policy: Assign TTL to force updating and deleting sensetive data
- Pull secret manager secret
### Secret Manager
- Force rotation of secret
- Control access to secrets using Resource-based Policy
- KMS encryption is mandatory
### RDS Security
- Transparent Data Encryption (TDE) for Oracle and MSSQL
- IAM Authentication  for MySQL and PostgreSQl
- SSL encryption
- KMS encryption at rest for underlying EBS
### SSL
- SNI:
    + Solved: Loading mutiple SSL onto one webserver
    + Require client to indicate the hostname of the target server in the initial SSL handshake
    + Only Works with ALB and NLB
- Prevent: Man in Middle Attack
    + Don't use public HTTP, use HTTPS
    + Use DNS that has DNSSEC
- Use case:
    + SSL for ALB
    + SSL for Ec2: retrieve ssl private key at EC2 boot time. Install certs on EC2
    + SSL Offloading: Offload SSL to CloudHSM. Must setup a cryptographic user (CU) on the CloudHSM device
### ACM
- Integration: LB, Cloudfront, API GW
- Automatically renew cert if generated by ACM
- Public cert: 
    + Must verify public DNS
    + Issued by a trusted CA
- Private cert:
    + For internal app
    + Create your own CA
    + Your app must trust your CA
- Is regional service. Can not copy cert to across region
### AWS CloudHSM
- Spread across multi A-Z
- Great for availability and durability 
- Deploy and share across multi VPC
- Create and manage
### S3
- SSE-S3: encrypts S3 objects using keys handled and managed by AWS
- SSE-KMS: 
    + Key usage appears in CloudTrail
    + object made public can never be read
    + kms:GenerateDataKey is allowed
- SSE-C
- Glacier: All data is AES-256 encrypted, key under AWS control
- Encryption: 
    + HTTPS is recommend, but it is mandatory for SSE-C
    + To enforce https, use aws:SecurityTransport
- Event Notifications: 
    + Destination: SNS,SQS,Lambda
- Pre-signed URLs: Valid for 3600s. can change with --expires-in
- S3 access point: 
    + Each access point gets its own DNS and policy to limit who can access it
    + One policy per access point => Easier to manage than complex bucket policy
    + Restrict access from specific VPC
    + Linked to a specific bucket
# AWS Shield
- Ec2, route 53, cloudfront, global accelator, load balancer
# WAF
- Deploy on ALB, API Gateway, Cloudfront, Appsync(Grapql)
- Define Web ACL
- Protect from common atk - SQL , XSS
- Size constraints, geo match
- rate-based rules
- rule actions: coun, allow, block, captcha
- Type of rule
    + Baseline Rule Groups: general protection from common threats
    + Specific Rule Groups: protection for many AWS WAF use cases
    + IP Reputation Rule Groups: block requests based on source (malicious IPs)
    + Bot Control Managed Rule Group: block and manage from bots
- Log
    + CW Logs: 5M/sec
    + S3: 5 min interval
    + Kinesis Data Firehose: limited by Firehose quotas
# Firewall Manager
- If you want to use WAF across accounts, accelerate WAF configuration, automate the protection of new resources, use Firewall Manager
# AWS Inspector
- Ec2: 
    + Leverage AWS System Manager(SSm) agent
    + Analyze against unintended network accessibility
    + Analyze the running OS against known vulnera
- For container push to ECR:
    + Assessment of containers as they are pushed
- Reporting and integration with AWS Security Hub
- Send finding to AWS Event Bridge
- Network reachability (Ec2)
- A risk score is associated with all vulnerabilities for prioritization
### AWS Config
- Doesn't prevent actions from hapening
- Record configurations and changes over time
- AWS Config is a per-region service
### AWS Managed Log
- Load Balancer: S3
- CloudTrail : S3, CW
- VPC Flow Logs: S3, Cw
- Route 53: S3
- S3: S3
- CloudFront: S3
- Aws Config: S3
### AWS GuardDuty
- CloudTrail Events Logs: unusual api call, unauthorized deployments
- VPC Flow Logs: unusual internal traffic, IP
- DNS Logs: compromised EC2 instances sending encoded data with DNS queries
- K8s Audit Logs: suspicious activities and potential EKS Cluster compromises
### AWS Security Hub
- Central security tool to manage across accounts and automate security checks
- Integrated dashboard
- Must enable AWS Config first
### AWS Detective
- Analyzes, investigates and quickly identifies the root cause of security issues of suspicious action
- Automatically collects and processes events from VPC Flow Logs and CloudTrail and GuardDuty
## Compute and Load Balancing
### Ec2
- Ec2 Instance Refresh: Update launch template and then re-creating all Ec2 instances
- Health check: 
    + EC2 Status
    + ELB Health check(HTTP)
### ECS
- Service: How many task should run and how they should be run
- Definition: metadata in json form
- Task: a instance of task definition
- ECS Iam Role:
    + Ec2 Instance Profile: used by EC2 instance
    + ECS Task IAM Role: allow each task have specific role
### ECR
- Supports both cross-region and cross-account replication
- Image scaning:
    + Basic scanning
    + Enhanced scanning: leverages amazon inspector
- Data volumes:
    + EBS
    + EFS
    + FSx for Lustre
    + FSx for netApp ONTAP
### App runner
- Fully managed service that makes it easy to deploy web applications and APs at scale
- Use cases: web apps, apis, microservices, rapid production deployments.
### Lambda
- RAM: 128MB - 10240MB
- CPU: is linked to RAM
- Timeout: 15 min
- /tmp storage: 10240MB
- Deployment package: 50MB zipped, 250MB unzipped including layers
- Concurrent Executions: 1000
- Container Image Size: 10GB
- Invocation Payload: 6MB sync, 256kb async
- Code Deploy can help you to automate traffic shift for Lambda alias
- Types:
    + Linear: grow traffic every x minutes until 100%
    + Canary: try X percent then 100%
    + AllAtOnce: immediate
- Synchronous Invocations: Cli,sdk,api gateway
- Asynchronous Invocations: 
    + S3,SNS, Event Bridge
    + Can define a DLQ: SNS or SQS
    + Attempts to retry on 3 errors
### Load Balancer
- Classic LB: HTTP or TCP. supports only one SS
- Application LB: 
    + Support http http2, websocket, 
    + Target: EC2, ECS Task, Lambda, IP
- Network LB:
    + TCP,UDP
    + One static IP per AZ and supports assigning EIP
    + Target: Ec2, IP, ALB
    + Zonal DNS Name: Resolving Regional NLB DNS name returns the ip for all NLB nodes in all enabled AZ
- Gateway LB:
    + Deploy, scale and manage for 3rd party network virtual appliances
    + Example: Firewall, Instrution Detection and Prevention Systems, Deep Packet Inspection Systems, payload manipulation, ...
    + Layer 3
    + Use geneve protocol on port 6081
    + Target: IP, Ec2
- Algorithm:
    + Least Outstanding Request: Work with ALB, CLB
    + Round Robin: ALB,CLB
    + Flow hash: Only Network LB
### Api Gateway
- Limit:  29 seconds, 10MB payload
- Integrations: * HTTP
                    * Lambda
                    * AWS Service
- Endpoint Types:
    + Edge-Optimized: For global clients
        * Request are routed through CloudFront(improve latency)
        * Still lives only one region
    + Regional: For same region
        * Manually combine with CloudFront
- Cache: 0 - 300 sec. invalidate the cache with header: Cache-Control: max-age=0
- Errors:
    + 400 Bad Request
    + 403: Access Denied. WAF Filter
    + 429: Quota exceeded
    + 502: Incompatible output
    + 504: Timeout
- Security:
    + Load SSL
    + Resource based policy: Control who can access the API
    + IAM Execution Role
    + CORS
- Authentication:
    + IAM based access: Pass IAM Credentials in headers through Sig V4
    + Lambda Authorizer: Verify Oauth, third party, SAML
    + Cognito User Pools: Client authenticates with Cognito
- Logs: 
    + Cloudwatch Logs: 
    + IntegrationLatency, Latency, CacheHitCount, CacheMissCount
- X-ray:
    + Tracing extra information 
    + Xray API gateway, Lambda gives you the full picture
### AWS AppSync:
- Grapql support
- Realtime with websocket or MQTT
- For mobile: local data acess and synchronization
### Route 53
- Record Types:
    + A: IPV4
    + AAAA: Ipv6
    + CNAME: map hostname to another hostname and can't create CNAME for the top node of a DNS namespace
    + NS: name servers for hosted zone
- Targets:
    + ELB
    + Cloudfront
    + API GW
    + Beanstalk
    + S3
    + VPC Interface Endpoint
    + Global Accelerator
    + Route53
- Zones:
    + Public zones: Route traffic on the internet
    + Private zones: Route traffic within one or more vpcs
- DNSSEC: 
    + Protects against Man in Middle Atks
    + Works only with Public Hosted Zone
- Resolver Endpoint:
    + Inbound: DNS Resolver on your network can forward DNS queries to Route 53
    + Outbound: Use Resolver Rule to forward DNS queries to your DNS Resolver
    + Each endpoint supports up to 10 000 queries/second/ip
- Rules:
    + Forwarding Rule: Forward DNS queries for a specified domain or all its subdomain to target IP addresses
    + System Rules: Overrides the Forwarding Rules
    + Auto-defined System Rules: Defines how DNS queries for selected domains are resolved(eg AWS internal domain names, Privated Hosted Zones, ...)
### AWS Global Accelerator
- Good fit for non HTTP use cases: UDP,TCP,Voice over IP
- Good for use cases that require static IP(2 Anycast IP)
- Good for use cases that require deterministic, fast regional failover
### AWS Outposts:
- Server racks that offers the same aws infrastructure, services, APIs and tools to build your own system just as in the cloud.
- You are responsible for the Outposts Rack physical security
- Benefits:
    + Low-latency access to on-premises systems
    + Local data processing
    + Data residency
    + Easier migration from on-permises to cloud
    + Fully managed service
- Some services that work on Outposts:
    + EC2
    + EBS
    + S3
        * Use S3 APIs to store and retrieve
        * S3 Storage class named s3 outposts
        * Default encryption: SSE-S3
        * S3 outposts -> s3 access point <- ec2
        * S3 outposts -> datasync -> S3
    + EKS
    + ECS
    + RDS
    + EMR
### AWS WaveLength
- Bridge AWS services to the edge of 5G networks
- Ec2, EBS,VPC
- Ultra-low latency applications through 5G
- No additional charges or service agreements.
- Use cases: Smart cities, Conntected vehicles, real-time gaming, AR/VR
### AWS Local Zones
- Place AWS compute, storage, database, ... closer to end users to run latency-sensitive applications.
- Extend your VPC to more locations - extension of an AWS Region
- Compatible with EC2, RDS, ECS, EBS, Elastic Cache,Direct Connect
- Example: 
    + AWS Region: us-east-1
    + AWS Local Zones: Boston, Chicago
## Storage
### EC2
- Network drive you attach to 1 instance only
- Can be resized
- Only gp2/gp3 and io1/io2 can be used as boot volume
- EBS Backup
    + Only backup changed blocks
    + Use IO so you shouldn't run them while your application is handling a lot of traffic
    + Snapshots will be stored in s3
    + Copy snapshots across region
    + Make AMI from snapshots
- Data Lifecyle Manager
    + Automate the creation, retention and deletion of EBS snapshots and EBS-backed AMIs
    + Use resource tags to identify the resources
    + Can't be used to manage snapshots/AMIS created outside DLM
- AWS Backup
    + Manages and monitors backups across the AWS services you use from a single place
- io1/io2:
    + Attach the same EBS to mutiple EC2 instances in the same AZ
    + Must use a file system that's cluster-aware
- Local Instance Store: 
    + Very high IOPS
    + Disks up to 7.5TB, stripped to reach 60TB
    + Can not be increased in size
    + Risk of data loss if hardware fails
### EFS
- Can be mounted to many EC2 in multi A-Z
- Expensive(3x gp2), pay per GB used
- Compatible with Linux, POSIX compliant, NFSv4.1
- Attach to one VPC, create one ENI per zone
- Scale up to 1000s, 10gb/s throughput
- Mode:
    + Performance Mode: 
        * General purpose: latency-sensitive(web server, CMS)
        * Max IO: higher latency, throughput, highly parallel, ...
    + Throughput Mode:
        * Bursting(1 TB = 50Mb/s + burst up to 100Mb/s)
        * Provisioned: set your throughput regardless of storage size, ...
- Storage Tiers:
    + Stand and EFS-IA. 
    + Life cycle policy: Maximum 30 days
- Access Points: 
    + Easily manage applications access to NFS environments
    + Restrict access from NFS clients using IAM policies
- File system policies:
    + Grants full access to all clients
    + Same S3 bucket policy .
- Cross Region Replication
    + Replicate objects in an EFS file system to another AWS region
    + Setup for new or existing EFS file systems
    + Doesn't affect the provisioned throughput of the EFS filesyste
    + Use cases: meet your compliance and business continuity goals
### S3
- Anti patterns: 
    + Lots of small files
    + POISX file system (use EFS instead)
    + Search features, queries, rapidly changing data
    + Dynamic content
- Storage classes comparison
![Storage classes comparison](/s3_storage_classes_comparison.png)
- S3 Event Notifications
    + Some useful events: S3:ObjectCreated, S3:ObjectRemoved, S3:ObjectRestore, S3:Replication
    + Create as many s3 events as desired 
    + Deliver events in second but can sometimes take a minutes or longer
    + Object name filtering possible
- Baseline: 3500 PUT/COPY/POST/DELETE and 5500 GET/HEAD per second per prefix in a bucket
- S3 Performance:
    + Multi-part upload: recommended for files > 100MB, must use for files > 5GB. Can help parallelize uploads(speed up transfers)
    + S3 Transfer Acceleration: Increase transfer by transfering file to an AWS edge location. Compatible with multipart-upload
    + S3 Byte-Range Fetches: Can be used to speed up downloads and retrieve only partial data
- Storage Class Analysis: 
    + Help you decide when to transition objects to the right storage class
    + Recommendations for Stand and Stand-IA
    + Updated daily 
    + 24-48h hours to start seeing data analysis
    + Visualize data in QuickSight
- Storage Lens
    + Default dashboard or create your own dashboard
    + Aggregate data for Organization, specific accounts, regions, buckets or prefixs
    + Can be configured to export metrics daily to an s3 bucket(CSV, Parquet)
    + Free Metrics: 
        * Available for all customers
        * Contains around 28 usage metrics
        * Data is available for queries for 14 days
    + Advanced metrics and recommendations
        * additional paid metrics and features
        * Advanced metric: activity, advanced cost optimization, advanced data protection, status code
        + Cloudwatch Publishing: Access metrics in CloudWatch without additional charges
        + Prefix Aggregation: Collect metrics at the prefix level
        + Data is available for queries for 15 months
### Amazon Fsx
- Fsx for Windows:
    + Supports SMB and NFTS, Active Directory
    + Can be mounted on Linux EC2 instances
    + Supports Distribute File System(DFS) Namespaces 
    + Scale up to 10s of GB/s, millions of IOPS, 100s PB of data
    + Storage Options: 
        * SSD
        * HDD
    + Can be accessed from your on-premises(VPN and Direct Connect)
    + Backed-up daily to S3
    + Can be configured to be multi-AZ(HA)
- Fsx for Lustre
    + ML, HPC, Video Processing, Financial Modeling
    + Scales up to 100s GB/s, millions of IOPS, sub-ms latencies
    + Seamless integration with s3
    + Storage Options: 
        * SSD
        * HDD
- Deployment Options:
    + Scratch File System:
        * Temporary storage
        * Data is not replicated
        * Use case: short processing, optimize costs
    + Persistent
        * Long-term storage, sesitive data
        * Replicated within same AZ
        * Replace failed files within minutes
- Fsx for ONTAP
    + NFS, SMB, iSCSI, 
    + Move workloads running on ONTAP or NAS to aws
    + Storage shrink or grows automatically
- FSX for OpenZFS
    + NFS, ZFS protocols
- Using DataSync to move from One AZ to Multiple AZ or decrease volume size
### DataSync
- On premises: Need agent
- File permissions and metadata are preserved
- One agent task can use 10Gbps, setup a bandwidth limit
- Private VIF through Direct Connect
    + Agent -> Direct Connect -> Private Link -> Interface VPC Endpoint -> AWS DataSync
### AWS Transfer 
- Transfers into and out of S3 or EFS
- FTP, FTPS, SFTP
- Integrate with existing authentication systems (AD, LDAP, Cognito, Custom)
- Types:
    + Public Endpoint: 
        * Ips managed by aws
        * Cant setup allow lists by source ip
    + VPC Endpoint with internal access
        * Static private ips
        * Setup allow lists(SG and NACL)
    + VPC Endpoint with inter-facing
        * Static private ips
        * Static publics ips
        * Setup sg

## Caching
### Cloudfront
- Improves read performance, content is cached at edge
- Integration with Shield, WAF, Route 53
- Expose external HTTPS
- Support Websocket
- Origins:
    + S3: 
        * Enhanced security with Origin Access Control(OAC)
        * Enable Static Web Hosting to configure
    + Media Store Container && Media Package Endpoint
        * Deliver video on-demand or live streaming video using AWS Media Services
    + Custom Origin(HTTP):
        * EC2
        * ALB or CLB
        * API Gateway
        * HTTP Backend
- Cloudfront vs Cross Region:
    + CloudFront: Great for static content that must be available everywhere
    + Cross region: Great for dynamic content that needs to be avaiable at low-latency in few regions
- Restrict access to ALB and Custom Origins:
    + Configure CloudFront to add Custom HTTP Header
    + Configure the ALB to only forward request that contain that custom header
- Origin Groups: One primary and one secondary origin
- Geo Restriction:
    + You can limit who can access your distribution
    + The country is determined using a 3rd geo-ip database
    + geo header CloudFront-Viewer-Country is in Lambda@Edge
- Cloudfront SignedURL: 
    + Allow access to a path, no matter the origin
    + Only root can manage it
    + Filter by IP, path, date, expiration
    + Leverage caching features
- S3 Presigned URL:
    + Issue a request as the person who pre-signed URL
    + Limited lifetime
- Custom Error Pages: Use Error Caching Minium TTL 
- Edge Function
    + Runs close to your uses to minimize latency
    + Doesn't have any cache, only to change requests/response
    + Two types: CloudFront Functions && Lambda Edge
    + Use cases: 
        * Manipulate HTTP requests and responses
        * Implement request filtering before reaching the application 
        * User authentication and authorization
        * AB testing
    + CloudFront: Deploys at edge location
    + Lambda Edge: Deploys at regional edge cache
    + CloudFront Functions : 
        * Cache key normalization: Transform request attributes
        * Header manipulation
        * URL rewrites
        * Request authentication and authorization
    + Lambda Edge:
        * Longer execution(serveral ms)
        * Adjustable CPU or mem
        * Depends on 3rd lib
        * Network access to external services for processing
        * File system access or access to the body of HTTP request
## Databases
### DynamoDB
- NoSQL database, massive scale(1 000 000 rps)
- Similar to Cassandra
- No disk space to provision, max object size 400kb
- Read: Eventually, strong consistency
- ACID support
- Backup available, point in time recovery
- Classes: Standard, IA
- Data Types: String, Number, Boolean, Binary, Null, List, Map, String Set, Number Set, Binary Set
- Primary Keys: Parition Key or Parition Key + Sort Key(timestamp is good choice)
- Indexs:
    + Local Second Index: 
        * Keep the same primary key
        * Select an alternative sort key
        * Must be defined at table creation time
    + Global Second Index
        * Change the primary and optional sort key
        * Can be defined after the table is created
- You can only query by PK + sort key on the main table and indexes
- TTL: 
- DynamoDB Streams: 
    + Can be read by Lambda, Ec2
    + 24 hours retention of dagta
- Global Tables:
    + Active Active Replication, many regions
    + Must enable DynamoDB Streams
    + Userful for low latency, DR purposes
- DAX
    + Seamless cache for DynamoDB, no application re-write
    + Write go through DAX To DynamoDB
    + Micro-latency for cached reads and queries
    + 5 minutes TTL by default
    + Up to 10 nodes
    + Multi AZ(3 nodes minimum recommended for production)
    + Secure(KMS, CloudTrail, )
### RDS
- Failover:
    + If you have an Amazon Aurora Replica in the same or a different Availability Zone, when failing over, Amazon Aurora flips the canonical name record (CNAME) for your DB Instance to point at the healthy replica, which in turn is promoted to become the new primary. Start-to-finish failover typically completes within 30 seconds.
    + If you are running Aurora Serverless and the DB instance or AZ becomes unavailable, Aurora will automatically recreate the DB instance in a different AZ.
    + If you do not have an Amazon Aurora Replica (i.e., single instance) and are not running Aurora Serverless, Aurora will attempt to create a new DB Instance in the same Availability Zone as the original instance
- RDS Events: Get notified via SNS for events(operations, outages)
- Multi AZ && Read Replicas:
    + Multi AZ: Standby instance for failover in case of outage
    + Replicas: Increase read throughput. Can be cross-region
- Security:
    + Transparent Data Encryption(TDE) for Oracle and SQL Server
    + IAM authentication for MySQL and PostgreSQL
- Oracle:
    + Use RDS backup for backup and restore
    + Use Oracle RMAN(recovery mananger) for backups and restore to non rds
    + Real Application Cluster(RAC)
        * RDS for Oracle doesn't support RAC
        * RAC is working on EC2 instance because you have full control
        * DMS works on Oracle RDS
- RDS Proxy: you no longer need code that handles cleaning up idle connections and managing connection pools
### Aurora
- Automated failover for master in less than 30s
- Support cross region replication
- Troubleshooting RDS and Aurora Performance
    + CW Metrics: CPU, Memory, Swap Usage
    + Enhanced Monitoring Metrics: host level, process view, per-second metric
    + Slow query logs
- Convert RDS to Aurora
    + Take a snap and restore
    + Create new aurora replica from rds instance and promote it 
## Service Communication
### AWS Step Functions
- Invoke a lambda function
- Run an AWS Batch, ECS task
- Insert an item to DynamoDB
- Publish message to SNS,SQS
- Launch an EMR, Glue, SageMaker jobs, another Step Function
- Invoke Step Function Workflow:
    + AWS Management Console
    + AWS SDK(StartExecution)
    + AWS cli(start-execution)
    + AWS Lambda(StartExecution api call)
    + API Gateway
    + Event Bridge
    + Code Pipeline
    + Step Functions
- Tasks
    + Lambda Task: Invoke a lambda function
    + Activity Task: 
        * Activity Worker, Ec2, Mobile, on-premise DC
        * They poll the Step Functions Service
    + Service Task:
        * Connect to a supported AWS service
        * Lambda function, ECS Task, Fargate, Dynamodb, Batch Job, SNS, SQS
    + WaitTask:
        * Wait for a duration or unitl a timestamp
    + Step Function doesn't integrate natively with AWS Medical Turk
- Express Workflow
    + Synchronous:
        * Wait until the Workflow completes, then return the result
        * Use cases: orchestrate microservices, handle errors, retries, parallel tasks,...
    + Asynchronous:
        * Doesn't for the Workflow to complete
        * Use cases: Workflow that don't require immediate response, messaging
## Streaming
### AWS Kinesis
- Kinesis Data Firehose
    + Destinations:
        * AWS: Redshift, S3, Elastic Search
        * 3rd partner: Splunk, Mongodb, Datadog, NewRelic
        * Custom: HTTP endpoint
    + Near realtime 
        * High throughput => buffer size(32MB) hit
        * Low throughput => buffer time(1 minute) hit
        * => If realtime flush from Kinesis to S3 is needed , use Lambda
    + Support custom data transformations using Lambda
    + Send all failed or all data to a backup S3 bucket
    + Doesn't support replay capability
- Kinesis Data Analytics
    + Streaming ETL: select columns, make simple transformation, on streaming data
    + Continuous metric generation : live leaderboard for a mobile game
    + Reponse analytics: look for a certain criteria and build alerting