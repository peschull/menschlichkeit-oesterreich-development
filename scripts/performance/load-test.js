// k6 Load Test for Menschlichkeit Österreich Platform
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp up
    { duration: '5m', target: 10 },   // Stay at 10 users  
    { duration: '2m', target: 50 },   // Ramp up to 50
    { duration: '5m', target: 50 },   // Stay at 50
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'],   // 95% requests under 200ms
    http_req_failed: ['rate<0.01'],     // Error rate under 1%
  },
};

const BASE_URL = 'https://api.menschlichkeit-oesterreich.at';

export default function () {
  // Test API Health Endpoint
  const healthRes = http.get(`${BASE_URL}/health`);
  check(healthRes, {
    'health check status 200': (r) => r.status === 200,
    'health check response time < 100ms': (r) => r.timings.duration < 100,
  });

  // Test Authentication Endpoint
  const authRes = http.post(`${BASE_URL}/auth/login`, {
    email: 'test@example.com',
    password: 'testpass'
  });
  check(authRes, {
    'auth response status is 200 or 401': (r) => [200, 401].includes(r.status),
  });

  // Test Database-heavy Endpoint
  const statsRes = http.get(`${BASE_URL}/stats`);
  check(statsRes, {
    'stats status 200': (r) => r.status === 200,
    'stats response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    'quality-reports/performance/load-test-results.json': JSON.stringify(data, null, 2),
  };
}
