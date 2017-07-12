rm -rf /tmp/*test*.sock
coffee -bc app.coffee
NODE_ENV=production
pm2 start app.js --name='app0' -- /tmp/test.0.sock
pm2 start app.js --name='app1' -- /tmp/test.1.sock
