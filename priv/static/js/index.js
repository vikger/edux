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

function setCookie(cname, cvalue, exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    let expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + encodeURIComponent(cvalue) + ";" + expires + ";path=/";
}

function getCookie(cname) {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for(let i = 0; i <ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return decodeURIComponent(c.substring(name.length, c.length));
        }
    }
    return "";
}

$(document).ready(function(){
    connect();

    var s = document.getElementById("source");
    s.value = getCookie("edux");

    $("#compile").on("click", function(event) {
        var source = $("#source").val();
        setCookie("edux", source, 1);
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
