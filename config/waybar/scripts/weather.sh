#!/bin/bash

# Your OpenWeatherMap API key and location coordinates for Munich
# You can get your API key by signing up at https://openweathermap.org/
# Munich coordinates: lat=48.137154, lon=11.576124
API_KEY="5781f661b29b4634960211556252606"
LAT=48.137154
LON=11.576124
LOCATION="Munich"

# Fetch weather data from the WeatherAPI.com API
# 'q' is the query parameter for the location, 'aqi=yes' includes air quality data which often contains UV index.
WEATHER_DATA=$(curl -s "http://api.weatherapi.com/v1/current.json?key=${API_KEY}&q=${LOCATION}&aqi=yes")

# Extract the temperature in Celsius from the JSON data
# 'jq -r' is used to get the raw string output without quotes
TEMPERATURE=$(echo "${WEATHER_DATA}" | jq -r '.current.temp_c | round')

# Optional: Extract the UV index
# WeatherAPI.com provides a 'uv' field in the 'current' object.
UV_INDEX=$(echo "${WEATHER_DATA}" | jq -r '.current.uv')

# Create a JSON output for Waybar. The 'tooltip' field will show on hover.
# The 'alt' field is an optional alternative text for styling or toggling.
# The UV index is included in the tooltip.
# If UV index is not available, the tooltip will just show a message.
if [ -n "${UV_INDEX}" ] && [ "${UV_INDEX}" != "null" ]; then
    TOOLTIP="UV Index: ${UV_INDEX}"
else
    TOOLTIP="UV Index: N/A"
fi

# Create the JSON output for Waybar.
# The 'text' field is what is shown on the bar.
# The 'tooltip' field is what is shown when you hover.
# We also include a 'class' for potential styling based on temperature.
echo "{\"text\": \"${TEMPERATURE}°C\", \"tooltip\": \"${TOOLTIP}\"}"
