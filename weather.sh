#!/bin/bash

# Load environment variables from .env
load_env() {
    if [[ -n "$OPENWEATHER_API_KEY" ]]; then
        return 0
    fi

    local script_dir env_file
    script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
    env_file="${script_dir}/.env"

    if [[ -f "$env_file" ]]; then
        export $(< "$env_file")
    else
        echo "Error: .env file not found. Please create a .env file with the required variables."
        exit 1
    fi
}

check_dependency() {
    local dependency=$1
    local name=$2
    if ! command -v "$dependency" &> /dev/null; then
        echo "Error: $name is not installed. Please install $name to run this script."
        exit 1
    fi
}

check_network() {
    if ! curl -s --head http://google.com &> /dev/null; then
        echo "Error: No active internet connection. Please check your network."
        exit 1
    fi
}

if_error() {
    echo "Usage: $0 <city_name>"
    echo "Example: $0 Kerala"
}

fetch_weather() {
    local city=$1
    curl -s "https://wttr.in/${city}?format=3"
}

fetch_current_weather() {
    local city=$1
    curl -s --max-time 10 "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${OPENWEATHER_API_KEY}&units=metric"
}

fetch_aqi_data() {
    local lat=$1
    local lon=$2
    curl -s --max-time 10 "http://api.openweathermap.org/data/2.5/air_pollution?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}"
}

map_aqi_level() {
    local aqi=$1
    case $aqi in
        1) echo "Good";;
        2) echo "Fair";;
        3) echo "Moderate";;
        4) echo "Poor";;
        5) echo "Very Poor";;
        *) echo "Unknown";;
    esac
}

main() {
    load_env
    check_dependency "jq" "jq"
    check_dependency "curl" "curl"
    check_network

    city="$1"
    if [[ -z "$city" ]]; then
        echo "Error: City name not provided."
        if_error
        exit 1
    fi

    echo "Fetching weather details for $city..."
    WEATHER=$(fetch_weather "$city")
    CURRENT_WEATHER=$(fetch_current_weather "$city")

    if [[ "$(echo "$CURRENT_WEATHER" | jq -r '.cod')" == "404" ]]; then
        echo "Error: Unable to fetch weather details for '$city'. Check the city name."
        exit 1
    fi

    if [[ "$WEATHER" == *"Unknown location"* ]]; then
        echo "Error: Unable to fetch weather details for '$city'. Check the city name."
        exit 1
    fi

    # Save JSON data to a file
    local script_dir
    script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
    echo "$CURRENT_WEATHER" > "${script_dir}/weather.json"

    lat=$(echo "$CURRENT_WEATHER" | jq -r '.coord.lat')
    lon=$(echo "$CURRENT_WEATHER" | jq -r '.coord.lon')
    AQI_DATA=$(fetch_aqi_data "$lat" "$lon")
    AQI=$(echo "$AQI_DATA" | jq -r '.list[0].main.aqi')
    AQI_LEVEL=$(map_aqi_level "$AQI")

    echo "========================================"
    echo "          🌤️  WEATHER REPORT 🌤️"
    echo "========================================"
    echo "$WEATHER"
    echo "========================================"
    echo "        🌍 DETAILED WEATHER REPORT 🌍"
    echo "City: $(echo "$CURRENT_WEATHER" | jq -r '.name')"
    echo "Temperature: $(echo "$CURRENT_WEATHER" | jq -r '.main.temp')°C"
    echo "Feels Like: $(echo "$CURRENT_WEATHER" | jq -r '.main.feels_like')°C"
    echo "Weather: $(echo "$CURRENT_WEATHER" | jq -r '.weather[0].description' | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')"
    echo "Humidity: $(echo "$CURRENT_WEATHER" | jq -r '.main.humidity')%"
    echo "Wind Speed: $(echo "$CURRENT_WEATHER" | jq -r '.wind.speed') m/s"
    echo "Pressure: $(echo "$CURRENT_WEATHER" | jq -r '.main.pressure') hPa"
    echo "========================================"

    SUNRISE=$(echo "$CURRENT_WEATHER" | jq -r '.sys.sunrise')
    SUNSET=$(echo "$CURRENT_WEATHER" | jq -r '.sys.sunset')
    SUNRISE_TIME=$(date -d @"$SUNRISE" "+%I:%M %p")
    SUNSET_TIME=$(date -d @"$SUNSET" "+%I:%M %p")

    echo "☀️  Sunrise: $SUNRISE_TIME"
    echo "🌙 Sunset: $SUNSET_TIME"
    echo "🌫️  Air Quality Index (AQI): $AQI ($AQI_LEVEL)"
    echo "========================================"
    echo "For more details, visit: https://wttr.in/${city}"
}

main "$@"
