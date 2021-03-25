import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'http://51-105-114-164.nip.io';

export let options = {
  vus: 1, // 1 user looping for 15 seconds
  duration: '15s',
  thresholds: {
    http_req_duration: ['p(95)<500'], // 99% of requests must complete below 1.5s
  },
};

export default function () {
  let res = http.get(`${BASE_URL}//api/visitreports/reports`);
  console.log('Duration: ' + res.timings.duration + 'ms; http status code: ' + res.status);

  check(res, {
    'response code was 200': (res) => res.status == 200
  });

  sleep(1);
}
