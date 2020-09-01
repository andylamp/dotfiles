# Power monitor using Grafana and TP-Link HS110 Plugs

This project came to be as I wanted to monitor my appliance power consumption over time; however, this supposedly
easy task was harder than I thought as, until fairly recently, there were no *affordable* reliable high current power 
plugs that I could buy. Thankfully, I discovered [TP-Link HS110][3] which were a match made in heaven as their protocol 
was reverse engineered meaning I could use mature, open source tools to do the monitoring. To that end, I elected to 
use [Grafana][1] which is a nifty little tool that can be used to monitor various signals that come out of your 
infrastructure - in my use case, power consumption. 

The steps to do this are the following:

 1. Setup [Grafana][1], [Prometheus][2], and [tp-link exporter][4] as a docker services.
 3. Install a Grafana dashboard which ingests and displays the required metrics.
 4. (Optionally) Configure `ufw` to allow access from the local network.

**Note**: This became something a bit larger than a note and the project is located (as a `git` submodule) [here][5] 
under the folder `grafana-tp-link`, which I cannot link as a relative link due to a Github 
limitation :) - please check it out!

[1]: https://grafana.com/
[2]: https://prometheus.io/
[3]: https://www.tp-link.com/gr/home-networking/smart-plug/hs110/
[4]: https://github.com/fffonion/tplink-plug-exporter
[5]: ../utils