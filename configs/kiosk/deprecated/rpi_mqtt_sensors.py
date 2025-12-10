import psutil, os, time, json
import paho.mqtt.client as mqtt

MQTT_BROKER = os.environ.get('MQTT_BROKER_IP')
RPI_HOST="rpi_" + os.uname()[1]
BASE_TOPIC = 'homeassistant/sensor/' + RPI_HOST

client = mqtt.Client()
client.connect(MQTT_BROKER)

DEVICE = {
    "identifiers": ["{RPI_HOST}-kiosk"],
    "name": "Raspberry Pi 4 Kiosk",
    "manufacturer": "Raspberry Pi Foundation",
    "model": "Pi 4 Model B"
}

def get_temp():
    res = os.popen("vcgencmd measure_temp").readline().strip()
    return float(res.replace("temp=", "").replace("'C", "").strip())

client.publish(f"{BASE_TOPIC}/cpu_temp/config", json.dumps({
    "name": "Pi 4 CPU Temp",
    "state_topic": "{RPI_HOST}/status",
    "unit_of_measurement": "°C",
    "value_template": "{{ value_json.temperature }}",
    "device_class": "temperature",
    "unique_id": "{RPI_HOST}_cpu_temp",
    "device": DEVICE
}), retain=True)

client.publish(f"{BASE_TOPIC}/cpu_usage/config", json.dumps({
    "name": "Pi 4 CPU Usage",
    "state_topic": "{RPI_HOST}/status",
    "unit_of_measurement": "%",
    "value_template": "{{ value_json.cpu }}",
    "unique_id": "{RPI_HOST}_cpu_usage",
    "device": DEVICE
}), retain=True)

client.publish(f"{BASE_TOPIC}/memory_usage/config", json.dumps({
    "name": "Pi 4 Memory Usage",
    "state_topic": "{RPI_HOST}/status",
    "unit_of_measurement": "%",
    "value_template": "{{ value_json.memory }}",
    "unique_id": "{RPI_HOST}_memory_usage",
    "device": DEVICE
}), retain=True)

client.publish("homeassistant/switch/{RPI_HOST}/display/config", json.dumps({
    "name": "Pi Display",
    "command_topic": "{RPI_HOST}/command/display",
    "payload_on": "on",
    "payload_off": "off",
    "state_topic": "{RPI_HOST}/display/state",
    "unique_id": "{RPI_HOST}_display_control",
    "device": DEVICE
}), retain=True)

client.publish("homeassistant/button/{RPI_HOST}/shutdown/config", json.dumps({
    "name": "Shutdown Pi",
    "command_topic": "{RPI_HOST}/command/shutdown",
    "payload_press": "shutdown",
    "unique_id": "{RPI_HOST}_shutdown_button",
    "device": DEVICE
}), retain=True)

while True:
    temp = get_temp()
    cpu = psutil.cpu_percent()
    mem = psutil.virtual_memory().percent
    payload = json.dumps({"temperature": temp, "cpu": cpu, "memory": mem})
    client.publish("{RPI_HOST}/status", payload)
    time.sleep(15 * 60)