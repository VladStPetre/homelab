import psutil, os, time, json
import paho.mqtt.client as mqtt

MQTT_BROKER = "$MQTT_BROKER"
BASE_TOPIC = 'homeassistant/sensor/pi3'
client = mqtt.Client()
client.connect(MQTT_BROKER)

DEVICE = {
    "identifiers": ["pi3-kiosk"],
    "name": "Raspberry Pi 3 Kiosk",
    "manufacturer": "Raspberry Pi Foundation",
    "model": "Pi 3 Model B"
}

client.publish(f"{BASE_TOPIC}/cpu_temp/config", json.dumps({
    "name": "Pi 3 CPU Temp",
    "state_topic": "pi3/status",
    "unit_of_measurement": "°C",
    "value_template": "{{ value_json.temperature }}",
    "device_class": "temperature",
    "unique_id": "pi3_cpu_temp",
    "device": DEVICE
}), retain=True)

client.publish(f"{BASE_TOPIC}/cpu_usage/config", json.dumps({
    "name": "Pi 3 CPU Usage",
    "state_topic": "pi3/status",
    "unit_of_measurement": "%",
    "value_template": "{{ value_json.cpu }}",
    "unique_id": "pi3_cpu_usage",
    "device": DEVICE
}), retain=True)

client.publish(f"{BASE_TOPIC}/memory_usage/config", json.dumps({
    "name": "Pi 3 Memory Usage",
    "state_topic": "pi3/status",
    "unit_of_measurement": "%",
    "value_template": "{{ value_json.memory }}",
    "unique_id": "pi3_memory_usage",
    "device": DEVICE
}), retain=True)

client.publish("homeassistant/switch/pi3/display/config", json.dumps({
    "name": "Pi Display",
    "command_topic": "pi3/command/display",
    "payload_on": "on",
    "payload_off": "off",
    "state_topic": "pi3/display/state",
    "unique_id": "pi3_display_control",
    "device": DEVICE
}), retain=True)

client.publish("homeassistant/button/pi3/shutdown/config", json.dumps({
    "name": "Shutdown Pi",
    "command_topic": "pi3/command/shutdown",
    "payload_press": "shutdown",
    "unique_id": "pi3_shutdown_button",
    "device": DEVICE
}), retain=True)

while True:
    temp = float(os.popen("vcgencmd measure_temp").readline().replace("temp=", "").replace("'C\\n", ""))
    cpu = psutil.cpu_percent()
    mem = psutil.virtual_memory().percent
    payload = json.dumps({"temperature": temp, "cpu": cpu, "memory": mem})
    client.publish("pi3/status", payload)
    time.sleep(60)