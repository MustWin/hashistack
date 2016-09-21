job "spark-slave" {
    region = "gce-us-central1"
    datacenters = ["gce-us-central1"]

    constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
    }

    update {
        stagger = "10s"

        max_parallel = 1
    }

    group "spark" {
        # count = 1

        restart {
            attempts = 10
            interval = "5m"

            delay = "25s"

            mode = "delay"
        }

        task "spark" {
            driver = "exec"

            config {
                command = "/bin/sh"
                args = ["local/jars/start-slave.sh", "spark-master.service.consul"]
            }

            service {
                name = "${TASKGROUP}-slave"
                tags = ["global", "spark", "slave", "routed"]
                port = "db"
                check {
                    name = "alive"
                    type = "tcp"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            resources {
                cpu = 500 # 500 MHz
                memory = 256 # 256MB
                network {
                    mbits = 10
                    port "db" {}
                }
            }

            artifact {
                source = "https://s3-us-west-2.amazonaws.com/mustwin-files/spark-exec.zip"
            }
        }
    }
}
