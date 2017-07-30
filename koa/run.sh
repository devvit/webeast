rm -rf /tmp/*test*.sock
coffee -bc app.coffee
export NODE_ENV=production
pm2 start app.js --name='app0' -- /tmp/test.0.sock
pm2 start app.js --name='app1' -- /tmp/test.1.sock
pm2 start app.js --name='app2' -- /tmp/test.2.sock
pm2 start app.js --name='app3' -- /tmp/test.3.sock
