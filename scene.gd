extends Node
var clientID = null
var websocket = preload('websocket.gd').new()

func _getMsg(data):
	print(data)
	if 'clientID' in data:
		clientID = data.clientID
		var jsObj = {
			"clientID":clientID
		}
		websocket.send(jsObj.to_json())

func _ready():
	websocket.start('localhost',8080)
	websocket.reciever.connect('msg_recieved',self,'_getMsg')
	
func _on_Button_pressed():
	var jsObj = {
		"clientID":clientID,
		"unit":{
			"cards":[
				{
					"type":"Dragon",
					"name":"trogdore"
				},
				{
					"type":"Dragon",
					"name":"trogdore"
				}
			]
		}
		
	}
	
	websocket.send(jsObj.to_json())