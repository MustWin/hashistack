job "helloworld-v1" {
  region      = "gce-us-central1"
  datacenters = ["gce-us-central1"]
  type = "service"
  priority    = 50

  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "hello-group" {
    count = 3

    constraint {
      attribute = "${node.datacenter}"
      value     = "gce-us-central1"
    }

    task "hello-task" {
      driver = "docker"
      config {
        image = "eveld/helloworld:1.0.0"
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
        name = "helloworld"
        tags = ["global", "us-central1", "routed"]
        port = "http"

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
