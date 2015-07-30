#PTB-Dots Display (ptbdotsdisplay.m)

Darko Odic (http://odic.psych.ubc.ca) <br />
Last Edit: 30/July/2015 <br />

This Psychtoolbox script is used to display pre-generated random dot stimuli for Approximate Number System experiments. You can use this readme as a general guide to using the program (further details can be found commented in the MATLAB code).

## Quick Overview
To run the script as an experiment, you need to adjust three things.

1. **Change config.txt file**: this file contains some very basic information that is required for running your program, including (many other properties are directly loaded from the input images):
  * `debug` ("on" or "off"): the debug mode runs the program in windowed mode (so you can read the console errors) and skips introductions. It is recommended you run this mode the first time you try out the script. 
  * `pracSN` (default: 999): the subject number used for your "practice" runs that significantly shortens the experiment.
  *  `isi` in miliseconds (default: 500): the number of ms that the dots will stay on the screen. For adults, 500ms should be great, but for children this number should be bumped up, depending on age. 
  * `key1` and `key2` in char (default: 'z' and 'm'): keys used for answering in your task. 
  
2. **Place images in /InputImages/**: the images that will be displayed are in the /InputImages/ folder, along with a file listing them and their properties. The best way to generate the images is to use the ptbdotsgen script, included with this. If you use your own images, please make sure you have the imagestats.txt file from which the image names and properties are loaded. 

3. **Change Instructions**: the instructions presented to the participant are in the /Instructions/ folder. They are easiest to generate in Powerpoint. Once done, save your slides as images. Depending on your screen resolution, you may have to change the slide size so that the image is not compressed or stretched. The instructions included are vanilla standard instructions we give to adult participants.


## Basic Overview of Functions
The script has two functions:

1. `ptbdotsdisplay`: this is the main function through which the entire experiment runs.
  * This function takes no inputs.
  * This function gives no outputs, but uses all the `Screen()` functions and terminates the experiment. 

2. `writeData`: helper function for outputting data.
  * This function takes as input the `output` structure defined at the end of each trial (see `output`) and the `fn` file, defined at the start of the script.
  * It will then write the designated columns to the file.
