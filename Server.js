let spawn = require("child_process").spawn

ok = true

make = spawn("python3", ["Make.py"], {cwd: "Elm"})
make.stdout.on("data", data => process.stdout.write(data.toString("utf-8")))
make.stderr.on("data", data => {
	console.log(data.toString("utf-8"))
	ok = false
})

console.log("Compiling...")

make.on("close", code => {
	if (code == 0 && ok)
		startEverything()
})


function startEverything() {
	process.stdout.write("\033[2J\033[0;0H")

	let http = require("http")
	let fs = require("fs")
	let url = require("url")
	let timers = require("timers")

	let ws = require("ws")

	let Elm = require("./Back/Server.js")

	elmServer = Elm.Server.worker()

	// Set up Elm ports
	elmServer.ports.wsSend.subscribe(data => {
		console.log("Sendning %s", JSON.stringify(data))
		msg = data[0]

		id = data[1]
		client = getClient(id)

		if (client !== undefined && client.readyState === ws.OPEN) {
			client.send(msg)
		}
	})

	CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-+*"

	function generateId(length) {
		res = ""
		for (var i = 0; i < length; i++) {
			res += CHARS[Math.random() * CHARS.length | 0]
		}
		if (getClient(res) !== undefined) {
			return generateId(length)
		}
		return res
	}

	p_clients = [] // {ip : String, id : String}

	function getIpFromP(id) {
		p_client = p_clients.filter(client => client.id === id)
		if (p_client.length === 0)
			return undefined
		return p_client[0].ip
	}

	function getClient(id) {
		ip = getIpFromP(id)
		if (ip === undefined)
			return ip

		client = [...wss.clients].filter(client => getIp(client) === ip)
		return client[0]
	}

	function getIp(client) {
		return client._socket.remoteAddress || client.upgradeReq.connection.remoteAddress
	}

	var server = http.createServer((req, res) => {
		method = req.method
		url = url.parse(req.url)
		ip = req.connection.remoteAddress

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
	console.log("Started server")


	var wss = new ws.Server({server: server})


	wss.on('connection', (socket => {

		id = generateId(20)
		p_clients.push({ip: getIp(socket), id: id})
		elmServer.ports.clientConnection.send(id)

		socket.on('message', (data, flags) => {
		})
	}))
}
