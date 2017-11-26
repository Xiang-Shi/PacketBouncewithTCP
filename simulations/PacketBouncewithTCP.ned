//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package packetbouncewithtcp.simulations;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.ethernet.Eth1G;
import inet.node.ethernet.EtherSwitch;
import inet.node.inet.StandardHost;


//
// TODO auto-generated type
//
network PacketBouncewithTCP
{
    @display("bgb=647,616");
    submodules:
        server3: StandardHost {
            @display("p=489,135");
        }
        client: StandardHost {
            @display("p=308,527");
        }
        configurator: IPv4NetworkConfigurator {
            @display("p=107,52");
        }
        server1: StandardHost {
            @display("p=150,135");
        }
        server2: StandardHost {
            @display("p=319,113");
        }
        etherSwitch1: EtherSwitch {
            @display("p=177,234");
        }
        etherSwitch2: EtherSwitch {
            @display("p=308,218");
        }
        etherSwitch3: EtherSwitch {
            @display("p=462,218");
        }
        etherSwitch4: EtherSwitch {
            @display("p=189,325");
        }
        etherSwitch5: EtherSwitch {
            @display("p=327,316");
        }
        etherSwitch6: EtherSwitch {
            @display("p=462,316");
        }
        etherSwitch7: EtherSwitch {
            @display("p=308,435");
        }
    connections:

        server1.ethg++ <--> Eth1G <--> etherSwitch1.ethg++;
        server2.ethg++ <--> Eth1G <--> etherSwitch2.ethg++;
        server3.ethg++ <--> Eth1G <--> etherSwitch3.ethg++;
        etherSwitch1.ethg++ <--> Eth1G <--> etherSwitch4.ethg++;
        etherSwitch2.ethg++ <--> Eth1G <--> etherSwitch5.ethg++;
        etherSwitch3.ethg++ <--> Eth1G <--> etherSwitch6.ethg++;
        etherSwitch4.ethg++ <--> Eth1G <--> etherSwitch7.ethg++;
        etherSwitch5.ethg++ <--> Eth1G <--> etherSwitch7.ethg++;
        etherSwitch6.ethg++ <--> Eth1G <--> etherSwitch7.ethg++;
        etherSwitch7.ethg++ <--> Eth1G <--> client.ethg++;
}
