job "redis" {
  region      = "${region}"
  datacenters = ["${datacenter}"]
  type        = "service"
  priority    = 50

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "redis" {
    count = ${count}

    constraint {
      attribute = "\$${node.datacenter}"
      value     = "${datacenter}"
    }

    restart {
      mode     = "delay"
      interval = "5m"
      attempts = 10
      delay    = "25s"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "${image}"

        port_map {
          db = 6379
        }
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10

        network {
          mbits = 1

          port "db" {
            static = 6379
          }
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
          name     = "redis alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
