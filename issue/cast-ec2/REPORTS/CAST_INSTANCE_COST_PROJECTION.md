# CAST EC2 Instance Cost Projection
**Date**: 2025-01-29  
**Region**: us-east-2  
**Calculation**: 730 hours/month (24/7 operation)  
**Pricing Source**: AWS On-Demand Pricing (us-east-1/us-east-2 comparable)

---

## Current CAST Configuration

| Instance Type | Environment | vCPU | Memory | Hourly Cost | Monthly Cost | Annual Cost | Notes |
|--------------|-------------|------|--------|-------------|--------------|-------------|-------|
| **m5.8xlarge** | Dev (Current) | 32 | 128 GB | $1.536 | **$1,121** | **$13,452** | ⚠️ Over-provisioned for dev |

---

## Recommended Instance Types by Environment

### Development Environment Recommendations

| Instance Type | vCPU | Memory | Hourly Cost | Monthly Cost | Annual Cost | Savings vs m5.8xlarge | Recommended For |
|--------------|------|--------|-------------|--------------|-------------|----------------------|------------------|
| **t3.medium** | 2 | 4 GB | $0.0416 | **$30** | **$364** | **97%** ($1,091/mo) | Basic dev, single developer |
| **t3.large** ⭐ | 2 | 8 GB | $0.0832 | **$61** | **$730** | **95%** ($1,060/mo) | **Standard dev (Recommended)** |
| **t3.xlarge** | 4 | 16 GB | $0.1664 | **$121** | **$1,458** | **89%** ($1,000/mo) | Heavy dev, multiple developers |
| **m5.large** | 2 | 8 GB | $0.096 | **$70** | **$840** | **94%** ($1,051/mo) | Dev requiring dedicated CPU |
| **m5.xlarge** | 4 | 16 GB | $0.192 | **$140** | **$1,681** | **87%** ($981/mo) | Dev with moderate sustained load |

**Development Environment Summary**:
- **Primary Recommendation**: `t3.large` - Best balance of cost and performance for dev
- **Alternative**: `t3.medium` if budget-conscious
- **Alternative**: `t3.xlarge` if multiple developers sharing instance

---

### Staging/QA Environment Recommendations

| Instance Type | vCPU | Memory | Hourly Cost | Monthly Cost | Annual Cost | Savings vs m5.8xlarge | Recommended For |
|--------------|------|--------|-------------|--------------|-------------|----------------------|------------------|
| **m5.xlarge** | 4 | 16 GB | $0.192 | **$140** | **$1,681** | **87%** ($981/mo) | Light staging workloads |
| **m5.2xlarge** ⭐ | 8 | 32 GB | $0.384 | **$280** | **$3,362** | **75%** ($841/mo) | **Standard staging (Recommended)** |
| **m7i.2xlarge** | 8 | 32 GB | ~$0.40* | **$292** | **$3,504** | **74%** ($829/mo) | Staging with modern CPUs |
| **m5.4xlarge** | 16 | 64 GB | $0.768 | **$561** | **$6,723** | **50%** ($560/mo) | Heavy staging workloads |

**Staging/QA Environment Summary**:
- **Primary Recommendation**: `m5.2xlarge` - Good balance for QA testing
- **Alternative**: `m7i.2xlarge` if using newer generation processors
- **Note**: *m7i pricing estimated based on AWS pricing patterns

---

### Production Environment Recommendations

#### Production Standard (Most Common Use Cases)

| Instance Type | vCPU | Memory | Hourly Cost | Monthly Cost | Annual Cost | Savings vs m5.8xlarge | Recommended For |
|--------------|------|--------|-------------|--------------|-------------|----------------------|------------------|
| **m5.4xlarge** ⭐ | 16 | 64 GB | $0.768 | **$561** | **$6,723** | **50%** ($560/mo) | **Standard production (Recommended)** |
| **m7i.4xlarge** | 16 | 64 GB | ~$0.80* | **$584** | **$7,008** | **48%** ($537/mo) | Production with modern CPUs |
| **m5.2xlarge** | 8 | 32 GB | $0.384 | **$280** | **$3,362** | **75%** ($841/mo) | Light production workloads |

#### Production High-Performance (CPU-Intensive Workloads)

| Instance Type | vCPU | Memory | Hourly Cost | Monthly Cost | Annual Cost | Savings vs m5.8xlarge | Recommended For |
|--------------|------|--------|-------------|--------------|-------------|----------------------|------------------|
| **c7i.4xlarge** ⭐ | 16 | 32 GB | $0.85 | **$621** | **$7,450** | **45%** ($500/mo) | **CPU-intensive analysis (Recommended)** |
| **c5.4xlarge** | 16 | 32 GB | $0.68 | **$496** | **$5,958** | **56%** ($625/mo) | CPU-intensive (older gen) |

#### Production High-Performance (Memory-Intensive Workloads)

| Instance Type | vCPU | Memory | Hourly Cost | Monthly Cost | Annual Cost | Savings vs m5.8xlarge | Recommended For |
|--------------|------|--------|-------------|--------------|-------------|----------------------|------------------|
| **r5.4xlarge** | 16 | 128 GB | $1.008 | **$736** | **$8,829** | **34%** ($385/mo) | Memory-intensive analysis |
| **m5.8xlarge** | 32 | 128 GB | $1.536 | **$1,121** | **$13,452** | 0% | Current baseline |

**Production Environment Summary**:
- **Primary Recommendation**: `m5.4xlarge` or `m7i.4xlarge` for balanced workloads
- **CPU-Intensive**: `c7i.4xlarge` for analysis jobs (45% savings)
- **Memory-Intensive**: Keep `m5.8xlarge` if 128GB memory is required
- **Alternative**: `r5.4xlarge` if need 128GB but fewer CPUs (34% savings)

