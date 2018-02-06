#

worker_processes 2
Rainbows! do
  use :XEpollThreadPool, pool_size: 16
  # worker_connections 128
end
