# Logical Clocks

[This](http://web.cs.iastate.edu/~cs554/NOTES/Ch6-LogicalClocks.pdf) is a great presentation.

Logical clocks are used to agree on order in which events occur. The absolute/real time is not important in this concept.

Event ordering can be based on any number of factors. In a local system, CPU time can be used. But in a distributed system, there is no perfectly synchronized time or clock that can be used, and local times may not be in sync (and probably are not). [Lamport](https://en.wikipedia.org/wiki/Leslie_Lamport) suggested a logical clock be used to address this.

#### Key concepts

- Processes exchange messages
- Message must be sent before received
- Send/receive used to order events and synchronize logical clocks

#### Properties

- If A happens before B in the same process (or system), then `A -> B`
- `A -> B` also means that A sent the message and B means the receipt of it
- Relation is transitive: e.g `A -> B` and `B -> C` implies `A -> C`
- Unordered events are concurrent: `A !-> B` and `B !->` A implies `A || B`

## Lamport’s Logical Clocks

- If `A -> B` then `timestamp(A) < timestamp(B)`

### Lamport’s Algorithm

<!---
```diagram
sequenceDiagram
Note left of i: Logical Clock: L(i)
Note right of j: Logical Clock: L(j)
loop Every Event: i => j
i->>i: Event Occurs. L(i) = L(i) + 1
i->>j: Event Sent. Send L(i)
j->>j: Event Received. L(j) = MAX(L(i), L(J)) + 1
end
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/8df698ce798b092930d7fb6955a38bc6.png' alt='diagram image' height='450px'>


**Note**: `A -> B` implies `L(A) < L(B)`, but `L(A) < L(B)` does not necessarily imply `A -> B`. In other words, `A -> B` implies that the logical clock of A is less than that of B, but the logical clock of A being less than that of B does *not* imply that `A -> B`.

## Totally Ordered Multicast

**Example**: We have a large distributed database. We need to make sure that replications are seen in the same order in all replicas. This requires us to cast the replicas to all systems in an absolutely total order.

**Example Situation:** The following events occur:
- A) We have $1000 in a bank account.
- B) We add $100
- C) We calculate 1% interest on the balance.

If the order is ABC, then the 1% interest will be $1100 * 0.01 = $11. But if the order is ACB, then the interest will be $1000 * 0.01 = $10. In this case, the order matters as the interest is different.

Lamport’s logical clocks can be applied to implement a totally‐ordered multicast in a distributed system.

### Implementation

Assumptions:
- No messages are lost
- Messages from the same sender are received in the same order as they were sent

Process `P(i)` will send out a message `M(i)` to all others with timestamp `T(i)`. An incoming message is queued according to it's timestamp. `P(i)` will pass a message to its own application if it meets 2 criteria: the message is at the head of the queue, the message has been acked by all other processes.


<!---
```diagram
sequenceDiagram
P(j)->>P(i): Puts Message m(j) at t=1

Note right of P(i): P(i) sends out m(i) at t=2 because the receipt of m(j) caused L(i) to increment by 1.

P(i)->>P(j): Puts Message m(i) at t=2
P(i)->>P(k): Puts Message m(i) at t=2

Note right of P(i): P(i) sends out m(i) to P(k) at t=2 before P(k) gets M(j) from P(j) at t=1. This is okay though because they are from different senders and the timestamps will sort it out.

Note left of P(j): Since all P(i..n) have ACKed M(i), we would normally be able to process it. However, M(i) is not at the head of the queue, M(j) is.

P(j)->>P(k): Puts Message m(j) at t=1

opt m(j) can be processed now
Note left of P(j): Since all P(i..n) have ACKed m(j) and m(j) is at the head of the queue, we can process it now.
P(i)->>P(i): Perform Message m(j)
P(j)->>P(j): Perform Message m(j)
P(k)->>P(k): Perform Message m(j)
end

opt M(i) can be processed now
Note left of P(j): Since all P(i..n) have ACKed m(i) and m(i) is at the head of the queue, we can process it now.
P(i)->>P(i): Perform Message m(i)
P(j)->>P(j): Perform Message m(i)
P(k)->>P(k): Perform Message m(i)
end
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/598942c362d82725a25fd056b83001b8.png' alt='diagram image' width='100%'>


All processes will end up with the same messages with the same timestamps, so order can be sorted out locally and therefore all messages are delivered in the same order.
