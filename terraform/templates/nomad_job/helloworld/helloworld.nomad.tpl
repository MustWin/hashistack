job "helloworld-v1" {
  region      = "${region}"
  datacenters = ["${datacenter}"]
  type = "service"
  priority    = 50

  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "hello-group" {
    count = ${count}

    constraint {
      attribute = "\$${node.datacenter}"
      value     = "${datacenter}"
    }

    task "hello-task" {
      driver = "docker"
      config {
        image = "${image}"
        port_map {
          http = 8080
        }
      }

      resources {
        cpu = 100
        memory = 200
        network {
          mbits = 1
          port "http" {}
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      service {
        name = "redis"
        tags = ["global", "${region}"]
        port = "db"

        check {
          name     = "hello alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
