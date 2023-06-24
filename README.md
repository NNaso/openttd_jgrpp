[![Docker Build Latest](https://github.com/NNaso/openttd_jgrpp/actions/workflows/latest-parallel.yml/badge.svg)](https://github.com/NNaso/openttd_jgrpp/)

[![dockeri.co](https://dockeri.co/image/nextek/openttd-jgrpp)](https://hub.docker.com/r/nextek/openttd-jgrpp)

### An Alpine based image of [bateau/openttd](https://hub.docker.com/r/bateau/openttd)'s docker. ###
### Includes JGRPP Patches https://github.com/JGRennison/OpenTTD-patches ###
## Usage ##

### Environment variables ###
These environment variables can be altered to change the behavior of the application inside the container.  
To set a new value to an enviroment variable use docker's `-e ` parameter (see https://docs.docker.com/engine/reference/commandline/run/ for more details)  

| Env | Default | Meaning |
| --- | ------- | ------- |
| savepath | "/home/openttd" | The path to which autosave wil save |
| loadgame | `null` | load game has 4 settings. false, true, last-autosave and exit.<br>  - **false**: this will just start server and create a new game.<br>  - **true**: if true is set you also need to set savename. savename needs to be the name of the saved game file. This will load the given saved game.<br>  - **last-autosave**: This will load the last autosaved game located in <$savepath>/autosave folder.<br>  - **exit**: This will load the exit.sav file located in <$savepath>/autosave/. |
| savename | `null` | Set this when allong with `loadgame=true` to the value of your save game file-name |
| PUID | "911" | This is the ID of the user inside the container. If you mount in (-v </path/of/your/choosing>:</path/inside/container>) you would need for the user inside the container to have the same ID as your user outside (so that you can save files for example). |
| PGID | "911" | Same thing here, except Group ID. Your user has a group, and it needs to map to the same ID inside the container. |
| debug | `null` | Set debug things. see openttd for debug options |


### Networking ###
By default docker does not expose the containers on your network. This must be done manually with `-p` parameter (see [here](https://docs.docker.com/engine/reference/commandline/run/) for more details on -p).
If your openttd config is set up to listen on port 3979 you need to map the container port to your machines network like so `-p 3979:3979` where the first reference is the host machines port and the second the container port.

### Examples ###

#### docker run ####
```
docker run --name OpenTTD_Server -d \
    -p 3979:3979/tcp \
    -p 3979:3979/udp \
    -e PUID=1000  \
    -e PGID=1000 \
    -e "loadgame=last-autosave" \
    -v /path/to/your/.openttd:/home/openttd/.openttd \
    --restart=unless-stopped \
    nextek/openttd-jgrpp:latest
```

#### Docker Compose ####
```MiniYAML
version: "3"
services:
  OpenTTD_Server:
    image: nextek/openttd-jgrpp:latest
    restart: unless-stopped
    ports:
      - 3979:3979/udp
      - 3979:3979/tcp
    environment:
      - loadgame=last-autosave
      - PUID=1000
      - PGID=1000
    volumes:
      - /path/to/your/.openttd:/home/openttd/.openttd
```

## Kubernetes ##

Supplied some example for deploying on kubernetes cluster. "k8s_openttd.yml"
just run 

    kubectl apply openttd.yaml

and it will apply configmap with openttd.cfg, deployment and service listening on port 31979 UDP/TCP.

## Links ##
   * Docker Hub -  [nextek/openttd-jgrpp](https://hub.docker.com/r/nextek/openttd-jgrpp)
   * Github -  [nnaso/openttd_jgrpp](https://github.com/NNaso/openttd_jgrpp)
