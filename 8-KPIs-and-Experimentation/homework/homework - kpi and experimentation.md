# LINKEDIN'S KPI AND EXPERIMENTATION

## User Journey

I've been using LinkedIn for over 5 years. Initially, I joined to maintain a professional network and look for job opportunities. At first, I mostly browsed colleages' profiles and sent connection requests. After following 10-15 industry-specific companies, I started saving 2-5 jobs weekly, guided by the recommended job list. Learning nudges encouraged me to complete a Google Cloud course, which led me to more engagement with learning posts and articles. One particularly valuable touchpoint was when a recruiter InMail led to an interview-the feature made me feel LinkedIn directly impacted my career. Another is 'People You May Know,' which widened my network and introduced me to relevant professionals. Lastly, endorsement notifications motivated me to endorse skills of connections, increasing engagement with my feed. Over time, these features made LinkedIn my main platform for professional networking, learning, and job discovery.

---

## Experiment 1: Personalized Networking Suggestions vs Generic Suggestions

**Objective:** Test if highly personalized networking suggestions (weighted by mutual connections, shared skills, shared groups, co-engagement, geography/school)increase high-quality connection requests.

**Treatment:** Personalized suggestions based on:
- Mutual connections (strong)
- Shared skills (strong)
- Shared groups (medium)
- Co-engagement on posts / articles (medium)
- Geography / School (light)

**Control:** Current generic "People You May Know" suggestions.

**Randomization Unit:** User-level

**Eligibility:** Signed-in members with >= 5 network suggestions per week; exclude new accounts < 1 month old and bot-like accounts.

**Exposure Definition:** Users shown at least 1 personalized suggestion per session.

**Primary Metric:** Accepted conenction requests per 1k suggestions shown

**Secondary Metrics:** First-message rate post-connection, hide / report suggestion rate, session starts from suggestions

**Guardrails:** Negative feedback on suggestions, feed dwell time, help-center visits for 'account restricted,' fairness checks by demographics

**Test Duration:** 4 weeks

**Minimum Detectable Effect (MDE):** +8-12% increase in accepted requests

**Sample Size Considerations:** Stratified by baseline networking activity

---

## Experiment 2: Job Recommendation Notifications - Daily vs Weekly

**Objective:** Evaluate if daily job recommendation notifications increase engagement compared to weekly notifications.

**Treatment:** Daily notifications (up to 3/day, email + in-app push)

**Control:** Weekly notifications (email + in-app push)

**Randomization Unit:** User-level

**Eligibility:** Users with "Open to Work" status or at least 1 recent job search; exclude inactive users (< 1 login / week)

**Exposure Definition:** Notification delivered and opened at least once during week

**Primary Metric:** Job applications started per user per week

**Secondary Metrics:** Job saves per user, sessions started from notification

**Guardrails:** Unsubcribe/spam rates, push disables, app uninstalls, notification fatigue (time-to-next-session), email deliverability

**Test Duration:** 4-6 weeks

**MDE:** +6-10% applications started

**Segmentation:** Active seekers vs passive users

---

## Experiment 3: Highlight Skill Endorsemnts on Feed vs Profile Only

**Objective**: Determine if showing skill endorsements in the feed increases profile engagement and connection activity.

**Treatment:** Add "Endorsement Card" in feed showing top 3 endorsed skills of a connection with "View Profile buttion"

**Control:** Endorsements only visible on profile

**Randomization Unit:** Viewer-level

**Eligibility:** Users with >=1 connection having >= 3 endorsements

**Exposure Definition:** Viewer sees endorsement card at least once per feed session

**Primary Metric:** CTR on endorsement module leading to profile view

**Secondary Metrics:** Number of endorsements given, connection requests sent to endorsed person, feed dweel time

**Guardrails:** Hide/report rate, feed negative feedback, session bounce, scroll depth, feed clutter

**Test Duration:** 2-3 weeks

**MDE:** +5-8% module CTR

**Segmentation:** 1st-degree vs 2nd-degree connecitons

---
