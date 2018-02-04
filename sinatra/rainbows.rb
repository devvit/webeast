#

worker_processes 2
Rainbows! do
  use :XEpollThreadPool, pool_size: 8
  # worker_connections 128
end
