# TODOs

## Networking

- [x] understand VPC, make ecs ec2 instances accesible via ssh over bastion
- [x] probe other instance for whether connection is possible withing private network
- [x] run elixir container with some open ports and try and connect to other instances with elixir running
- [ ] do the above without epmd

## Discovery

- [x] ~~setup discovery with libcluster and cloud map once network connection is verified~~

using this for now:

```elixir
:inet_res.lookup('ecs-test.megapool.local', :in, :srv)
# TODO use inet_res records
|> Enum.map(fn {_, _, _, a} -> :inet_res.lookup(a, :in, :a) end)
|> Enum.map(fn ip -> {ip, Node.connect(:"e@#{:inet.ntoa(ip)}")} end)
```

- [x] cloud map doesn't work cross-region, so another approach for service discovery needs to be used, like ec2 instance tags

```elixir
import SweetXml, only: [sigil_x: 2]

# adapted from https://github.com/kyleaa/libcluster_ec2/blob/master/lib/strategy/tags.ex to work cross-region
regions = ["eu-north-1", "ap-southeast-1"]
tags = [{_name = "env", _value = "test"}, {"cluster", "megapool"}]
# maybe use vpc-id as well
params = [filters: [{"tag:Name", "megapool"}, {"instance-state-name", "running"}]]
request = ExAws.EC2.describe_instances(params)

regions
|> Enum map(fn region ->
  {:ok, %{body: body}} = ExAws.request(request, region: region)

  SweetXml.xpath(body, ~x"//DescribeInstancesResponse/reservationSet/item/instancesSet/item/privateIpAddress/text()"ls)
  |> Enum.uniq()
  |> Enum.map(fn ip -> :"e@#{ip}" end)
end)
|> List.flatten()
```

- [ ] try keeping dns approach but register and deregister with route53 "manually"
- [ ] try epmdless dist
- [ ] try multicast gossip https://github.com/bitwalker/libcluster/blob/master/lib/strategy/gossip.ex

## Benchmark communication (inner region)

