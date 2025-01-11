

---

# ClimAPI Bash

**ClimAPI Bash** is a simple and efficient command-line tool for fetching and displaying current weather information using the wttr.in service. This script is perfect for users who want quick weather updates directly from their terminal.

## Features

- Fetch current weather conditions for any city
- Simple and easy-to-use interface
- Displays errors gracefully with informative messages
- Suggests viewing the full report on wttr.in

## Requirements

- **Bash**: Ensure you have bash installed on your system.
- **curl**: A command-line tool for transferring data with URLs.

## Installation

1. **Clone the repository**:
    ```sh
    git clone https://github.com/irfanbroo/ClimAPI_bash.git
    cd ClimAPI_bash
    ```

2. **Install required packages**:
    ```sh
    sudo apt-get install curl
    ```

## Usage

1. **Run the script**:
    ```sh
    ./weather.sh <city_name>
    ```

    Replace `<city_name>` with the name of the city you want to get weather information for.

    **Example**:
    ```sh
    ./weather.sh Delhi
    ```

2. **Sample Output**:
    ```
    Fetching weather details for Delhi.....
    ========================================
              WEATHER REPORT
    ========================================
    Delhi: 🌦️ +20°C
    ========================================
    For more details, visit: https://wttr.in/Delhi
    ```

## Script Breakdown

- **Error Handling**:
    ```sh
    if_error(){
        echo "Usage: $0 <city_name>"
        echo "Example: $0 Kerala"
    }

    if [ -z "$city" ]; then
        echo "Error: City name not provided."
        if_error
        exit 1
    fi
    ```

- **Fetching Weather Data**:
    ```sh
    echo "Fetching weather details for $city....."
    WEATHER=$(curl -s "https://wttr.in/${city}?format=3")
    ```

- **Validating Response**:
    ```sh
    if [[ "$WEATHER" == *"Unknown location"* ]]; then
        echo "Error: Unable to fetch weather details for '$city'. Check the city name"
        exit 1
    fi
    ```

- **Displaying Weather Details**:
    ```sh
    echo "========================================"
    echo "          WEATHER REPORT"
    echo "========================================"
    echo "$WEATHER"
    echo "========================================"
    echo "For more details, visit: https://wttr.in/${city}"
    ```

## Contributing

We welcome contributions to improve ClimAPI Bash! Feel free to fork the repository, make changes, and submit pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

- [wttr.in](https://wttr.in/) for providing the weather service.

---

