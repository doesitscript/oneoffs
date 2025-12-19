# Network Architecture Diagram

## TFC Runners VPC Network Architecture

```mermaid
graph TB
    subgraph "AWS Account: 920411896753"
        subgraph "Region: us-east-2"
            subgraph "VPC: tfc-runners (vpc-0ef9fa027c0756355)"
                subgraph "CIDR: 10.62.51.0/26 + 10.62.50.192/26"
                    
                    subgraph "AZ: us-east-2a"
                        subnet1["Private Subnet<br/>subnet-0ae9b355369c5d4f8<br/>10.62.51.0/28<br/>9 available IPs"]
                        task1["ECS Task 1<br/>tfc-agent"]
                        task2["ECS Task 2<br/>tfc-agent"]
                    end
                    
                    subgraph "AZ: us-east-2b"
                        subnet2["Private Subnet<br/>subnet-08556aef02d8995f3<br/>10.62.51.16/28<br/>9 available IPs"]
                        task3["ECS Task 3<br/>tfc-agent"]
                    end
                    
                    subgraph "AZ: us-east-2c"
                        subnet3["Private Subnet<br/>subnet-03f5dcd1cc0857e1b<br/>10.62.51.32/28<br/>10 available IPs"]
                        task4["ECS Task 4<br/>tfc-agent"]
                        task5["ECS Task 5<br/>tfc-agent"]
                    end
                    
                    subgraph "Security Configuration"
                        sg["Security Group<br/>sg-00bdaaa794ba97b7b<br/>tfc-agent<br/><br/>Egress Rules:<br/>• TCP/443 → 0.0.0.0/0<br/>• TCP/7146 → 0.0.0.0/0<br/>• ALL → 10.0.0.0/8"]
                    end
                    
                    subgraph "VPC Endpoints"
                        s3ep["S3 Gateway Endpoint<br/>vpce-0bf2cdc8811b0b38e<br/>com.amazonaws.us-east-2.s3"]
                        dynamoep["DynamoDB Gateway Endpoint<br/>vpce-00e7e61be3017e34e<br/>com.amazonaws.us-east-2.dynamodb"]
                    end
                    
                    subgraph "Routing"
                        rt1["Route Table 1<br/>rtb-0394f28ddb3b800f8<br/>us-east-2a"]
                        rt2["Route Table 2<br/>rtb-005acf65a688766f6<br/>us-east-2b"] 
                        rt3["Route Table 3<br/>rtb-0eaaba12a6b9af284<br/>us-east-2c"]
                    end
                end
            end
            
            tgw["Transit Gateway<br/>tgw-070334cf083fca7cc<br/><br/>Default Route:<br/>0.0.0.0/0"]
            
            subgraph "AWS Services"
                s3svc["Amazon S3"]
                dynamosvc["Amazon DynamoDB"]
            end
        end
        
        subgraph "External Connectivity"
            internet["Internet<br/>(Terraform Cloud)"]
            internal["Internal Networks<br/>(10.0.0.0/8)"]
        end
    end
    
    subgraph "ECS Service Details"
        ecsinfo["ECS Cluster: bfh-aws-cloudops-runners-ue2<br/>Service: tfc-agent<br/>Launch Type: FARGATE<br/>Platform Version: 1.4.0<br/><br/>Desired Count: 5<br/>Running Count: 5<br/>Pending Count: 0<br/><br/>Task Definition: tfc-agent:1<br/>Service Role: AWSServiceRoleForECS<br/>Created By: tfc-apply-awsfoundations"]
    end
    
    %% Network Connections
    subnet1 -.-> rt1
    subnet2 -.-> rt2
    subnet3 -.-> rt3
    
    rt1 --> tgw
    rt2 --> tgw
    rt3 --> tgw
    
    rt1 -.-> s3ep
    rt2 -.-> s3ep
    rt3 -.-> s3ep
    
    rt1 -.-> dynamoep
    rt2 -.-> dynamoep
    rt3 -.-> dynamoep
    
    task1 -.-> sg
    task2 -.-> sg
    task3 -.-> sg
    task4 -.-> sg
    task5 -.-> sg
    
    tgw --> internet
    tgw --> internal
    
    s3ep -.-> s3svc
    dynamoep -.-> dynamosvc
    
    %% Task Distribution
    task1 -.-> subnet1
    task2 -.-> subnet1
    task3 -.-> subnet2
    task4 -.-> subnet3
    task5 -.-> subnet3
    
    %% Styling
    classDef privateSubnet fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef ecsTask fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef security fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef routing fill:#f1f8e9,stroke:#33691e,stroke-width:2px
    classDef endpoint fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    classDef external fill:#ffebee,stroke:#b71c1c,stroke-width:2px
    classDef info fill:#f5f5f5,stroke:#424242,stroke-width:1px
    
    class subnet1,subnet2,subnet3 privateSubnet
    class task1,task2,task3,task4,task5 ecsTask
    class sg security
    class rt1,rt2,rt3,tgw routing
    class s3ep,dynamoep endpoint
    class internet,internal,s3svc,dynamosvc external
    class ecsinfo info
```

## Key Architecture Characteristics

### **Multi-AZ High Availability**
- **3 Availability Zones**: us-east-2a, us-east-2b, us-east-2c
- **Task Distribution**: 2 tasks in 2a, 1 task in 2b, 2 tasks in 2c
- **Auto-rebalancing**: ECS availability zone rebalancing enabled

### **Private Network Design**
- **No Public Subnets**: All subnets are private with `assignPublicIp: DISABLED`
- **No NAT Gateways**: Internet egress via Transit Gateway
- **Small Subnets**: /28 subnets (11 usable IPs each) - minimal footprint

### **Egress Strategy**
- **Primary Route**: 0.0.0.0/0 → Transit Gateway (tgw-070334cf083fca7cc)
- **VPC Endpoints**: Direct access to S3 and DynamoDB via gateway endpoints
- **Security Groups**: Restrictive egress (443, 7146, internal networks only)

### **Service Isolation**
- **Dedicated VPC**: Single-purpose VPC for TFC runners
- **Dedicated Security Group**: Single security group with minimal permissions  
- **No Load Balancers**: Direct task-to-task communication not required
- **No Service Discovery**: Tasks operate independently

### **Missing Components**
- **NAT Gateways**: None present (egress via Transit Gateway)
- **Internet Gateways**: None visible (private-only architecture)
- **SSM VPC Endpoints**: Not configured (no Session Manager access)
- **Public Subnets**: Architecture is entirely private