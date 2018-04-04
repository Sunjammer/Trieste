package;
import tinyosc.OSC;
import enet.ENet;
import glfw.GLFW.*;
class Main{
    static function main(){
        if(ENet.initialize() != 0){
            throw 'ENet init error';
        }

        var event:ENetEvent = null;
        var eventStatus = 1;

        var adr:ENetAddress = null;
        adr.host = ENet.ENET_HOST_ANY;
        adr.port = 1984;

        var server:ENetHost = ENet.host_create(cast adr, 32, 2, 0, 0);
        if(server == null){
            trace("An error occurred while trying to create an ENet server host.");
            ENet.deinitialize();
            return;
        }

        trace("Server listening on 1984");

        glfwInit();
        var win = glfwCreateWindow(800, 600, "Test", null, null);
        glfwMakeContextCurrent(win);
        while(glfwWindowShouldClose(win) == 0){
            eventStatus = ENet.host_service(server, cast event, 50);
            if (eventStatus > 0) {
                
                var peer = event.peer; 
                var adress = peer.address; 
                var host = adress.host;
                
                switch(event.type) {
                    case ENetEventType.ENET_EVENT_TYPE_CONNECT:

                        trace('Server got a new connection from $host');

                    case ENetEventType.ENET_EVENT_TYPE_RECEIVE:
                        
                        var b = event.packet.getDataBytes();
                        var payload = haxe.Unserializer.run(b.toString());
                        trace("Server received message from "+host+" - "+payload);

                        // broadcast to all connected clients
                        ENet.host_broadcast(server, 0, event.packet);

                    case ENetEventType.ENET_EVENT_TYPE_DISCONNECT:
                        
                        trace('$host disconnected from Server');

                    default:
                }
            }
            glfwPollEvents();
            Sys.sleep(0.016);
        }
    }
}