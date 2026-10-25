# Halcyon changes to Glimmer file `shaders/block.properties`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 10

```properties
# plant
block.1003 = minecraft:cactus_flower minecraft:pink_petals minecraft:spore_blossom minecraft:wildflowers minecraft:potted_acacia_sapling minecraft:potted_allium minecraft:potted_azalea_bush minecraft:potted_azure_bluet minecraft:potted_bamboo minecraft:potted_birch_sapling minecraft:potted_blue_orchid minecraft:potted_brown_mushroom minecraft:potted_cactus minecraft:potted_cherry_sapling minecraft:potted_closed_eyeblossom minecraft:potted_cornflower minecraft:potted_crimson_fungus minecraft:potted_crimson_roots minecraft:potted_dandelion minecraft:potted_dark_oak_sapling minecraft:potted_dead_bush minecraft:potted_fern minecraft:potted_flowering_azalea_bush minecraft:potted_jungle_sapling minecraft:potted_lily_of_the_valley minecraft:potted_mangrove_propagule minecraft:potted_oak_sapling minecraft:potted_open_eyeblossom minecraft:potted_orange_tulip minecraft:potted_oxeye_daisy minecraft:potted_pale_oak_sapling minecraft:potted_pink_tulip minecraft:potted_poppy minecraft:potted_red_mushroom minecraft:potted_red_tulip minecraft:potted_spruce_sapling minecraft:potted_torchflower minecraft:potted_warped_fungus minecraft:potted_warped_roots minecraft:potted_white_tulip minecraft:potted_wither_rose minecraft:big_dripleaf minecraft:big_dripleaf_stem minecraft:bush minecraft:cave_vines minecraft:firefly_bush minecraft:kelp minecraft:kelp_plant minecraft:mangrove_roots minecraft:short_dry_grass minecraft:sugar_cane minecraft:tall_dry_grass minecraft:vine minecraft:cactus minecraft:carved_pumpkin minecraft:cocoa minecraft:melon minecraft:moss_block minecraft:pumpkin minecraft:pale_moss_block minecraft:pale_moss_carpet minecraft:leaf_litter minecraft:potted_golden_dandelion
```

## 2. replaces Glimmer line 19

```properties
# sway=short, plant
block.1006 = minecraft:orange_tulip minecraft:dark_oak_sapling minecraft:poppy minecraft:azure_bluet minecraft:sweet_berry_bush minecraft:seagrass minecraft:short_grass minecraft:cherry_sapling minecraft:melon_stem minecraft:pink_tulip minecraft:wheat minecraft:beetroots minecraft:pumpkin_stem minecraft:dead_bush minecraft:wither_rose minecraft:cornflower minecraft:allium minecraft:blue_orchid minecraft:pale_oak_sapling minecraft:red_tulip minecraft:white_tulip minecraft:jungle_sapling minecraft:carrots minecraft:closed_eyeblossom minecraft:torchflower minecraft:oxeye_daisy minecraft:fern minecraft:potatoes minecraft:acacia_sapling minecraft:torchflower_crop minecraft:birch_sapling minecraft:spruce_sapling minecraft:dandelion minecraft:bamboo_sapling minecraft:open_eyeblossom minecraft:oak_sapling minecraft:lily_of_the_valley minecraft:mangrove_propagule:hanging=false minecraft:short_dry_grass minecraft:tall_dry_grass minecraft:golden_dandelion %minecraft:saplings %minecraft:small_flowers
```

## 3. replaces Glimmer line 28

```properties
# sway=full, leaves, plant
block.1009 = minecraft:azalea_leaves minecraft:flowering_azalea_leaves minecraft:cherry_leaves minecraft:jungle_leaves minecraft:pale_oak_leaves minecraft:spruce_leaves minecraft:acacia_leaves minecraft:birch_leaves minecraft:oak_leaves minecraft:mangrove_leaves minecraft:dark_oak_leaves %minecraft:leaves
```

## 4. replaces Glimmer line 40

```properties
block.1013 = minecraft:wall_torch minecraft:torch minecraft:candle minecraft:candle_cake minecraft:white_candle minecraft:orange_candle minecraft:magenta_candle minecraft:light_blue_candle minecraft:yellow_candle minecraft:lime_candle minecraft:pink_candle minecraft:gray_candle minecraft:light_gray_candle minecraft:cyan_candle minecraft:purple_candle minecraft:blue_candle minecraft:brown_candle minecraft:green_candle minecraft:red_candle minecraft:black_candle minecraft:white_candle_cake minecraft:orange_candle_cake minecraft:magenta_candle_cake minecraft:light_blue_candle_cake minecraft:yellow_candle_cake minecraft:lime_candle_cake minecraft:pink_candle_cake minecraft:gray_candle_cake minecraft:light_gray_candle_cake minecraft:cyan_candle_cake minecraft:purple_candle_cake minecraft:blue_candle_cake minecraft:brown_candle_cake minecraft:green_candle_cake minecraft:red_candle_cake minecraft:black_candle_cake
```

## 5. inserted after Glimmer line 88

```properties
block.1030 = minecraft:copper_torch minecraft:copper_wall_torch minecraft:copper_lantern:hanging=false minecraft:waxed_copper_lantern:hanging=false minecraft:exposed_copper_lantern:hanging=false minecraft:waxed_exposed_copper_lantern:hanging=false minecraft:weathered_copper_lantern:hanging=false minecraft:waxed_weathered_copper_lantern:hanging=false minecraft:oxidized_copper_lantern:hanging=false minecraft:waxed_oxidized_copper_lantern:hanging=false

block.1031 = minecraft:copper_lantern:hanging=true minecraft:waxed_copper_lantern:hanging=true minecraft:exposed_copper_lantern:hanging=true minecraft:waxed_exposed_copper_lantern:hanging=true minecraft:weathered_copper_lantern:hanging=true minecraft:waxed_weathered_copper_lantern:hanging=true minecraft:oxidized_copper_lantern:hanging=true minecraft:waxed_oxidized_copper_lantern:hanging=true

block.1032 = minecraft:lantern:hanging=false

block.1033 = minecraft:glowstone minecraft:redstone_lamp:lit=true
block.1034 = minecraft:sea_lantern
block.1035 = minecraft:crying_obsidian minecraft:respawn_anchor minecraft:amethyst_cluster minecraft:large_amethyst_bud
block.1036 = minecraft:shroomlight minecraft:magma_block
block.1037 = minecraft:light

block.1038 = minecraft:obsidian
block.1039 = minecraft:iron_block minecraft:gold_block minecraft:netherite_block minecraft:copper_block minecraft:cut_copper minecraft:chiseled_copper minecraft:waxed_copper_block minecraft:waxed_cut_copper minecraft:waxed_chiseled_copper
```

