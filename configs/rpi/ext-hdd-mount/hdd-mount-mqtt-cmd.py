import paho.mqtt.client as mqtt
import os

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')

def is_mounted(mount_point):
    with open('/proc/mounts') as f:
        return any(mount_point in line for line in f)

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()

    if topic == "echo/command/vexthddmount":
        if payload == "off":
            os.system("sudo umount /mnt/media")
        elif payload == "on":
            os.system("sudo mount /mnt/media")

        # Always check and publish ACTUAL status after running the command
        state = "on" if is_mounted("/mnt/media") else "off"
        client.publish("echo/vexthdd/state", state, retain=True)

print("connecting to broker - ", MQTT_BROKER)
client = mqtt.Client()
client.connect(MQTT_BROKER)
client.subscribe("echo/command/#")
client.on_message = on_message
client.loop_forever()