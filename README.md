# wemux-client
A wemux client running in a Docker container

##### 1. Start the Docker container
```
docker run -p <YOUR SSH PORT>:22 -v /tmp/wemux-wemux:/tmp/wemux-wemux wemux-client
```

##### 2. Ask users for their public SSH key

##### 3. Use wemux-mgr.sh to manage users who can connect to the container

Usage:

```
wemux-mgr.sh CONTAINER COMMAND

With:
  CONTAINER: the name or id of the container

  COMMAND:
    adduser|u USER [SSH_PUBIC_KEY_PATH]
      Add a user in the Docker container in mirror mode

    addkey|k USER SSH_PUBLIC_KEY_PATH
      Add a SSH_PUBIC_KEY_PATH into the authorized_keys
      file of the USER 

    setmode|m USER MODE
      Set the wemux mode for the user (mirror, pair, rogue)
```

##### 4. Ask users to connect to your Docker container using their username and SSH key
