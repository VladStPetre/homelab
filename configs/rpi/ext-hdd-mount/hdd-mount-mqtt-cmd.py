import paho.mqtt.client as mqtt
import os
import time
import logging

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
logging.basicConfig(level=logging.INFO)

def wait_for_state(desired, timeout=15):
    for _ in range(timeout):
        if is_mounted("/mnt/media") == desired:
            return True
        time.sleep(1)
    return False

def is_mounted(mount_point):
    with open('/proc/mounts') as f:
        return any(mount_point in line for line in f)

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()

    if topic == "echo/command/vexthddmount":
        if payload == "off":
            os.system("sudo umount /mnt/media")
            wait_for_state(True, timeout=15)
        elif payload == "on":
            os.system("sudo mount /mnt/media")
            wait_for_state(False, timeout=15)

        # Always check and publish ACTUAL status after running the command
        logging.info("received -> echo/command/vexthddmount", payload)

        state = "on" if is_mounted("/mnt/media") else "off"
        client.publish("echo/vexthdd/state", state, retain=True)

        logging.info("published -> echo/vexthdd/state", state)
    else:
        logging.info("hdd-mount-cmd topic is:", topic)


client = mqtt.Client()
client.connect(MQTT_BROKER)
client.subscribe("echo/command/#")
client.on_message = on_message
client.loop_forever()