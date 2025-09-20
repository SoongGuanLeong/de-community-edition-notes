# Runbook for Profit, Growth and Engagement Pipelines

This document outlines ownership, oncall responsibilities, runbooks, and common issues for five key data pipelines supporting profit, growth and engagement reporting.

---

## 1. Ownership
| Business Area | Pipeline                         | Primary Owner | Secondary Owner |
|---------------|----------------------------------|---------------|-----------------|
| Profit        | Unit-level profit (experiments)  | Engineer A    | Engineer B      |
| Profit        | Aggregate profit (investors)     | Engineer B    | Engineer C      |
| Growth        | Aggregate growth (investors)     | Engineer C    | Engineer D      |
| Growth        | Daily growth (experiments)       | Engineer D    | Engineer A      |
| Engagement    | Aggregate Engagement (investors) | Engineer A    | Engineer C      |

---

## 2. Oncall Schedule
We use a weekly rotation (that follows the week number of the company's calendar) with **4 engineers** to ensure fairness.

- Week 1: Engineer A
- Week 2: Engineer B
- Week 3: Engineer C
- Week 4: Engineer D
- Then repeat cycle.

**Holiday coverage**:
- If an engineer is on holiday, they swap with the next person in the rotation in advance.
- No engineer covers two consecutive weeks unless agreed upon.

---

## 3. Runbooks (Investors-Facing Pipelines Only)

### 3.1 Aggregate Profit (Investors)
- **Primary Owner**: Engineer B
- **Secondary Owner**: Engineer C
- **Upstream Owners**: Sales Systems Team, Finance Data Team
- **Common Issues**:
    - Delay in Finance DB sync
    - Mismatched transaction IDs across systems
- **Critical Downstream Users**: Finance Reporting, Investor Relations
- **SLA & Agreements**: Daily delivery by 6 hours after midnight UTC; accuracy within 1% of Finance DB

---

### 3.2 Aggregate Growth (Investors)
- **Primary Owner**: Engineer C
- **Secondary Owner**: Engineer D
- **Upstream Owners**: Customer Data Platform, Subscription Services Team
- **Common Issues**:
    - Missing churn events
    - Delayed subscription renewal data
- **Critical Downstream Users**: Product Analytics, Investor Relations
- **SLA & Agreements**: Daily delivery by 7 hours after midnight UTC; completeness > 98%

---

### 3.3 Aggregate Engagement (Investors)
- **Primary Owner**: Engineer A
- **Secondary Owner**: Engineer C
- **Upstream Owners**: Application Logging Team, Data Ingestion Platform
- **Common Issues**:
    - High-traffic log drops
    - Schema drift in clickstream events
- **Critical Downstream Users**: Product Analytics, Investor Relations
- **SLA & Agreements**: Daily delivery by 8 hours after midnight UTC; event ingestion > 99%

---

## 4. Summary
- **Ownership**: Each pipeline has a primary and secondary engineer for resilience.
- **Oncall**: Weekly rotation with holiday swap agreements.
- **Runbooks**: Investor pipelines have structured runbooks with owners, upstream & downstream teams, common issues and SLAs.

This ensures accountability, transparency, and reliability in investor reporting.