#!/bin/bash

# White Opacity (WO) Window Glue script

# This script attempts to create a city/building night texture by alternating a
# "transparent" image and a "window" image. It sounds weird but trust me, it
# works.

# When you look at a large tower-type building at night, the most common
# arrangement of lit-up windows is by floors, commonly contigious by floors. It
# makes a sort of sense, since offices are arranged by floor and nighttime
# activity tends to be clustered to a certain set of rooms.

# So, we build the texture row-by-row. We build each row by chaining together a
# random amount of one window type (ON/OFF) and then rolling another window type
# and chain amount.

# This script utilizes commands largely native to Ubuntu, except for
# ImageMagick.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Variables/Constants
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# What are the window files we'll be using?
WINDOW_ON_PNG=""
WINDOW_DIM_PNG=""
WINDOW_OFF_PNG=16T.png

# What's the maximum and minimum length for a consecutive chain of windows?
MIN_CHAIN_LENGTH=1
MAX_CHAIN_LENGTH=8

# When we try to roll a new state, we roll between 1 and some higher value: what
# is that higher value?
STATE_ROLL_SIZE=100
# What's the chance that a particular window will be "off"? (This will trigger
# if we roll <= this number)
OFF_CHANCE=40
# What's the chance that a particular window will be "dim"? (This will trigger
# if we roll <= this number and we roll > OFF_CHANCE)
DIM_CHANCE=80
# If we're not OFF or DIM, then we will be LIT. The chance of being lit can be
# calculated as $(STATE_ROLL_SIZE - DIM_CHANCE).

# How many columns of windows?
BLD_COLUMNS=64
# How many rows?
BLD_ROWS=64

# When we build an row image, what is that image called?
COMPONENT_IMAGE=component.png
# What are we outputting to?
OUTPUT_IMAGE=output_building.png

# What's our current window state?
WINDOW_IMAGE="AAA"
# How many windows remain in the current chain?
CHAIN_REMAIN=0

# We glue together the different images by using the `seq` command to do a for
# loop.
# What `seq` command do we use for columns?
COLUMN_SEQUENCE="seq 1 $BLD_COLUMNS"
# What `seq` command do we use for rows?
ROW_SEQUENCE="seq 1 $BLD_ROWS"

# To attach images to each other using the magick-convert command, we need to
# use an 'append' keyword/argument.
# What append do we use when trying to glue together images horizontally?
HORIZONTAL_APPEND="+append"
# What append do we use when trying to glue together images vertically?
VERTICAL_APPEND="-append"

# What sequence command do we use in the `build_component` function?
COMPONENT_SEQUENCE=$COLUMN_SEQUENCE
# What sequence command do we use in the `build_whole` function?
WHOLE_SEQUENCE=$ROW_SEQUENCE

# What append do we use in the `build_component` function?
COMPONENT_APPEND=$HORIZONTAL_APPEND
# What append do we use in the `build_whole` function?
WHOLE_APPEND=$VERTICAL_APPEND

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Up
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# For some reason the CTRL+C interrupt only works 50% of the time normally
# (because of ImageMagick, I think), and defining this trap function makes it
# work near 100% of the time.
trap ctrl_c INT
function ctrl_c {
    exit
}

# Ask if this is a vertically arranged building or a horizontally arranged
# building
whiptail \
    --title "Horizontal or Vertical Construction?" \
    --yes-button "Horizontal" --no-button "Vertical" --yesno \
    "Is this texture vertically-oriented or horizontally oriented?" \
    10 65

# If the output from whiptail was 0, then it was the "yes" button - in this
# case, that's "Horizontal".
if [ "$?" -eq 0 ]
then
    # Set the variables for the build_component function
    COMPONENT_SEQUENCE=$COLUMN_SEQUENCE
    COMPONENT_APPEND=$HORIZONTAL_APPEND
    # Set the variables for the build_whole function
    WHOLE_SEQUENCE=$ROW_SEQUENCE
    WHOLE_APPEND=$VERTICAL_APPEND
