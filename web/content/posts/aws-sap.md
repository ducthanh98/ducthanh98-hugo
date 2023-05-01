---
title: "Amazon Solution Architect Professional Note"
date: 2022-11-28T22:58:35+07:00
draft: false
---


### DDOS 
- Type
    + Application Layer: HTTP flood
    + Protocol Attack: SYN Flood
    + Volumetric: DNS Amplification

## Identify and Federation
### Policy Priorty
Explicit DENY -> SCP -> Resource Policy -> Permissions Boundaries -> Session Policies -> Identity Policies
### Directory Service
- AD Connector: Only redirects no local identity data in AWS
- Simple AD: AD compatible managed on AWS
- AWS Managed MS AD: 
    + Establish trust connection with your on-premise AD
    + Support AD Native schema extensions which required by some AD applications
    + Large userS
    + Integrates with radius/MFA
### IAM:
- Explicit DENY has precedence over ALOW
- NotAction: explicit allow a FEW THING in there
- Access Advisor: See permissions granted and when last accessed
- Access analyzer: Analyze resources that are shared with external entity
- Access Key: 
    + Can have two access keys
    + Can be created, deleted, made inactivate or activate
### STS
- When you assume a role, you give up your permissions and take the permissions assigned to the role and vice versa
- Temporary credentials can't be cancelled
- Changing the trust policy has no impact on existing credentials
- Revoking the leaked credentials: 
    + Denying access to credentials created by AssumeRole, AssumeRoleWithSAML, or AssumeRoleWithWebIdentity
        * Delete role, change permisisons impact all assumers
        * you must have the PutRolePolicy to attach the AWSRevokeOlderSessions inline policy 
    + Denying access to credentials created by GetFederationToken or GetSessionToken
        * edit or delete the policies that are attached to the IAM user 
        *  <strong>Note</strong>: You cannot change the permissions for an AWS account root user so we recommend that you do not call GetFederationToken or GetSessionToken as a root user.
### AWS Organization
- Feature Mode:
    + Consolidated billing feature: 
    + Consolidated billing across all acounts - single payment method
    + Pricing benefits from aggregated usage
    + Invited accounts must approve enabling all features
    + Ability to apply an SCP
    + Reserved Instances: All accounts can receive the benefits that are purchased by any another account. The payer can turn off reserved instance discount and savings plans discount sharing for any accounts, including the payer
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
- Products need to support RAM
- No charge for using RAM
- Share with other account or your OG
- Avoid resource duplication
- Share route53: https://aws.amazon.com/vi/premiumsupport/knowledge-center/route-53-share-resolver-rules-with-ram/
- Sharing managed prefix list: https://docs.aws.amazon.com/vpc/latest/userguide/sharing-managed-prefix-lists.html
### AWS SSO
- Choose Identity Provider -> Login -> Select AWS Account to Assume
### AWS Cognito
- User pool: user management,sign in, sign off and get jwt
- Identity Pool: return temporary credentials
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
        *  Event Bridge: the fastest, most reactive way
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
### AWS Shield
- Ec2, route 53, cloudfront, global accelator, load balancer
### WAF
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
### Firewall Manager
- If you want to use WAF across accounts, accelerate WAF configuration, automate the protection of new resources, use Firewall Manager
### AWS Inspector
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
- Instances type
    + Reserved Instaces:
        * To renew a RI, just queue an purchase RI whenever the previous one expires 
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
![Storage classes comparison](/aws/s3_storage_classes_comparison.png)
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
### AWS SWF
- Build workflows - coordination over distributed componnents
- Predecessor to Step Function - use instances/servers
- Choose SWF If
    +  AWS Flow Framework
    + External signals to intervene in processes
    + Launch child flows and then returns to parent
    + Complex decisions - support customer decider
- Medical Turk
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
### AWS MSK
- Consumers: 
    + Kinesis Data Analytics for Apache Flink  
    + AWS Glue
    + Lambda
    + Application
### AWS Batch
- Run as Docker images
- No time limit
- 2 Options
    + AWS Fargate
    + Dynamic provisioning 
- Example: batch process of images, thousands of concurrent jobs, ...
- Schedule Batch Jobs using Amazon EventBridge
- Orchestrate Batch Jobs using AWS Step Functions
- Environments: 
    + Managed Compute Environment: You can choose On-demand or spot(no need to worry about capacity)
    + Unmanaged Compute Envrionment:
