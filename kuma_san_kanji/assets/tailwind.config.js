// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/kuma_san_kanji_web.ex",
    "../lib/kuma_san_kanji_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "oklch(63.5% 0.25 31)",
        // Cherry blossom inspired colors (in oklch color space)
        accent: {
          blue: "oklch(55% 0.1 250)",     // Muted blue
          pink: "oklch(75% 0.1 350)",     // Soft pink
          purple: "oklch(60% 0.1 300)",   // Muted purple
          green: "oklch(75% 0.1 150)",    // Muted green
          yellow: "oklch(85% 0.1 90)",    // Soft yellow
        },
        sakura: {
          light: "oklch(95% 0.03 350)",   // Very light pink
          DEFAULT: "oklch(85% 0.08 350)", // Medium pink
          dark: "oklch(70% 0.12 350)",    // Darker pink
          blossom: "oklch(80% 0.1 5)",    // Blossom pink
          white: "oklch(98% 0.01 350)",   // Off-white
        }
      },
      fontFamily: {
        'katakana': ['"Zen Maru Gothic"', '"M PLUS 1p"', 'sans-serif'],
        'display': ['"Stick"', '"Yuji Syuku"', 'monospace'],
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
