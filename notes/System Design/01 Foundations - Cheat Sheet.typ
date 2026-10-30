#import "/template/boox.typ": *
#show: note.with(title: "Foundations", subject: "System Design", kind: "cheat")

#let small(body) = text(0.8em, body)
#let s = 1.3pt  // diagram stroke

= Computer architecture
#table(columns: (auto, 1fr, auto, auto, auto),
  table.header([], [What], [Size], [Speed], [Persists?]),
  [*Cache*], [On the CPU die, SRAM. L1 < L2 < L3 in size, L1 is the fastest], [KB–10s MB], [ns], [No],
  [*RAM*], [Open apps and variables (DRAM)], [1–128 GB], [µs / MB], [No],
  [*SSD*], [Flash, no moving parts], [TB], [ms / MB], [Yes],
  [*HDD*], [Spinning platter + head, wears out], [TB], [slower], [Yes],
)
- Speed: cache > RAM > SSD > HDD. Size and cheapness go in the reverse order.
- *RAM ↔ disk never talk directly.* The CPU sits between them.
- *CPU loop:* fetch → decode → execute, and each instruction takes under 1 ns.
- *Read path:* cache → RAM → disk. A hit is served fast; a miss goes down a level.
- CPU caches are managed by *hardware*. The OS manages the *page cache* (disk data kept in RAM).
- *Cache* = a smaller, faster copy of slower data (CPU, browser caching on disk, …).
- *Moore:* transistors ×2 every ≈ 2 years: $N = N_0 dot 2^(t\/2)$. Exponential, now plateauing.

