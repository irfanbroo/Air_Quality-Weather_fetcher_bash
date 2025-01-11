#!/bin/bash

if_error(){
        echo "Usage: $0 <city_name>"
        echo "Example: $0 Kerala"
}

city="$1"
api_key="804619b6f979a6320d16c23b95b7d0d2"

if [ -z "$city" ]; then
        echo "Error: City name not provided."
        if_error
        exit 1
fi

# Here, i am displaying the loading message

echo "Fetching weather details for $city....."


# Now, lets fetch the weather data

WEATHER=$(curl -s "https://wttr.in/${city}?format=3")
CURRENT_WEATHER=$(curl -s --max-time 10 "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${api_key}&units=metric")

# Now, lets check if it retuns our desired value

if [[ "$(echo "$CURRENT_WEATHER" | jq -r '.cod')" == "404" ]]; then

        echo "Error: Unable to fetch weather details for '$city' from OpenWeatherMap. Check the city name"
        exit 1
fi


if [[ "$WEATHER" == *"Unknown location"* ]]; then
        echo "Error: Unable to fetch weather details for '$city'. Check the city name"

        exit 1
fi

# Extracting the latitude and longitude for AQI request


lat=$(echo "$CURRENT_WEATHER" | jq -r '.coord.lat')
lon=$(echo "$CURRENT_WEATHER" | jq -r '.coord.lon')


# Fetching the AQI Data with timeout

AQI_DATA=$(curl -s --max-time 10 "http://api.openweathermap.org/data/2.5/air_pollution?lat=${lat}&lon=${lon}&appid=${api_key}")



# Extracting the AQI Value

AQI=$(echo "$AQI_DATA" | jq -r '.list[0].main.aqi')

# Now, lets map the AQI value to a descriptive level

case $AQI in

        1) AQI_LEVEL="Good";;
        2) AQI_LEVEL="Fair";;
        3) AQI_LEVEL="Moderate";;
        4) AQI_LEVEL="Poor";;
        5) AQI_LEVEL="Very Poor";;
        *) AQI_LEVEL="Unknown";;
esac




# Extract sunrise and sunset times

SUNRISE=$(echo "$CURRENT_WEATHER" | jq -r '.sys.sunrise')
SUNSET=$(echo "$CURRENT_WEATHER" | jq -r '.sys.sunset')
SUNRISE_TIME=$(date -d @$SUNRISE)
SUNSET_TIME=$(date -d @$SUNSET)




# Now its time to Display the weather details
echo "========================================"
echo "          WEATHER REPORT"
echo "========================================"
echo "$WEATHER"
echo "========================================"
echo "        DETAILED WEATHER REPORT"
echo "$CURRENT_WEATHER"
echo "========================================"
echo "Sunrise: $SUNRISE_TIME"
echo "Sunset: $SUNSET_TIME"
echo "Air Quality Index (AQI): $AQI ($AQI_LEVEL)"
echo "========================================"






# Suggest viewing the full report

echo "For more details, visit: https://wttr.in/${city}"
