const {
    listReportsSchema,
    createReportsSchema,
    readReportsSchema,
    deleteReportsSchema,
    updateReportsSchema,
    statsByContactSchema,
    statsOverallSchema,
    statsTimelineSchema
} = require('../schemas/reports');


const {
    listReportsHandler,
    createReportsHandler,
    deleteReportsHandler,
    readReportsHandler,
    updateReportsHandler,
    statsByContactHandler,
    statsOverallHandler,
    statsTimelineHandler
} = require('../handler/reports');

const startupDelay = process.env.READINESSDELAYSECONDS || 15;
var ready = false;
setTimeout(()=> ready = true, startupDelay * 1000);

module.exports = async function (fastify, opts) {
    fastify.route({
        method: 'GET',
        url: '/',
        handler: async function(request, reply) {
            reply.code(200).send();
        }
    });
    
    // Liveness probe
    fastify.route({
        method: 'GET',
        url: '/health/live',
        handler: async function(request, reply) {
            reply.code(200).send();
        }
    });

    // Readiness probe
    fastify.route({
        method: 'GET',
        url: '/health/ready',
        handler: async function(request, reply) {
            if(ready) {
                reply.code(200).send("Healthy");
            } else {
                reply.code(503).send();
            }
        }
    });

    fastify.route({
        method: 'GET',
        url: '/reports',
        schema: listReportsSchema,
        handler: listReportsHandler
    });

    fastify.route({
        method: 'POST',
        url: '/reports',
        schema: createReportsSchema,
        handler: createReportsHandler
    });

    fastify.route({
        method: 'GET',
        url: '/reports/:id',
        schema: readReportsSchema,
        handler: readReportsHandler
    });

    fastify.route({
        method: 'PUT',
        url: '/reports/:id',
        schema: updateReportsSchema,
        handler: updateReportsHandler
    });
    
    fastify.route({
        method: 'DELETE',
        url: '/reports/:id',
        schema: deleteReportsSchema,
        handler: deleteReportsHandler
    });

    // Stats
    
    fastify.route({
        method: 'GET',
        url: '/stats/timeline',
        schema: statsTimelineSchema,
        handler: statsTimelineHandler
    });

    fastify.route({
        method: 'GET',
        url: '/stats/:contactid',
        schema: statsByContactSchema,
        handler: statsByContactHandler
    });

    fastify.route({
        method: 'GET',
        url: '/stats',
        schema: statsOverallSchema,
        handler: statsOverallHandler
    });
};