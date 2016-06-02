	extends StreamPeerTCP

const USER_AGENT = "Godot-client"

var thread = Thread.new()
var host = '127.0.0.1'
var port = 8080
var TIMEOUT = 30
var error = ''
var messages = []
var reciever = Node.new()

func _run(_self):
	###
	# Handshake
	###
	var tm = 0.0
	
	# connect
	while true:
		if get_status()==STATUS_ERROR:
			error = 'Connection fail'
			return
		if get_status()==STATUS_CONNECTED:
			break
		tm += 0.1
		if tm>TIMEOUT:
			error = 'Connection timeout'
			return
		OS.delay_msec(100)
	
	var _host = self.host
	if self.port != 80:
		_host += ':' + str(self.port)
	var header = ''
	var data = ''
	
	header  = "GET ws://"+_host+"/ HTTP/1.1\r\n"
	header += "Host: "+_host+"\r\n"
	header += "Connection: Upgrade\r\n"
	header += "Pragma: no-cache\r\n"
	header += "Cache-Control: no-cache\r\n"
	header += "Upgrade: websocket\r\n"
	header += "Sec-WebSocket-Version: 13\r\n"
	header += "User-Agent: "+USER_AGENT+"\r\n"
	header += "Accept-Encoding: gzip, deflate, sdch\r\n"
	header += "Accept-Language: "+str(OS.get_locale())+";q=0.8,en-US;q=0.6,en;q=0.4\r\n"
	header += "Sec-WebSocket-Key: 6Aw8vTgcG5EvXdQywVvbh_3fMxvd4Q7dcL2caAHAFjV\r\n"
	header += "Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits\r\n"
	header += "\r\n"
	
	if OK!=put_data( header.to_ascii() ):
		print('something went wrong with the handshake')
		return

	data = ''
	tm = 0.0
	var start_read = false
	while true:
		if get_available_bytes()>0 and not start_read:
			data += get_string(get_available_bytes())
			start_read = true
		elif get_available_bytes()==0 and start_read:
			break
		
		OS.delay_msec(100)
		tm += 0.1
		if tm>TIMEOUT:
			print('timeout')
			return


	var connection_ok = false
	for lin in data.split("\n"):
		if lin.find("HTTP/1.1 101")>-1:
			connection_ok = true
	if not connection_ok:
		print(data)
		return
	
	data = ''
	while is_connected():

		if get_available_bytes() > 0:
			print(get_available_bytes())
			var byte = get_8()
			var fin = byte & 0x80
			var opcode = byte & 0x0F
			byte = get_8()
			var mskd = byte & 0x80
			var payload = byte & 0x7F
			
			var st = RawArray()
			for i in range(get_available_bytes()):
				st.push_back(get_u8())
			#print(get_data(get_available_bytes())[1].get_string_from_ascii())
			#print(get_data()[1].get_string_from_ascii())
			receive(st.get_string_from_ascii())
			
		# message to send?
		while messages.size() > 0:
			var msg = messages[0]
			messages.pop_front()
			
			# mount frame
			var byte = 0x80 # fin
			byte = byte | 0x01 # text frame
			put_8(byte)
			# no mask
			byte = msg.length() # payload size
			put_u8(byte)
			for i in range(msg.length()):
				put_u8(msg.ord_at(i))
			#put_u8(msg)
	
func send(msg):
	messages.append(msg)

func receive(msg):
	var d = Dictionary()
	d.parse_json(msg)
	reciever.emit_signal('msg_recieved',d)


func start(host,port):
	reciever.add_user_signal('msg_recieved')
	self.host = host
	self.port = port
	set_big_endian(true)
	if OK==connect(IP.resolve_hostname(host),port):
		thread.start(self,'_run', self)
	else:
		print('no')


