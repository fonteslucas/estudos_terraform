ecscluster = "myterraform-ecs-cluster"
containernetworkmode = "bridge"
containerport = 80
cpuunits = 256
memoryreservation = 256
memory = 1024
desiredcountservice = 2
maxtaskcapacityasg = 4
mintaskcapacityasg = 2
microservicename = "simple-aspnet-app"