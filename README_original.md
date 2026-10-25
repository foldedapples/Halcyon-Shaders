# Halcyon Shaderpack

Hey guys! Halcyon is a Minecraft shaderpack I've been trying to code. It basically started as just me messing around with [Glimmer](https://github.com/jbritain/glimmer-shaders) by jbritain to see if I could make it look more realistic. I used AI to help me fix and learn the water ripple simulation as for me that was so hard lol, but im trying my best to learn everything and write everything myself. This is my first shader pack edit or in general. Eventrually i will make my own pack when i learn everything :9

I kept the MIT license just like Glimmer.

Right now I got it working on Iris for Minecraft 1.21.11 and 26.1 up to 26.3. I even got Distant Horizons and Voxy to work with it!

Version: 1.0.0-alpha.22 | why is this shit so hard to learn 

I'm still learning how GLSL works so it's definitely a work in progress and you will probably find bugs lol. You can read the [CHANGELOG.md](CHANGELOG.md) to see what I've been fixing.

## Stuff I Added (Features)
- 3D Volumetric clouds that you can actually fly through! (and they cast shadows on the ground now)
- Used real NASA textures for the moon, and I figured out how to code moon phases and eclipses
- Real stars and the Milky Way in the night sky (mapped them out myself!)
- Auroras and rainbows
- Totally reworked the water: the oceans have way bigger waves, caustic reflections, underwater fog, and cool light rays
- Interactive water!! It literally ripples when you walk or swim through it, and boats leave a wake behind them now
- Rain makes the blocks actually look wet and forms puddles
- Colored lighting from glowing blocks
- LabPBR resource pack support
- Changed the End to look like deep space with a giant black hole :0
- Added smoke and heat distortion to the Nether

## How to install it
1. Install [Iris](https://modrinth.com/mod/iris) first.
2. Drag the Halcyon zip file into your `.minecraft/shaderpacks` folder.
3. Boot up the game, go to Video Settings > Shader Packs, and click Halcyon.

*Note:* You need a graphics card that supports OpenGL 4.3. I don't own a Mac so it doesn't work on macOS, sorry!
Also if you are updating from an older version of my pack, make sure to click your preset button again in the shader settings so it resets properly!

## Credits / People I borrowed code from
- First off, [Glimmer](https://github.com/jbritain/glimmer-shaders) by jbritain (MIT). This whole pack is built on top of his code. I copy-pasted his original README at the very bottom.
- Halcyon edits by me: Freak4U
- Moon texture: NASA's Scientific Visualization Studio, [CGI Moon Kit](https://svs.gsfc.nasa.gov/4720) 
  (Ernie Wright / Noah Petro). The color is from the LRO LROC WAC mosaic and elevation is LRO LOLA. (NASA images are free to use).
- Milky Way: NASA's [Deep Star Maps 2020](https://svs.gsfc.nasa.gov/4851) (Ernie Wright).
- Stars: I used the Hipparcos Main Catalogue (ESA 1997) and Yale Bright Star Catalogue to get the star positions. (More info and CC BY-NC 3.0 IGO license stuff is in `shaders/textures/CREDITS-night-sky.md`).
- Cool math/code I found from other smart people:
  - [Tony McMapface](https://github.com/h3r2tic/tony-mc-mapface) tonemapper by Tomasz Stachowiak (MIT)
  - ["Very fast procedural ocean"](https://www.shadertoy.com/view/MdXyzX) by afl_ext (MIT)
  - ["Hash without Sine"](https://www.shadertoy.com/view/4djSRW) by Dave Hoskins (MIT)
  - Also the Hillaire atmosphere code that jbritain already credited in Glimmer.
- I looked at [Eclipse Shader](https://github.com/Merlin1809/Eclipse-Shader) and [Bliss](https://github.com/X0nk/Bliss-Shader) to see how they did some stuff, but I didn't copy any of their code or files since they aren't MIT!

---
*(Here is the original Glimmer README that I promised to keep!)*
---

# Glimmer

![](/assets/glimmer-banner.png)

Glimmer is a Minecraft shaderpack designed to be simple and performant without looking like it.

[![modrinth](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/available/modrinth_vector.svg)](https://modrinth.com/mod/glimmer-shaders)
[![discord](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/social/discord-plural_vector.svg)](https://discord.gg/b9SHNcvs6c)
[![curseforge](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/available/curseforge_vector.svg)](https://legacy.curseforge.com/minecraft/shaders/glimmer-shaders)

## Features
- 'Potato', 'Toaster', 'Integrated Graphics' and 'Dedicated Graphics' presets, designed to run on anything from your fridge to a NASA supercomputer.
- Complete LabPBR 1.3 compliance.
- Distant Horizons support!
- 'Infinite Ocean', adding water stretching out of render distance.
- Shadows, using either the shadow map or approximated from the lightmap.
- Screen space reflections and refractions.
- Procedural 2D clouds.
- Temporal filtering to reduce noise at low sample counts.
- Bloom.
- Support for the [ColorWheel](https://djefrey.github.io/colorwheel/) mod.

## Compatibility
- OpenGL 4.3+ - macOS is *not* supported, nor is the Raspberry Pi. Most modern GPUs (integrated or dedicated) should work fine.
- Iris 1.6+, OptiFine is *not* supported.

## Acknowledgements
- Andrew Hilmer, for his [Shadertoy implementation](https://www.shadertoy.com/view/slSXRW) of Sébastien Hillaire's ['A Scalable and Production Ready Sky and Atmosphere Rendering Technique'](https://github.com/sebh/UnrealEngineSkyAtmosphere)
- [Belmu](https://github.com/BelmuTM) - Reference code for SSR
- [Emin](https://github.com/EminGT) - Shadow bias calculation from [Complementary](https://github.com/ComplementaryDevelopment/ComplementaryReimagined)
- [NinjaMike](https://github.com/NinjaMike) - Directional lightmapping method
- [sixthsurge](https://github.com/sixthsurge) - A decent amount of code reference from [Photon](https://github.com/sixthsurge/photon), especially the combined projection matrix used for SSR on distant horizons terrain
- [Null](https://github.com/Null-MC/) - Help porting in the atmospheric scattering code
- [BuilderB0y](https://github.com/builderb0y) from whom I shamelessly stole the idea of an infinite ocean plane
- kloppi417 for so helpfully fixing the capitalization of "macOS", to whom I am forever in debt
- As always, the members of the ShaderLABS Discord server who have helped me get this far learning how to do all this
- Many other people, there are links scattered throughout the code
- (Halcyon) Moon texture: NASA's Scientific Visualization Studio, [CGI Moon Kit](https://svs.gsfc.nasa.gov/4720) - visualizer Ernie Wright (USRA), scientist Noah Petro (NASA/GSFC); LRO LROC WAC colour mosaic (NASA/GSFC/Arizona State University) and LRO LOLA elevation

## Get in touch
If you have an issue with Glimmer or just want to chat, you can [join my Discord server](https://discord.gg/b9SHNcvs6c) or find me in `#jbritains-shaderpacks` in the [shaderLABS Discord server](https://discord.gg/RpzWN9S).