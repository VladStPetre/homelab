import psutil, os, time, json
import paho.mqtt.client as mqtt
import logging

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

logging.info("connecting to broker - %s", MQTT_BROKER)
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

client.publish("homeassistant/switch/echo/nfsnas/config", json.dumps({
    "name": "Echo nfsnas",
    "command_topic": "echo/command/nfsnasmount",
    "payload_on": "on",
    "payload_off": "off",
    "state_topic": "echo/nfsnas/state",
    "unique_id": "echo_nfsnasmount_control",
    "device": DEVICE
}), retain=True)

def is_mounted(mount_point):
    with open('/proc/mounts') as f:
        return any(mount_point in line for line in f)

def publish_state(mount_point, topic):
    state = "on" if is_mounted(mount_point) else "off"
    client.publish(topic, state, retain=True)
    logging.info("published -> {} -> %s".format(topic), state)

mnt_nas = "/mnt/nas"
mnt_media = "/mnt/media"

vexthdd_topic = "echo/vexthdd/state"
nfsnas_topic = "echo/nfsnas/state"

publish_state(mnt_media, vexthdd_topic)
publish_state(mnt_nas, nfsnas_topic)

while True:
    publish_state(mnt_media, vexthdd_topic)
    publish_state(mnt_nas, nfsnas_topic)

    time.sleep(60)