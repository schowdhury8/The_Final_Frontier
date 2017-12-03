breed [playerBullets playerBullet]
breed [empireMissiles empireMissile]
breed [rebelMissiles rebelMissile]
breed [bullets bullet]
breed [rebelBots rebelBot]
breed [empireBots empireBot]
breed [bases base]
breed [deads dead]
breed [stations station]
breed [ritems ritem]
breed [protons proton]

turtles-own [class
  max-HP HP attack speed ammo ammoClip
  enemyTarget tag delay originalSize
  take-missile-damage
  take-bullet-damage
  counter1 counter2
  money armor
  cause_damage
  max-shield  shield
  protonNum]
patches-own [nextColor counter]

empireBots-own [shield-regen energy]
rebelBots-own [shield-regen energy]

bases-own [alignment shield-regen max-energy energy energy-regen]

globals [clicked?]

;;;;;;;;;;;;;;;;;;;;;
;; SETUP FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;
to setup ;Setup function that sets up the world with all the necessary parts
  ca
  base-setup
  player-setup
  patches-setup
  station-setup
  ask turtles [set counter1 11 set counter2 0]
  reset-ticks
end

to base-setup ;Creates bases for the two opposing alliances
  create-bases 1 [ ;Creates the Rebel Base, Yavin 4
    set size 10
    set originalSize size
    set alignment "Rebels"
    set xcor (3.5 - max-pxcor)
    set shape "yavin_4"
    set heading 0
    set max-HP 10000
    set HP 10000
    set energy 0
    set energy-regen 1
    set shield 5000
    set shield-regen 5
    set max-energy 10000
    set delay 0
    set cause_damage 1
    set take-missile-damage 10
    set take-bullet-damage 2
    set armor 1
  ]

  create-bases 1 [ ;Creates the Imperial Base, the Death Star
    set size 10
    set originalSize size
    set alignment "Empire"
    set xcor (max-pxcor - 3.5)
    set shape "death_star"
    set heading 0
    set color grey
    set max-HP 10000
    set HP 10000
    set energy 0
    set energy-regen 1
    set shield 5000
    set shield-regen 5
    set max-energy 10000
    set delay 0
    set cause_damage 1
    set take-missile-damage 10
    set take-bullet-damage 2
    set armor 1
  ]
end

to player-setup ;Checks if player chooses to be part of the Rebels or the Empire, and then sets specifications for being on either alliance
  ifelse playerAlliance = "Rebels" [
    create-rebelBots 1 [
      set size 3
      set originalSize size
      set class "player"
      set ammo 6
      set ammoClip ammo
      set xcor -30
      set shape "x-wing"
      set heading 90
      set max-HP 100
      set HP 100
      set delay 0
      set cause_damage 1
      set take-missile-damage 10
      set take-bullet-damage 2
      set protonNum 0
    ]
  ]

  [
    create-empireBots 1 [
      set size 3
      set originalSize size
      set class "player"
      set ammo 6
      set ammoClip ammo
      set xcor 30
      set shape "tie_fighter"
      set heading -90
      set max-HP 100
      set HP 100
      set delay 0
      set cause_damage 1
      set take-missile-damage 10
      set take-bullet-damage 2
      set protonNum 0
    ]
  ]
end

to patches-setup ;Creates a procedurally generated "star map" as the background
  ask patches [
    if random 100 < 7.5 [set pcolor (random 90) / 10]
  ]

end

to station-setup ;Creates bases for the two opposing alliances
  create-stations 1 [ ;Creates the Rebel Space Station, the Valor Station
    set size 5
    set shape "valor_station"
    setxy 3.5 - max-pxcor max-pycor - 3.5
    set HP 5000
  ]
  create-stations 1 [ ;Creates the Imperial Space Station, the Trade Federation Station
    set size 5
    set shape "federation_station"
    setxy max-pxcor - 3.5 3.5 - max-pycor
    set HP 5000
  ]
end


;;;;;;;;;;;;;;;;;;;;;;
;; PLAYER FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;;
to mouseCtrl
  if class = "player"
  and mouse-xcor < max-pxcor
  and mouse-xcor > min-pxcor
  and mouse-ycor < max-pycor
  and mouse-ycor > min-pycor [

    	setxy mouse-xcor mouse-ycor
    	playerShoot

  		]
end

to playerShoot

  set clicked? false

  if mouse-down? [
    set clicked? true
    crtLaser "player" playerAlliance
  ]

  if (not mouse-down?) and clicked? = true[
    set clicked? false
  	]

  ifelse ammoClip > 1
      [set ammoClip (ammoClip - 1)]
  	[set ammoClip ammo]

  ask playerBullets [
    every .001 [fd 1]
    if xcor >= (max-pxcor - 1) OR xcor <= (1 - max-pxcor) [die]
  ]

end


;;;;;;;;;;;;;;;;;;;;
;; GAME FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;
to scrolling ;Scrolls through the procedurally generated "star map" as the background while creating procedurally creating a new one to simulate movement through space (yes, it's not real, just a simulation... sorry)
  ifelse playerAlliance = "Rebels" [
    every 0.025 [
      ask patches with [pxcor = 32] [if random 100 < 7.5 [set pcolor (random 90) / 10]]
      ask patches with [pxcor < max-pxcor] [set nextColor [pcolor] of patch-at 1 0]
      ask patches [set pcolor nextColor]
    ]
  ]

  [
    every 0.025 [
      ask patches with [pxcor = -32] [if random 100 < 7.5 [set pcolor (random 90) / 10]]
      ask patches with [pxcor > (- max-pxcor)] [set nextColor [pcolor] of patch-at -1 0]
      ask patches [set pcolor nextColor]
    ]
  ]
end

to crtLaser [parentClass alliance]
  if parentClass = "player" and alliance = "Rebels" [
    hatch-playerBullets 1 [
      set class "playerBullet"
      set color red
      set shape "line"

      set label ""
      set size 2.5
      set originalSize size
      set cause_damage 1
    ]
  ]

  if parentClass = "player" and alliance = "Empire" [
    hatch-playerBullets 1 [
      set class "playerBullet"
      set color lime
      set shape "line"
      set label ""
      set size 2.5
      set originalSize size
      set cause_damage 1
    ]
  ]

  if parentClass = "bruiser" and alliance = "Rebels" [
    hatch-rebelMissiles 1 [ ;AKA Codename Heatseeker
      set class "heatseeker"
      set color red
      set shape "Missile"
      set size 1
      set originalSize size
      set speed 0.2
      set HP 10
      set delay 0
      set cause_damage 1
      set take-bullet-damage 1
      set shield 0
    ]
  ]

  if parentClass = "bruiser" and alliance = "Empire"  [
    hatch-empireMissiles 1 [ ;AKA Codename Heatseeker
      set class "heatseeker"
      set color lime
      set shape "Missile"
      set size 1
      set originalSize size
      set speed 0.2
      set HP 5
      set delay 0
      set cause_damage 1
      set take-bullet-damage 1
      set shield 0
    ]
  ]
end

to hitDetect ;In the event of the player's bullets hitting one of the breeds, said breed should do as instructed
  if breed = playerBullets and color = red [
    ask empireBots in-radius 1 [ifelse shield > 0 [set shield shield - (take-bullet-damage - armor)set shape "shield"][set HP HP - (take-bullet-damage - armor)]]
    ask bases with [alignment = "Empire"] in-radius 1 [ifelse shield > 0 [set shield shield - (take-bullet-damage - armor) set shape "shield"][set HP HP - (take-bullet-damage - armor)]]
    ask empireMissiles in-radius 1 [set HP HP - take-bullet-damage]
  ]

  if breed = playerBullets and color = lime [
    ask rebelBots in-radius 1 [ifelse shield > 0 [set shield shield - (take-bullet-damage - armor)set shape "shield"][set HP HP - (take-bullet-damage - armor)]]
    ask bases with [alignment = "Rebels"] in-radius 1 [ifelse shield > 0 [set shield shield - (take-bullet-damage - armor)set shape "shield"][set HP HP - (take-bullet-damage - armor)]]
    ask rebelMissiles in-radius 1 [set HP HP - take-bullet-damage]
  ]

  if breed = empiremissiles [
    if any? rebelBots in-radius 1
    [if cause_damage = 1
      [ask rebelBots in-radius 1 [ifelse shield > 0 [set shield shield - (take-missile-damage - armor)set shape "shield"][set HP HP - (take-missile-damage - armor)]]
        set HP 0 set cause_damage 0]]
    if any? bases with [alignment = "Rebels"] in-radius 5.5
    [if cause_damage = 1
      [ask bases with [alignment = "Rebels"] in-radius 5.5 [ifelse shield > 0 [set shield shield - (take-missile-damage - armor)set shape "shield"][set HP HP - (take-missile-damage - armor)]]
        set HP 0 set cause_damage 0]]]

  if breed = rebelmissiles [
    if any? empireBots in-radius 1
    [if cause_damage = 1
      [ask empireBots in-radius 1 [ifelse shield > 0 [set shield shield - (take-missile-damage - armor) set shape "shield"][set HP HP - (take-missile-damage - armor)]]
        set HP 0 set cause_damage 0]]
    if any? bases with [alignment = "Empire"] in-radius 5.5
      [if cause_damage = 1
        [ask bases with [alignment = "Empire"] in-radius 5.5 [ifelse shield > 0 [set shield shield - (take-missile-damage - armor)set shape "shield"][set HP HP - (take-missile-damage - armor)]]
          set HP 0 set cause_damage 0]]]

  if breed = protons [
    ifelse xcor < max-pxcor - 1 or xcor < 1 - max-pxcor [
      ifelse playerAlliance = "Rebels"
      [if any? empireBots in-radius 4 or any? bases with [alignment = "Empire"] in-radius 7 or any?  empireMissiles in-radius 1
        [ask empireBots in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor)set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
          ask bases with [alignment = "Empire"] in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor) set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
          ask empireMissiles in-radius 10 [set HP HP - take-bullet-damage] set HP 0]]
      [if any? rebelBots in-radius 4 or any?  bases with [alignment = "Rebels"] in-radius 5 or any?  rebelMissiles in-radius 3[
        ask rebelBots in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor)set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
        ask bases with [alignment = "Rebels"] in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor)set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
        ask rebelMissiles in-radius 10 [set HP HP - take-bullet-damage] set HP 0]]] [die]]

  if class = "rogue" [
    ifelse xcor < max-pxcor - 1 or xcor < 1 - max-pxcor [
      ifelse playerAlliance = "Rebels"
      [if any? empireBots in-radius 4 or any? bases with [alignment = "Empire"] in-radius 7 or any?  empireMissiles in-radius 1
        [ask empireBots in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor)set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
          ask bases with [alignment = "Empire"] in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor) set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
          ask empireMissiles in-radius 10 [set HP HP - take-bullet-damage] set HP 0]]
      [if any? rebelBots in-radius 4 or any?  bases with [alignment = "Rebels"] in-radius 5 or any?  rebelMissiles in-radius 3[
        ask rebelBots in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor)set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
        ask bases with [alignment = "Rebels"] in-radius 10 [ifelse shield > 0 [set shield shield - (take-bullet-damage * 5 - armor)set shape "shield"][set HP HP - (take-bullet-damage * 5 - armor)]]
        ask rebelMissiles in-radius 10 [set HP HP - take-bullet-damage] set HP 0]]] [die]]

