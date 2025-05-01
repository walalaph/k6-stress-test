import http from 'k6/http';
import { check } from 'k6';

export default function () {
  const url = 'http://localhost:8080/v1/required-document?appId=test';

  const res = http.get(url, { redirects: 4 });

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response is JSON': (r) => r.headers['Content-Type']?.includes('application/json'),
  });
}
