import paho.mqtt.client as mqtt
import os

MQTT_BROKER = "$MQTT_BROKER"

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()

    if topic == "pi3/command/display":
        if payload == "off":
            os.system("vcgencmd display_power 0")
            client.publish("pi3/display/state", "off")
        elif payload == "on":
            os.system("vcgencmd display_power 1")
            client.publish("pi3/display/state", "on")

    elif topic == "pi3/command/shutdown":
        os.system("sudo shutdown -h now")

client = mqtt.Client()
client.connect(MQTT_BROKER)
client.subscribe("pi3/command/#")
client.on_message = on_message
client.loop_forever()