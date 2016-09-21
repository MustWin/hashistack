// This is the address of the Consul agent. By default, this is 127.0.0.1:8500,
// which is the default bind and port for a local Consul agent. It is not
// recommended that you communicate directly with a Consul server, and instead
// communicate with the local Consul agent. There are many reasons for this,
// most importantly the Consul agent is able to multiplex connections to the
// Consul server and reduce the number of open HTTP connections. Additionally,
// it provides a "well-known" IP address for which clients can connect.
consul = "127.0.0.1:8500"

// This is the ACL token to use when connecting to Consul. If you did not
// enable ACLs on your Consul cluster, you do not need to set this option.
//
// This option is also available via the environment variable CONSUL_TOKEN.
// token = "abcd1234"

// This is the signal to listen for to trigger a reload event. The default
// value is shown below. Setting this value to the empty string will cause CT
// to not listen for any reload signals.
//reload_signal = "SIGHUP"

// This is the signal to listen for to trigger a core dump event. The default
// value is shown below. Setting this value to the empty string will cause CT
// to not listen for any core dump signals.
//dump_signal = "SIGQUIT"

// This is the signal to listen for to trigger a graceful stop. The default
// value is shown below. Setting this value to the empty string will cause CT
// to not listen for any graceful stop signals.
//kill_signal = "SIGINT"

// This is the amount of time to wait before retrying a connection to Consul.
// Consul Template is highly fault tolerant, meaning it does not exit in the
// face of failure. Instead, it uses exponential back-off and retry functions to
// wait for the cluster to become available, as is customary in distributed
// systems.
retry = "10s"

// This is the maximum interval to allow "stale" data. By default, only the
// Consul leader will respond to queries; any requests to a follower will
// forward to the leader. In large clusters with many requests, this is not as
// scalable, so this option allows any follower to respond to a query, so long
// as the last-replicated data is within these bounds. Higher values result in
// less cluster load, but are more likely to have outdated data.
max_stale = "10m"

// This is the log level. If you find a bug in Consul Template, please enable
// debug logs so we can help identify the issue. This is also available as a
// command line flag.
log_level = "warn"

// This is the path to store a PID file which will contain the process ID of the
// Consul Template process. This is useful if you plan to send custom signals
// to the process.
pid_file = "/var/run/consul-template.pid"

// This is the quiescence timers; it defines the minimum and maximum amount of
// time to wait for the cluster to reach a consistent state before rendering a
// template. This is useful to enable in systems that have a lot of flapping,
// because it will reduce the the number of times a template is rendered.
wait = "5s:10s"

// This denotes the start of the configuration section for Vault. All values
// contained in this section pertain to Vault.
//vault {
  // This is the address of the Vault leader. The protocol (http(s)) portion
  // of the address is required.
  // address = "https://vault.service.consul:8200"

  // This is the token to use when communicating with the Vault server.
  // Like other tools that integrate with Vault, Consul Template makes the
  // assumption that you provide it with a Vault token; it does not have the
  // incorporated logic to generate tokens via Vault's auth methods.
  //
  // This value can also be specified via the environment variable VAULT_TOKEN.
  // token = "abcd1234"

  // This option tells Consul Template to automatically renew the Vault token
  // given. If you are unfamiliar with Vault's architecture, Vault requires
  // tokens be renewed at some regular interval or they will be revoked. Consul
  // Template will automatically renew the token at half the lease duration of
  // the token. The default value is true, but this option can be disabled if
  // you want to renew the Vault token using an out-of-band process.
  //
  // Note that secrets specified in a template (using {{secret}} for example)
  // are always renewed, even if this option is set to false. This option only
  // applies to the top-level Vault token itself.
  // renew = true

  // This section details the SSL options for connecting to the Vault server.
  // Please see the SSL options below for more information (they are the same).
  // ssl {
    // ...
  // }
// }

// This block specifies the basic authentication information to pass with the
// request. For more information on authentication, please see the Consul
// documentation.
auth {
  enabled  = false
  username = "test"
  password = "test"
}

// This block configures the SSL options for connecting to the Consul server.
ssl {
  // This enables SSL. Specifying any option for SSL will also enable it.
  enabled = false

  // This enables SSL peer verification. The default value is "true", which
  // will check the global CA chain to make sure the given certificates are
  // valid. If you are using a self-signed certificate that you have not added
  // to the CA chain, you may want to disable SSL verification. However, please
  // understand this is a potential security vulnerability.
  verify = false

  // This is the path to the certificate to use to authenticate. If just a
  // certificate is provided, it is assumed to contain both the certificate and
  // the key to convert to an X509 certificate. If both the certificate and
  // key are specified, Consul Template will automatically combine them into an
  // X509 certificate for you.
  cert = "/path/to/client/cert"
  key = "/path/to/client/key"

  // This is the path to the certificate authority to use as a CA. This is
  // useful for self-signed certificates or for organizations using their own
  // internal certificate authority.
  ca_cert = "/path/to/ca"
}

