# wemux-client
A wemux client running in a Docker container

1. Start the Docker container
2. Use wemux-mgr.sh to manage users who can connect to the container

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
