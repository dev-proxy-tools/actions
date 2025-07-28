import axios from 'axios';

(async () => {
  const result = await axios.get('https://jsonplaceholder.typicode.com/posts');
  const response = result.data;
  console.log(JSON.stringify(response, null, 2));
})();