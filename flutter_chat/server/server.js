
const users = {};
const rooms = {};

const io = require("socket.io")(
	require("http").createServer(
		function() {}
	).listen(80)
);

io.on("connection", io => {
	console.log("\n\nConnection stablished with a client");

	io.on("validate", (inData, inCallBack) => {
		const user = users[inData.userName];
		if (user) {
			if (user.password == inData.password){
				inCallBack({status: "ok"});
			} else {
				inCallBack({status: "fail"});
			}
		} else {
			users[inData.userName] = inData;
			io.broadcast.emit("newUser", users);
			inCallBack({status: "created"});
		}
	});

	// 
	io.on("create", (inData, inCallBack) => {

		if (rooms[inData.roomName]){
			inCallBack({ status: "exists"});
		} else {
			inData.users = {};
			rooms[inData.roomName] = inData;
			io.broadcast.emit("created", rooms);
			inCallBack({ status: "created", room: rooms });
		}
	});

	// list rooms message handler
	io.on("listRooms", (inData, inCallBack) => {
		inCallBack(rooms);
	});

	// list users
	io.on("listUsers", (inData, inCallBack) => {
		inCallBack(users);
	});

	// user join room handler
	io.on("join", (inData, inCallBack) => {
		const room = rooms[inData.roomName];

		if (Object.keys(room.users).length >= rooms.maxPeople){
			inCallBack.status({status: "full"});
		} else {
			room.users[inData.userName] = users[inData.userName];
			io.broadcast.emit("joined", room);
			inCallBack({ status: "joined", room: room});
		}
	});

	// post message handler
	io.on("post", (inData, inCallBack) => {
		io.broadcast.emit("posted", inData);
		inCallBack({status: "ok"});
	});

	// invite user to room handler
	io.on("invite", (inData, inCallBack) => {
		io.broadcast.emit("invited", inData);
		inCallBack({status: "ok"});
	});

	// user leaves room handler
	io.on("leave", (inData, inCallBack) => {

		const room = rooms[inData.roomName];
		delete room.users[inData.userName];
		
		io.broadcast.emit("left", room);
		inCallBack({status: "ok"});
	});

	// close room handler
	io.on("close", (inData, inCallBack) => {
		
		delete rooms[inData.roomName];
		io.broadcast.emit("closed", 
			{ roomName: inData.roomName, rooms: rooms}
		);
		inCallBack(rooms);
	});

	//

});

