# start a producer

docker run -d -u nobody --name ch6_ipc_producer allingeek/ch6_ipc -producer 

# start the consumer

#docker run -d -u nobody --name ch6_ipc_consumer --ipc container:ch6_ipc_producer allingeek/ch6_ipc -consumer

#docker logs ch6_ipc_producer
#docker logs ch6_ipc_consumer

#docker rm -f ch6_ipc_producer ch6_ipc_consumer
