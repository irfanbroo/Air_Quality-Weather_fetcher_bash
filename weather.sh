#!/bin/bash

if_error(){
        echo "Usage: $0 <city_name>"
        echo "Example: $0 Kerala"
}

city="$1"

if [ -z "$city" ]; then
        echo "Error: City name not provided."
        if_error
        exit 1
fi

# Here, i am displaying the loading message

echo "Fetching weather details for $city....."


# Now, lets fetch the weather data

WEATHER=$(curl -s "https://wttr.in/${city}?format=3")



# Checking if the response is actually valid


if [[ "$WEATHER" == *"Unknown location"* ]]; then
        echo "Error: Unable to fetch weather details for '$city'. Check the city name"

        exit 1
fi


# Now its time to Display the weather details
echo "========================================"
echo "          WEATHER REPORT"
echo "========================================"
echo "$WEATHER"
echo "========================================"


# Suggest viewing the full report

echo "For more details, visit: https://wttr.in/${city}"
