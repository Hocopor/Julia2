// Simple test to check how dev server serves static files
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 5173,
  path: '/Julia2/assets/hero-photo-v3.png',
  method: 'GET'
};

const req = http.request(options, (res) => {
  console.log('Status:', res.statusCode);
  console.log('Headers:', JSON.stringify(res.headers, null, 2));
  
  res.on('data', (chunk) => {
    console.log('Got chunk of', chunk.length, 'bytes');
  });
  
  res.on('end', () => {
    console.log('Response ended');
  });
});

req.on('error', (e) => {
  console.error('Error:', e.message);
});

req.end();
