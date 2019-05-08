# drawingGame
this is a simple drawing game that works in combination with Wekinator http://www.wekinator.org/.
The goal is to create a playful experience for collecting behavioural data of 2 players, one that makes the drawings the other that guesses the emotional valence of the strokes.

The game is built with Processing and depends on oscP5, netP5 for OSC communication and minim for the sound.
The processing sketch should be ready to go but you will need to download and install Wekinator http://www.wekinator.org/downloads/

Once you've installed Wekinator, download my preset here.
https://github.com/antocreo/wekinator_drawingGame

The game should be now ready!

### Instructions:
You can train your own model or use the existing one. Then you can start playing by drawing your own gestures and asking a friend to guess what is the emotional valence of your drawing.
You have one only gesture, 10 seconds and a limited amount of “ink” to draw.
You have also 10 seconds to guess your emotional state or evaluate your fellow’s.
This is a collaborative game, two human player compete against an artificial player.

### Troubleshooting
To the best of my knowledge, the game has not bugs but you might have problems with OSC ports if they are used for other things.

