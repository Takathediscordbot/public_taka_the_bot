# Taka the discord bot

This repository includes everything that composes the discord bot @Takathebot#2453.
The bot is for now only limited to one discord server, which is twitch community's discord server.
It was also made in all parts (excluding third-party libraries) by me, @takathedinosaur.

## What this bot does

This bot is honestly quite versatile in its functionalities, it has a lot of very niche functionalities that you wouldn't normally find in a lot of discord bot, all assembled together. It currently does not have moderation functionalities, but that will probably come in a *future* update. I keep this bot updated all by myself so development can be quite slow.
For now though here's a list of functionalities:
    - Silly commands (Commands that send gifs, which are all stored in a database making them easy to create for the current holder of the bot.)
    - Tetrio Stats Commands, heavily inspired from [Sheetbot](https://github.com/Kerrmunism/sheetBot). The functionalities are pretty much the same with some added quirks like calculating stats from tetra league replays.
    - Tetrio Image Rendering, heavily inspired by [Hiyajo Maho](https://discord.com/api/oauth2/authorize?client_id=484558503545929729&permissions=0&scope=bot%20applications.commands). The images are rendered directly from the web making the results a little more accurate to the real website, and replay/profile urls are provided with the image renders to make them more easily accessible. 
    - AI Conversations, currently the bot has its own personality using GPT-3.5 to generate responses to messages. Its access is limited to a specific discord channel to not have the bot interacting literally everwhere.

Everything in the bot uses slash commands, appart from AI interactions which require the actual messages to respond.
In a *future* update I might lock the access to the AI behind slash commands, but I'd rather not do that to keep conversations more natural.

## What I aspire to do next

The next step in development could very well be to make an API based on the calculation methods, and silly commands to give access to the images for everyone and give an ease of use to stats calculations. It will make the code cleaner and mean I can make a web interface to interact with the bots functionalities directly. 
For now, I'm simply trying to make things better in general by, for example, adding this readme file which will let people use my bot with less struggles. 

## Architecture

### taka_the_discord_bot_client/

This is where the actual discord bot that interacts with the Discord API lies. Its actual architecture is also quite complex as it has a bunch of functionalities so I won't get too much into details here. It has its own github repository, like most other projects but some functionalities will not work without the other projects.

Even if you want to run the bot independently, with minimal setups, I advise you clone this repository rather than the taka_the_discord_bot_client repository because you will likely need the workspace configuration as well as the taka_the_discord_bot_common and tetrio-api repos. 

### taka_the_discord_common 

Although it is pretty much entirely unused for now, this module exists in case I would need to share code such as models or services between projects. I expect to possibly use it more in a future refactor. For now it exists at a very outdated pace compared to other projects.

### taka_the_discord_bot_database

This folder exists for possible database initialisation scripts, to run taka_the_discord_bot_client.
For now it only includes a single script that is an entire dump of my database, not updated frequently but still can manage to get back to a reasonably close state to the final database.
It is planned to include different scripts that would only manage the creation of the necessary tables instead of creating a bunch of data that most people cannot use because they lack the images of the discord bot.

### taka_the_discord_bot_status

This folder includes a simple webserver that has as its only goal to show if the different projects are currently running. It is heavily based on my domain names (that are hard coded into the project), so most people won't find much use in using that binary.

### taka_the_discord_bot_tetrio_html_server

A web server used to generate the tetrio user profile cards with their badges and stats included, and their tetra league stats the way they're shown on tetr.io.
It currently is very complex and badly managed and heavily needs refactoring, but as it is not the main project, as I am searching for a solution to generate profile cards and tetra league stats without using an html server, it probably won't get too much attention, especially since performance is not yet an issue for my bot with my current VPS configuration.

### tetrio-api

This is a library I made to communicate with the ch.tetr.io API with respect to caching. A library to communicate with the ch.tetr.io API already exists in rust but it does not manage the cache so I thought the best solution was to make my own. It is the most documented and maintained part of this workspace, as any bugs in my discord often come from API changes and I will promptly apply the changes to the library directly.

## Running


### Preconfiguration

To get started with my discord bot, you should clone this repository recursively, by running
```bash
    git clone --recursive https://github.com/Takathediscordbot/public_taka_the_bot.git 
```

Before running the bot, you will need to setup which functionalities you want to use. To do that, you can head to the taka_the_discord_bot_client/Cargo.toml file and set the default variable. 

```toml
[features]
default = []
```

This will define which features the bot will compile with. Each features have their own requirements for environment variables;
the database feature flag requires a DATABASE_URL environment variable to exist which should point to a postgres database which you can setup with the scripts in the taka_the_discord_bot_database folder; the html_server_image_generation requires a HTML_SERVER_URL environment to exist and to run the server in taka_the_discord_bot_tetrio_html_server; and finally the ai feature flag requires you to set AI_CHANNEL, a channel in which users can create threads to speak to the bot, and
OPENAI_TOKEN which should be a api key giving access to GPT 3.5-turbo.

Besides feature specific environment variables, the bot also requires a DISCORD_TOKEN environment to connect as a discord bot and a TEST_GUILD environment variable to set which server the bot can create commands in. A AUTHOR_ID also has to be set to access functionalities that are locked only to the creator of the bot.
 So far the bot can only work in one discord server at a time, until a future update.



### With docker 

To build this project, you will most likely have to customize the docker-compose file heavily.
Indeed, the docker-compose file actually manages domain names and nginx web servers for my discord bot. I would therefore advise that you do not use the one given in the repo and make you own. A docker-compose.example.yaml file exists which you can use to build the bot and parameterize it.

Once you're done with all the configuration, simply run: 
```bash
    docker compose up
```


### Without docker

The bot can easily be run without additional features such as a database, ai integration nor image generation by running.

```bash
    cargo run --bin taka_the_discord_bot
```

To enabled the optional features, you can use the feature flags

Enable database (you will need to set the correct database url in the DATABASE_URL environment variable):
```bash
    cargo run --bin taka_the_discord_bot --features database
```

Enable tetrio image rendering (you will need to set the correct url in the HTML_SERVER_URL environment variable):
```bash
    cargo run --bin taka_the_discord_bot --features html_server_image_generation
```

You will also need to run the tetrio html server, which requires having a TETR.IO bot token (which are only given exceptionally by tetrio admins.) Setting an invalid TETR.IO bot token is fine but you will only have access to the TETR.IO profile images and not the tetra league replays.

```bash
BIND_URL="0.0.0.0:8080"
TETRIO_API_TOKEN="Bearer your tetrio bot token here"
```

Running the tetrio html server:
```bash
    cargo run --bin tetrio_html_server
```


Enable AI prompting (you will need to set the OPENAI_TOKEN as well AI_CHANNEL environment variables)
```bash
    cargo run --bin taka_the_discord_bot --features ai
```

Run with all features enabled: 
```bash
    cargo run --bin taka_the_discord_bot --features full
```

## Special Thanks 

Special thanks to [Kerrmunism](https://github.com/Kerrmunism) for making sheetBot and making all calculations available, as well as helping me in the development of this bot. 

Special thanks to [Dimentio](https://github.com/Dimentio) for making Hiyajo Maho which has inspired me a lot in the design of this discord bot.

Special thanks to [osk](https://osk.sh/) and the TETR.IO team for making [TETR.IO](https://tetr.io/). Also don't sue me please.

And finally, special thanks to everyone in my community for giving me continuous support in the making of the discord bot.