const http = require('http');

const server = http.createServer((req, res) => {
    if (req.url === '/alive') {
        res.statusCode = 200;
        return res.end();
    }
    res.statusCode = 404;
    return res.end();
});

server.listen(3000, () => {
    console.log('Server running on port 3000');
});
