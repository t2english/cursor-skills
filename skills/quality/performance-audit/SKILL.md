---
name: performance-audit
description: Profile and optimize application performance across backend, database, and frontend. Identifies bottlenecks, suggests optimizations, and validates improvements with benchmarks. Use when investigating slow responses, optimizing queries, reducing bundle size, or conducting load testing. Triggers on "slow", "optimize", "performance", "profile", "bundle size", "slow query", "N+1", "load test", "benchmark". Do NOT use for setting up monitoring (use observability-setup) or general code review (use code-review).
metadata:
  author: T2E
  version: "1.0.0"
---

# Performance Audit

Find bottlenecks. Fix them. Prove they're fixed.

## Step 1: Identify the Bottleneck

Before optimizing, measure. Never optimize based on intuition.

```
1. What is slow? (specific endpoint, page, operation)
2. How slow? (current latency/throughput numbers)
3. What is the target? (acceptable latency/throughput)
4. Where is the time spent? (profile before changing code)
```

## Step 2: Backend Profiling

**Node.js**:
- `clinic.js` for comprehensive profiling (doctor, flame, bubbleprof)
- `0x` for flame graphs
- `--prof` flag for V8 profiler
- `console.time`/`console.timeEnd` for quick measurements

**Python**:
- `py-spy` for sampling profiler (no code changes needed)
- `cProfile` for deterministic profiling
- `line_profiler` for line-by-line analysis

**Go**:
- `pprof` (built-in): CPU, memory, goroutine profiles
- `go test -bench` for micro-benchmarks
- `trace` for execution traces

## Step 3: Database Optimization

Common issues and fixes:

**N+1 Queries**: Loading related data in a loop instead of a join/include.
- Detect: enable query logging, look for repeated similar queries
- Fix: use eager loading (Prisma `include`, SQLAlchemy `joinedload`)

**Missing Indexes**: Full table scans on filtered/sorted columns.
- Detect: `EXPLAIN ANALYZE` on slow queries
- Fix: add indexes on WHERE, JOIN, and ORDER BY columns

**Over-fetching**: Selecting all columns when only a few are needed.
- Fix: select only required fields, use pagination

**Connection Pool**: Too few connections causing queuing.
- Fix: configure pool size based on expected concurrency

## Step 4: Frontend Optimization

**Bundle Size**:
- Analyze: `webpack-bundle-analyzer`, `source-map-explorer`, or `vite-bundle-visualizer`
- Fix: code splitting, lazy loading, tree shaking, replace heavy libraries

**Rendering**:
- Identify unnecessary re-renders (React DevTools Profiler)
- Memoize expensive computations (useMemo, React.memo)
- Virtualize long lists (react-virtual, tanstack-virtual)

**Network**:
- Compress assets (gzip/brotli)
- Lazy load images and below-fold content
- Cache static assets with appropriate headers

## Step 5: Load Testing

When you need to validate under load:

- **k6**: JavaScript-based, good for API testing
- **artillery**: YAML config, good for quick scenarios

Always:
1. Define success criteria (max p99 latency, min throughput)
2. Test against a staging environment (never production)
3. Ramp up gradually (find the breaking point)
4. Monitor system resources during tests

## Step 6: Validate Improvements

Every optimization must be measured:

```
Before: [metric] = [value]
Change: [what was changed]
After:  [metric] = [value]
Improvement: [percentage or absolute]
```

If the improvement is less than 10%, question whether the added complexity is worth it.

## Quick Wins Checklist

Common optimizations that almost always help:

- [ ] Enable gzip/brotli compression
- [ ] Add database indexes on frequently queried columns
- [ ] Implement response caching for read-heavy endpoints
- [ ] Use connection pooling for database connections
- [ ] Lazy load images and non-critical scripts
- [ ] Replace moment.js with dayjs or date-fns
- [ ] Enable HTTP/2 if not already
- [ ] Set appropriate cache headers for static assets

## Integration

- **observability-setup**: provides metrics data for identifying bottlenecks
- **code-review**: flags obvious performance anti-patterns
- **testing-strategy**: performance tests as part of test suite
