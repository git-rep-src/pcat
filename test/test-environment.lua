#!/usr/bin/lua

function print_env(v)
    print(("%s=%s"):format(v, os.getenv(v)))
end

print_env("PCAT_REMOTE_ADDR")
print_env("PCAT_REMOTE_PORT")

print_env("PCAT_LOCAL_ADDR")
print_env("PCAT_LOCAL_PORT")

print_env("PCAT_PROTO")