---

### Special Use Cases

#### Container/Kubernetes Workloads (CAST AI)

| Instance Type | vCPU | Memory | Hourly Cost | Monthly Cost | Annual Cost | Environment | Recommended For |
|--------------|------|--------|-------------|--------------|-------------|-------------|------------------|
| **m5.large** | 2 | 8 GB | $0.096 | **$70** | **$840** | Dev | Container dev workloads |
| **m5.xlarge** | 4 | 16 GB | $0.192 | **$140** | **$1,681** | Staging | Container staging |
| **m7i.2xlarge** | 8 | 32 GB | ~$0.40* | **$292** | **$3,504** | Production | Container production |
| **m7i.4xlarge** | 16 | 64 GB | ~$0.80* | **$584** | **$7,008** | Production | High-performance containers |

---

## Cost Comparison Matrix

### Monthly Costs (All Environments)

| Environment | Recommended Instance | Monthly Cost | Annual Cost | % of Current Cost |
|-------------|---------------------|--------------|-------------|-------------------|
| **Development** | t3.large | $61 | $730 | 5.4% |
| **Staging/QA** | m5.2xlarge | $280 | $3,362 | 25.0% |
| **Production Standard** | m5.4xlarge | $561 | $6,723 | 50.0% |
| **Production CPU-Intensive** | c7i.4xlarge | $621 | $7,450 | 55.4% |
| **Production Memory-Intensive** | m5.8xlarge | $1,121 | $13,452 | 100.0% |

### Annual Cost Savings Scenarios

| Current Setup | Recommended Setup | Annual Savings | 3-Year Savings |
|---------------|-------------------|----------------|----------------|
| Dev: m5.8xlarge | Dev: t3.large | **$12,722** | **$38,166** |
| Prod: m5.8xlarge | Prod: m5.4xlarge | **$6,729** | **$20,187** |
| Prod: m5.8xlarge | Prod: c7i.4xlarge | **$6,002** | **$18,006** |
| Both: 2x m5.8xlarge | Dev: t3.large + Prod: m5.4xlarge | **$19,451** | **$58,353** |

---

## Recommended Environment-Based Strategy

### Development Environment
**Recommended**: `t3.large`
- **Cost**: $61/month ($730/year)
- **Savings**: $1,060/month vs current
- **Rationale**: Sufficient for Windows + CAST Software + SQL Server dev workload. Burstable CPU handles intermittent analysis jobs.

### Staging/QA Environment
**Recommended**: `m5.2xlarge` or `m7i.2xlarge`
- **Cost**: $280-$292/month ($3,362-$3,504/year)
- **Savings**: $829-$841/month vs current
- **Rationale**: Dedicated CPU for consistent QA testing. 32GB RAM handles staging workloads well.

### Production Environment
**Option 1 - Balanced (Recommended)**: `m5.4xlarge` or `m7i.4xlarge`
- **Cost**: $561-$584/month ($6,723-$7,008/year)
- **Savings**: $537-$560/month vs current
- **Rationale**: 64GB RAM typically sufficient, 50% cost savings

**Option 2 - CPU-Intensive**: `c7i.4xlarge`
- **Cost**: $621/month ($7,450/year)
- **Savings**: $500/month vs current
- **Rationale**: Better CPU performance for code analysis jobs, similar cost to m5.4xlarge

**Option 3 - Memory-Intensive**: Keep `m5.8xlarge` or use `r5.4xlarge`
- **Cost**: $736-$1,121/month
- **Savings**: $0-$385/month vs current
- **Rationale**: Only if 128GB RAM is actually required

---

## Storage Cost Considerations

### Current Configuration
- **Root Volume**: 250 GB gp3 (~$20/month)
- **Second Drive**: 500 GB io2 with 3000 IOPS (~$155/month)
- **Total Storage**: ~$175/month

### Recommended Storage Optimization

| Drive | Current | Recommended | Monthly Cost | Savings |
|-------|---------|-------------|--------------|---------|
| **Second Drive** | 500 GB io2 (3000 IOPS) | 500 GB gp3 (3000 IOPS) | ~$40 | **$115/mo** |
| **Total Storage** | $175/month | ~$60/month | | **$115/mo** |

**Total Infrastructure Savings**:
- Instance: $1,060/month (dev) to $560/month (prod)
- Storage: $115/month (gp3 vs io2)
- **Combined**: $1,175/month (dev) to $675/month (prod)

---

## Notes

1. **Pricing Source**: Based on AWS On-Demand pricing for us-east-2 region (similar to us-east-1)
2. **m7i Pricing**: Estimated based on AWS pricing patterns (typically 5-10% more than m5)
3. **Storage Costs**: Separate from instance costs
4. **Reserved Instances**: Additional 30-72% savings possible with 1-3 year commitments
5. **Spot Instances**: Additional 50-90% savings possible for non-critical workloads
6. **Right-Sizing**: Actual savings may vary based on actual workload requirements

---

## Implementation Priority

1. **Immediate (High ROI)**: 
   - Dev: Migrate to `t3.large` → **$1,060/month savings**
   - Storage: Migrate io2 to gp3 → **$115/month savings**

2. **Short-term (3 months)**:
   - Staging: Migrate to `m5.2xlarge` → **$841/month savings**
   - Production: Right-size based on actual usage metrics

3. **Long-term (6-12 months)**:
   - Evaluate Reserved Instances for production
   - Consider Spot Instances for non-critical workloads
   - Monitor actual resource utilization and adjust

