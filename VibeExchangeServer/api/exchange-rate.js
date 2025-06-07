module.exports = async (request, response) => {
    // 1. Authenticate the request from our app
    const appAuthKey = process.env.APP_AUTH_KEY;
    const authHeader = request.headers['authorization'];
  
    if (!appAuthKey || `Bearer ${appAuthKey}` !== authHeader) {
      return response.status(401).json({ error: 'Unauthorized' });
    }
  
    // 2. Get the base currency from the query string
    const { base } = request.query;
    if (!base) {
      return response.status(400).json({ error: 'base currency query parameter is required' });
    }
  
    // 3. Call the ExchangeRate-API
    const exchangeRateApiKey = process.env.EXCHANGE_RATE_API_KEY;
    const apiUrl = `https://v6.exchangerate-api.com/v6/${exchangeRateApiKey}/latest/${base}`;
  
    try {
      const apiResponse = await fetch(apiUrl);
  
      // The fetch API in Node.js doesn't have a .json() method directly on the response stream in all environments.
      // To be safe, let's get the body text and parse it.
      const body = await apiResponse.text();
      const data = JSON.parse(body);
  
      if (data.result === 'error') {
          // Pass through errors from the external API
          return response.status(apiResponse.status).json(data);
      }
  
      // 4. Send the response back to our app
      response.status(200).json(data);
    } catch (error) {
      console.error(error);
      response.status(500).json({ error: 'Something went wrong on the server.' });
    }
  };