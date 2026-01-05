
# Application Architecture

## System Overview

```mermaid
graph TB
    %% Styling
    classDef internet fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef agw fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef lb fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef k8s fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef sql fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    classDef azure fill:#bbdefb,stroke:#0d47a1,stroke-width:2px
    
    %% Internet Layer
    INTERNET[Internet Users]:::internet
    
    %% Application Gateway Layer
    AGW[Application Gateway<br/>WAF_v2<br/>Public IP: XX.XX.XX.XX]:::agw
    
    %% Internal Load Balancer
    LB[Internal Load Balancer<br/>Private IP: 10.224.0.5<br/>Port: 80]:::lb
    
    %% Kubernetes Layer
    subgraph "Azure Kubernetes Service (AKS)"
        INGRESS[nginx-ingress Controller<br/>Health: /healthz]:::k8s
        
        subgraph "Flask Application"
            APP1[Flask App Pod 1<br/>Health: /health]:::k8s
            APP2[Flask App Pod 2<br/>Health: /health]:::k8s
            APP3[Flask App Pod 3<br/>Health: /health]:::k8s
        end
    end
    
    %% Azure SQL Layer
    SQL[Azure SQL Database<br/>Managed Identity Auth]:::sql
    
    %% Azure Services
    ACR[Azure Container Registry]:::azure
    
    %% Connections
    INTERNET -- "HTTPS/HTTP<br/>Port 80/443" --> AGW
    AGW -- "Internal HTTP<br/>Port 80" --> LB
    
    %% Health Probe Flow (CORRECTED)
    AGW -. "Health Probe<br/>Port 80" .-> LB
    LB -- "Traffic" --> INGRESS
    INGRESS -- "Traffic Routing" --> APP1
    INGRESS -- "Traffic Routing" --> APP2
    INGRESS -- "Traffic Routing" --> APP3
    
    %% Internal Health Checks
    LB -. "Health Check<br/>/healthz" .-> INGRESS
    INGRESS -. "Readiness Probe<br/>/health" .-> APP1
    INGRESS -. "Readiness Probe<br/>/health" .-> APP2
    INGRESS -. "Readiness Probe<br/>/health" .-> APP3
    
    APP1 -- "Managed Identity<br/>Token-based Auth" --> SQL
    APP2 -- "Managed Identity<br/>Token-based Auth" --> SQL
    APP3 -- "Managed Identity<br/>Token-based Auth" --> SQL
    
    ACR -- "Container Images" --> INGRESS
```

## Architecture Explanation

### Flow Description:
1. **External Traffic**: Internet users access via HTTPS/HTTP
2. **Application Gateway**: Azure WAF_v2 provides security
3. **Internal Load Balancer**: Distributes traffic within VNET
4. **Kubernetes**: nginx-ingress routes to Flask pods
5. **Database**: Azure SQL with managed identity
6. **Registry**: ACR stores container images

### Key Features:
- ✅ WAF protection
- ✅ Private networking
- ✅ Managed identity authentication
- ✅ Health monitoring at every layer
- ✅ High availability with multiple pods
```
