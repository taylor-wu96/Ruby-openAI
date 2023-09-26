# ChatGPT API Wrapper

## Overview
This repository contains a Ruby module that serves as a wrapper for the OpenAI GPT-3.5 Turbo API. It simplifies the process of sending messages to the API and handling errors.

## Requirements
- Ruby
- net/http, uri, json, dotenv Ruby gems
- OpenAI API Key

## Installation
Clone the repository.
Run `bundle install` to install the required Ruby gems.
Create a .env file in the root directory and add your OpenAI API key as `OPENAI_API_KEY=your_api_key_here`.

## Usage
To use the API wrapper, you can call the send_message method from the RubyOpenAI::ChatGPTAPI class. Here's a simple example:

```
response = RubyOpenAI::ChatGPTAPI.send_message('Hello!')
puts response['choices'][0]['message']['content']
```

## Error Handling
The module includes custom error classes for HTTP 401 (Unauthorized) and 404 (Not Found) errors.

## Contributing
If you'd like to contribute, please fork the repository and make changes as you'd like. Pull requests are warmly welcome.

## License
This project is licensed under the MIT License.

