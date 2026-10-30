deck: System Design::01 Foundations
tags: system-design foundations

Q: Computer architecture: what are the 4 main parts, with one phrase each?
A: **Disk**: big, slow, permanent. **RAM**: smaller, fast, temporary. **CPU**: does all the work and moves data. **Cache**: tiny, fastest, on the CPU die.

Q: Order cache, RAM, SSD and HDD by speed. How do size and cost per GB compare?
A: Speed: cache > RAM > SSD > HDD. Size goes in the reverse order. Cost per GB follows speed: cache is the most expensive per GB.

Q: What does "persistent" (non-volatile) storage mean, and which component has it?
A: The data survives when the power is off. The **disk** (HDD or SSD) is persistent. RAM and cache are not.

Q: HDD vs SSD: give 3 differences.
A: An HDD is **mechanical** (spinning platter + read/write head), **slower**, wears out over time, and is cheaper per GB. An SSD is **electronic flash with no moving parts**, **much faster**, and costs more per GB.

Q: Why must you save your work to disk before shutting down?
A: RAM is **volatile**: its contents are erased when the power goes off.

Q: Roughly how long does writing 1 MB take in RAM vs on disk?
A: RAM: about **microseconds** ($10^{-6}$ s). Disk: about **milliseconds** ($10^{-3}$ s). RAM is roughly 1000× faster.

Q: Do RAM and disk communicate directly?
A: **No.** The CPU moves data between them.

Q: Describe the CPU instruction cycle.
A: Code is compiled to binary instructions stored in RAM. The CPU repeatedly **fetches** an instruction, **decodes** it and **executes** it.

Q: How long does a single CPU instruction take: milliseconds or nanoseconds?
A: **Under a nanosecond.** CPUs run at GHz, which is billions of cycles per second.

Q: Give 2 reasons a CPU cache is faster than RAM.
A: 1) It is on the **same die** as the CPU. 2) It is made of **SRAM**, which is faster than the **DRAM** used for main memory.

Q: What are L1, L2 and L3, and how do they compare?
A: The CPU's cache levels. **L1** is the smallest and fastest, and **L3** is the largest and slowest of the three. Sizes range from KBs to tens of MBs.

Q: In what order does the computer check for data on a read? What are a cache hit and a cache miss?
A: Cache → RAM → disk. **Hit:** the data is in the cache and unchanged, so it is served from there. **Miss:** go down a level.

Q: Who manages what goes into the CPU's L1/L2/L3 cache?
A: The **CPU hardware** (its cache controller), not the OS. The OS manages the **page cache**, which keeps disk data in RAM.

Q: Define a cache in one sentence, and give a non-CPU example.
A: A smaller, faster store that keeps **copies** of data from a slower one. Example: a browser caches HTML, CSS, JS and images **on disk**, because the network is slower than the disk.

Q: State Moore's Law. Why does its chart look linear?
A: The number of transistors on a chip **doubles about every 2 years**: $N = N_0 \cdot 2^{t/2}$. The chart's y-axis is **logarithmic**, so exponential growth looks like a straight line. The growth is now slowing.

Q: What is a server?
A: A computer that **handles requests from other computers**.

Q: Why do servers usually use external storage?
A: Built-in storage is **limited in size**, so the server talks to a database or cloud storage **over the network**.

Q: In a web app, who is the client, and what does the server send back for a front-end feature?
A: The user's **web browser** is the client. The server sends the **HTML, CSS and JavaScript** needed to show the feature.

Q: Vertical vs horizontal scaling: definition and one pro and one con of each.
A: **Vertical:** upgrade one machine (more RAM, CPU). Pro: easy. Con: hard ceiling and a single point of failure. **Horizontal:** add more machines. Pro: no ceiling, survives failures, cheap commodity hardware. Con: needs much more engineering (coordination, spreading load).

Q: Which scaling style do large systems prefer, and when is the other one fine?
A: Large systems prefer **horizontal** scaling. **Vertical** is often enough, and simpler, for small apps. Amazon Prime Video even moved some services back to a monolith.

Q: What does a load balancer do?
A: It decides **which server handles each request**, spreading incoming requests **evenly** across a group of servers.

Q: Logs vs metrics vs alerts: what does each do?
A: **Logs** record what happened (requests, errors, the lead-up to a crash). **Metrics** are numbers such as CPU, RAM and network traffic, used to find bottlenecks. **Alerts** push a notification when a metric misses its target.

Q: Why are logs often written to an external server?
A: For **reliability**. If the server crashes, its logs survive somewhere else.

Q: Give an example of an alert rule.
A: The target is 100% of requests succeeding. Alert if the success rate drops **below 95%**.

Q: What 3 things does every large system do with data?
A: **Move**, **store** and **transform** it.

Q: Why is a bad design choice worse than bad code?
A: Bad code is cheap to rewrite. A bad design, such as the wrong database, means **migrating data and rewriting parts of the app**.

Q: Which 4 qualities define a good design? (mnemonic: "A Real Tough Load")
A: **A**vailability, **R**eliability, **T**hroughput, **L**atency.

Q: What is the formula for availability?
A: $$\text{availability} = \frac{\text{uptime}}{\text{uptime} + \text{downtime}}$$

Q: How much downtime per year does each of 99%, 99.9%, 99.99% and 99.999% allow?
A: 99%: **3.65 days**. 99.9%: **8.76 hours**. 99.99%: **52.6 minutes**. 99.999%: **5.26 minutes**. Each extra 9 means 10× less downtime.

Q: A system is up 23 of 24 hours a day. What is its availability, and is that good?
A: $23/24 \approx 96\%$. That is **poor**: users and money are lost for an hour every day.

Q: Planned vs unplanned downtime: give examples of each.
A: **Planned:** software updates, maintenance, backups. **Unplanned:** hardware or software failure, natural disaster.

Q: SLA vs SLO?
A: An **SLA** is the agreement or promise made to customers (e.g. AWS promises 99.99% a month, with service credits refunded if missed). An **SLO** is the internal objective the team must hit to meet the SLA.

Q: Define reliability. How is it different from availability?
A: Reliability is the **probability the system works without failing** over a period of time. Availability asks "is it up right now?". Reliability asks "how easily does it go down?"

Q: What is fault tolerance?
A: How well a system **detects and heals itself** when a part fails, for example by disabling a feature, switching mode or switching to another server.

Q: How do redundancy, fault tolerance and reliability relate?
A: **Redundancy** (spare components) gives **fault tolerance**, which gives **reliability**. Without redundancy there is no fault tolerance.

Q: Active-passive vs active-active redundancy?
A: **Active-passive:** the backup sits idle until the primary fails. **Active-active:** both servers handle traffic all the time.

Q: Why doesn't redundancy fully protect against a DDoS attack?
A: The backup server takes over, but the flood of traffic **overloads it too**.

Q: What is throughput? Name 3 ways to measure it.
A: The amount of work handled per unit of time. Measures: **requests/second**, **queries/second (QPS)** for user-facing systems, and **bytes/second** for data pipelines.

Q: Throughput vs bandwidth?
A: **Bandwidth** is the maximum data rate possible. **Throughput** is what you actually achieve, and it is always ≤ the bandwidth.

Q: What is latency, and how is it different from throughput?
A: Latency is the delay for **one** request to complete (the round trip). Throughput is **how many** requests per second. On a highway, throughput is cars per hour and latency is one car's trip time.
