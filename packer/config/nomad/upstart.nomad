description "Nomad agent"

start on runlevel [2345]
stop on runlevel [!2345]

# Respawn infinitely
respawn limit unlimited

console log

nice -10
limit nofile 65535 65535

pre-start script
  while [ ! -f /etc/nomad.d/configured ]
  do
    DT=$(date '+%Y/%m/%d %H:%M:%S')
    echo "$DT: Waiting on configuration"
    sleep 1
  done
end script

script
  if [ -f "/etc/service/nomad" ]; then
    . /etc/service/nomad
  fi

  exec /usr/local/bin/nomad agent -config="/etc/nomad.d" \$${NOMAD_FLAGS} >>/var/log/nomad.log 2>&1
end script

post-start script
  echo "nomad,$(hostname),$(date '+%s')" | sudo tee -a /home/ubuntu/c1m/spawn/spawn.csv
end script
