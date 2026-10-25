# Changelog

Halcyon started as an edit of [Glimmer](https://github.com/jbritain/glimmer-shaders) by jbritain (it used to be
called "Glimmer Photoreal"). All the Glimmer stuff is still in here, this is just what I changed or added.

Heads up: alpha.16 is the last one I actually tested in game. Newer ones compile fine but there might be bugs I haven't seen yet :0. Still testing alpha.22 seems to be good but could use work. i am trying

## alpha.22 - you can fly through clouds now!!! woot woot
- Flying into clouds finally works. Before, clouds only drew on the sky so if you went up there you could just see
  the ground through them lol
- Going into a cloud fades everything into mist
- No more weird glowing halos around blocks when the sky is cloudy
- Clouds look a lot better up close
- Cloud tops don't get cut off flat anymore and the bottoms aren't all the same height (added some math for this)
- Inside big clouds it's not just flat grey anymore
- Cloud shadows match the clouds better
- Cinematic clouds are 75% resolution now because full res was literally frying my PC
- Fixed a bunch of small cloud bugs (clouds disappearing in gaps, doubled clouds behind glass/water, weird rings inside
  clouds, storm tops getting clipped)

## alpha.21 - real stars!! i tried my best
- The stars are real now. I found a list of about 41,000 stars from the Hipparcos catalogue and put them in their actual spots and colours
- Milky Way is NASA's Deep Star Maps texture instead of the fake one I made
- Stars show up one by one at sunset, and the moon makes the faint ones fade
- Stars twinkle more near the horizon
- New Night Sky menu with Milky Way and star settings
- New Night Sky Season setting so you can change what's in the sky at midnight
- Fixed a massive bug where stars were showing up at noon (oops)

## alpha.20 - leaves, End portal, metal blocks | shit was so hard 
- Fixed white patches on leaves when it rains (puddles were forming on top of leaves... made no sense)
- End portals show space with stars and a tiny black hole now instead of those flickery squares
- End Portal Brightness setting
- Obsidian is a little shiny now
- New Vanilla Metals setting, iron/gold/copper/netherite blocks look like actual metal without a resource pack
- Modded leaves and flowers get the leaf effects too
- Far away rivers and lakes aren't a perfect mirror anymore

## alpha.19 - water update
- Water was looking way too bright and cyan, so it's darker and bluer now
- Far away water isn't silver anymore
- Water colour profiles: Natural Blue, Crystal Clear, Deep Ocean, Murky, Cinematic
- New water sliders (clarity, darkness, saturation, reflections)
- Weather Waves setting, the sea actually gets rougher when it rains or storms!
- Fixed waves repeating in the exact same direction
- Far water doesn't shimmer anymore
- Underwater at sunset looks way better
- Fixed water turning pitch black if absorption and scattering were both set to 0

Still broken: at sunrise/sunset the shadows in the underwater light rays point a bit the wrong way. I have no idea how to fix this yet.

## alpha.18 - cloud shadows
- Cloud shadows actually show up on the ground now. Auto exposure was just brightening the screen right back up and fighting my code
- Cloud Shadow Visibility setting
- Cloud Shadow Resolution setting (256 or 512)
- Debug View 10 shows cloud shadows

## alpha.17 - water polish | fianlly holy fawk dudes
- Ripples are rounder and smoother
- Better splashes when you jump in
- Deep water stays dark blue
- Less sparkly water in the distance
- Waves come in sets now

## alpha.16 - green screen fix | this shit was so hard idk how i can learn this im trying 
- Fixed the dreaded green lines on screen after going in water. The interactive water option wasn't hooked up right so Iris
  didn't know it existed
- Eclipses on/off switch works now (same exact problem lol)
- Coloured light goes through leaves again

## alpha.15 - interactive water | with the help of ai i got it to work but i hate that i had to use AI
- Water ripples when you walk, swim or jump in
- Boats leave a wake!
- Added a check so it turns itself off when you're not near water (saves lag)
- Settings are in the Water menu
- Off by default on Potato, Toaster and Low presets
- Debug View 9 shows the water sim

Note: Only works for your own player and boat right now, and only in the overworld.