end

to baseAttrib
  every 1 [ask bases [
    if shield < max-shield [set shield shield + shield-regen]
    if energy < max-energy [set energy energy + energy-regen]
    ]
  ]
end

to bruiserAttrib
  every 1 [ask turtles with [class = "bruiser"] [
    if shield < max-shield [set shield shield + shield-regen]
    if energy < max-energy [set energy energy + energy-regen]
    ]
  ]
end

to explode ;BOOM
  every 0.04 [
    ask turtles [
      if HP <= 0 [
        set delay delay + 1
        set shape "explosion"
        if delay = 1 [set size 0.2 * originalSize]
        if delay = 2 [set size 0.4 * originalSize]
        if delay = 3 [set size 0.8 * originalSize]
        if delay = 4 [set size 1.6 * originalSize]
        if delay = 5 [die]
      ]
    ]
  ]
end

to win_cond ;Function that displays a user-message, congratulating the player for winning... or to express disappointment for letting their alliance down
  ifelse playerAlliance = "Rebels" [ifelse base 1 = nobody [user-message (word "You have crushed evil plans of the Empire. Peace has returned to galaxy once again!") stop]
    [if base 0 = nobody [user-message (word "With the last line of Rebels' defense crushed, there is nothing to stop the Empire from taking over the galaxy.") stop]]]
  [ifelse base 1 = nobody [user-message (word "Our plan has been crushed by the Rebels, the Emperor will certainly not be pleased.") stop]
    [if base 0 = nobody [user-message (word "You have served the Emperor well, minion. The galaxy will finally be ruled over by the Empire!") stop]]]
end


;;;;;;;;;;;;;;;;;;
;; AI FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;

to AISpawn ;Function that randomly spawns AI characters (NPCs) on the enemy team
  ifelse playerAlliance = "Rebels" [ ;If player is a Rebel, then auto-spawn Imperial ships
    ask bases with [alignment = "Empire"] [
      if energy >= 10 [callReinforcements "bruiser" empireBots set energy energy - 10]
    ]
  ]

  [ ;If player is in the Empire, then auto-spawn Rebel ships
    ask bases with [alignment = "Rebels"] [
      if energy >= 10 [callReinforcements "bruiser" rebelBots set energy energy - 10]
    ]
  ]
end
;Unfortunately, a nested ifelse statement from ifelse random 4 = 0 and so on... ended up crashing NetLogo multiple times. So, there aren't any variations in the enemy AI ships.


to AIMovement ;Function that handles the movement of all the AI characters (NPCs)
  ask bases [
    if ycor < max-pycor and ycor > min-pycor
    	[ifelse alignment = "Rebels" [lt 1] [rt 1]
    ]
  ]

  ask stations [lt 2]

  ask rebelBots [
    if class = "bruiser" [
      trackEnemy
      retreat
    ]

    if class = "scout" [
      trackEnemy
      dodge
    ]

    if class = "rogue" [
      trackEnemy
    ]

    if class = "falchion" [
      trackEnemy
      retreat
    ]
  ]

  ask empireBots [
    if class = "bruiser" [
      trackEnemy
      retreat
    ]

    if class = "scout" [
      trackEnemy
      dodge
    ]

    if class = "rogue" [
      trackEnemy
    ]

    if class = "falchion" [
      trackEnemy
      retreat
    ]
  ]
end

to AIShoot ;Function that handles the shooting mechanics of all the AI characters (NPCs)
  ask rebelBots with [class = "bruiser"] [
    crtLaser "bruiser" "Rebels"
  ]

  ask empireBots with [class = "bruiser"] [
    crtLaser "bruiser" "Empire"
  ]

  ask rebelBots with [class = "falchion"] [
    create-link-with (min-one-of reverser [distance myself]) [
      set thickness 0.25
      set color red
    ]
    ask (min-one-of reverser [distance myself]) [set HP HP - 5]
  ]

  ask empireBots with [class = "falchion"] [
    create-link-with (min-one-of reverser [distance myself]) [
      set thickness 0.25
      set color lime
    ]
    ask (min-one-of reverser [distance myself]) [set HP HP - 5]
  ]
end

to trackEnemy ;Tracks the enemy target it set from reverser (above) and moves towards it
  if hp <= 0 [stop]

  set enemyTarget (min-one-of reverser [distance myself])
  ifelse enemyTarget != nobody [face enemyTarget fd speed hitDetect]
                                [fd speed]
end

to missileDefSys ;The patented (well, not quite...) system for defense against enemy missiles
  if energy >= 10 [ifelse playerAlliance = "Rebels" [hatch 1 [set hp 10 set size 4 set shape "shield"] ask empiremissiles in-radius 3[set hp 0]]
    [hatch 1 [set hp 10 set size 4 set shape "shield"] ask rebelmissiles in-radius 3[set hp 0]]]
end

to dodge ;Function that tells a ship to dodge any incoming missiles or lasers coming at it (evasive manuevers)
  ifelse playerAlliance = "Rebels"
  [if any? rebelmissiles in-radius 3[missileDefSys]
    if any? playerBullets in-radius 3
    [hatch 1 [set size 0.1 set heading 0]
      ask other empireBots-here [ifelse any? playerBullets in-cone 3 90 [ask empireBots-here [lt 30 fd 1]]
        [ask other empireBots-here [rt 30 fd 1]] die]]]
  [if any? empiremissiles in-radius 3[missileDefSys]
    if any? playerBullets in-radius 3
    [hatch 1 [set size 0.1 set heading 0]
      ask other empireBots-here [ifelse any? playerBullets in-cone 3 90 [ask empireBots-here [lt 30 fd 1]]
        [ask other empireBots-here [rt 30 fd 1]] die]]]
end

to retreat ;Function that tells the AI to retreat back to space stations given that they have less than 50 HP
  if HP < 50
  [ifelse playerAlliance = "Rebels"
    [set enemyTarget station 3]
    [set enemyTarget station 4]]
end


