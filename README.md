# NCG2
NCG2 is an acronym for Neon City Generator 2 - except I don't quite like that name so I'm just going to keep it as an acronym.

It's a successor to an earlier project written in Java. You can go take a look at that project if you want, but it's not necessary.

This project is a generative art piece. That sounds a bit formal for my tastes, but "art piece" is really the most appropriate way to describe this project. It's not a game! It just kinda sits there and looks nice, and you can change how it looks with some basic controls. So maybe its a tool. An art tool? Something like that. I mostly was working on it to try and "complete" my earlier version and learn some of Godot's shaders.

## Using the project
First, download the latest version of [Godot 3.5](https://godotengine.org/download). And yes, it does have to be at least 3.5! There might even end up being incompatibilities with 3.6 - as of this writing, that's still on the horizon and I don't know what that looks like just yet.

Anyway, you load the project much as you would any other project: from the Godot Project Manager window, press the "Import..." button, then select the appropriate `project.godot` file.

You can then use the project like any other Godot project.

## But how does it work?
I want to do an actual proper documentation push on this at some point (maybe even a video of some sort?) but I feel it would be irresponsible of me to not provide at least a cursory explanation about how this whole thing works.

Basically it works like this: we generate a city, and then we manipulate that city by either manipulating common resources (which goes very quickly!) or by editing every instance of something on screen (which typically goes very slowly - you'll see the impact on your frames). The different handles you manipulate - the settings for the city - are then bundled up into profiles. I've baked in some profiles for you to use, but you can also save your own custom profiles and load those at runtime.

### City Generation
How do we generate a city, though? That's effectively, though not cleanly, split into three steps:

1. Block Planning
1. Building Planning
1. Building Construction

These are all executed by the `cities/GrowBlockCity` scene. If you want to play around with this generation, I recommend looking at `cities/GrowCityTest`.

However, the `GrowBlockCity` scene only serves as an orchestrator - the actual steps above are accomplished using the `factory/BlockFactory` scene and the `factory/BuildingFactory` scene.

The build process is started by calling `start_make_chain()` on `GrowBlockCity`. This starts the process of building the city, which is handled entirely within the `GrowBlockCity` scene. Once the process is complete, the `city_complete` signal is emitted.

#### Block Planning
Okay, so once the `start_make_chain()` is called, a thread is started using `BlockFactory`'s `start_make_blocks_thread()` function. This function, in turn, uses the `grow_points/GrowBlockifier` object to actually propel the block planning.

The algorithm of planning the blocks really deserves it's own documentation, but we can summarize it here: the world is assumed to be composed of *window units*. One window unit means one window on a side of a building. This is the fundamental constant that underpins our entire algorithm.

A series of points are scattered over space (`spawn_step`) - only one per (x, y) coordinate. They are scattered so they are, at minimum, at least some fixed distance from any other scattered point.

For each point, we then grow a rectangle (called a `GrowAABB`) outward from each point (`grow_pass`). Every time we process a point, we grow it in four directions. You can call these directions anything you want: up, down, left, right, north, east, west, south, +x, -x, +y, -y. It doesn't really matter - we just keep growing UNTIL we collide with another rectangle. We can only collide with another rectangle while growing in a particular direction - so, if growing in a direction collided with another rectangle, we shrink the current rectangle back down and then do not continue to grow in that direction.

Now, if one of these growing-rectangles can no longer grow any direction, it's considered complete. We go over our list of actively growing rectangles and remove those that are complete (`clean_pass`).

We repeat this process until we have no more rectangles to grow. What we now have is a list of `GrowAABB` objects, where each `GrowAABB` represents a space (measured in *window units*) that **does not overlap with any other rectangle**. This is emitted by the `BlockFactory` as a list in the `blocks_completed` signal.

#### Building Planning & Construction
This list of `GrowAABB` objects is then fed into the `BuildingFactory` scene by `GrowBlockCity`. The information stored in the `GrowAABB` is fed into the factory's `start_make_blueprint_thread()`, which (unsurprisingly) starts a thread where we blueprint a single building.

And here's where things get complicated - the `BuildingFactory` has a series of objects called **stages**. Each stage is effectively a pass over the building. So, we first run the building through all of the blueprint stages - once that's complete, we run in it through all of the construction stages. Once that's happened, the building is complete and is stuck in the scene. Once that's done for all buildings, the city is complete.

If you want to take a look at the stages, see `factory/stages` and `factory/FactoryStageManifest.gd`.

### City Manipulation
Okay, so you have the GUI. The GUI directly manipulates a `Dictionary` contained in the global `MaterialColorControl` node, which we typically refer to as the MCC. The MCC is kind of our global state node, and can be found in the `util/` directory.

Whenever the GUI manipulates a particular value in the MCC's profile dictionary, the GUI calls the `update_key` function. The MCC then takes the appropriate action for the given setting.

## Licensing
This project is licensed under the MIT License - EXCEPT for some open source fonts found in the `fonts/` directory.

As per the terms of the license, any projects deriving from this one must include a copy of the MIT license which includes my copyright. I'd also appreciate a shoutout in the credits, or something. That's not really required, though.

## Credits & Special Thanks
All the work in this project was done by me - Nicolas McCormick Fredrickson! But there's two people who deserve special thanks for this project.

First is [@sailorhg (sailor mercury)](https://twitter.com/sailorhg) who did a Sailor Moon city piece back in August 2020. I stumbled across that and thought to myself, "Say, that looks like my old project! I should really finish that at some point." That was the impetus for getting this thing off the ground again. It also inspired the Sailor Moon color scheme in the project itself.

The other one is [Shamus Young](https://www.shamusyoung.com/twentysidedtale/). Shamus did a project he called ["Pixel City" way back in 2009](https://www.shamusyoung.com/twentysidedtale/?p=2940). The first iteration of the NCG was an attempt to implement his algorithm, though I think I did it so poorly it ended up being it's own thing. I stopped reading his blog years ago but he even did a [second iteration back in 2018](https://www.shamusyoung.com/twentysidedtale/?p=42400). Shamus' programming blogs were fundamental in my development as a programmer, as they broke down often impenetrable computing concepts in easy-to-understand language.

Unfortunately, Shamus Young is no longer with us. I had always intended to share this project with Shamus, whenever I got around to finishing it - but it seems Time, that infernal bandit, has robbed me yet again. And so my "Special Thanks" is more of an "In Memoriam". This project is dedicated to his memory.

I would beg that you go back and look at Shamus' old programming blogs, especially if programming has always interested you but seemed far too opaque for you to understand. His critical essays were also excellent, and you may find that, like me, you'll lament a man you never truly knew.

It's my hope that, with time (and documentation!) this project can turn into a learning tool, just like Shamus' old programming blogs. And a new cohort of programmers can learn from my code, just as I learned from Shamus.

Don't go crazy just yet though - there's more documenting to do! Besides, that explanation I wrote above is ROUGH.
