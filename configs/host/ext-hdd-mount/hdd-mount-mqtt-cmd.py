import paho.mqtt.client as mqtt
import subprocess
import os
import time
import logging

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")


def is_mounted(unit_name, timeout=3):
    try:
        r = subprocess.run(
            ["systemctl", "is-active", "--quiet", unit_name],
            timeout=timeout
        )
        return r.returncode == 0
    except subprocess.TimeoutExpired:
        return False


def handle_mnt_point(mount_point, mount_svc, cmd_topic, payload, client, sensor_topic):

    logging.info("mqtt-cmd :: received -> %s -> %s", cmd_topic, payload)

    if payload == "off":
        logging.info("mqtt-cmd :: unmounting -> %s", mount_point)

        r = subprocess.run(
            ["sudo", "systemctl", "stop", mount_svc],
            capture_output=True,
            text=True,
            timeout=5
        )

        if r.returncode != 0:
            logging.info("mqtt-cmd ::Unmounting failed -> %s", r.stderr)

    elif payload == "on":
        logging.info("mqtt-cmd :: mounting -> %s", mount_point)

        r = subprocess.run(
            ["ls",  mount_point],
            capture_output=True,
            text=True,
            timeout=5
        )

        if r.returncode != 0:
            logging.info("mqtt-cmd :: Mounting failed -> %s", r.stderr)

    # Always check and publish ACTUAL status after running the command
    state = "on" if is_mounted(mount_svc) else "off"
    client.publish(sensor_topic, state, retain=True)

    logging.info("mqtt-cmd :: published -> %s -> %s", sensor_topic, state)

def handle_backrest_scale(payload):
    scale = 0 if payload == "down" else 1

    logging.info("mqtt-cmd :: backrest scaling to -> %s", scale)

    r = subprocess.run(
        ["docker", "service", "scale", "backup_backrest={}".format(scale)],
        capture_output=True,
        text=True,
        timeout=15
    )

    if r.returncode == 0:
        logging.info("mqtt-cmd :: backrest scaled to -> %s", scale)
    else:
        logging.info("mqtt-cmd :: backrest scaling failed -> %s", r.stderr)

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()

    mnt_nas = "/mnt/nas"
    mnt_media = "/mnt/media"
    mnt_svc_nas = "mnt-nas.mount"
    mnt_svc_media = "mnt-media.mount"

    vexthdd_topic = "echo/vexthdd/state"
    nfsnas_topic = "echo/nfsnas/state"

    if topic == "echo/command/vexthddmount":
        handle_mnt_point(mnt_media, mnt_svc_media, topic, payload, client, vexthdd_topic)

    elif topic == "echo/command/nfsnasmount":
        handle_mnt_point(mnt_nas, mnt_svc_nas, topic, payload, client, nfsnas_topic)

    elif topic == "echo/command/naswol":
        logging.info("mqtt-cmd :: Sending magic packet -> %s", topic)

        r = subprocess.run(
            ["wakeonlan", "-i", "192.168.7.255", "-p", "9", "24:5E:BE:48:32:E1"],
            capture_output=True,
            text=True,
            timeout=5
        )

        if r.returncode != 0:
            logging.info("mqtt-cmd :: WOL failed -> %s", r.stderr)

    elif topic == "echo/command/backrestscale":
        handle_backrest_scale(payload)

    else:
        logging.info("mqtt-cmd :: topic is -> %s", topic)


client = mqtt.Client()
client.connect(MQTT_BROKER)
client.subscribe("echo/command/#")
client.on_message = on_message
client.loop_forever()