;;;;;;;;;;;;;;;;;;;;
;; ITEM FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;
to random-item ;Function that spawns a powerup item randomly
  every 30
  [ifelse random 10 = 9 [create-ritems 1 [set shape "green-shield" set hp 1 set size 2
    ifelse random 2 = 1[set xcor random 17]
                        [set xcor random -17]
    ifelse random 2 = 1[set ycor random 17]
                        [set ycor random -17] set delay 0]]
    [ifelse random 9 = 8 [create-ritems 1 [set shape "red-heart" set hp 1 set size 2
      ifelse random 2 = 1[set xcor random 17]
                          [set xcor random -17]
      ifelse random 2 = 1[set ycor random 17]
                          [set ycor random -17] set delay 0]]
      [ifelse random 8 = 7 [create-ritems 1 [set shape "protoss-pylon" set hp 1 set size 2
        ifelse random 2 = 1[set xcor random 17]
                            [set xcor random -17]
        ifelse random 2 = 1[set ycor random 17]
                            [set ycor random -17] set delay 0]]
        [ifelse random 7 = 6 [create-ritems 1 [set shape "proton-torpedo" set hp 1 set size 2
          ifelse random 2 = 1[set xcor random 17]
                              [set xcor random -17]
          ifelse random 2 = 1[set ycor random 17]
                              [set ycor random -17] set delay 0]]
          [ifelse random 6 = 5 [create-ritems 1 [set shape "time-stop" set hp 1 set size 2
            ifelse random 2 = 1[set xcor random 17]
                                [set xcor random -17]
            ifelse random 2 = 1[set ycor random 17]
              [set ycor random -17] set delay 0]]
            [
              ifelse random 5 = 4 [create-ritems 1 [set shape "star-drone" set hp 1 set size 2
                ifelse random 2 = 1[set xcor random 17]
                                    [set xcor random -17]
                ifelse random 2 = 1[set ycor random 17]
                                    [set ycor random -17] set delay 0]][
                ifelse random 4 = 3 [create-ritems 1 [set shape "green-money" set hp 1 set size 2
                  ifelse random 2 = 1[set xcor random 17]
                                      [set xcor random -17]
                  ifelse random 2 = 1[set ycor random 17]
                                      [set ycor random -17] set delay 0]][
                  ifelse random 3 = 2 [create-ritems 1 [set shape "iron-sword" set hp 1 set size 2
                    ifelse random 2 = 1[set xcor random 17]
                                        [set xcor random -17]
                    ifelse random 2 = 1[set ycor random 17]
                                        [set ycor random -17] set delay 0]][
                    ifelse random 2 = 1 [create-ritems 1 [set shape "1up" set hp 1 set size 2
                      ifelse random 2 = 1[set xcor random 17]
                                          [set xcor random -17]
                      ifelse random 2 = 1[set ycor random 17]
                                          [set ycor random -17] set delay 0]]
                    [create-ritems 1 [set shape "?" set hp 1 set size 2
                      ifelse random 2 = 1[set xcor random 17]
                                          [set xcor random -17]
                      ifelse random 2 = 1[set ycor random 17]
                                          [set ycor random -17] set delay 0]]]]]]]]]]]
end

to item-movement1 ;One of the two randomized movement modes for the powerup items
  lt 2
  fd 0.1
end

to item-movement2 ;The other one of the two randomized movement modes for the powerup items
  rt 2
  fd 0.1
end

to item-decay ;Function that handles the 'decay' of the powerup if it is not collected before 5 seconds
  set delay delay + 1
  if delay >= 5 [die]
end

to item-contact ;Function that is called whenever any character comes in contact with any of the powerups and consequently, awards an extra attribute
  if shape = "red-heart" [if any? rebelBots-here [ask rebelBots-here [set max-hp max-hp * 1.5 set hp max-hp] die]
    if any? empireBots-here [ask empireBots-here [set max-hp max-hp * 1.5 set hp max-hp] die]]
  if shape = "green-shield" [if any? rebelBots-here [ask rebelBots-here [set armor armor + 1]die]
    if any? empireBots-here [ask empireBots-here [set armor armor + 1]die]]
  if shape = "green-money" [if any? rebelBots-here [ask rebelBots-here [set money money + 100]die]
    if any? empireBots-here [ask empireBots-here [set money money + 100]die]]
  if shape = "iron-sword" [if any? rebelBots-here [ask empireBots [set take-bullet-damage take-bullet-damage + 1 set take-missile-damage take-missile-damage + 5]
    ask base 1 [set take-bullet-damage take-bullet-damage + 1 set take-missile-damage take-missile-damage + 5]die]
    if any? empireBots-here [ask rebelBots [set take-bullet-damage take-bullet-damage + 1 set take-missile-damage take-missile-damage + 5]
      ask base 0 [set take-bullet-damage take-bullet-damage + 1 set take-missile-damage take-missile-damage + 5]die]]
  if shape = "protoss-pylon" [if any? rebelBots-here [ask base 0 [set energy-regen energy-regen + 1] die]
    if any? empireBots-here [ask empireBots-here [set energy-regen energy-regen + 1] die]]
  if shape = "proton-torpedo"[if any? rebelBots-here [ask rebelBots-here [set protonNum protonNum + 1] die]
    if any? empireBots-here [ask empireBots-here [set protonNum protonNum + 1] die]]
  if shape = "star-drone" [if any? rebelBots-here [ask rebelBots-here [hatch 1 [set size 2 set HP 50 set shape "drone" set class "drone"  set originalsize 2 set speed 0.1]] die]
    if any? empireBots-here [ask empireBots-here [hatch 1 [set size 2 set HP 50 set shape "drone" set class "drone"  set originalsize 2 set speed 0.1]] die]]
  if shape = "time-stop" [if any? rebelBots-here or any? empireBots-here[ask other turtles [set counter1 0] die]]
  if shape = "?" [if any? rebelBots-here or any? empireBots-here[ask turtles-here [set counter2 11 ] die]]

end

to timestop ;Function that handles the behavior of the TIMESTOP powerup
  ifelse playerAlliance = "Rebels" [ ifelse counter1 < 10 [ask empireBots [set speed 0] ask empireMissiles [set speed 0] set counter1 counter1 + 1]
    [ask empireBots [set speed 0.1] ask empireMissiles [set speed 0.1] set counter1 11]]
  [ ifelse counter1 < 10 [ask rebelBots [set speed 0] ask rebelMissiles [set speed 0] set counter1 counter1 + 1]
    [ask rebelBots [set speed 0.1] ask rebelMissiles [set speed 0.1] set counter1 11]]
end

to invisible ;Function that handles the behavior of the INVISIBILITY powerup
  if counter2 > 0 [ask turtles with [class = "player"] [set shape "void" set breed deads]
    ask turtles with [class = "drone"] [set shape "void" set breed deads] set counter2 counter2 - 1]
  ifelse playerAlliance = "Rebels" [if counter2 = 0
    [ask turtles with [class = "player"] [set shape "x-wing" set breed rebelBots]
      ask turtles with [class = "drone"] [set shape "drone" set breed rebelBots]]]
  [if counter2 = 0
    [ask turtles with [class = "player"] [set shape "tie_fighter" set breed empireBots]
      ask turtles with [class = "drone"] [set shape "drone" set breed empireBots]]]
end

to towardPlayer ;Function that controls the direction the drone should be heading
  if not any? turtles-here with [class = "player"] [set heading towards one-of turtles with [class = "player"]
    fd speed]
  ifelse playerAlliance = "Rebels" [set heading 90] [set heading 270]
end

to drone-movement ;Function that handles the behavior of the DRONE powerup
  if not any? turtles with [class = "player"] in-radius 3 [ask turtles with [class = "drone"][towardPlayer]]
  playerShoot
end

to proton-create ;If player has collected more than one proton torpedo, this functions is called to fire it
  if protonNum > 0  [set protonNum protonNum - 1
    ask turtles with [class = "player" and shape = "x-wing" ][hatch-protons 1 [set shape "proton-torp" set class "proton" set speed 0.2]]]
end

to proton-movement ;This function controls the movement of proton torpedoes once fired
  if breed = protons [ifelse playerAlliance = "Rebels"
    [set heading 90 fd speed set originalsize 6]
    [set heading 270 fd speed set originalsize 6]]
end

to energyBoost
  ask bases [set energy energy + 50]
end


;;;;;;;;;;;;;;;;;;;;;;;
;; CALLING FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;;;
to callReinforcements [summoned alliance] ;The function that calls reinforcements for both alliances using parameters and by referencing another function that actually calls the specific class of ship (see below)
  ifelse alignment = "Rebels" and alliance = rebelBots [
    hatch-rebelBots 1 [
      set class summoned
      set breed alliance
      set heading 90
      setxy -30 random-ycor
      set delay 0
      set speed 0.01
      set shield 50
      set shield-regen 1
      rebelCaller
    ]
  ]
  [if alignment = "Empire" and alliance = empireBots
    [
      hatch-empireBots 1 [
        set class summoned
        set breed alliance
        set heading -90
        setxy 30 random-ycor
        set delay 0
        set speed 0.01
        set shield 50
        set shield-regen 1
        empireCaller
      ]
    ]
  ]