// This block defines the configuration for connecting to a syslog server for
// logging.
syslog {
  // This enables syslog logging. Specifying any other option also enables
  // syslog logging.
  enabled = false

  // This is the name of the syslog facility to log to.
  facility = "LOCAL5"
}

// This block defines the configuration for de-duplication mode. Please see the
// de-duplication mode documentation later in the README for more information
// on how de-duplication mode operates.
deduplicate {
  // This enables de-duplication mode. Specifying any other options also enables
  // de-duplication mode.
  enabled = true

  // This is the prefix to the path in Consul's KV store where de-duplication
  // templates will be pre-rendered and stored.
  prefix = "consul-template/dedup/"
}

// This block defines the configuration for exec mode. Please see the exec mode
// documentation at the bottom of this README for more information on how exec
// mode operates and the caveats of this mode.
//exec {
  // This is the command to exec as a child process. There can be only one
  // command per Consul Template process.
//  command = "/usr/bin/app"

  // This is a random splay to wait before killing the command. The default
  // value is 0 (no wait), but large clusters should consider setting a splay
  // value to prevent all child processes from reloading at the same time when
  // data changes occur. When this value is set to non-zero, Consul Template
  // will wait a random period of time up to the splay value before reloading
  // or killing the child process. This can be used to prevent the thundering
  // herd problem on applications that do not gracefully reload.
//  splay = "5s"

  // This defines the signal that will be sent to the child process when a
  // change occurs in a watched template. The signal will only be sent after
  // the process is started, and the process will only be started after all
  // dependent templates have been rendered at least once. The default value
  // is "" (empty or nil), which tells Consul Template to restart the child
  // process instead of sending it a signal. This is useful for legacy
  // applications or applications that cannot properly reload their
  // configuration without a full reload.
//  reload_signal = "SIGUSR1"

  // This defines the signal sent to the child process when Consul Template is
  // gracefully shutting down. The application should begin a graceful cleanup.
  // If the application does not terminate before the `kill_timeout`, it will
  // be terminated (effectively "kill -9"). The default value is "SIGTERM".
//  kill_signal = "SIGINT"

  // This defines the amount of time to wait for the child process to gracefully
  // terminate when Consul Template exits. After this specified time, the child
  // process will be force-killed (effectively "kill -9"). The default value is
  // "30s".
//  kill_timeout = "2s"
//}

// This block defines the configuration for a template. Unlike other blocks,
// this block may be specified multiple times to configure multiple templates.
// It is also possible to configure templates via the CLI directly.
template {
  // This is the source file on disk to use as the input template. This is often
  // called the "Consul Template template". This option is required.
  source = "/etc/consul-template.d/consul-template.tpl"

  // This is the destination path on disk where the source template will render.
  // If the parent directories do not exist, Consul Template will attempt to
  // create them.
  destination = "/etc/haproxy/haproxy.cfg"

  // This is the optional command to run when the template is rendered. The
  // command will only run if the resulting template changes. The command must
  // return within 30s (configurable), and it must have a successful exit code.
  // Consul Template is not a replacement for a process monitor or init system.
  command = "/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid || '') || true"

  // This is the maximum amount of time to wait for the optional command to
  // return. Default is 30s.
  command_timeout = "60s"

  // This is the permission to render the file. If this option is left
  // unspecified, Consul Template will attempt to match the permissions of the
  // file that already exists at the destination path. If no file exists at that
  // path, the permissions are 0644.
  perms = 0600

  // This option backs up the previously rendered template at the destination
  // path before writing a new one. It keeps exactly one backup. This option is
  // useful for preventing accidental changes to the data without having a
  // rollback strategy.
  backup = true

  // These are the delimiters to use in the template. The default is "{{" and
  // "}}", but for some templates, it may be easier to use a different delimiter
  // that does not conflict with the output file itself.
  left_delimiter  = "{{"
  right_delimiter = "}}"

  // This is the `minimum(:maximum)` to wait before rendering a new template to
  // disk and triggering a command, separated by a colon (`:`). If the optional
  // maximum value is omitted, it is assumed to be 4x the required minimum value.
  // This is a numeric time with a unit suffix ("5s"). There is no default value.
  // The wait value for a template takes precedence over any globally-configured
  // wait.
  wait = "2s:6s"
}
