import paho.mqtt.client as mqtt
import os
import time
import logging

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

def wait_for_state(mount_point, desired, timeout=15):
    for _ in range(timeout):
        if is_mounted(mount_point) == desired:
            return True
        time.sleep(1)
    return False


def is_mounted(mount_point):
    with open('/proc/mounts') as f:
        return any(mount_point in line for line in f)


def handle_mnt_point(mount_point, cmd_topic, payload, client, sensor_topic):

    if payload == "off":
        os.system("sudo umount {}".format(mount_point))
        wait_for_state(mount_point,True, timeout=15)
    elif payload == "on":
        os.system("sudo mount {}".format(mount_point))
        wait_for_state(mount_point, False, timeout=15)

        # Always check and publish ACTUAL status after running the command
    logging.info("mqtt-cmd :: received -> {} -> %s".format(cmd_topic), payload)

    state = "on" if is_mounted(mount_point) else "off"
    client.publish(sensor_topic, state, retain=True)

    logging.info("mqtt-cmd :: published -> {} -> %s".format(sensor_topic), state)


def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()

    mnt_nas = "/mnt/nas"
    mnt_media = "/mnt/media"

    vexthdd_topic = "echo/vexthdd/state"
    nfsnas_topic = "echo/nfsnas/state"

    if topic == "echo/command/vexthddmount":
        handle_mnt_point(mnt_media, topic, payload, client, vexthdd_topic)
    elif topic == "echo/command/nfsnasmount":
        handle_mnt_point(mnt_nas, topic, payload, client, nfsnas_topic)
    elif topic == "echo/command/naswol":
        os.system("wakeonlan -i 192.168.7.255 -p 9 24:5E:BE:48:32:E1")
        logging.info("mqtt-cmd :: sent magic packet -> %s", topic)
    else:
        logging.info("mqtt-cmd :: topic is -> %s", topic)


client = mqtt.Client()
client.connect(MQTT_BROKER)
client.subscribe("echo/command/#")
client.on_message = on_message
client.loop_forever()