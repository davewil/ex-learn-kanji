# Kanji Learning App

This project is a web application, called Kuma-san Kanji, for learning Kanji (漢字). It is built in Elixir using Phoenix Liveview, Tailwind CSS and the Ash Framework. The application uses a SQLite database.

## Terminology used

- _Vistor_, user of the website that has not signed up.
- _User_, user of the website that has signed up.

## Features

- Home page where visitors are provided with an explanation of how the application works.
- Sign Up page where a visitor can create an account to become a user.
- Login In button for already signed up visitors.
- Explore Kanji page where visitors and users are presented with a random Kanji and information about it. This includes the various meanings, pronounciations, and example usages in Japanese sentences.

## Styling

- Use a font with a strong resemblance to the Katakana script in Japanese. Angular and spiky.
- For the palette choose of Sakura and cherry blossoms.
- Tono-kun, a male black and tan shiba inu, and Hime-chan, a female red shiba inu, are the mascots for the application. Generate SVG for to represent them and use them to help users use the application.

# KumaSanKanji

## Setup

- Install Elixir and Erlang ([Install Guide](https://elixir-lang.org/install.html))
- Install Node.js and npm for asset compilation

## Development

Run these commands in PowerShell:

```powershell
mix setup
npm install --prefix assets
npm run build --prefix assets
mix run reset_and_seed_dev.exs
mix phx.server
```

Now you can visit [http://localhost:4000](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Styling and Theming

- Tailwind CSS is configured in `assets/tailwind.config.js` with a custom OKLCH color palette.
- Katakana-inspired fonts:
  - `font-katakana`: "Zen Maru Gothic", "M PLUS 1p", sans-serif
  - `font-display`: "Stick", "Yuji Syuku", monospace
- Custom component classes defined in `assets/css/app.css`.
