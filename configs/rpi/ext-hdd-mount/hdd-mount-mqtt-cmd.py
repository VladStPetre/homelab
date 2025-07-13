import paho.mqtt.client as mqtt
import os

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()

    if topic == "echo/command/vexthddmount":
        if payload == "off":
            os.system("umount /mnt/media")
            client.publish("echo/vexthdd/state", "off")
        elif payload == "on":
            os.system("mount /mnt/media")
            client.publish("echo/vexthdd/state", "on")

client = mqtt.Client()
client.connect(MQTT_BROKER)
client.subscribe("echo/command/#")
client.on_message = on_message
client.loop_forever()