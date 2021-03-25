import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 1, // 1 user looping for 15 seconds
  duration: '15s',
  thresholds: {
    http_req_duration: ['avg<5500'], // average of requests must complete below 5.5s
  },
};

export default function () {
  let res = http.get(`http://${__ENV.APP_ENDPOINT}/api/visitreports/reports`);
  console.log('Duration: ' + res.timings.duration + 'ms; http status code: ' + res.status);

  check(res, {
    'response code was 200': (res) => res.status == 200
  });

  sleep(0.25);
}
