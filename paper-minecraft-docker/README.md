### Run PaperMC in a docker container ###

Build:
`docker build -t paper .`


Run:
`docker run -it -v /opt/minecraft:/data -p 25565:25565 --name paper --restart=always paper:latest`