## alpha.14 - End and daylight fixes | mmmm
- Fixed the weird purple/lavender band in the End sky
- Daylight was too grey and foggy, fixed the math
- Clouds aren't as white
- Added debug views
- High is the default preset now (if you used another one, pick it again)
- Fixed gold and other metals being the completely wrong colour
- Fixed light blocks not giving light and candles giving weird coloured light

## alpha.13 - End, Nether, waves
- The End has a space sky now with a black hole, stars and nebulas
- The End has fog
- The Nether has smoke and cool heat shimmer when you get near lava
- Bigger waves, and they change depending on the biome
- New End and Nether menus

## alpha.12 - it's called Halcyon now | lol thought real hard on this
- Renamed from "Glimmer Photoreal" to Halcyon (old settings files still work though)
- Fixed colours being too dark and too saturated
- Colour profiles: Natural, Vibrant, Cinematic, Photorealistic
- Fixed some lighting bugs that accidentally carried over from Glimmer
- Cleaned up the presets
- Made it a bit faster

## alpha.11 - lava and underwater
- Lava isn't completely white anymore lol
- New lava settings
- Underwater is foggier and looks more real
- Underwater light rays
- Caustics Strength setting

## alpha.10
- Lots of random bug fixes (underwater, Distant Horizons, clouds, exposure)

## alpha.9
- Auto exposure is on by default
- Moonlight isn't as blue
- Water colour looks more natural

## alpha.8
- Sun reflections on water actually work now (they were way too weak)
- Fixed dark spots and weird reflections on water

## alpha.7 - clouds
- Different cloud types depending on the weather
- Clouds move with the wind now!
- Cloud Quality and Cloud Height settings

## alpha.6
- Fixed the screen going completely white in rain
- Clear Underwater View (no fisheye effect underwater)

## alpha.5
- Aurora "Every night" actually lasts all night now

## alpha.4
- Fixed the screen going white because of literally one bad pixel breaking the shader

## alpha.3
- Moon uses real NASA textures now

## alpha.2
- Fixes after actually testing it in game for the first time (water, underwater fog, coloured light, rain colour, aurora)
- Added eclipses, rainbows and cirrus clouds

## first version
- Basically just me messing with Glimmer: new water with bigger waves, rain ripples and caustics
- Wet stuff and puddles when it rains
- Better sun and moon, eclipses, aurora and volumetric clouds
- Screen-space GI, white balance and depth of field
- New menu and presets

---

## Known problems
- Water parallax is still super experimental and glitchy -  yup cant figure it out
- Polished floors indoors don't get reflections
- Depth of field completely breaks if you use Distant Horizons or Voxy - 
- Interactive water ripples only react to your own player - thats all i can do for now till i get better idk if thats even possiable.

## Tools
The `tools/` folder isn't in the zip. It's just a bunch of messy scripts I used for making the night sky textures and previewing the sky
and clouds.

## Licence and credits
MIT, like Glimmer (see `LICENSE`). The Glimmer credits in `README.md` still apply. Extra third-party code I used: afl_ext
"Very fast procedural ocean" (MIT, already in Glimmer), Dave Hoskins "Hash without Sine" (MIT), Heitz 2018 VNDF
sampling (published algorithm), Tanner Helland's blackbody fit (published approximation), and Allen's lunar phase
magnitude curve.

**Moon texture:** NASA's Scientific Visualization Studio CGI Moon Kit (svs.gsfc.nasa.gov/4720): visualizer Ernie
Wright (USRA), scientist Noah Petro (NASA/GSFC); colour from the LRO LROC WAC mosaic (NASA/GSFC/Arizona State
University), elevation from LRO LOLA. NASA imagery is generally free to use (NASA media usage
guidelines); just to be clear NASA has nothing to do with this project lol.

**Night sky:** Milky Way from NASA's Scientific Visualization Studio, Deep Star Maps 2020 (svs.gsfc.nasa.gov/4851),
visualizer Ernie Wright (USRA), built from Hipparcos-2, Tycho-2 and Gaia DR2 (ESA/Gaia/DPAC). Stars from the
Hipparcos Main Catalogue (ESA 1997) and the Yale Bright Star Catalogue 5th ed. (Hoffleit & Warren 1991), via CDS
VizieR. Gaia data are distributed by ESA under CC BY-NC 3.0 IGO; details and sources are in
`shaders/textures/CREDITS-night-sky.md`. The cloud noise and backup moon textures I just made myself.