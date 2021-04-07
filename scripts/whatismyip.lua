--A "what is my IP" service code. Since most web browsers put up with servers
--not sending proper HTTP headers, you can simply query the service with it.

print(os.getenv "PCAT_REMOTE_ADDR")
