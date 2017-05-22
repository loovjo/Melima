let http = require("http")
let fs = require("fs")
let url = require("url")
let timers = require("timers")

let ws = require("ws")


state = {
    players: []
}

var server = http.createServer((req, res) => {
    method = req.method
    url = url.parse(req.url)
    ip  = req.connection.remoteAddress

    if (method === "GET") {
        filePath = "Web" + url.pathname

        if (fs.existsSync(filePath)) {
            if (!fs.lstatSync(filePath).isFile()) {
                filePath = "Web/main.html"
            }
            content = fs.readFileSync(filePath)
            res.setHeader("Content-Type", "text/html")
            res.end(content)
        } else {
            res.end("NOEXIST!")
        }
    }
})
server.listen(8000)


var wss = new ws.Server({server: server})


var broadcast = timers.setInterval(() => {

    wss.clients.forEach(client => {
        if (client.readyState === ws.OPEN) {
            ip = client._socket.remoteAddress || client.upgradeReq.connection.remoteAddress

            clientState = {gameState: state, you: {ip: ip}}
            client.send(JSON.stringify(clientState))
        }
    })
}, 100)

wss.on('connection', (socket => {

    socket.on('message', (data, flags) => {
        ip = socket._socket.remoteAddress || socket.upgradeReq.connection.remoteAddress
    })
}))