- Modes: 
    + One Mode
    + Multi Node: 
        * large scale, good for HPC.
        * Doesn't work with spot
        * Work better if your EC2 launch mode is a placement group
### AWS EMR
- EMR stands for Elastic MapReduce
- Helps creating Hadoop cluster(big data) 
- Nodes:
    + Master Node
    + Core Node
    + Task Node(Optional)
- Purchasing options: on-demand, reserved, spot
- Instance Configuration
    + Uniform Intance Groups: Select a single instance type and purchasing option for each node(has auto scaling)
    + Instance fleet: select target capacity, mix instance types and purchasing options (no auto scaling)
### AWS Glue
- Manage extract, transform and load (ETL) service
- Fully serverless
- Example: S3, RDS -> Extract -> Glue(Transform) -> Load -> Redshift
### Redshift
- Based on postgresql
- OLAP - Online Analytical Processing
- 10x better performances than other data warehouses, scale to PBS of data
- Columnar storage
- Massive Parallel Query
- Load from S3, Kinesis Firehose, DynamoDb, DMS
- Snapshots: 
    + Automated: every 8 hours, every 5 GB, or on a schedule. Set retention
    + Manual: snapshot is retained until you delete it
    + Config it to automatically copy snapshots to another region
    + Copy cross-region snapshots for an encrypted Redshift: Use snapshot copy grant
- Redshift Spectrum: 
    + Query S3 without loading it
    + Must have a Redshift cluster available to start query
- Workload Management: Enables you to flexibly manage queries priorties within workloads.
- Concurrency scaling: 
    + Charged per second
    + Provide consistently faster performance 
    + Automatically adds additional cluster capacity
### AWS Timestream
- Time series database
- AWS IOT
- Kinesis 
- Prometheus 
### AWS Athena
- Using SQL(built on Presto)
- Supports CSV, JSON, ORC, Parquet
- Commonly used with Amazon Quicksight for reporting/dashboard
- Use cases: Business intelligence/analytics/reporting/ query logs, CloudTrails
- Use columnar for cost savings
    + Apache Parquet or ORC is recommend
    + Huge performance improvement
    + Use Glue to convert you data 
- Compress data for smaller retrievals(bzip2, gzip, )
- Partition datasets in S3 for easy querying
### AWS Quicksight
- Serveless dashboard
## Monitoring
### Cloudwatch
- CW Metrics:
    + Provided by many AWS service
    + EC2 Standard: 5min, detail monitoring: 1m
    + Ram is not a built-in metric
    + Create custom metrics: Standard resolution: 1m, high resolution: 1s
- CW Alarms
    + Trigger actions
    + Intercepted by AWS EventBridge
- CW Dashboards:
    + show metrics of multiple regions
- CW Synthetics Canary
    + Configurable script that monitor your  API, Websites, ...
    + Reproduce what your customers do programmatically to find issues
    + Integration with CW
    + Scripts written in Nodejs, Python
    + Run once or regular SCHEDULE
    + Blueprints:
        * Heart beat monitor: load url, storage screenshot and an HTTP archive file
        * API Canary: test basic read and write functions
        * Broken Link Checker: check all links inside the URL that you are testing
        * Visual Monitoring : compare a screenshot taken during a canary run with a baseline screenshot
        * Canary Recorder : record 
        * GUI Workflow Builder: verifies that actions can be taken on your webpage
- Can define expiration policies(never,30d,...)
- Send logs to : S3, Kinesis Stream, Firehose, Lambda, ElasticSearch
- CW Insight can be used to query logs and add queries to CW Dashboard
- EventBridge: Resource-based policy
### AWS X-ray
- Visual analysis of our application
- Integrate with:
    + EC2: X-ray client
    + ECS: X-ray agent or docker
    + Lambda
    + Beanstalk
    + Api Gateway
- X-ray agent or services need IAM permissions
### AWS Personal Health Dashboard
- Global service
- Show how AWS outages directly impact you
- Show maintenace events
- Accessible through AWS Health API
- Aggregation across multiple accounts of an AWS Organization 
- Use EventBridge(CW) to react to changes for AWS Health events
## Deployment and Management
- We still have full controll over the underlying services
- Free but you pay for the underlying instances.
- Support many platforms. If not supported, you can write your own custom platform
- Deployment
    + Blue/Green:
        * Zero downtime
        * The new environment can be validated independently and rollback if issues
        * Route53 can be setup using weighted polies to redirect a little bit of traffic
        * Using Beanstalk swap URLs(DNS swap) when done