else
    # Set the variables for the build_component function
    COMPONENT_SEQUENCE=$ROW_SEQUENCE
    COMPONENT_APPEND=$VERTICAL_APPEND
    # Set the variables for the build_whole function
    WHOLE_SEQUENCE=$COLUMN_SEQUENCE
    WHOLE_APPEND=$HORIZONTAL_APPEND
fi

WINDOW_ON_PNG=$(whiptail \
    --title "Choose a window texture!" \
    --menu "Choose a dithering strategy." 15 35 8 \
        16A_01.png  "Full" \
        16A_02.png  "No Edge" \
        16A_03.png  "Bottom Contact" \
        16A_04.png  "Top Slice" \
        16A_05.png  "Horizontal Bar" \
        16A_06.png  "Vertical Bar"\
    3>&1 1>&2 2>&3
)  

if [ "$?" -eq 1 ]
then
    echo "Operation cancelled."
    exit
fi

# Now, determine the "DIM" image we'll be using by swapping the "A" in the
# WINDOW_ON_PNG string with a "B"
WINDOW_DIM_PNG=${WINDOW_ON_PNG/A/B}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Build Functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Rolls a new state - call this whenever you need to shake things up!
function roll_new_state {
    # Whip up an effective maximum and an effective minimum chain length
    local eff_max=$(($MAX_CHAIN_LENGTH - ($MIN_CHAIN_LENGTH - 1)))
    local eff_min=$(($MIN_CHAIN_LENGTH))
    # Randomize the remaining chain size
    CHAIN_REMAIN=$(($RANDOM % $eff_max + $eff_min))
    
    # Roll for our state
    local state_roll=$(($RANDOM % STATE_ROLL_SIZE + 1))
    
    # If the state roll is less than the "OFF" chance, then it's OFF!
    if [ "$state_roll" -le "$OFF_CHANCE" ]
    then
        WINDOW_IMAGE=$WINDOW_OFF_PNG
        
    # Othwerwise, if it's less than the "DIM" chance, then it's DIM!
    elif [ "$state_roll" -le "$DIM_CHANCE" ]
    then
    	WINDOW_IMAGE=$WINDOW_DIM_PNG
    
    # Otherwise, it must be ON!
    else
        WINDOW_IMAGE=$WINDOW_ON_PNG
        
    fi
}

# Builds a single row of an image to the ROW_IMAGE file
function build_component {

    # We always reset the chain count for the first window
    CHAIN_REMAIN=0
    
    # We'll stick the images we want to glue together into this array
    local img_arr=()

    # For each window...
    for x in `$COMPONENT_SEQUENCE`;
    do
        # If the chain was completed, roll a new state
        if [ "$CHAIN_REMAIN" -le 0 ]
        then
            roll_new_state
        fi
        
        # Stick the current image into the array
        img_arr=("${img_arr[@]}" "$WINDOW_IMAGE")

        # Now that we've placed a window, decrement our chain-remaining count
        CHAIN_REMAIN=$(($CHAIN_REMAIN - 1))
    done
    
    # Glue it all together!
    magick convert "${img_arr[@]}" $COMPONENT_APPEND $COMPONENT_IMAGE 
}

# Builds out a whole texture to the OUTPUT_IMAGE, component-by-component.
function build_whole {
    # For each window...
    for y in `$WHOLE_SEQUENCE`;
    do
        # Make a new row
        build_component
        
        echo "ROW $y Complete!"
        
        # If this is the first row, we need to copy over a single image to
        # serve as the "seed".
        if [ "$y" -le 1 ] 
        then
            cp -f $COMPONENT_IMAGE $OUTPUT_IMAGE
        # Otherwise, we need to append the current image to the existing row
        # image
        else
            magick convert $OUTPUT_IMAGE $COMPONENT_IMAGE $WHOLE_APPEND $OUTPUT_IMAGE
        fi
    done 
}

build_whole

