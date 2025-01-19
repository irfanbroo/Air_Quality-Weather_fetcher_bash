
# Weather and Air Quality Fetcher

## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Usage](#usage)
    1. [Command-Line Arguments](#command-line-arguments)
    2. [Examples](#examples)
6. [Sample Output](#sample-output)
7. [Script Details](#script-details)
    1. [Function Definitions](#function-definitions)
    2. [Fetching Weather Data](#fetching-weather-data)
    3. [Fetching AQI Data](#fetching-aqi-data)
    4. [Displaying Weather Details](#displaying-weather-details)
8. [Error Handling](#error-handling)
9. [API Information](#api-information)
10. [License](#license)
11. [Acknowledgments](#acknowledgments)

## Introduction

I really put some work into this project and here is my finalised code, feeling good after making all the stuff work and seeing it in action. 
The Weather and Air Quality Fetcher script provides a comprehensive weather report for a specified city. It fetches weather data from both [wttr.in](https://wttr.in) and OpenWeatherMap, including details such as temperature, weather conditions, sunrise and sunset times, and the Air Quality Index (AQI). The script then displays this information in a user-friendly format.

## Features

- Fetches weather summary from [wttr.in](https://wttr.in).
- Fetches detailed weather data from OpenWeatherMap.
- Fetches and displays the Air Quality Index (AQI) and its descriptive level.
- Displays sunrise and sunset times in a human-readable format.
- Error handling for invalid city names.

## Prerequisites

- **jq**: A lightweight and flexible command-line JSON processor.
- **curl**: A command-line tool for transferring data with URLs.

Ensure both `jq` and `curl` are installed on your system.

## Installation

To install `jq` and `curl`, you can use the following commands based on your operating system:

### For Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install jq curl
```

### For CentOS/RHEL:
```bash
sudo yum install jq curl
```

### For NixOS/NixPKGmanager: 

```bash
sudo nano /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

### For Fedora/RPM:-

```bash
sudo dnf install curl jq
```

### For macOS:
```bash
brew install jq curl
```

## Usage

### Command-Line Arguments

```bash
./weather_script.sh <city_name>
```

### Examples

```bash
./weather_script.sh Delhi
./weather_script.sh Kerala
```

## Sample Output

```plaintext
Fetching weather details for Delhi.....
========================================
          WEATHER REPORT
========================================
Delhi: 🌞 +30°C
========================================
        DETAILED WEATHER REPORT
{
  "coord": { "lon": 77.22, "lat": 28.67 },
  "weather": [
    { "main": "Clear", "description": "clear sky" }
  ],
  "main": { "temp": 30.0, "pressure": 1012, "humidity": 40 },
  "visibility": 10000,
  "wind": { "speed": 5.7, "deg": 320 },
  "clouds": { "all": 0 },
  "dt": 1618914195,
  "sys": {
    "type": 1,
    "id": 9052,
    "country": "IN",
    "sunrise": 1618872354,
    "sunset": 1618917224
  },
  "timezone": 19800,
  "id": 1273294,
  "name": "Delhi",
  "cod": 200
}
========================================
Sunrise: Sat Apr 24 06:32:34 UTC 2021
Sunset: Sat Apr 24 19:27:04 UTC 2021
Air Quality Index (AQI): 3 (Moderate)
========================================
For more details, visit: https://wttr.in/Delhi
```

## Script Details

### Function Definitions

- **`if_error`**: Displays usage information and example command.
    ```bash
    if_error(){
        echo "Usage: $0 <city_name>"
        echo "Example: $0 Kerala"
    }
    ```

### Fetching Weather Data

- Fetches weather summary from wttr.in.
    ```bash
    WEATHER=$(curl -s "https://wttr.in/${city}?format=3")
    ```

- Fetches detailed weather data from OpenWeatherMap using the provided API key.
    ```bash
    CURRENT_WEATHER=$(curl -s --max-time 10 "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${api_key}&units=metric")
    ```

- Checks for valid responses and handles errors accordingly.
    ```bash
    if [[ "$(echo "$CURRENT_WEATHER" | jq -r '.cod')" == "404" ]]; then
        echo "Error: Unable to fetch weather details for '$city' from OpenWeatherMap. Check the city name"
        exit 1
    fi

    if [[ "$WEATHER" == *"Unknown location"* ]]; then
        echo "Error: Unable to fetch weather details for '$city'. Check the city name"
        exit 1
    fi
    ```

### Fetching AQI Data

- Extracts latitude and longitude from the weather data.
    ```bash
    lat=$(echo "$CURRENT_WEATHER" | jq -r '.coord.lat')
    lon=$(echo "$CURRENT_WEATHER" | jq -r '.coord.lon')
    ```

- Fetches AQI data from OpenWeatherMap.
    ```bash
    AQI_DATA=$(curl -s --max-time 10 "http://api.openweathermap.org/data/2.5/air_pollution?lat=${lat}&lon=${lon}&appid=${api_key}")
    ```

- Extracts the AQI value and maps it to a descriptive level using a `case` statement.
    ```bash
    AQI=$(echo "$AQI_DATA" | jq -r '.list[0].main.aqi')

    case $AQI in
        1) AQI_LEVEL="Good";;
        2) AQI_LEVEL="Fair";;
        3) AQI_LEVEL="Moderate";;
        4) AQI_LEVEL="Poor";;
        5) AQI_LEVEL="Very Poor";;
        *) AQI_LEVEL="Unknown";;
    esac
    ```

### Displaying Weather Details

- Extracts and converts sunrise and sunset times to a human-readable format.
    ```bash
    SUNRISE=$(echo "$CURRENT_WEATHER" | jq -r '.sys.sunrise')
    SUNSET=$(echo "$CURRENT_WEATHER" | jq -r '.sys.sunset')
    SUNRISE_TIME=$(date -d @$SUNRISE)
    SUNSET_TIME=$(date -d @$SUNSET)
    ```

- Displays the fetched weather summary.
    ```bash
    echo "========================================"
    echo "          WEATHER REPORT"
    echo "========================================"
    echo "$WEATHER"
    echo "========================================"
    ```

- Displays detailed weather information, including temperature, weather conditions, sunrise/sunset times, and AQI.
    ```bash
    echo "        DETAILED WEATHER REPORT"
    echo "$CURRENT_WEATHER"
    echo "========================================"
    echo "Sunrise: $SUNRISE_TIME"
    echo "Sunset: $SUNSET_TIME"
    echo "Air Quality Index (AQI): $AQI ($AQI_LEVEL)"
    echo "========================================"
    ```

## Error Handling

The script checks for the following errors:
- City name not provided.
    ```bash
    if [ -z "$city" ]; then
        echo "Error: City name not provided."
        if_error
        exit 1
    fi
    ```

- Invalid city name resulting in a 404 response from OpenWeatherMap.
    ```bash
    if [[ "$(echo "$CURRENT_WEATHER" | jq -r '.cod')" == "404" ]]; then
        echo "Error: Unable to fetch weather details for '$city' from OpenWeatherMap. Check the city name"
        exit 1
    fi
    ```

- Unknown location response from wttr.in.
    ```bash
    if [[ "$WEATHER" == *"Unknown location"* ]]; then
        echo "Error: Unable to fetch weather details for '$city'. Check the city name"
        exit 1
    fi
    ```

## API Information

- **OpenWeatherMap API**: Provides detailed weather and air quality data. You need an API key to access this service. Sign up at [OpenWeatherMap](https://openweathermap.org) to get your API key.
- **wttr.in**: A simple weather service that provides weather reports for a given location.

## License

This project is licensed under the MIT License. See the LICENSE file for details 

## Acknowledgments

- [wttr.in](https://wttr.in) for providing a simple weather report.
- [OpenWeatherMap](https://openweathermap.org) for detailed weather and AQI data.

---