### Code Deploy
- In place update: Update current existing EC2 instances
- Blue/Green deployment: 
    + Must be using an ELB
    + A new auto scaling group is created
- Lambda
    + Traffic shifting feature
    + Pre and post traffic hooks features to validate deployment
    + SAM natively use CodeDeploy
- ECS
    + Support Blue/Green
    + A new task set is created, and traffic is re-routed to the new task test
    + Support Canary Deployment(Canary10Percent5Minutes)
### Cloudformation
- Backbone of Beanstalk, Service Catalog, SAM
- Use DeletionPolicy to control how Cloudformation delete or not a resource
    + DeletionPolicy=Retain: Keep a resource
    + DeletionPolicy=Snapshot: EBS, ElasticCache, DB
    + DeletionPolicy=Delete(default) : For AWS::RDS::DB,  the default is snapshot. You need first empty S3 bucket before delete  
- Custom Resources :  You can define a custom resource to address any of these cases:
    + A AWS Resource is not yet supported
    + An On-premise resource
    + Emptying an S3 before being deleted
- Stacksets:
    + Create, update, delete stack across multiple accounts and regions with a single operation
    + Admin can create stacksets and trusted account can create,update,delete stack instances from Stacksets
    + When you update a stackset, all associated stack instances are updated throughout all accounts and regions
    + Enable Automatic Deployment to automatically deploy to accounts in OG or OUs
- Cloudformation Drift: Detect drift on an entire stack or an individual resources within a stack
- Integrate with secret manager:
- Resource Import:
    + Each resource must have a deletionPolicy and identifier
    + Can't import the same resource into multiple stacks
### Service Catalog
- Admin can create a portfolio(collection of products) and then assign them to other user.
- Cloudformation is backbone and helps ensure consistency and standarization by admin
- Can give user access to launching products without requiring deep knowledge 
- Help with governance, compliance and consistency
### Cloud Development Kit
- A familiar language -> CDK -> Cloudformation template
### AWS System Manager
- Need to install SSM agent, installed by default Linux AMI and some ubuntu ami
- Make sure ec2 instances have a proper IAM role to allow System Manager action
- Run command
    + Execute a script or a command
    + Integrate with IAM CloudTrail
    + No need for ssh
- Send command before an ASG instance is terminated
    + Create hook that puts the instance in Terminating:Wait
    + Monitor that state using Event Bridge
    + Trigger a SSM to perform actions
- Patch Managers
    + Define a patch baseline
    + Define a patch group: use tag Patch Group
    + Define maintenance windows(schedule, patch groups, registered task)
    + Add the AWS-RunPatchBaseLine Run command as part of the registerd tasks of the maintenance Windows
    + Define rate control
    + Monitor Patch Compliance using SSM Inventory
- Session Manager
    + Allow to start a secure shell on your EC2 or on-prem
    + Support linux, window, mac
    + Log can be sent to S3 or CloudWatch
    + CloudTrail con intercept StartSession events
- OpsCenter
    + Resolve Operational Issues(OpsItems: issues, events and alerts)
### CloudMap
- Works as a service discovery
- Use SDK, API, DNS to query AWS CloudMap
## AWS Cost Allocation Tags
- Just like Tags, but they show up as column in Reports
- Cost allocation tags just appear in the Billing Console
- AWS Generated Cost Allocation Tags
    + Starts with prefix aws: (eg: aws:CreatedBy)
    + Automatically applied to the resource you creat
- User Tag
    + Start with prefix user:
    + Defined by the user
- Cost allocation Tags just appear in the Billing Console
- Takes up 24h to show up in the report
### Trusted Advisor
- Can check if s3 is made public, but can't check for s3 object that are public inside of your bucket so use Event Bridge, S3 Events, AWS Config Rule instead
- Service Limits
    + Limit can only be monitored
    + Cases must be created manually in AWS Support Centre to increase limits
    + Use AWS Service Quotas
