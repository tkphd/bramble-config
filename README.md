```
      .                               .      .;
    .'                              .'      .;'
   ;-.    .;.::..-.    . ,';.,';.  ;-.     .;  .-.
  ;   ;   .;   ;   :   ;;  ;;  ;; ;   ;   :: .;.-'
.'`::'`-.;'    `:::'-'';  ;;  ';.'`::'`-_;;_.-`:::'
                     _;        `-'
```

Configuration files to generate a [bramble][brm], or
cluster of [Raspberry Pi 3][rpi] single-board computers
running [Raspbian][rsp] and managed using [Ansible][ans].

## *Caveat Emptor*

Each computer in the bramble has a 4-core [CPU][cpu] at
1.2 GHz, 1 GB RAM, a micro SD slot for boot media, four
USB 2.0 ports, 100 Mbit Ethernet, and WiFi. Creating a
cluster is instructive and useful for IT infrastructure
testing, especially [queuing system][slr], [file system][zfs],
and [container][sin] research.

It is ***not*** intended to perform useful computational tasks.
There are [better][mms] [tools][hpc] for that.

## Layout

The files contained in this repository will be most useful to you
if your bramble contains at least three [nodes][nod], for example:

####  `head`
The primary point of contact between your Bramble and the outside
network, this node serves administrative duties, only. Configured
with an 8 GB microSD card and 16 GB USB stick.

#### `data`
The primary point of contact for network data stores, this node
serves data and database duties, only. Configured with an 8 GB
microSD card and 64 GB USB stick.

#### `r1n1`
The first node (`n1`) on the first rack (`r1`) serves computational
duties, as well as light data service for other nodes on its rack
when a distributed filesystem (*e.g.*, [Lustre][lst]) is installed.
Configured with an 8 GB microSD card and 16 GB USB stick.

#### `r1nX`
The balance of nodes on the first rack (`r1`) serve computational duty,
only. Configured with an 8 GB microSD card and 16 GB USB stick.

### Interconnect
To reduce latency, the nodes have wired Ethernet connections to a Gigabit
switch. This switch is not connected to a DHCP server, so static IP
addresses are assigned on `192.168.3.100/24`. The translation from name
to IP is `100 + 10*rack + node`. So, for example, `r1n1` is `192.168.3.111`,
`r1n4` is `192.168.3.114`; `head`, or `r0n1`, is `192.168.3.101`, and
`data` is `192.168.3.102`. For convenience, and software updates, WiFi
is also enabled on all nodes. A more representative configuration for
a HPC cluster would funnel traffic through `head`, or a router at
`192.168.3.1`, but this introduces unnecessary complications to the setup.
This is, after all, meant to be fun :-)

[![Public Domain](https://i.creativecommons.org/p/mark/1.0/80x15.png)][cc0]

[ans]: https://www.ansible.com/
[brm]: https://www.jeffgeerling.com/blog/2015/how-build-your-own-raspberry-pi-cluster-bramble
[cc0]: https://creativecommons.org/publicdomain/zero/1.0/
[cpu]: https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2837/README.md
[hpc]: https://github.com/usnistgov/hiperc
[lst]: http://lustre.org/
[mms]: https://github.com/mesoscale/mmsp
[nod]: https://www.cise.ufl.edu/research/ParallelPatterns/glossary.htm#glossary:node
[rpi]: https://www.raspberrypi.org/products/raspberry-pi-3-model-b/
[rsp]: https://raspbian.org/
[sin]: http://singularity.lbl.gov/
[slr]: https://slurm.schedmd.com/
[zfs]: http://zfsonlinux.org/
