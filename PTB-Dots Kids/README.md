#PTB-Dots Kids (ptbdotskids.m)

Darko Odic (http://odic.psych.ubc.ca) <br />
Last Edit: 02/August/2015 <br />

This Psychtoolbox script is used to generate random dot stimuli for Approximate Number System experiments *used with children* aged 3 - 10. It works similar to the PTB-Dots AOI script, but provides a series of functions that make it easier to display and work with children, including kid-friendly characters, a progress bar, kid-friendly feedback, etc. 

## PTB-Dots vs. PANAMATH
If you are interested in running simple ANS experiments with children and are a MATLAB and Psychtoolbox novice, we **strongly** recommend that you use the <a href="http://www.panamath.org/">PANAMATH</a> software. For most researchers, PANAMATH will do an outstanding job and provide a much more intuitive interface for running ANS experiments with children. But, for those researchers interested in deeper level of customization than PANAMATH can provide - enjoy PTB-Dots Kids!  

## Quick Overview
To run the script as an experiment, you need to adjust the config.txt file, including:
  * `debug` ("on" or "off"): the debug mode runs the program in windowed mode (so you can read the console errors). It is recommended you run this mode the first time you try out the script. 
  * `pracSN` (default: 999): the subject number used for your "practice" runs that significantly shortens the experiment.
  *  `isi` in miliseconds (default: 1200): the number of ms that the dots will stay on the screen. This value will strongly depend on age, but in general 800 - 1200 ms will be fine for kids 3 - 10. 
  * `numberArray` array (default: [30,10;10,30;20,10;10,20;18,12;12,18;24,20;20,24]): the list of numbers/ratios that will be presented, separated by semicolons. For example [20,10;10,20] means that the participant will always see either 20 yellow and 10 blue or 10 yellow and 20 blue dots. *Make sure that there are no spaces between the commas or semicolons when you type in these values, as this will cause the line to not be read in properly*. 
  * `allowedVariability` in percent (default 40): the maximum percent that one dot can be different from the default size. Higher variability means more heterogenous sizes between the dots. In general, 20 - 50% is a good number. 
  * `defaultSizePercentScreen` in percent (default: 1.5): the default cumulative size of the dots in each set (percent of total used screen size is used to make the size scalable with different drawRect options). Typically this will range from 0.5 - 3.0, depending on the total number of dots. 
  * `trialsPerBin' (default: 2): the number of fully balanced trials that will happen in the experiment. For example, if you have the default 6 ratios x 2 area congruency = 12 bins * 2 trialsPerBin = 24 trials total.
  * `color1rgb` and `color2rgb` in RGB values (defaults: [255,255,0] amd [0,0,255]: the colours for the two sets of dots.
  * `key1` and `key2` in char (default: 'f' and 'j'): keys used for answering in your task. *We do not recommend allowing kids younger than 8 to press their own keys*. Instead, they can tap the screen or vocalize the response. 
  * `character1` and `character2` (default: "spongebob" and "smurf"): the PNG files of the two kid-friendly characters associated with each set of dots. The script also provides 'bigbird' and 'grover'. You can feel free to use your own so long as they are transparent background PNG files.
  * `feedback` (default: "on"): whether or not the child will receive kid-friendly audio feedback after each trial. The feedback trials are in the /Sounds/ folder. 
  * `freezeFirstTrial` (default: "on"): an option setting whether there will be one extra very easy first trial with an infinite ISI. This is useful for showing young kids what the dots look like and what they need to do.
  * `progressBar` (default: "on"): an optional setting for showing a filling progress bar in the bottom of the display. This is very useful for knowing how far in the experiment you are and for motivating kids to keep going.
 
## Advice for helping kids understand the task
There is no method that works with every kid at every age. Three- and four-year-olds will be a tad confused at first, and eight-year-olds will be bored. But, in general, there are a few tips on helping kids understand the task:
*  Start by introducing them to the two characters. Be excited! Tell them that each character has a box (wow! a box!). Point on the screen as you say whose box is whose (this helps in case they don't know both the characters or are colour-blind). Make it seem like these boxes will hold the greatest treasure they have ever seen! 
* The simplest game is to have kids tell you which character has more dots (you can replace dots with marbles, or spots, or circles, or toys, or coasters, whatever). If they tell you that those are not dots but something else - go with it! 
* If they clearly did not understand what to do, force-quit the program (q by default) and start again. Two exceptions: don't do this after they've done more than 5-10 trials, and don't quit more than once! Some kids just won't get it, and that's alright. It's not **that** good of a game after all. 
* Having young kids press the response buttons is just going to be a bad time for everyone. Encourage them to say or yell the answer or point to the screen or do an interpretive dance. Just don't have them push the buttons (spacebar being needed for the next trial to begin is a useful tool). 
* Some kids get dissuaded by the negative feedback. If you notice this, either mute the computer, or tell them that even you didn't know the answer to that one! If you guys are working together against this silly game they will usually truck along (just don't give them the answers).
* The progress bar can be an excellent tool for showing them how far they've come and how soon you will both be done! 

## Basic Overview of Functions
The script has four functions:

1. `ptbdotskids`: this is the main function through which the entire experiment runs.
  * This function takes no inputs.
  * This function gives no outputs, but uses all the `Screen()` functions and terminates the experiment. 

2. `writeData`: helper function for outputting data.
  * This function takes as input the `output` structure defined at the end of each trial (see `output`) and the `fn` file, defined at the start of the script.
  * It will then write the designated columns to the file.

3. `drawDots`: the function used to jitter the size of the dots, place them on the screen, and make sure that the correct number is on the screen without overlap in the dots. This function is complicated and for a full overview see comments in the script itself.
  * There are many inputs, but the most relevant ones are the `numberSet` (which specifies the number of dots, e.g., [5,10] would draw 5 yellow and 10 blue dots), and the `drawRectSet` (which specifies the location of each set, e.g., [rect, rect] would draw both sets across the entire screen). 
  * It has one direct output: `didIt`, which returns a boolean depending on whether the function successfully made the dots and placed them on the screen without overlap (it may fail if, e.g., there are too many big dots that simply can't fit on the screen). 
  
4. `checkOverlap`: helper function for checking if any pairs of XY coordinates (i.e., two dots) overlap or not. 
  * This function takes as input three XY pairs.
  * It outputs a boolean if the first pair overlaps with second two pairs. 

## If you need more than two sets of dots
When working with children it is important to spatially distribute the dots. This makes it easier to identify which dot is which, helps kids understand the task, and allows us to test kids that may be colour-blind. As a result, it is not possible to add extra sets of dots into this script. If you absolutely need more sets, use the `ptbdotsaoi.m` script. 