--

lapis = require "lapis"

class extends lapis.Application
  [index: '/']: =>
    json: { hello: 'world' }
