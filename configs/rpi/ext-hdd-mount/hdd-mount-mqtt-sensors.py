import psutil, os, time, json
import paho.mqtt.client as mqtt

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
BASE_TOPIC = 'homeassistant/sensor/echo'
client = mqtt.Client()
client.connect(MQTT_BROKER)

DEVICE = {
    "identifiers": ["echo-G3"],
    "name": "Echo host",
    "manufacturer": "GMKTec",
    "model": "G3 plus"
}

client.publish("homeassistant/switch/echo/vexthdd/config", json.dumps({
    "name": "Echo vexthdd",
    "command_topic": "echo/command/vexthddmount",
    "payload_on": "on",
    "payload_off": "off",
    "state_topic": "echo/vexthdd/state",
    "unique_id": "echo_vexthddmount_control",
    "device": DEVICE
}), retain=True)