#fig(caption: [Read path: check the fastest place first])[
  #diagram(spacing: (9mm, 7mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt,
    node((0, 0), [CPU needs \ data], name: <need>, shape: fletcher.shapes.pill),
    node((1, 0), [*In cache?*], name: <c>, stroke: 2pt),
    node((2, 0), [*In RAM?*], name: <r>, stroke: 2pt),
    node((3, 0), [Disk \ #small[ms]], name: <d>, shape: fletcher.shapes.cylinder),
    node((1, 1), [*Hit*: use it \ #small[≈ 1 ns]], name: <hit>),
    node((2, 1), [Copy → cache \ #small[≈ 100 ns]], name: <rc>),
    node((3, 1), [Copy → RAM \ → cache], name: <dc>),
    edge(<need>, <c>, "-|>"), edge(<c>, <r>, "-|>", [miss]), edge(<r>, <d>, "-|>", [miss]),
    edge(<c>, <hit>, "-|>", [hit], label-side: left), edge(<r>, <rc>, "-|>", [hit], label-side: left), edge(<d>, <dc>, "-|>"),
  )
]

= Application architecture
- *Dev:* code → build & deploy → *server* → external *storage* (DB / cloud over the network).
- *User:* browser (client) → *load balancer* → servers → HTML / CSS / JS back.
- *Bottleneck* (CPU or RAM) → *scale*:
#table(columns: (auto, 1fr, 1fr),
  table.header([], [Vertical (up)], [Horizontal (out)]),
  [How], [Bigger machine], [More machines + LB],
  [Pros], [Easy], [No ceiling, survives failure, cheap hardware],
  [Cons], [Hard ceiling, single point of failure], [Engineering effort: coordination, spreading load],
)
- External services via *APIs* (e.g. Stripe).
- *Logs* = what happened (store them externally). *Metrics* = CPU / RAM / network numbers. *Alerts* = a push when a metric misses its target (e.g. success rate < 95%).

#fig(caption: [Request flow, observability loop and the scaling decision])[
  #diagram(spacing: (9mm, 8mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt, node-shape: rect,
    node((1, -1), [APIs \ #small[Stripe…]], name: <api>, stroke: (dash: "dashed")),
    node((2, -1), [Dev], name: <dev>, shape: fletcher.shapes.pill),
    node((0, 0), [User], name: <u>, shape: fletcher.shapes.pill),
    node((1, 0), [LB], name: <lb>, shape: fletcher.shapes.pill),
    node((2, 0), [*Servers* ×N], name: <s>, stroke: 2.4pt),
    node((3, 0), [Storage], name: <db>, shape: fletcher.shapes.cylinder),
    node((1, 1), [Logs], name: <lg>, shape: fletcher.shapes.cylinder),
    node((2, 1), [Metrics], name: <m>),
    node((3, 1), [Alerts], name: <al>, shape: fletcher.shapes.hexagon),
    edge(<u>, <lb>, "-|>"), edge(<lb>, <s>, "-|>"), edge(<s>, <db>, "-|>"), edge(<s>, <api>, "-|>"),
    edge(<dev>, <s>, "-|>", [deploy], label-side: left),
    edge(<s>, <lg>, "-|>"), edge(<s>, <m>, "-|>"), edge(<lg>, <m>, "-|>"), edge(<m>, <al>, "-|>"),
    edge(<al>, (4, 1), (4, -1), <dev>, "-|>", [notify], label-pos: 0.75, label-side: right),
  )
  #v(2pt)
  #diagram(spacing: (9mm, 4mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt, node-shape: rect,
    node((0, 1), [Bottleneck \ #small[CPU / RAM]], name: <b>, shape: fletcher.shapes.pill),
    node((1, 1), [*Big system or* \ *need failover?*], name: <q>, stroke: 2pt),
    node((2, 0), [*Horizontal* + LB], name: <h>),
    node((2, 2), [*Vertical*: bigger box], name: <v>),
    edge(<b>, <q>, "-|>"), edge(<q>, <h>, "-|>", [yes]), edge(<q>, <v>, "-|>", [no], label-side: right),
  )
]

= Design requirements
- *Every system:* *Move · Store · Transform* data.
- Bad code is cheap to fix. Bad design is costly (DB migration + rewrite).
- *Judge a design by "A Real Tough Load":* Availability · Reliability · Throughput · Latency.

#formula[$ "availability" = "uptime" / ("uptime" + "downtime") $]

#table(columns: (1fr, 1fr, 1fr, 1fr),
  table.header([99%], [99.9%], [99.99%], [99.999%]),
  [3.65 days/yr], [8.76 h/yr], [52.6 min/yr], [5.26 min/yr],
)
- Each extra 9 means 10× less downtime. 23/24 h ≈ 96%, which is poor.
- *SLA* = the promise to customers (AWS: 99.99%/month, or credits back). *SLO* = the internal target that meets the SLA.
- *Redundancy → fault tolerance → reliability.* Active-passive: the backup is idle. Active-active: both serve traffic.
- Under a DDoS, redundancy alone fails, because the backup gets flooded too.
- *Throughput* = how many per second: req/s, QPS (user-facing), bytes/s (pipelines). It is always ≤ the *bandwidth*.
- *Latency* = how long one request takes (round trip). Highway analogy: throughput is cars per hour, latency is one car's trip time.

#fig(caption: [What a system does, and how to judge it])[
  #diagram(spacing: (8mm, 3mm), node-stroke: s, edge-stroke: s, node-inset: 5pt, node-corner-radius: 2pt, node-shape: rect,
    node((0, 1.5), [*Data*], name: <data>, shape: fletcher.shapes.pill),
    node((1, 0.5), [Move], name: <mv>), node((1, 1.5), [Store], name: <st>), node((1, 2.5), [Transform], name: <tr>),
    edge(<data>, <mv>, "-|>"), edge(<data>, <st>, "-|>"), edge(<data>, <tr>, "-|>"),
    node((2, 1.5), [*Good \ design?*], name: <g>, stroke: 2.4pt),
    edge(<mv>, <g>, "-"), edge(<st>, <g>, "-|>"), edge(<tr>, <g>, "-"),
    node((3, 0), [#strong[A]vailability \ #small[up / (up + down)]], name: <a>),
    node((3, 1), [#strong[R]eliability \ #small[won't fail]], name: <r>),
    node((3, 2), [#strong[T]hroughput \ #small[how many / s]], name: <t>),
    node((3, 3), [#strong[L]atency \ #small[how long / req]], name: <l>),
    edge(<g>, <a>, "-|>"), edge(<g>, <r>, "-|>"), edge(<g>, <t>, "-|>"), edge(<g>, <l>, "-|>"),
    node((4, 0), [SLO → SLA], name: <sla>, stroke: (dash: "dashed")),
    node((4, 1), [Redundancy → \ fault tolerance], name: <red>, stroke: (dash: "dashed")),
    node((4, 2), [scale up / out], name: <sc>, stroke: (dash: "dashed")),
    node((4, 3), [round trip], name: <rt>, stroke: (dash: "dashed")),
    edge(<a>, <sla>, "-"), edge(<r>, <red>, "-"), edge(<t>, <sc>, "-"), edge(<l>, <rt>, "-"),
  )
]

= Numbers to know (approximate)
#table(columns: (1fr, auto),
  table.header([Operation], [Time]),
  [L1 cache read], [≈ 1 ns],
  [RAM read], [≈ 100 ns],
  [SSD random read], [≈ 100 µs],
  [HDD seek], [≈ 10 ms],
  [Round trip inside a datacentre], [≈ 0.5 ms],
  [Round trip across continents], [≈ 150 ms],
)

#fig(caption: [The latency ladder: from L1 to a trip across continents is ≈ 150 million× slower])[
  #diagram(spacing: (14mm, 8mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt, node-shape: rect,
    node((0, 0), [L1 \ *1 ns*], name: <a>), node((1, 0), [RAM \ *100 ns*], name: <b>), node((2, 0), [SSD \ *100 µs*], name: <c>),
    node((2, 1), [DC trip \ *0.5 ms*], name: <d>), node((1, 1), [HDD \ *10 ms*], name: <e>), node((0, 1), [Continent \ *150 ms*], name: <f>, stroke: 2.4pt),
    edge(<a>, <b>, "-|>", [×100]), edge(<b>, <c>, "-|>", [×1000]), edge(<c>, <d>, "-|>", [×5], label-side: left),
    edge(<d>, <e>, "-|>", [×20]), edge(<e>, <f>, "-|>", [×15]),
  )
]
