import psutil, os, time, json
import paho.mqtt.client as mqtt
import logging
import subprocess

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

def is_mounted(unit_name, timeout=3):
    try:
        r = subprocess.run(
            ["systemctl", "is-active", "--quiet", unit_name],
            timeout=timeout
        )
        return r.returncode == 0
    except subprocess.TimeoutExpired:
        return False

def publish_state(mount_svc, topic):
    state = "on" if is_mounted(mount_svc, 5) else "off"
    client.publish(topic, state, retain=True)
    logging.info("mqtt-sensors :: published -> %s -> %s", topic, state)

mnt_svc_nas = "mnt-nas.mount"
mnt_svc_media = "mnt-media.mount"

vexthdd_topic = "echo/vexthdd/state"
nfsnas_topic = "echo/nfsnas/state"

publish_state(mnt_svc_media, vexthdd_topic)
publish_state(mnt_svc_nas, nfsnas_topic)

while True:
    publish_state(mnt_svc_media, vexthdd_topic)
    publish_state(mnt_svc_nas, nfsnas_topic)

    time.sleep(60)