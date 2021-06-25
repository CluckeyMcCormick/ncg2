#!/bin/bash

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
WINDOW_ON_PNG=16A_02.png
WINDOW_OFF_PNG=16T.png

# What's the maximum and minimum length for a consecutive chain of windows?
MIN_CHAIN_LENGTH=1
MAX_CHAIN_LENGTH=8

# When we try to roll a new state, we roll between 1 and some higher value: what
# is that higher value?
STATE_ROLL_SIZE=100
# What's the chance that a particular window will be "on"? (This will trigger if
# we roll <= this number)
ON_CHANCE=60

# How many columns of windows?
BLD_COLUMNS=32
# How many rows?
BLD_ROWS=32

# When we build an row image, what is that image called?
ROW_IMAGE=row.png
# When we build an column image, what is that image called?
COLUMN_IMAGE=column.png
# What are we outputting to?
OUTPUT_IMAGE=output_building.png

# What's our current window state?
WINDOW_IMAGE="AAA"
# How many windows remain in the current chain?
CHAIN_REMAIN=0

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
    
    # If the state roll is less than the "ON" chance, then it's ON!
    if [ "$state_roll" -le "$ON_CHANCE" ] 
    then
        WINDOW_IMAGE=$WINDOW_ON_PNG
    # Othwerwise, it's off
    else
        WINDOW_IMAGE=$WINDOW_OFF_PNG
    fi
}

# Builds a single row of an image to the ROW_IMAGE file
function build_row {

    # We always reset the chain count for the first window
    CHAIN_REMAIN=0

    # For each window...
    for x in `seq 1 $BLD_COLUMNS`;
    do
        # If the chain was completed, roll a new state
        if [ "$CHAIN_REMAIN" -le 0 ]
        then
            roll_new_state
        fi
        
        # If this is the first window, we need to copy over a single image to
        # serve as the "seed".
        if [ "$x" -le 1 ] 
        then
            cp -f $WINDOW_IMAGE $ROW_IMAGE
        # Otherwise, we need to append the current image to the existing row
        # image
        else
            magick convert $ROW_IMAGE $WINDOW_IMAGE +append $ROW_IMAGE
        fi

        # Now that we've placed a window, decrement our chain-remaining count
        CHAIN_REMAIN=$(($CHAIN_REMAIN - 1))
    done  
}

# Builds out a whole texture to the OUTPUT_IMAGE, row-by-row.
function build_row_based_building {
    # For each window...
    for y in `seq 1 $BLD_ROWS`;
    do
        # Make a new row
        build_row
        
        echo "ROW $y Complete!"
        
        # If this is the first row, we need to copy over a single image to
        # serve as the "seed".
        if [ "$y" -le 1 ] 
        then
            cp -f $ROW_IMAGE $OUTPUT_IMAGE
        # Otherwise, we need to append the current image to the existing row
        # image
        else
            magick convert $OUTPUT_IMAGE $ROW_IMAGE -append $OUTPUT_IMAGE
        fi
    done 
}

build_row_based_building

