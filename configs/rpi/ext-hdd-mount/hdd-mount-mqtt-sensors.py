import psutil, os, time, json
import paho.mqtt.client as mqtt

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
BASE_TOPIC = 'homeassistant/sensor/echo'

print("connecting to broker - ", MQTT_BROKER)
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

def is_mounted(mount_point):
    with open('/proc/mounts') as f:
        return any(mount_point in line for line in f)

state = "on" if is_mounted("/mnt/media") else "off"
client.publish("echo/vexthdd/state", state, retain=True)

while True:
    state = "on" if is_mounted("/mnt/media") else "off"
    client.publish("echo/vexthdd/state", state, retain=True)
    time.sleep(60)