- [x] estimate throughput between erlang nodes over erl_dist (it's good enough)

```elixir
defmodule G do
  use GenServer
  def init(_opts), do: {:ok, _state = nil}
  def handle_info(_message, state), do: {:noreply, state}
end

iex(e@10.0.1.171)2> GenServer.start_link(G, _opts = [], name: G)
```

```elixir
iex(e@10.0.2.211)7> :timer.tc(fn -> Enum.each(1..130000, fn _ -> send({G, :"e@10.0.1.171"}, {:ok, :asdfasdf, %{"some" => "info"}}) end) end)
{1005197, :ok}
```

ping between two hosts (different AZs) was ~1ms, instances were t4g.micro (2 arm64 vcpu, 1 gb mem)

```
[ec2-user@ip-10-0-2-211 ~]$ ping 10.0.1.171

PING 10.0.1.171 (10.0.1.171) 56(84) bytes of data.
64 bytes from 10.0.1.171: icmp_seq=1 ttl=255 time=1.10 ms
64 bytes from 10.0.1.171: icmp_seq=2 ttl=255 time=1.09 ms
64 bytes from 10.0.1.171: icmp_seq=3 ttl=255 time=1.09 ms
64 bytes from 10.0.1.171: icmp_seq=4 ttl=255 time=1.09 ms
64 bytes from 10.0.1.171: icmp_seq=5 ttl=255 time=1.09 ms
^C
--- 10.0.1.171 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4004ms
rtt min/avg/max/mdev = 1.091/1.094/1.105/0.042 ms
```

and with pubsub

```elixir
iex(e@10.0.2.211)7> Phoenix.PubSub.subscribe(E.PubSub, "topic")
:ok
```

```elixir
iex(e@10.0.1.171)9> Phoenix.PubSub.broadcast(E.PubSub, "topic", "pubsub message")
:ok

iex(e@10.0.1.171)10> :timer.tc(fn -> Phoenix.PubSub.broadcast(E.PubSub, "topic", "pubsub message") end)
{23, :ok}

iex(e@10.0.1.171)11> :timer.tc(fn -> Enum.each(1..1000, fn _ -> Phoenix.PubSub.broadcast(E.PubSub, "topic", "pubsub message") end) end)
{9209, :ok}

iex(e@10.0.1.171)12> :timer.tc(fn -> Enum.each(1..100000, fn _ -> Phoenix.PubSub.broadcast(E.PubSub, "topic", "pubsub message") end) end)
{835025, :ok}
```

- [ ] compare with plain tcp connection sending `:erlang.term_to_iovec`

## Load Balancer, TLS termination

- [x] add lb

```
wrk -t 16 -c 800 -d 10 http://megapool-750333977.eu-north-1.elb.amazonaws.com/health
Running 10s test @ http://megapool-750333977.eu-north-1.elb.amazonaws.com/health
  16 threads and 800 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    64.20ms   25.42ms 221.57ms   79.14%
    Req/Sec   794.29    187.73     1.07k    84.45%
  125681 requests in 10.06s, 38.23MB read
Requests/sec:  12492.70
Transfer/sec:      3.80MB
```

- [x] add TLS cert to AWS, use in ALB (certs are requested manually for now)
- [x] setup route 53 dns (done manually)

## Spot Fleet

- [ ] use EC2 Fleet or Spot Fleet
- [ ] check if draining starts correctly (got notification -> leave lb, cluster, don't accept jobs etc.)

## Cross-region VPC peering

- [x] add eu-north-1 <-> ap-southeast-1 peering, add Singapore cluster, do the benchmark above again cross-region

ping between eu-north-1a and ap-southeast-1c is `~176ms`

```
[ec2-user@ip-10-0-1-92 ~]$ ping 10.1.3.99

PING 10.1.3.99 (10.1.3.99) 56(84) bytes of data.
64 bytes from 10.1.3.99: icmp_seq=1 ttl=255 time=176 ms
64 bytes from 10.1.3.99: icmp_seq=2 ttl=255 time=176 ms
64 bytes from 10.1.3.99: icmp_seq=3 ttl=255 time=176 ms
64 bytes from 10.1.3.99: icmp_seq=4 ttl=255 time=176 ms
64 bytes from 10.1.3.99: icmp_seq=5 ttl=255 time=176 ms
64 bytes from 10.1.3.99: icmp_seq=6 ttl=255 time=176 ms
64 bytes from 10.1.3.99: icmp_seq=7 ttl=255 time=176 ms
^C
--- 10.1.3.99 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6007ms
rtt min/avg/max/mdev = 176.910/176.932/176.948/0.550 ms
```

ping between eu-north-1a and ap-southeast-1b is `~175ms`

```
[ec2-user@ip-10-0-1-92 ~]$ ping 10.1.2.233
PING 10.1.2.233 (10.1.2.233) 56(84) bytes of data.
64 bytes from 10.1.2.233: icmp_seq=1 ttl=255 time=175 ms
64 bytes from 10.1.2.233: icmp_seq=2 ttl=255 time=175 ms
64 bytes from 10.1.2.233: icmp_seq=3 ttl=255 time=175 ms
64 bytes from 10.1.2.233: icmp_seq=4 ttl=255 time=175 ms
64 bytes from 10.1.2.233: icmp_seq=5 ttl=255 time=175 ms
64 bytes from 10.1.2.233: icmp_seq=6 ttl=255 time=175 ms
64 bytes from 10.1.2.233: icmp_seq=7 ttl=255 time=175 ms
^C
--- 10.1.2.233 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6003ms
rtt min/avg/max/mdev = 175.658/175.671/175.699/0.548 ms
```

pubsub benchmark shows almost 2x cut in performance, probably because there are 2x number of nodes

```elixir
iex(e@10.0.1.92)1> Phoenix.PubSub.subscribe(E.PubSub, "topic")
:ok

iex(e@10.0.1.92)4> :erpc.call(:"e@10.1.3.99", fn -> :timer.tc(fn -> Enum.each(1..100000, fn _ -> Phoenix.PubSub.broadcast(E.PubSub, "topic", "pubsub message") end) end) end)
{2320957, :ok}
```

- [x] setup route 53 latency/geolocation dns

## Seamless deployment

- [x] run wrk and check how many requests are dropped during container update to verify seamless deployment with autoscaling group behind ALB
- [ ] speed up deployment (draining takes too long, speed up health checks as well)

## Auto-scaling CloudWatch alarms

- [ ] when can't place a container due to all memory reserved
- [ ] when cpu/memory gets above ~80%

## Misc

- [x] try node draining
- [x] try non healthy_count=0 deployment strategy (need to be able to avoid hitting eaddrinuse)
- [x] maybe use DAEMON deployment mode
- [ ] use soft memory limits on main app container
- [ ] allocate imgproxy in the same task?
- [x] alb stickiness by user id / header / something?
- [ ] https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#deployment_circuit_breaker?
- [ ] is Node.connect transitive?
- [ ] fly-like rpc
- [ ] db setup, with replica
- [ ] vpc peering into db vpc
- [ ] try benching and erlang-25 (should have arm jit support, but does musl support jit?)
- [ ] maybe use public subnet to avoid nat gateway, security groups would still forbid wan connections
- [ ] remove info logs from endpoint
- [ ] prettify console on ecs instances (like ubuntu default)
- [ ] fix remote iex problems on amazon linux

## Cleanup

- [ ] cleanup terraform files, maybe split into modules

## Docs

1. Include info on resources that have been created manually:

   - TLS cert request (todo: automate)
   - route53 (todo: automate)
   - primary db (todo: moved to terraform as well)

1. Explain how to create staging/bench/dev resources (possibly per branch/PR) with terraform

useful links:

- https://github.com/arminc/terraform-ecs
- https://github.com/cloudposse/terraform-aws-ecs-alb-service-task/blob/master/main.tf
