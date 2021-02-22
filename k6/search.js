import http from 'k6/http';
import { check, sleep, group } from 'k6';

export let options = {
    stages: [
        { duration: '20s', target: 10 },
        { duration: '20s', target: 20 },
        { duration: '20s', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<200', 'avg<125'], 
      },
};

export default function() {
    let res = http.get('http://20-73-198-159.nip.io/api/search/contacts?phrase=mustermann');
    check(res, { 'status was 200': (r) => r.status == 200 });
    sleep(1);
}