end

to callBruisers ;Function that calls a BRUISER class ship by checking energy requirements first
  ask rebelBots with [class = "player"] [
    ifelse [energy] of base 0 >= 20  [
      set label "REQUESING A BRUISER!"
      ask base 0 [callReinforcements "bruiser" rebelBots set energy energy - 20]
    ] [set label "NOT ENOUGH ENERGY"]
  ]

  ask empireBots with [class = "player"] [
    ifelse [energy] of base 1 >= 20  [
      set label "REQUESING A BRUISER!"
      ask base 1 [callReinforcements "bruiser" empireBots set energy energy - 20]
    ]
    [set label "NOT ENOUGH ENERGY"]
  ]
end

to callScouts ;Function that calls a SCOUT class ship by checking energy requirements first
  ask rebelBots with [class = "player"] [
    ifelse [energy] of base 0 >= 10  [
      set label "REQUESING A SCOUT!"
      ask base 0 [callReinforcements "scout" rebelBots set energy energy - 10]
    ] [set label "NOT ENOUGH ENERGY"]
  ]

  ask empireBots with [class = "player"] [
    ifelse [energy] of base 1 >= 10  [
      set label "REQUESING A SCOUT!"
      ask base 1 [callReinforcements "scout" empireBots set energy energy - 10]
    ]
    [set label "NOT ENOUGH ENERGY"]
  ]
end

to callRogues ;Function that calls a ROGUE class ship by checking energy requirements first
  ask rebelBots with [class = "player"] [
    ifelse [energy] of base 0 >= 15  [
      set label "REQUESING A SCOUT!"
      ask base 0 [callReinforcements "rogue" rebelBots set energy energy - 15]
    ] [set label "NOT ENOUGH ENERGY"]
  ]

  ask empireBots with [class = "player"] [
    ifelse [energy] of base 1 >= 15  [
      set label "REQUESING A SCOUT!"
      ask base 1 [callReinforcements "rogue" empireBots set energy energy - 15]
    ]
    [set label "NOT ENOUGH ENERGY"]
  ]
end

to callFalchions ;Function that calls a FALCHION class ship by checking energy requirements first
  ask rebelBots with [class = "player"] [
    ifelse [energy] of base 0 >= 25  [
      set label "REQUESING A FALCHION!"
      ask base 0 [callReinforcements "falchion" rebelBots set energy energy - 25]
    ] [set label "NOT ENOUGH ENERGY"]
  ]

  ask empireBots with [class = "player"] [
    ifelse [energy] of base 1 >= 25  [
      set label "REQUESING A SCOUT!"
      ask base 1 [callReinforcements "falchion" empireBots set energy energy - 25]
    ]
    [set label "NOT ENOUGH ENERGY"]
  ]
end

to rebelCaller ;The function referenced by callReinforcements to acquire the attributes of the reinforcement to be called (rebel version)
  if class = "bruiser" [
    set size 5
    set originalSize size
    set shape "tantive_iv"
    set color random 140
    set speed 0.005
    set HP 100
  ]

  if class = "scout" [
    set size 1.5
    set originalSize size
    set shape "gauntlet_fighter"
    set color random 140
    set speed 0.75
    set HP 10
  ]

  if class = "rogue" [
    set size 3.5
    set originalSize size
    set shape "rogue_one"
    set color random 140
    set speed 0.35
    set HP 10000
  ]

  if class = "falchion" [
    set size 5
    set originalSize size
    set shape "falchion_tank"
    set color random 140
    set speed 0.005
    set HP 100
    hatch 1 [
      set shape "falchion_tank_cannon"
      set size 5
      set color random 140
    ]
  ]
end

to empireCaller ;The function referenced by callReinforcements to acquire the attributes of the reinforcement to be called (empire version)
  if class = "bruiser" [
    set size 5
    set originalSize size
    set shape "star_destroyer"
    set color random 140
    set speed 0.005
    set HP 100
  ]

  if class = "scout" [
    set size 1
    set originalSize size
    set shape "lone_scout-a"
    set color random 140
    set speed 0.75
    set shield 0
    set HP 5
  ]

  if class = "rogue" [
    set size 3.5
    set originalSize size
    set shape "rogue_one"
    set color random 140
    set speed 0.35
    set HP 10000
  ]

  if class = "falchion" [
    set size 5
    set originalSize size
    set shape "falchion_tank"
    set color random 140
    set speed 0.005
    set HP 100
    hatch 1 [
      set shape "falchion_tank_cannon"
      set size 5
      set color random 140
    ]
  ]
end


;;;;;;;;;;;;;;;
;; REPORTERS ;;
;;;;;;;;;;;;;;;
to-report reverser ;Takes the breed of a turtle and reports a target from the enemy team (different types of turtles have different targets!)
  if breed = rebelMissiles [ifelse count empireBots > 0 [report empireBots] [report bases with [alignment = "Empire"]]]
  if breed = empireMissiles [ifelse count rebelBots > 0 [report rebelBots] [report bases with [alignment = "Rebels"]]]

  if breed = rebelBots [ifelse count empireBots > 0 [report empireBots] [report bases with [alignment = "Empire"]]]
  if breed = empireBots [ifelse count rebelBots > 0 [report rebelBots] [report bases with [alignment = "Rebels"]]]
  report rebelBots
end

to-report Player_HP ;Reports the HP of the player
  ifelse playerAlliance = "Rebels"
  [report [HP] of rebelBot 2]
  [report [HP] of empireBot 2]
end

to-report Base_HP ;Reports the HP of the player's base
  ifelse playerAlliance = "Rebels"
  [report [HP] of base 0]
  [report [HP] of base 1]
end

to-report Base_Energy ;Reports the energy amount of the player's base
  ifelse playerAlliance = "Rebels"
  [report [energy] of base 0]
  [report [energy] of base 1]
end

to-report Base_Shield ;Reports the shield amount of the player's base
  ifelse playerAlliance = "Rebels"
  [report [shield] of base 0]
  [report [shield] of base 1]
end

to-report proton-torp ;Reports the HP of the player's base
  ifelse playerAlliance = "Rebels"
  [report [protonNum] of rebelBot 2]
  [report [protonNum] of empireBot 2]
end