- Enable weekly email notifications from the console
- Ability to set CW Alarms when reaching limits
- Programmatic Access using AWS suport API (Not support with free plan)
### AWS Service Quotas: 
- Notify you when you're close to a service quota value threshold
### AWS Savings Plan
- New pricing model to get discount based on long-term usage
- EC2 Instance Savings plan (upto 72% - same discount as Standard RIs)
    + Select instance family(M5,C5...) and locked to a specific region
    + Flexible across size, OS, tenacy(dedicated or default)
- Compute Savings plan(upto 66% - same discount as Convertible RIs)
    + Ability to move between instance family, region, compute type,os , tenancy
- SageMaker Savings Plan: upto 64% off for SageMaker
### AWS Budget
- Create budget and send alarms when costs exceeds the budget
- 4 types: Usage, Cost, Reservation, Savings plan, ...
- Upto 5 SNS per budget
- Can filter by many options
- Budget Actions: 
    + Applying an IAM policy to a user, group, role
    + Apply a SCP to an OU
    + Stop EC2 or RDS
- Cost Explorer: Forecast up to 12 months based on previous usage
### AWS Compute Optimizer
- Help you choose optimal configurations and right size for your workloads
- Use ML to analyze your resources configurations and their CW metrics
- Need CW Agent to analyze RAM metrics
- Supported resources:
    + EC2
    + Auto Scaling
    + EBS
    + Lambda
- Lower your cost by up to 25%
## Migration
 ### 6R
- Rehosting
    + lift and shift
    + simple migrations by re-hosting on AWS
    + Cost save as much as 30% on cost
    + Example: Using AWS VM Import/Export, AWS Server Migration Service
- Replatforming
    + Migrate your db to RDS
- Repurchase
    + drop and shop
- Refactoring/Re-architecting
    + Reimagining how the application is architected using Cloud Native
    + Example: MongoDB to DynamoDB
- Retire
    + Turn off things you don't need
- Retain
    + Do nothing for now
### Storage Gateway
- Bridge between on-premises data and cloud data
- Types
    + S3 File Gateway: 
        * Use NFS or SMB
        * Cache most recently data
        * Bucket access using IAM role for each file Gateway
        * Transition to S3  Glacier using Lifecyle policy
    + Fsx File Gateway
        * Native access to AWS Fsx
        * Useful for group file shares and home directories
    + Volume Gateway
        * Block storage using ISCSI protocol
        * Backed by EBS snapshot
        * Cached Volumes: low latency access to most recent data
        * Stored Volumes: entire dataset is on premise, scheduled backups to s3
    + Tape Gateway
        * Tape, iSCSI
- Hardware  appliance
    + Helpful for daily backups in small data centers
    + Works with File Gateway, Volume Gateway, Tape Gateway
- Extensions:
### Snow Family
- offline devices to perform data migrations
- Move TBs or PBs of data in or out
- Types:
    + Snowball Edge: 
        * Pay per data transfer job
        * Snowball Edge Storage Optimized: 80TB of HD capacity
        * Snowball Ede Compute Optimized: 42TB of HDD capacity
    + Snow Cone:
        * 8TBs of usable storage
        * Must provide your own battery
        * Can be sent back to AWS or use AWS DataSync to send data
    * Snowmobile
        * Transfer extrabytes of data
        * 100PB of capacity
        * Better than snowball if you transfer more than 100PB
- Use AWS OpsHub to manage your Snow family device
- improve transfer performance
    + Perform multiple write opertions at one time: from multiple terminal
    + Transfer small files in batches
    + Don't perform other operations on files during transfer
    + Reduce local network use
    + Eliminate unnecessary hops
- The data transfer rate is typically between 25MB and 40MB/s. If you need more , Use Amazone S3 Adpater for Snowball
### AWS Cloud Adoption Readiness Tool(CART)
- Develop efficient and effective plans for cloud adoption and migrations
### Disater Recovery
- Backup and restore: High RTO and RPO
- Pilot Light: A small version of the app is always running in the cloud
- Warn Standby: Full system is up and running, but at minimum size
- Multi Size/Hot site approach: Very low RTO - very expensive. Full production scale is running AWS and On-premises
### AWS Fault Injection Simulator
- Based on Chaos Engineering - stressing an application by creating disruptive events(sudden increase CPU and Memory)
- Supports: EKS,EC2, ECS,RDS
### AWS VM Migration
- Application Discovery Services
    + Gathering information about on-premise data centers
    + Agentless discovery(Application Discovery Agentless Connector):
        * Open Virtual Application(OVA) package that can be deployed to a VM Host
        * VM Inventory, Configuration, performance history such as CPU, memory, disk usage
        * Any OS
    + Agent-based discovery
        * system configuration, system performance, running processes, network, 
        * Support: Microsoft Server, linux, ...
    + Data can be exported as CSV or viewed within AWS Migration Hub
    + Query with Athena
