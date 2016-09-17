job "classlogger-consul-raw-exec" {
  region      = "${region}"
  datacenters = ["${datacenter}"]
  type        = "service"
  priority    = 50

  group "classlogger-1" {
    count = ${count}

    constraint {
      attribute = "\$${node.class}"
      value     = "class_1"
    }

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
    }

    task "classlogger-1" {
      driver = "raw_exec"

      config {
        command = "classlogger"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        REDIS_ADDR = "redis.service.consul:6379"
        NODE_CLASS = "\$${node.class}"
      }

      service {
        name = "\$${JOB}-\$${TASKGROUP}-classlogger"
      }
    }
  }

  group "classlogger-2" {
    count = ${count}

    constraint {
      attribute = "\$${node.class}"
      value     = "class_2"
    }

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
    }

    task "classlogger-2" {
      driver = "raw_exec"

      config {
        command = "classlogger"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        REDIS_ADDR = "redis.service.consul:6379"
        NODE_CLASS = "\$${node.class}"
      }

      service {
        name = "\$${JOB}-\$${TASKGROUP}-classlogger"
      }
    }
  }

  group "classlogger-3" {
    count = ${count}

    constraint {
      attribute = "\$${node.class}"
      value     = "class_3"
    }

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
    }

    task "classlogger-3" {
      driver = "raw_exec"

      config {
        command = "classlogger"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        REDIS_ADDR = "redis.service.consul:6379"
        NODE_CLASS = "\$${node.class}"
      }

      service {
        name = "\$${JOB}-\$${TASKGROUP}-classlogger"
      }
    }
  }

  group "classlogger-4" {
    count = ${count}

    constraint {
      attribute = "\$${node.class}"
      value     = "class_4"
    }

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
    }

    task "classlogger-4" {
      driver = "raw_exec"

      config {
        command = "classlogger"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        REDIS_ADDR = "redis.service.consul:6379"
        NODE_CLASS = "\$${node.class}"
      }

      service {
        name = "\$${JOB}-\$${TASKGROUP}-classlogger"
      }
    }
  }

  group "classlogger-5" {
    count = ${count}

    constraint {
      attribute = "\$${node.class}"
      value     = "class_5"
    }

    restart {
      mode     = "fail"
      attempts = 3
      interval = "5m"
      delay    = "2s"
    }

    task "classlogger-5" {
      driver = "raw_exec"

      config {
        command = "classlogger"
      }

      resources {
        cpu    = 20
        memory = 15
        disk   = 10
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      env {
        REDIS_ADDR = "redis.service.consul:6379"
        NODE_CLASS = "\$${node.class}"
      }

      service {
        name = "\$${JOB}-\$${TASKGROUP}-classlogger"
      }
    }
  }
}
