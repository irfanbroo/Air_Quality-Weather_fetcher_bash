#!/usr/bin/env zsh

load_env() {
    if [[ -n "$OPENWEATHER_API_KEY" ]]; then return 0; fi
    local env_file=".env"
    if [[ -f "$env_file" ]]; then
        export $(grep -v '^#' "$env_file" | xargs)
    else
        print -P "\e[31mError: .env file not found.\e[0m"
        exit 1
    fi
}

check_dependencies() {
    for dep in "curl" "jq"; do
        if ! command -v "$dep" &> /dev/null; then
            print -P "\e[31mError: $dep is not installed.\e[0m"
            exit 1
        fi
    done
}

fetch_weather_data() {
    local city="$1"
    curl -s "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${OPENWEATHER_API_KEY}&units=metric"
}

fetch_aqi_data() {
    local lat="$1" lon="$2"
    curl -s "http://api.openweathermap.org/data/2.5/air_pollution?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}"
}

capitalize() {
    echo "$1" | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}'
}

main() {
    load_env
    check_dependencies

    if [[ -z "$1" ]]; then
        print -P "\e[33mUsage: $0 <city_name>\e[0m"
        exit 1
    fi

    local city="$1"
    print -P "\e[34mFetching weather details for $city...\e[0m"

    # Fetch weather data
    WEATHER_DATA=$(fetch_weather_data "$city")

    # Check for valid response
    if [[ "$(echo "$WEATHER_DATA" | jq -r '.cod')" == "404" ]]; then
        print -P "\e[31mError: City '$city' not found.\e[0m"
        exit 1
    fi

    # Extract weather info
    local lat=$(echo "$WEATHER_DATA" | jq -r '.coord.lat')
    local lon=$(echo "$WEATHER_DATA" | jq -r '.coord.lon')
    local city_name=$(echo "$WEATHER_DATA" | jq -r '.name')
    local temp=$(echo "$WEATHER_DATA" | jq -r '.main.temp')
    local feels_like=$(echo "$WEATHER_DATA" | jq -r '.main.feels_like')
    local weather_desc=$(capitalize "$(echo "$WEATHER_DATA" | jq -r '.weather[0].description')")
    local humidity=$(echo "$WEATHER_DATA" | jq -r '.main.humidity')
    local wind=$(echo "$WEATHER_DATA" | jq -r '.wind.speed')
    local pressure=$(echo "$WEATHER_DATA" | jq -r '.main.pressure')

    # Fetch AQI data
    aqi_data=$(fetch_aqi_data "$lat" "$lon")

    # Parse AQI
    local aqi=$(echo "$aqi_data" | jq -r '.list[0].main.aqi')
    local aqi_level
    case $aqi in
        1) aqi_level="\e[32mGood\e[0m" ;;
        2) aqi_level="\e[33mFair\e[0m" ;;
        3) aqi_level="\e[33mModerate\e[0m" ;;
        4) aqi_level="\e[31mPoor\e[0m" ;;
        5) aqi_level="\e[31mVery Poor\e[0m" ;;
        *) aqi_level="\e[37mUnknown\e[0m" ;;
    esac

    # Sunrise/Sunset
    local sunrise=$(echo "$WEATHER_DATA" | jq -r '.sys.sunrise')
    local sunset=$(echo "$WEATHER_DATA" | jq -r '.sys.sunset')
    local sunrise_time sunset_time
    if [[ "$(uname)" == "Darwin" ]]; then
        sunrise_time=$(date -r "$sunrise" "+%I:%M %p")
        sunset_time=$(date -r "$sunset" "+%I:%M %p")
    else
        sunrise_time=$(date -d @"$sunrise" "+%I:%M %p")
        sunset_time=$(date -d @"$sunset" "+%I:%M %p")
    fi

    # Display Results
    print -P "\e[34m========================================\e[0m"
    print -P "          \e[36m🌤️  WEATHER REPORT 🌤️\e[0m"
    print -P "\e[34m========================================\e[0m"
    print -P "\e[35mCity:          \e[33m$city_name\e[0m"
    print -P "\e[35mTemperature:   \e[33m${temp}°C\e[0m"
    print -P "\e[35mFeels Like:    \e[33m${feels_like}°C\e[0m"
    print -P "\e[35mWeather:       \e[33m$weather_desc\e[0m"
    print -P "\e[35mHumidity:      \e[33m${humidity}%\em"
    print -P "\e[35mWind Speed:    \e[33m${wind} m/s\e[0m"
    print -P "\e[35mPressure:      \e[33m${pressure} hPa\e[0m"
    print -P "\e[34m========================================\e[0m"
    print -P "\e[35m☀️  Sunrise:     \e[33m$sunrise_time\e[0m"
    print -P "\e[35m🌙 Sunset:      \e[33m$sunset_time\e[0m"
    print -P "\e[35m🌫️  AQI:         \e[33m$aqi ($aqi_level)\e[0m"
    print -P "\e[34m========================================\e[0m"

}

main "$@"

