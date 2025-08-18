import paho.mqtt.client as mqtt
import os

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
RPI_HOST="rpi_" + os.uname()[1]

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()

    if topic == "{BASE_TOPIC}/command/display":
        if payload == "off":
            os.system("vcgencmd display_power 0")
            client.publish("{BASE_TOPIC}/display/state", "off")
        elif payload == "on":
            os.system("vcgencmd display_power 1")
            client.publish("{BASE_TOPIC}/display/state", "on")

    elif topic == "{BASE_TOPIC}/command/shutdown":
        os.system("sudo shutdown -h now")

client = mqtt.Client()
client.connect(MQTT_BROKER)
client.subscribe("{BASE_TOPIC}/command/#")
client.on_message = on_message
client.loop_forever()