;;;;;;;;;;;;;;;;;
;; GO FUNCTION ;;
;;;;;;;;;;;;;;;;;
to GO ;The final, comprehensive GO function that runs everything defined above

  if mouse-inside? [
    ifelse followPlayer? [if turtle 2 != nobody [follow turtle 2]] [reset-perspective]
    random-item
    scrolling
    explode
    baseAttrib


    ask turtles [
      mouseCtrl
      hitDetect
    ]

    every 0.05 [AIMovement]
    every 0.005 [ask turtles with [class = "drone"] [drone-movement]]
    every 3.5 [ask turtles [set label ""]]

    every (random 2) + 2 [
      AISpawn
      AIShoot
    ]

    every 0.005 [
      ask empireMissiles [trackEnemy]
      ask rebelMissiles [trackEnemy]
      ask protons [proton-movement]
    ]

    every 0.1 [ ;This is used to bring back the original shape of the ship after displaying its shield
      ask turtles [
        if who = 1  [set shape "Death_Star"]
        if who = 0 [set shape "yavin_4"]
        if breed = rebelBots with [class = "bruiser"] [set shape "tantive_iv"]
        if breed = empireBots with [class = "bruiser"] [set shape "star_destroyer"]
        if breed = rebelBots with [class = "falchion"] [set shape "falchion_tank"]
        if breed = empireBots with [class = "falchion"] [set shape "falchion_tank"]
      ]
    ]
    every 0.005[ask ritems [ifelse 2 = 1 [item-movement1][item-movement2] item-contact] ]
    every 1 [ask ritems[item-decay] ask turtles [timestop invisible] ]

    win_cond

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
322
16
1175
454
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-32
32
-16
16
0
0
1
ticks
420.0

BUTTON
14
39
128
73
SETUP WORLD
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
165
343
228
376
GO
if mouse-inside? [go]
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SWITCH
162
39
290
72
followplayer?
followplayer?
1
1
-1000

CHOOSER
163
90
301
135
playerAlliance
playerAlliance
"Empire" "Rebels"
0

BUTTON
163
139
282
172
CALL BRUISERS
callBruisers
NIL
1
T
OBSERVER
NIL
Z
NIL
NIL
1

BUTTON
163
181
272
214
CALL SCOUTS
callScouts
NIL
1
T
OBSERVER
NIL
X
NIL
NIL
1

BUTTON
164
222
274
255
CALL ROGUES
callRogues
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
1

MONITOR
33
92
117
137
Player_HP
Player_HP
17
1
11

MONITOR
33
139
95
184
NIL
Base_HP
17
1
11

MONITOR
33
227
119
272
NIL
Base_Energy
17
1
11

MONITOR
34
182
113
227
NIL
Base_Shield
17
1
11

BUTTON
31
335
150
368
ENERGY BOOST
energyBoost
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
26
277
160
322
Num_Proton_Torpedo
proton-torp
17
1
11

BUTTON
165
303
307
336
Fire Proton Torpedo
proton-create
NIL
1
T
TURTLE
NIL
A
NIL
NIL
1

BUTTON
164
262
292
295
CALL FALCHIONS
callFalchions
NIL
1
T
OBSERVER
NIL
V
NIL
NIL
1

@#$#@#$#@
# WHAT IS IT?
## **STAR WARS: THE FINAL FRONTIER**

***FOR THE HEROIC REBEL WITHIN YOU***
It's been four years since the battle of Yavin, when the first Death Star was destroyed by the heroic actions of Han Solo and Luke Skywalker. However, now, the rebellion once again finds itself in a precarious situation. A second death star, shielded by a generator on the moon of Endor, nears final construction, and will be ready to fire on the rebel base at Yavin 4. As general Luke Skywalker infiltrates the death star to defeat the emperor, it is on YOU to pull off a decisive victory in the skies. 
Good luck commander.

***FOR THE IMPERIAL TYRANT WITHIN YOU***
After the devastating loss of the first Death Star to Luke Skywalker, the Emperor wishes to crush the rebellion once and for all. The order of the great Empire has been undermined by the chaos caused by the rebellion. As the second Death Star nears completion, the Empire has been made aware of a dastardly rebel plot to destroy one of the Empire's last vestiges of power. YOU, as one of the emperor's hands, pilot an advanced TIE Fighter. As the Emperor and Vader engage Luke Skywalker aboard the Death Star, you must ensure your side's success in space. The might of the imperial fleet is behind you. Good luck commander.

# HOW IT WORKS

This NetLogo model or rather, game works off a set of principles that are reminiscent of many of our homeworks. In fact, the first thing you might have noticed is how it may look a tad bit like Red VS Blue, albeit a much more expanded and freeform version of it. 

Even the scrolling 'starry' background was part of one of our homeworks that involved H-shift and V-shift. 

So, much of what's being used here isn't new at all to most of those reading this, but simply the basics being utilized in a different manner to make something larger than itself. 

Essentially, the AI in the game are controlled randomly by moving towards, shooting bullets or lasers at the closest (minimum distance) enemy within their sight. The members of one alliance can determine who's a friend or foe using a reporter that we called **reverser** (odd name, yes, but makes somewhat of some sense), that basically reports the opposite breed being the enemy breed. 

Furthermore, our system of calling reinforcements using **callReinforcements** uses a type of modular design in which only ONE function is being called. But what makes the use of the function different each time in different contexts is the two parameters that you also include. These esentially give all the necessary information to create a reinforcement, what type of reinforcement, which side it's on, what color it is, what speed it has, etc. 

It's really quite amazing what you can do with code if you explore different ways to use it. This has truly been an interesting learning experience for the both of us.

# HOW TO USE IT

First of all, read WHAT IS IT? to gain a brief exposition. 
Next, choose whichever side you wish to join: The Rebels or The Empire from the **playerAlliance** chooser.

Then **setup** the world or should I say... your battlefield. 

This world is where you try to annihilate the enemy team's base, while at the same time, trying to protect your own, as well as protect your own ship and your reinforcements.

To begin the battle, click **GO** and then watch the battle unfold as the enemy team starts preparing to fight immediately. You must care to do the same. 

Use your mouse to move your ship around and left click to shoot (hold to shoot longer rays). 

To call reinforcements for your alliance, use the hotkeys or click on any one of the **CALL** buttons, based on your own preference of ship you wish to call. Keep in mind that if you move your mouse out of the world, everything just stops. This is for ease of use when you have to move your mouse out of the world to do other things, such as press buttons, etc. (Also, it's supposed to demonstrate your brilliant prowess in  control over time and space.)

**IMPORTANT**
Keep an eye on your **Player_HP**, **Base_HP**, **Base_Shield**, **Base_Energy** reporters on the left side.
They all correspond to what they're named, so they're pretty self explanatory.

Each base has a shield, as well as HP. First, you must destroy their shield to even make a dent on their HP, and the same goes for your base. So, keep that in mind.
Each base also has energy which is CRUCIAL, since energy determines how many ships you can build. Each ship class has an energy cost, and if you don't meet those cost requirements, then you're not going to be able to build it. Think of it as an economy system, in a way...
*Your resources are limited, so strategize wisely.*

**"BUT WAIT, HOW DO I SEE THE SHIELD AND HP OF THE ENEMY BASE?!"**, you would ask... I hope.

Well, the answer to that is... **YOU DON'T!** That's part of the challenge, you see?
You've got to keep attacking, until you know for sure that they're done for. 

Some tips:
If you shoot at a base, and they're shield comes on, then their sheild is still intact, which means you're not hurting their HP at all. Keep attacking and break their shield.
Likewise, if you shoot at them and no shield is to be seen, then they're defenseless. Push through and finish them!

One final note: 
You may have noticed the **ENERGY BOOST** button. This is purely optional, but in the case that you want to accelerate the gameplay a bit (or increase the difficulty hehe), you can just press that button.
Essentially, it increases both sides' base energy so that both alliances can spawn new ships.

# THE DIFFERENT CLASSES

There are 4 different classes of ships in your arsenal to use against the enemy.

## Bruiser Class
A lethal class of spaceships that is capable of both dealing and taking large amounts of damage by shooting heat-seeking missiles. 
**COSTS 20 ENERGY**
+ Damage
+ Durability
- Speed

The Rebels have ships modeled after Tantive IV, the main Rebel spacecraft that housed most of the Rebel alliance prior to the Battle of Yavin. 
The Empire has of course, their signature Star Destroyers… ‘Nuff said.

## Scout Class
A small, but important class of ships that is able to traverse through the battlefield quickly, while doing best to evade the line of fire to get to the enemy base and sabotage it by stealing energy.
**COSTS 10 ENERGY**
+ Cheap
+ VERY Fast and Evasive
- Very susceptible to damage

The Rebels have the Gauntlet Fighters, originally Mandalorian fighters that were later used by Darth Maul’s Shadow Collective and consequently, salvaged by the Rebels.
The Empire has a long line of scout vessels called Lone Scout-A that’s indeed quite similar to the signature TIE Fighters, but serves a vastly different purpose. 

## Rogue Class
An indeed abstract class, yet beneficial in some manner. Faulty droids are put in control of these ‘rogue’ ships, which have a tendency to crash into enemy ships. Sounds reminiscent of a tactic used in World War II… oh wait, wrong universe. 
**COSTS 15 ENERGY**
+ Cheap
+ Deals a lot of damage when crashing
- Not a very versatile class

## Falchion Class
The great Falchion class of laser tank ships were both salvaged by the Rebellion and the Empire. A few strategically timed of these mighty warriors of space can tip the balance in either side’s favor.
**COSTS 25 ENERGY**
+ Durability
+ Insane Damage
- Really Expensive

# ITEMS & POWERUPS

We also have an Items & Powerups system, that randomly spawns an item onto the battlefield to collect. Beware though, if you don't do it fast enough, it'll disappear into the vast emptyness of space. 

**“?”** - Grants the player invisibility
**HP x 1.5** - Multiplies HP of player by 1.5
**armor + 1** - Adds one armor point to player
**money + 100** - Awards player 100 credits (or money)
**attack bullet damage + 1** - Gives player ability to deal +1 more damage each hit
**energy regen of base + 1** - Increases the player's base regen by 1
**1up** - Grants the player 1 extra life should they be destroyed in battle
*proton torpedo* - Gives the player one proton torpedo with blast radius of 10 and damage of missile damage x10! (USE THIS WISELY)
**drone** - Spawns the player's very own personal drone that provides extra firepower
**time stop** - Allows the player to move around while the other objects are frozen in time (ART THOU THE TRUE TIME LORD?)

# THINGS TO TRY

An idea to think about: is there a definitive way to beat the enemy?
Is there a specific strategy or sequence of ships to call, to guarantee a win?
On the other hand, is there a strategy that guarantees failure?

Well, that's where you come in!
Try and experiment with different ships and maybe even formations of all your ships. 
*The sky... err... space is the limit.*

Good luck!

# EXTENDING THE MODEL

An extension of our model would be to improve the AI, since frankly, it isn't the brightest. To be specific, we would like to be able to target enemies better and in a more efficient manner and utilize pathfinding algorithms such as Dijkstra's algorithm, the A* search algorithm or even Concurrent Dijkstra's algorithm, which are often used in many other video games.

# CREDITS AND REFERENCES

***TEAM ENTROPY***
**SHAYAN CHOWDHURY & TIANRUN LIU**
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

1up
true
11
Polygon -2064490 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Rectangle -13840069 true false 60 105 75 210
Polygon -13840069 true false 105 105 105 210 165 210 165 105 150 105 150 195 120 195 120 105
Polygon -13840069 true false 180 105 180 210 195 210 195 165 240 165 240 105 180 105
Polygon -2064490 true false 195 120 195 150 225 150 225 120 195 120

?
true
10
Polygon -13840069 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -1 true false 90 120 120 120 135 90 165 90 180 105 180 135 135 165 135 210 165 210 165 180 210 150 210 90 195 60 135 60 120 60 90 120
Polygon -1 true false 135 225 135 255 150 255 165 255 165 225 135 225

death_star
true
0
Circle -7500403 true true -3 -3 306
Circle -16777216 false false 28 43 92
Circle -16777216 false false 69 69 42
Rectangle -16777216 false false 135 75 165 135
Line -16777216 false 0 150 300 150
Rectangle -16777216 false false 135 165 165 225
Rectangle -16777216 false false 105 165 120 225
Rectangle -16777216 false false 75 165 90 225
Rectangle -16777216 false false 45 165 60 225
Rectangle -16777216 false false 30 165 30 210
Rectangle -16777216 false false 15 165 30 210
Rectangle -16777216 false false 180 165 195 225
Rectangle -16777216 false false 210 165 225 225
Rectangle -16777216 false false 240 165 255 225
Rectangle -16777216 false false 270 165 285 210
Rectangle -16777216 false false 135 240 165 285
Rectangle -16777216 false false 105 240 120 285
Rectangle -16777216 false false 75 240 90 270
Rectangle -16777216 false false 45 240 60 255
Rectangle -16777216 false false 180 240 195 285
Rectangle -16777216 false false 210 240 225 270
Rectangle -16777216 false false 240 240 255 255
Rectangle -16777216 false false 135 15 165 60
Rectangle -16777216 false false 180 75 195 135
Rectangle -16777216 false false 180 15 195 60
Rectangle -16777216 false false 15 120 30 135
Rectangle -16777216 false false 105 15 120 45
Rectangle -16777216 false false 210 75 225 135
Rectangle -16777216 false false 210 15 225 60
Rectangle -16777216 false false 240 45 255 60
Rectangle -16777216 false false 240 75 255 135
Rectangle -16777216 false false 270 90 285 135
Rectangle -16777216 false false 105 120 105 135
Rectangle -16777216 false false 105 120 120 135

drone
true
4
Circle -7500403 true false 90 90 120
Polygon -7500403 true false 105 105 120 45 135 45 135 105 105 105
Polygon -7500403 true false 90 135 135 45 135 120 90 135
Polygon -7500403 true false 210 135 180 45 165 45 165 150 210 135
Polygon -1 true false 90 165 135 165 135 150 90 150 90 165
Polygon -1 true false 180 165 210 165 210 150 165 150 165 165 180 165
Rectangle -13791810 true false 120 105 135 135
Rectangle -13791810 true false 165 105 180 135
Rectangle -13791810 true false 120 195 180 210
Polygon -7500403 true false 90 135 120 45 120 135 90 135

explosion
false
0
Polygon -1184463 true false 106 286 105 210 58 282 45 225 -5 210 30 180 -8 108 23 146 26 109 38 72 15 45 82 55 103 11 122 41 135 30 165 15 195 30 195 60 240 45 211 156 255 225 193 263 168 278 165 255
Polygon -955883 true false 120 195 60 210 105 165 60 135 45 105 103 93 105 30 120 81 136 36 195 75 180 143 210 195 135 255
Polygon -2674135 true false 140 194 180 195 157 153 147 134 165 90 60 105 120 135 120 192

falchion_tank
true
0
Polygon -6459832 true false 60 75 75 240 225 240 240 75 60 75
Polygon -6459832 true false 60 75 150 60 240 75 60 75
Line -16777216 false 45 105 255 105
Line -16777216 false 60 225 240 225
Line -16777216 false 60 195 240 195
Line -16777216 false 45 150 255 150
Polygon -7500403 true true 90 75 75 105 75 225 120 240 180 240 225 225 225 105 210 75
Polygon -16777216 false false 225 105 210 75 211 231 225 225
Polygon -16777216 false false 75 105 90 75 89 231 75 225
Polygon -16777216 false false 89 232 116 239 183 240 211 231 211 222 89 221
Circle -2674135 true false 105 105 90
Circle -16777216 true false 135 135 30
Circle -16777216 false false 108 108 85
Polygon -16777216 false false 105 75 195 75 180 90 120 90 105 75
Polygon -16777216 false false 105 221 120 206 180 206 195 221 105 221
Polygon -13345367 true false 75 240 60 270 240 270 225 240 75 240
Polygon -13345367 true false 60 75 60 150 75 240 60 75
Polygon -13345367 true false 240 75 240 150 225 240 240 75
Polygon -16777216 false false 240 75 240 150 225 240 240 75
Polygon -16777216 false false 60 75 60 150 75 240 60 75
Polygon -16777216 false false 60 75 150 60 240 75 225 240 75 240 60 75
Line -16777216 false 90 75 210 75
Polygon -16777216 false false 225 240 75 240 60 270 240 270 225 240
Polygon -16777216 false false 225 270 225 240 225 270 210 240 210 270 195 240 195 270 180 240 180 270 165 240 165 270 150 240 150 270 135 240 135 270 120 240 120 270 105 240 105 270 90 240 90 270 75 240 75 270
Polygon -16777216 false false 75 270 75 240 75 270 90 240 90 270 105 240 105 270 120 240 120 270 135 240 135 270 150 240 150 270 165 240 165 270 180 240 180 270 195 240 195 270 210 240 210 270 225 240 225 270

falchion_tank_cannon
true
0
Circle -16777216 true false 135 135 30
Circle -16777216 true false 135 150 30
Circle -16777216 false false 135 150 30
Polygon -7500403 true true 150 180 180 150 165 45 135 45 120 150 150 180 165 180
Polygon -16777216 false false 135 45 165 45 180 150 150 180 120 150 135 45

federation_station
true
0
Polygon -7500403 true true 150 150 165 75 135 75
Polygon -16777216 false false 150 150 165 75 135 75
Polygon -7500403 true true 150 150 240 135 240 165
Polygon -16777216 false false 150 150 240 135 240 165
Polygon -7500403 true true 150 150 60 135 60 165
Polygon -16777216 false false 150 150 60 135 60 165
Circle -7500403 true true 108 108 85
Circle -16777216 false false 116 116 67
Circle -16777216 true false 129 129 42
Polygon -7500403 true true 150 45 180 30 210 30 255 60 285 150 255 240 225 270 195 270 180 255 180 225 195 210 225 210 225 90 180 90 150 75
Polygon -7500403 true true 150 45 120 30 90 30 45 60 15 150 45 240 75 270 105 270 120 255 120 225 105 210 75 210 75 90 120 90 150 75
Rectangle -16777216 true false 195 225 225 255
Rectangle -16777216 true false 75 225 105 255
Polygon -16777216 true false 210 45 180 45 150 60 180 75 210 75
Polygon -16777216 true false 90 45 120 45 150 60 120 75 90 75
Polygon -16777216 false false 60 60 30 150 60 240
Polygon -16777216 false false 240 60 270 150 240 240
Line -16777216 false 270 150 240 195
Line -16777216 false 270 150 240 105
Line -16777216 false 30 150 60 105
Line -16777216 false 30 150 60 195
Line -16777216 false 30 150 60 165
Line -16777216 false 30 150 60 135
Line -16777216 false 270 150 240 135
Line -16777216 false 270 150 240 165
Polygon -16777216 false false 150 45 120 30 90 30 45 60 15 150 45 240 75 270 105 270 120 255 120 225 105 210 75 210 75 163 107 158 107 141 75 136 75 90 120 90 136 82 141 108 159 108 163 82 180 90 225 90 225 137 193 141 193 157 225 164 225 210 195 210 180 225 180 255 195 270 225 270 255 240 285 150 255 60 210 30 180 30

gauntlet_fighter
true
0
Polygon -7500403 true true 195 195 180 180 180 195 195 225
Polygon -16777216 false false 195 195 195 225 180 195 180 180
Polygon -7500403 true true 105 195 120 180 120 195 105 225
Polygon -16777216 false false 105 195 105 225 120 195 120 180
Polygon -7500403 true true 120 270 105 210 105 120 90 105 90 30 60 45 45 180 15 195 15 225 60 240 75 255 120 270
Polygon -7500403 true true 135 75 165 75 180 105 180 195 165 255 135 255 120 195 120 105 135 75
Polygon -7500403 true true 180 270 195 210 195 120 210 105 210 30 240 45 255 180 285 195 285 225 240 240 225 255 180 270
Polygon -16777216 false false 180 270 225 255 240 240 195 210
Line -16777216 false 255 180 195 210
Line -16777216 false 255 180 240 240
Line -16777216 false 210 105 225 195
Line -16777216 false 210 30 255 180
Rectangle -16777216 false false 135 75 165 255
Polygon -16777216 false false 165 75 180 105 180 195 165 255
Polygon -16777216 false false 135 75 120 105 120 195 135 255
Polygon -16777216 false false 90 30 60 45 45 180 15 195 15 225 60 240 75 255 120 270 105 210 105 120 90 105
Polygon -16777216 false false 210 30 240 45 255 180 285 195 285 225 240 240 225 255 180 270 195 210 195 120 210 105
Line -16777216 false 45 180 60 240
Polygon -16777216 false false 120 270 75 255 60 240 105 210
Line -16777216 false 90 105 75 195
Line -16777216 false 90 30 45 180
Line -16777216 false 45 180 105 210
Polygon -13345367 true false 150 120 165 135 150 180 135 135
Line -16777216 false 180 105 165 120
Line -16777216 false 120 105 135 120
Line -16777216 false 120 195 135 180
Line -16777216 false 180 195 165 180
Polygon -16777216 false false 135 135 150 120 165 135 150 180

green-money
true
10
Polygon -10899396 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -1 true false 195 105 180 105 180 75 120 75 105 90 105 120 120 135 180 135 195 150 195 210 180 225 105 225 90 195 90 180 105 180 120 210 165 210 180 195 180 165 165 150 105 150 90 135 90 75 105 60 180 60 195 75 195 90
Polygon -1 true false 120 45 120 240 135 240 135 45 120 45
Polygon -1 true false 150 45 150 240 165 240 165 45 150 45

green-shield
true
3
Polygon -14835848 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -7500403 true false 75 90 75 195 150 255 225 195 225 90 75 90
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0

iron-sword
true
4
Polygon -2674135 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -7500403 true false 150 45 120 75 120 180 120 195 180 195 180 75
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -16777216 true false 105 225 105 195 195 195 195 225 105 225
Polygon -7500403 true false 135 225 135 255 165 255 165 225 135 225

line
true
0
Line -7500403 true 150 0 150 300

lone_scout-a
true
0
Rectangle -7500403 true true 105 75 195 255
Rectangle -16777216 false false 120 90 180 240
Line -16777216 false 120 240 105 255
Line -16777216 false 120 90 105 75
Line -16777216 false 180 90 195 75
Line -16777216 false 180 240 195 255
Polygon -7500403 true true 210 75 255 105 255 225 210 255
Polygon -7500403 true true 90 75 45 105 45 225 90 255
Rectangle -16777216 false false 105 75 195 255
Polygon -13345367 true false 180 255 165 270 135 270 120 255
Polygon -7500403 true true 120 75 135 45 165 45 180 75
Polygon -7500403 true true 210 135 195 105 195 225 210 195
Polygon -7500403 true true 90 135 105 105 105 225 90 195
Polygon -16777216 false false 105 105 90 135 90 195 105 225
Polygon -16777216 false false 195 105 210 135 210 195 195 225
Polygon -16777216 false false 90 75 45 105 45 225 90 255
Polygon -16777216 false false 210 75 255 105 255 225 210 255
Rectangle -16777216 true false 135 105 165 225
Line -16777216 false 150 45 180 75
Line -16777216 false 150 45 120 75
Line -16777216 false 150 45 165 75
Line -16777216 false 150 45 135 75
Line -16777216 false 150 45 150 75
Polygon -16777216 false false 120 75 135 45 165 45 180 75

missile
true
0
Circle -1 true false 120 0 60
Rectangle -7500403 true true 120 30 180 195
Polygon -7500403 false true 120 135 75 180 75 240 120 195 120 180
Polygon -1 true false 120 135 90 180 90 240 120 195 120 135
Polygon -1 true false 180 135 180 180 180 195 210 240 210 180 180 135
Polygon -955883 true false 135 195 135 210 150 225 165 210 165 195 135 195
Polygon -1184463 true false 135 195 135 225 150 255 165 225 165 195 165 210 150 225 135 210 135 195
Polygon -2674135 true false 135 195 120 225 120 240 135 270 150 300 165 270 180 240 180 225 165 195 165 225 150 255 135 225 135 195

proton-torp
true
0
Circle -2674135 true false 105 0 90
Polygon -2674135 true false 105 45 195 45 150 300 105 45
Circle -955883 true false 120 15 60
Polygon -955883 true false 120 45 150 195 180 45 120 45
Circle -1184463 true false 135 30 30
Polygon -1184463 true false 135 45 165 45 150 120 135 45 165 45

proton-torpedo
true
10
Polygon -1184463 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -1 true false 150 120 150 180 225 180 225 120 165 120
Polygon -7500403 true false 120 120 120 180 150 165 150 135 120 120
Polygon -2674135 true false 60 150 90 180 120 180 120 120 90 120

protoss-pylon
true
10
Polygon -955883 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -11221820 true false 150 45 90 150 120 195 150 240 210 150
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -1184463 true false 105 120 60 135 60 165 90 180 210 180 240 165 240 135 195 120 210 135 225 150 210 165 90 165 75 150 90 135

red-heart
true
3
Polygon -11221820 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -2674135 true false 60 135 105 195 150 255 195 195 240 135 150 120
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -2674135 true false 60 135 150 120 105 75 60 135
Polygon -2674135 true false 240 135 195 75 150 120

rogue_one
true
0
Polygon -7500403 true true 150 61 270 196 240 196 210 181 180 196 150 181 120 196 90 181 60 196 30 196 150 61
Polygon -8630108 true false 165 90 135 90 120 195 150 180 180 195 165 90
Polygon -2674135 true false 180 120 210 165 195 180 180 120
Polygon -2674135 true false 120 120 90 165 105 180 120 120
Circle -2674135 true false 49 174 18
Circle -2674135 true false 233 174 18
Circle -16777216 false false 234 174 18
Circle -16777216 false false 48 174 18
Polygon -16777216 false false 180 120 195 180 210 165 180 120
Polygon -16777216 false false 120 120 105 180 90 165 120 120
Polygon -2674135 true false 150 105 150 165 165 180 150 105 135 180 150 165
Polygon -16777216 false false 150 105 165 180 150 165 135 180 150 105
Line -16777216 false 150 105 165 90
Line -16777216 false 150 105 135 90
Line -16777216 false 135 180 120 195
Line -16777216 false 165 180 180 195
Line -16777216 false 135 90 120 195
Line -16777216 false 165 90 180 195
Polygon -2674135 true false 150 75 120 105 150 90 180 105 150 75
Polygon -16777216 false false 150 75 120 105 150 90 180 105 150 75
Line -16777216 false 105 180 120 195
Line -16777216 false 195 180 180 195
Line -16777216 false 90 165 60 195
Line -16777216 false 210 165 240 195
Polygon -16777216 true false 186 114 216 144 216 159 186 114
Polygon -16777216 true false 114 114 84 144 84 159 114 114

shield
true
0
Circle -11221820 true false 0 0 300
Polygon -1 false false 150 120 120 135 120 165 150 180 180 165 180 135 150 120
Polygon -1 false false 120 135 90 120 60 135 60 165 90 180 120 165
Polygon -1 false false 60 135 30 120 0 135 0 165 30 180 60 165
Polygon -1 false false 90 120 90 90 60 75 30 90 30 120 60 135 90 120
Polygon -1 false false 90 90 120 75 150 90 150 120 120 135 90 120 90 90
Polygon -1 false false 150 90 180 75 210 90 210 120 180 135 150 120 150 90
Polygon -1 false false 180 135 180 165 210 180 240 165 270 180 300 165 300 135 270 120 240 135 240 165 240 135 210 120 180 135 180 165
Polygon -1 false false 90 90 60 75 60 45 90 30 120 45 120 75 90 90
Polygon -1 false false 120 75 120 45 150 30 180 45 180 75 150 90 120 75
Line -1 false 180 45 210 30
Line -1 false 210 30 240 45
Polygon -1 false false 240 45 240 75 210 90 180 75 180 45 210 30 240 45
Polygon -1 false false 240 75 210 90 210 120 240 135 270 120 270 90 240 75
Polygon -1 false false 60 165 30 180 30 210 60 225 90 210 90 180 60 165
Polygon -1 false false 90 180 90 210 60 225 60 255 90 270 120 255 120 225 90 210
Polygon -1 false false 120 225 150 210 150 180 120 165 90 180 90 210 120 225
Polygon -1 false false 150 210 120 225 120 255 150 270 180 255 180 225 150 210 120 225
Polygon -1 false false 210 210 180 225 180 255 210 270 240 255 240 225 210 210
Polygon -1 false false 210 180 210 210 240 225 270 210 270 180 240 165 210 180 210 210
Circle -11221820 false false -3 -3 306

star-drone
true
11
Polygon -5825686 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -7500403 true false 120 195 120 255 150 285 180 255 180 195 120 195
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -7500403 true false 120 75 120 105 105 120 105 150 135 180 165 180 195 150 195 120 180 105 180 75 210 105 210 165 180 195 120 195 90 165 90 105 120 75
Polygon -16777216 false false 120 195 120 255 150 285 180 255 180 195 120 195 120 225
Line -16777216 false 120 210 180 210
Line -16777216 false 120 225 180 225
Line -16777216 false 120 240 180 240
Line -16777216 false 120 255 180 255
Line -16777216 false 135 270 165 270

star_destroyer
true
10
Polygon -7500403 true false 150 30 240 240 150 270 60 240 150 30
Rectangle -7500403 true false 120 255 180 270
Rectangle -7500403 true false 90 240 210 255
Polygon -16777216 false false 180 195 120 195 120 210 135 225 135 240 150 255 165 240 165 225 180 210 180 195
Polygon -16777216 false false 165 120 135 120 150 60 165 120
Line -16777216 false 165 150 165 135
Line -16777216 false 135 150 135 135
Line -16777216 false 165 150 150 165
Line -16777216 false 150 165 135 150
Line -16777216 false 150 165 150 195
Line -16777216 false 165 225 135 225
Line -16777216 false 195 225 180 225
Line -16777216 false 120 225 105 225
Polygon -16777216 false false 150 105 150 75 150 105
Polygon -16777216 false false 180 195 180 165 165 135 135 135 120 165 120 195
Polygon -16777216 false false 180 165 210 225 150 255 90 225 120 165
Line -16777216 false 165 105 135 105

tantive_iv
true
0
Polygon -7500403 true true 195 60 195 30 150 15 105 30 105 60 120 75 120 105 105 135 105 150 120 165 120 180 105 195 105 210 105 285 195 285 195 210 195 195 180 180 180 165 195 150 195 135 180 105 180 75 195 60
Rectangle -16777216 false false 135 75 165 105
Rectangle -16777216 false false 105 195 195 285
Line -16777216 false 180 195 180 285
Line -16777216 false 165 195 165 285
Line -16777216 false 150 195 150 285
Line -16777216 false 135 195 135 285
Line -16777216 false 120 195 120 285
Circle -16777216 true false 135 150 30
Polygon -2674135 true false 150 15 120 26 180 25
Polygon -2674135 true false 112 28 105 30 105 60 112 69
Polygon -2674135 true false 188 28 195 30 195 60 188 69
Rectangle -16777216 true false 120 33 180 63
Polygon -16777216 false false 150 105 195 150 165 135 135 135 105 150 150 105
Polygon -16777216 false false 150 105 165 150 150 165 135 150
Line -16777216 false 195 255 105 255
Line -16777216 false 195 225 105 225
Polygon -16777216 false false 180 195 120 195 150 165
Polygon -16777216 false false 150 15 195 30 195 60 180 75 180 105 195 135 195 150 180 165 180 180 195 195 195 285 105 285 105 195 120 180 120 165 105 150 105 135 120 105 120 75 105 60 105 30

tie_fighter
true
0
Rectangle -7500403 true true 60 45 75 255
Rectangle -7500403 true true 135 105 165 120
Rectangle -7500403 true true 120 120 135 135
Rectangle -7500403 true true 105 135 120 165
Rectangle -7500403 true true 165 120 180 135
Rectangle -7500403 true true 180 135 195 165
Rectangle -7500403 true true 165 165 180 180
Rectangle -7500403 true true 120 165 135 180
Rectangle -7500403 true true 135 180 165 195
Rectangle -7500403 true true 225 45 240 255
Rectangle -7500403 true true 135 135 165 165
Rectangle -16777216 true false 120 135 135 165
Rectangle -16777216 true false 165 135 180 165
Rectangle -16777216 true false 135 165 165 180
Rectangle -16777216 true false 135 120 165 135
Rectangle -7500403 true true 75 142 105 157
Rectangle -7500403 true true 195 142 225 157

time-stop
true
10
Polygon -8630108 true false 150 0 30 75 30 225 150 300 270 225 270 75 150 0
Polygon -1 true false 150 0 150 15 45 90 45 210 150 285 255 210 255 90 150 15 150 0 270 75 270 225 150 300 30 225 30 75 150 0
Polygon -6459832 true false 90 75 90 90 210 90 210 75 105 75
Polygon -6459832 true false 90 210 90 225 210 225 210 210 150 210
Polygon -1 true false 90 90 210 210 90 210 210 90 90 90

valor_station
true
0
Polygon -16777216 false false 255 45 225 45 210 60 210 90 225 105 255 105 270 90 270 60
Rectangle -7500403 true true 141 180 161 255
Rectangle -16777216 false false 141 180 161 256
Polygon -7500403 true true 165 120 180 135 240 90 225 75
Polygon -16777216 false false 225 75 165 120 180 135 240 90
Polygon -7500403 true true 135 120 120 135 60 90 75 75
Polygon -16777216 false false 75 75 135 120 120 135 60 90
Circle -7500403 true true 105 105 90
Rectangle -16777216 false false 127 128 172 173
Rectangle -16777216 false false 135 135 165 165
Circle -16777216 true false 135 135 30
Line -16777216 false 128 170 136 164
Line -16777216 false 127 128 135 136
Line -16777216 false 171 128 164 135
Line -16777216 false 171 172 164 164
Circle -16777216 false false 108 108 85
Polygon -7500403 true true 75 45 45 45 30 60 30 90 45 105 75 105 90 90 90 60
Polygon -7500403 true true 225 45 255 45 270 60 270 90 255 105 225 105 210 90 210 60
Polygon -7500403 true true 165 233 135 233 120 248 120 278 135 293 165 293 180 278 180 248
Rectangle -16777216 true false 135 248 165 278
Rectangle -16777216 true false 45 60 75 90
Rectangle -16777216 true false 225 60 255 90
Line -16777216 false 117 106 104 121
Line -16777216 false 100 92 86 109
Line -16777216 false 183 106 196 121
Line -16777216 false 200 92 214 109
Line -16777216 false 141 210 160 210
Line -16777216 false 140 225 160 225
Polygon -16777216 false false 135 233 119 246 119 278 134 293 165 293 181 277 181 248 166 232 136 232 119 246
Polygon -16777216 false false 45 45 75 45 90 60 90 90 75 105 45 105 30 90 30 60

void
true
0

x-wing
true
0
Rectangle -1 true false 150 30 165 135
Rectangle -7500403 true true 135 135 180 195
Rectangle -1 true false 150 180 165 195
Rectangle -2674135 true false 135 75 150 150
Rectangle -2674135 true false 165 75 180 150
Rectangle -1 true false 45 195 45 210
Rectangle -1 true false 30 210 45 210
Rectangle -1 true false 45 195 270 225
Rectangle -1 true false 60 225 240 240
Rectangle -1 true false 90 240 210 255
Rectangle -1 true false 105 240 105 255
Rectangle -7500403 true true 105 240 120 285
Rectangle -7500403 true true 90 195 135 240
Rectangle -7500403 true true 180 195 225 240
Rectangle -2674135 true false 60 195 90 225
Rectangle -1 true false 120 180 120 195
Rectangle -1 true false 120 120 135 195
Rectangle -1 true false 180 120 195 195
Rectangle -2674135 true false 225 195 255 225
Rectangle -7500403 true true 195 240 210 285
Rectangle -1 true false 45 135 60 195
Rectangle -1 true false 255 135 270 195

yavin_4
true
0
Circle -14835848 true false -1 -1 301
Polygon -10899396 true false 45 60 75 75 135 75 150 105 150 150 120 165 135 195 135 270 90 225 90 165 105 165 60 135 60 90 45 60
Polygon -10899396 true false 165 75 180 120 210 135 195 165 225 210 270 180 255 135 255 90 210 75 165 75
Polygon -13840069 true false 165 210 180 225 195 225 180 195 165 210
Polygon -13840069 true false 240 225 240 240 270 225 285 195 240 225
Polygon -13840069 true false 15 195 30 240 75 240 75 195 45 165 15 195
Polygon -1 true false 90 30 105 45 180 60 195 45 150 15 90 30
Polygon -1 true false 195 45 225 45 240 30 150 15
Polygon -1 true false 90 30 60 30 135 15 150 15
Polygon -1 true false 90 270 135 285 195 270 210 285 165 300 105 285 90 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
