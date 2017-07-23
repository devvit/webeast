rm -rf /tmp/*test*.sock
coffee -bc app.coffee
export NODE_ENV=production
pm2 start app.json
