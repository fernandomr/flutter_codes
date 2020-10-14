
const users = {};
const rooms = {};

const io = require("socket.io")(
	require("http").createServer(
		function() {}
	).listen(80)
);

io.on("connection", io => {
	console.log("\n\nConnection stablished with a client");
});