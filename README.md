# Openframe-WebApp

A responsive front-end web app for Openframe.

## Installation

To install and configure this server run the following command:
```
bash <(curl -s https://raw.githubusercontent.com/mataebi/Openframe-WebApp/master/scripts/install.sh)
```
After asking you some questions about the setup you would like to use the install script should take care of the rest.

You may uninstall the software by using the uninstall script running the following comand:
```
bash <(curl -s https://raw.githubusercontent.com/mataebi/Openframe-WebApp/master/scripts/uninstall.sh)
```

### Local Development Setup

Install the dependencies: `npm i`

Create a `.env` file using `.env-sample` as an example. Make sure to set the `API_HOST` variable to point to the desired API host. For example:
- for a local Openframe API server: `API_HOST=http://0.0.0.0:8888`
- for the official Openframe production API server: `API_HOST=https://api.openframe.io/v0/`

Run the web app via the webpack dev server: `npm start`