- Application Migration Service
    + lift and shift
    + Convert physical, virtual server to run natively on AWS
    + Minimal downtime, reduced costs
- Elastic Disater Recovery
    + Quickly and easily recover your physical, virtual into AWS
    + Continuous block-level replication for your servers
    + Example: protect your critical databases
- AWS Migration Evaluator
    + Analyze current state, define target state, then develop migration plan
### AWS Backup
- Supported service:
    + EC2
    + RDS, DynamoDB, DocumentDB, Neptune
    + EFS, FSx
    + Storage Gateway(Volume Gateway)
- Support cross-region and cross-account backups
## VPC
### Basics
- NACL: 
    + Processes in order, lowest rule number first. Once a match occurs, processing stops. 
    + DENY everything by default
    + Each subnet can have one NACL
- Border Gateway Protocol(BGP)
    + 
- Public subnets
    + Has a route table that sends 0.0.0.0/0 to an IGW
    + Must have a public ipv4
- Private subnets
    + Access internet with a nat instance or nat gateway
    + 0.0.0.0/0 -> nat
- VPC Flow logs
    + Can be defined at the VPC level, Subnet, ENI level
    + can be sent to CW and S3
    + Capture package metadata NOT PACKAGE CONTENT
    + Applied to VPC - subnet or directly interface
    + VPC Flow log not realtime
    + example
        * 2 123456789010 eni-1235b8ca123456789 172.31.16.139 172.31.16.21 20641 22 6 20 4249 1418530010 1418530070 ACCEPT OK
        * 2 123456789010 eni-1235b8ca123456789 172.31.9.69 172.31.9.12 49761 3389 6 20 4249 1418530010 1418530070 REJECT OK
        * 1 = ICMP Protocol, 6 = TCP, 17 = UDP

- Subnet
    + Every subnet has a vpc router interface
    + Interfaces use subnet + 1 address
    + Routes priority: /16 higher = more specific = higher priority
- 
### VPC Peering
- Connect two VPC, privately using AWS network
- Must not have overlapping CIDR
- You must update route tables in each VPC's subnet to ensure instances can communicate
### Transit Gateway
- Trasitive peering between thousands of VPC and on premises, hub connection
- Regional resource
- No route learning/progation across peer. Static routes are required
- Data is encrypted
- Share across-account using RAM
- RouteTables: Limit which VPC can talk with other VPC
- Work with Direct Connection Gateway, VPN
- Support IP Multicast
### Client VPN
- Split tunnel is NOT the default. It must be enabled else all data goes via tunnel
- Managed implementation of OpenVPN
- Billed based on network associations
### Site to Site VPN
- Encrypted using IPSec, running over the public internet
- Quick to provision less than an hour
- Static connect(without BGP): No balancing and multi connect failover
- Dynamic: BGP is configured on both on-premises site and aws side.networks are exchanged via bgp
- Speed Limitation: 1.25GB
- Latency: inconsistent, public network
- Cost: aws hourly, all software configuration,... 
- Can be used as a backup for DX
### VPC Endpoint
- VPC Endpoint Gateway
    + Only works for S3, DynamoDB, must create one gateway per vpc
    + Must update route table entries
    + Gateway is defined at VPC level
    + DNS resolution must be enabled
    + Gateway endpoint cannot extended ou of VPC(VPN,DX, peering)
- VPC Endpoint Interface
    + Provision an ENI that will have a private endpoint interface
    + Leverage SG for security
    + Private DNS
    + DNS resolution must be enabled
    + Interface can be accessed from DX,VPN
- VPC Endpoint policy and S3 policy
    + S3 bucket may have: "aws:sourceVpce":"vpce-1a2b3c4d" to deny any traffic that doesn't come from a specific VPC Endpoint
    + S3 policies can restrict access only from public IP or EIP(private ip is not working) 
    + aws:SourceIp doesn't apply for VPC endpoints
