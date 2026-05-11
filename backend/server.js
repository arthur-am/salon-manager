require('dotenv').config();

const app = require('./src/app');
const messaging = require('./src/messaging/publisher');

const PORT = process.env.PORT || 3000;

messaging.connect();

app.listen(PORT, () => {
  console.log(`[server] rodando em http://localhost:${PORT}`);
});
