var ws;

function send(message) {
    console.log("send: ", message);
    ws.send(JSON.stringify(message));
};

function connect() {
    const hostname = document.location.href.split("/", 3)[2];
    if (ws) {
        ws.close();
    }
    var schema = (location.href.split(":")[0] == "https") ? "wss" : "ws";
    ws = new WebSocket(schema + "://" + hostname + "/ws");
    console.log(ws)
    ws.onopen = function(){
//        send({type: "ping"})
    }

    ws.onmessage = function(message){
        console.log("message", message.data);
        const shell = document.getElementById("shell");
        shell.value += message.data;
        shell.scrollTop = shell.scrollHeight;
    }
}


$(document).ready(function(){
    connect();
    $("#compile").on("click", function(event) {
        var source = $("#source").val();
        send({type: "compile", source: source});
    });

    $("#run").on("click", function(event) {
        var command = $("#command").val();
        const shell = document.getElementById("shell");
        shell.value += $("#command").val() + "\n";
        send({type: "run", command: command});
    });

    var command = document.getElementById("command");
    command.addEventListener("keypress", function(event) {
        if (event.key === "Enter") {
            event.preventDefault();
            document.getElementById("run").click();
        }
    });
});
