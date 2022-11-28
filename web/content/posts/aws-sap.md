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
- Asynchronous Invocations: S3,SNS, Event Bridge
- Attempts to retry on 3 errors
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
- 

