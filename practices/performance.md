# Performance traps

**Open when:** writing code that touches a query, a collection, or a loop.
**Skip if:** the change doesn't scale with data size.

## Why this one is yours

You don't profile and you don't benchmark — that's execution
([`running-things.md`](running-things.md)). But the worst performance bugs in generated code
aren't subtle timing issues; they're **structural and visible in the diff**. You don't need a
profiler to see a query inside a loop. Read your own change for these before handing it over.

## The N+1, first and always

The most common real defect in generated endpoint code:

```python
✗  orders = Order.all()
   for o in orders:
       print(o.customer.name)     # one query per order

✓  orders = Order.all().prefetch("customer")   # one query, or two
```

Same shape in every ORM — `prefetch_related` / `includes` / `joinLoad` / `With`. The tell is
**any attribute access on a related object inside a loop**. If you wrote a loop over rows,
re-read it asking what fires per iteration.

## The rest of the list

| Trap | Fix |
| --- | --- |
| Unbounded fetch — no `LIMIT`, no pagination | Paginate. "There are only 50 rows" is a claim about today |
| Loading rows to count them | `COUNT(*)` |
| Loading rows to check existence | `EXISTS` / `LIMIT 1` |
| Work hoistable out of a loop | Compile the regex, open the connection, read the config **once** |
| Sequential `await` on independent calls | Gather them concurrently |
| `x in some_list` inside a loop | Build a set first — O(n²) → O(n) |
| Reading a whole file or response into memory | Stream it, if the ecosystem makes that easy |
| A new query path with no supporting index | Add the index migration, `CONCURRENTLY` — [`migrations.md`](migrations.md) |
| Serializing a whole object graph to return three fields | Select the three fields |

## Where "it's fine" is usually wrong

Two arguments that sound reasonable and aren't:

- *"The table is small."* Table sizes are a property of the deployment, not the code. The
  code outlives your knowledge of the data.
- *"It's an internal admin route."* Internal routes hit the same database, hold the same
  connections, and are the ones nobody notices degrading.

If the cost scales with row count, say so — even when you believe it's fine today.

## What isn't yours

Micro-optimization, profiling, benchmarking, caching strategy. **Don't optimize what you
can't measure**, and don't add a cache to paper over a structural problem — that's the
`code-restraint.md` rule and it holds here.

Structural traps aren't optimization. They're correctness at scale, and they're free to
avoid at write time and expensive to find later.

## Flag it

Anything whose cost grows with data volume gets named in the handoff, with the growth
characteristic:

> `GET /reports` fans out one query per project. Fine at ~20 projects; it'll be felt around
> a few hundred. Batched version is straightforward if you want it now.
