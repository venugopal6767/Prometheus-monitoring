const client = require('prom-client');
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const requestCounter = new client.Counter({
    name: 'http_requests_total',
    help: 'Total HTTP requests',
    labelNames: ['method', 'endpoint']
});

const responseHistogram = new client.Histogram({
    name: 'http_response_duration_seconds',
    help: 'Duration of HTTP responses in seconds',
    labelNames: ['method', 'endpoint'],
    buckets: [0.1, 0.5, 1, 2, 5]
});

register.registerMetric(requestCounter);
register.registerMetric(responseHistogram);

const middleware = (req, res, next) => {
    const end = responseHistogram.startTimer({ method: req.method, endpoint: req.path });
    res.on('finish', () => {
        requestCounter.labels(req.method, req.path).inc();
        end();
    });
    next();
};

module.exports = { register, middleware };