const http = require('node:http');
const { Pool } = require('pg');

// pg lee PGHOST, PGPORT, PGUSER, PGDATABASE y PGPASSWORD del entorno.
const pool = new Pool({ connectionTimeoutMillis: 5000, query_timeout: 5000 });
pool.on('error', (error) => console.error('Error de PostgreSQL:', error.message));

const server = http.createServer(async (request, response) => {
  response.setHeader('Content-Type', 'application/json; charset=utf-8');

  if (request.method !== 'GET' || request.url !== '/') {
    response.writeHead(404);
    response.end(JSON.stringify({ message: 'Ruta no encontrada' }));
    return;
  }

  try {
    const result = await pool.query(
      'SELECT current_database() AS database, current_user AS username, inet_server_addr()::text AS server_address'
    );
    response.writeHead(200);
    response.end(JSON.stringify({
      message: 'Backend funcionando y conectado a PostgreSQL',
      environment: process.env.APP_ENV,
      host: process.env.PGHOST,
      ...result.rows[0],
    }));
  } catch (error) {
    console.error('Falló la consulta a PostgreSQL:', error.message);
    response.writeHead(503);
    response.end(JSON.stringify({ message: 'PostgreSQL no está disponible' }));
  }
});

server.listen(3000, '0.0.0.0', () => {
  console.log(`Backend ${process.env.APP_ENV} escuchando en el puerto 3000`);
});

process.on('SIGTERM', () => {
  server.close(() => pool.end().then(() => process.exit(0)));
});