### AWS PrivateLink
- Requires a network load balancer(Service VPC) and ENI(Customer VPC)
- PrivateLink with DX: Corporate -> DX -> Private VIF -> Private Link -> Gateway Interface -> S3
### Interface Endpoint
- Private access to a public AWS Service
- Added to a specific subnets - an ENI - not HA
- For HA, add one endpoint to one subnet per AZ
- Access controller via SG
- Endpoint policies
- Only support TCP and IPv4 
- Uses PrivateLink 
### AWS Site to Site VPN
- Establish
    + On-premise
        * Setup a software or hardware VPN appliance
        * The on-premise VPN should be accessible using a public IP 
    + AWS
        * Setup virtual private gateway(VGW) and attach to your VPC
        * Setup a customer gateway to point the on-premise VPN appliance
    => Two VPN connections are created for redundancy, encrypted using IPSec
- Route Propagation
    + Static routing
        * Create static route in corperate for specific IP through CGW
        * Create static route in AWS for specific IP through VGW
    + Dynamic routing(BGP) 
- VPN Cloudhub
    + Connect up to 10 CGW for each VGW
- VPN to multiple VPC
    + Create a seperate VPN connection for each CGW
    + Direct conneciton is recommended because it has a direct connection gateway
-  Shared service 
### Direct Connection
- Provides a dedicated private connection from a remote network to your VPC
- Support BGP and BGP Md5 authentication
- MACSEC: Security feature
- Private access to AWS Services through VIF
- Must setup a failover DX or VIF
- Virtual Interfaces
    + Public VIF: connect to public AWS Endpoints
    + Private VIF: connect to a resources in your VPC and VPC needs to be in the same region as the DX location. Using private ASN (64512-65535)
    + Transit Virtual Interface: connect to a resource in your VPC using Transit Gateway
- VPC ENDPOINTS can't accessed through private VIF
- Encryption
    + Not encrypted by default
    + DX + VPN provides an IPSec connections
    + VPN over DX use public VIF
- LAG
    + Increased speed and failover 
    + Aggregate up to 4 connections 
    + Conditions:
        * Dedicated connection
        * Same bandwidth
        * Terminate at the same AWS DX Endpoint
- DX Gateway: Setup a DX to one or more VPC in many different regions
### VPC Flow Logs
- Capture information about IP traffic going into your interfaces
    + VPC Flow Logs
    + Subnet FLow Logs
    + ENI FLow Logs
- Save to CW, S3
- Query using Athena or CW Insight
### AWS Network Firewall
- Protect your entire VPC from layer 3 to 7
- Internally,  Network Firewall use AWS Gateway Load Balancer
- Rule can centrally managed cross-account by AWS Firewall Manager to apply to many VPCs
- Traffic filtering: allow, drop, alert
- Send logs of rule matches to S3, CW, Firehose
## Other
### AWS Workspaces
- Remote Desktop Service/Citrix
- Consistent desktop, from anywhere 
- Monthly, hourly pricing
- Use Directory Service(Simple, AD, AD Connector) for authentication and user management
- Use ENI in VPC
- Connect on-premises over VPN or Direct Connect
- Workspaces are not HA, they occupy a single az
### AWS Global Accelerator
- Have 2 anycast IP
- Anycast IP's allow a single IP to be in multiple locations. Routing moves traffic to closest location
- Can be used for non HTTP/s
## Machine Learning
# Kendra
![Screenshot](/aws/kendra.png)
# Personalize
![Screenshot](/aws/personalize.png)
# Textract
- Automatically extracts text, handwriting, data from any scanned data
# Overview
![Screenshot](/aws/ml_overview.png)

AWS Systems Manager Automation documents to fix non-compliant resources
The log group and the destination must be in the same AWS Region. However, the destination can point to an AWS resource such as a Kinesis Data Firehose stream that is located in a different Region.
With an HTTP API direct integration to DynamoDB is not possible but you can connect to multiple Lambda functions and configure methods and paths.
Create a lifecycle policy for the incomplete multipart uploads on the S3 bucket to prevent new failed uploads from accumulating


This mode is a good choice for projects with a clean working directory and a source that is a large Git repository. If you choose this option and your project does not use a Git repository (GitHub, GitHub Enterprise, or Bitbucket), the option is ignored hence this is incorrect.