# Overview

This is a k3s single-node kubernetes cluster installed and configured by ansible. Infrastructure provisioning is performed by terraform. Grafana, Prometheus and Kafka are installed and configured using helm (as limited as possible, only required features are there). I am using official repos for Prometheus and Grafana, and bitnami for Kafka. A couple of pods running custom built docker images (running Ruby scripts (that you can find inside *./docker/*) in a bucle) act as producer and consumer. Grafana and prometheus are published using Load Balancers. Vagrant is creating a port forward to each of these ports.

# Deployment


## Requirements

* Vagrant
* VirtualBox
* Patience

## Deploy

Vagrant will create the vm and install basic packages for Ansible to be able to run. Ansible will configure the infra and run terraform at the end to provision workloads (this is the last task).

```
vagrant up
```

## Usage

##### Grafana

URL: http://127.0.0.1:3000
Username: evolution
Password: evolution

yep...really safe

Two dashboards are available, one is monitoring kafka server and the other one the topics.

##### Prometheus

(just in case you want to take a look)

URL: http://127.0.0.1:9090

##### Kubectl config file

Inside the guest OS under `/etc/rancher/k3s/k3s.yaml`

Just connect to the node using `vagrant ssh` and use kubectl (as root) and you are good to go.

##### Manually monitor kafka topics

Launch a shell inside kafka-0 pod.

If you run directly *kafka-console-consumer.sh* script, you will get a fancy error saying that port is in use. Right now I think this is a bitnami issue because they have another process running and using that port, but might not be an issue and just the expected behaviour. Just change the port before interacting with provided scrits:

```
export JMX_PORT=5557
kafka-console-consumer.sh --topic input --from-beginning --bootstrap-server kafka-headless:9092
```

# FAQ

###### Why ruby?

My python is kind of rusty.

###### Why k3s?

Small, fast, comes packed with everything I need.

###### Why Terraform?

no reason....for my liking :)

###### Why Load Balancers?

Basically they are acting as node port, not that much of a difference. And since klipper comes with k3s then...why not?

###### Why is this documentation a mess?

It's 1 am!

###### You lied to me. I can not see a single workload in kubernetes

Perhaps you already had a terraform state file, so terraform never ran. Just check if the last ansible task (Provision Infra) ran i(CHANGED) or just returned OK. If returned OK, you already have a terraform state file. Delete *./terraform/terraform.tfstate* and run `vagrant provision`.

###### Nope, this is not working at all

I ran this several times and was no able to see issues. Also relaxed timeouts just in case (slow connections, etc), still, if something went wrong, send me an email to sergiojvg92@gmail.com.






