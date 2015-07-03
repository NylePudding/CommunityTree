;;COMMUNITY TREE
;;MADE BY LLEWELYN GRIFFITHS
;; 01/07/2015

;; Useful info
;; LINKS
;; Red - "Official" partner
;; Green - Child of
;; Brown - Divorced
;; Black - Afair

;;TODO/IDEAS
;; - Check for previous divorces/afairs when selecting a partner
;; - Add random names for each turtle
;; - Rework intrigue cycle by incrementing years, the age of a turtle effects certain events.
;; - Rework generation checking to be more elegant and customisable. 
;; - Make visual representation more clear.
;; - Print what happens with each intrigue cycle.





turtles-own[forename surname partner children gender mother father homosexual had-children afairs afair-avaliable divorces]

to setup
  
  clear-all
  set-default-shape turtles "person"
  
  ask patches[
    set pcolor white
  ]
  repeat STARTING-COUPLES [
    make-couple
  ]
  
end

to demo
  
  setup
  
  repeat 2[
    generation-cycle
  ]
  
  repeat 1[
    intrigue-cycle
  ]
  
end


to generation-cycle
  
  create-families
  find-partners
  
end

to intrigue-cycle
  
  process-divorces
  process-afairs
  
end


to process-divorces
  ask turtles[
    if partner != -1 or partner != who[
      let rand random(101)
      if rand < DIVORCE-CHANCE[
        divorce who
      ]
    ]
  ]
end


to process-afairs
  ask turtles[
    let rand random(101)
    set afair-avaliable false
    if rand < AFAIR-CHANCE[
      set afair-avaliable true
    ]
  ]
  
  ask turtles[
    
    let me-who who
    
    if afair-avaliable = true[
      ask other turtles [
        if afair-avaliable = true[
          if generations-away 2 me-who who = true [
            have-afair me-who who
          ]
        ]
      ]
    ]
  ]
end

to have-afair[me them]
  ask turtle me[
    set afairs fput them afairs
    
    create-link-with turtle them [
      set color black
    ]
  ]
  
  ask turtle them[
    set afairs fput me afairs
  ]
end

to divorce[me]
  let them -1
  ask turtle me[
    set them partner
    set partner -1
    set had-children false
    set divorces fput them divorces
    if father != -1[
      let original-surname ""
      ask turtle father[
        set original-surname surname
      ]
      set surname original-surname
    ]
    if father = -1[
      set surname generate-surname
    ]

  ]
  if them != -1[
    ask turtle them[
      set partner -1
      set had-children false
      set divorces fput me divorces
      
      if father != -1[
        let original-surname ""
        ask turtle father[
          set original-surname surname
        ]
        set surname original-surname
      ]
      if father = -1[
        set surname generate-surname
      ]
      
    ]
  ]
  
  remove-links-between me them
  
  ask turtle me[
    if them != -1[
      create-link-with turtle them [
        set color brown
      ]
    ]
  ]
  
  
end

to remove-links-between [ a b ] 
   if is-link? link a b [ ask link a b [ die ] ] 
   if is-link? link b a [ ask link b a [ die ] ] 
end 

to create-families
  ask turtles [
    if homosexual = false[
      if partner != -1[
        if had-children = false[
          if gender = "m"[
            make-family who partner
          ]
          if gender = "f" [
            make-family partner who
          ]
        
          set had-children true 
        
          ask turtle partner [
            set had-children true
          ]
        ]
      ]
    ]
  ]
end

to find-partners
  ask turtles [
    
    let me who
    let match -1
    let g gender
    let last-name surname
    
    if partner = -1[
      
      ask other turtles [
        if generations-away 2 me who = true [
          if partner = -1 [
            if homosexual = false [
              if gender != g[
                set match who
              ]
            ]
            if homosexual = true [
              if gender = g [
                set match who
              ]
            ]
          ]
        ]
      ]
      
      
      if match != -1[
        let m-surname ""
        ask turtle match [
          set partner me
          set m-surname surname
          
          if homosexual = false[
            if gender = "f"[
              set surname last-name
            ]
          ]
          if homosexual = true[
            set surname last-name
          ]
          
          create-link-with turtle me [
            set color blue
          ]
        ]
        if homosexual = false [
          if gender = "f"[
            set surname m-surname
          ]
        ]
      ]
      
      
      if match = -1 [
        let rand random(101)
        if rand < OUTSIDER-CHANCE[
          make-outsider who
        ]
      ]
      
      if match != -1 [
        set partner match
      ]
      
    ]
  ]
end

to-report generations-away[g me target]
  
  ;;g parpameter currently unused
  let me-m -1
  let me-f -1
  let ta-m -1
  let ta-f -1
  let result true
  
  ask turtle me [
    set me-m mother
    set me-f father
  ]
  
  ask turtle target [
    if who = me-m or who = me-f [
      set result false
    ]
    if mother = me-m or father = me-f[
      set result false
    ]
    
    set ta-f father
    set ta-m mother
    
  ]
  
  if ta-f != -1 and ta-m != -1[
    ask turtle ta-f [
      if mother = me-m or father = me-f[
        set result false
      ]  
    ]
  
    ask turtle ta-m [
      if mother = me-m or father = me-f[
        set result false
      ]  
    ]
    
    foreach children[
      
      ask turtle ? [
        
        if who = me-m or who = me-f[
          set result false
        ]
        
        foreach children[
          
          ask turtle ? [
            if who = me-m or who = me-f[
              set result false
            ]
          ]
        ]
      ]
    ]
  ] 
  
    report result
end

to make-couple
  
  let c1 -1
  let c1-surname ""
  let c2 -1
  
  create-turtles 1 [
    setxy random-xcor random-ycor
    set color blue
    set forename generate-forename "m"
    set surname generate-surname
    set c1-surname surname
    set afair-avaliable false
    set afairs (list)
    set divorces (list)
    set partner -1
    set children (list)
    set gender "m"
    set mother -1
    set father -1
    set homosexual false
    set had-children false
    set c1 who
  ]
  create-turtles 1 [
    setxy random-xcor random-ycor
    set color red
    set forename generate-forename "f"
    set surname c1-surname
    set afair-avaliable false
    set afairs (list)
    set divorces (list)
    set partner c1
    set children (list)
    set gender "f"
    set mother -1
    set father -1
    set homosexual false
    set had-children false
    set c2 who
  ]
  
  ask turtle c1 [
    set partner c2
    create-link-with turtle c2 [
      set color red
    ]
  ]
  
end


to make-outsider[them]
  
  let outsider -1
  let them-gender "m"
  
  ask turtle them [
    set them-gender gender
  ]
  
  
  hatch 1 [
    setxy random-xcor random-ycor
    
    set partner them
    set children (list)
    
    
    if homosexual = false [
      if them-gender = "m"[
        set gender "f"
        set color red
      ]
      if them-gender = "f" [
        set gender "m"
        set color blue
      ]
    ]
    if homosexual = true [
      set gender them-gender
      if them-gender = "m"[
        set color blue
      ]
      if them-gender = "f"[
        set color red
      ]
    ]
    
    set forename generate-forename gender
    set mother -1
    set father -1
    set homosexual false
    set had-children false
    set afair-avaliable false
    set afairs (list)
    set divorces (list)
    
    set outsider who
  ]
  
  ask turtle them [
    set partner outsider
    create-link-with turtle outsider [
      set color red
    ]
  ]
  
end


to make-child[m f]
  let c-who -1
  
  hatch 1 [
    set partner -1
    set children (list)
    set mother f
    set father m
    set homosexual true
    set afair-avaliable false
    set afairs (list)
    set divorces (list)
    set had-children false
    set c-who who
    set homosexual false
    
    if random(101) < HOMOSEXUAL-CHANCE[
      set homosexual true
    ]
    
    let rand random(2)
    if rand = 1 [
      set gender "m"
      set color blue
    ]
    if rand = 0 [
      set gender "f"
      set color red
    ]
    
    set forename generate-forename gender
    
    create-link-with turtle m [
      set color green
    ]
    create-link-with turtle f [
      set color green
    ]
    
    ask turtle m [
      set children fput c-who children
    ]
    ask turtle f [
      set children fput c-who children
    ]
    
  ]
end


to make-family[m f]
  
  let c MAX-CHILDREN + 1
  
  let no-of-c random(c)
  
  repeat no-of-c [
    make-child m f
  ]
  
end

to-report generate-forename[g]
  let forenames (list)
  
  if g = "f"[
    set forenames (list "Sarah" "Amy" "Rosie" "Nicole" "Pennelope" "Rue" "Megan" "Hannah" "Bridget" "Jessica" "Guenevere" "Ellen" "Lilly" "Hermione" "Abbie" "Laura" "Kelly" "Mildrid" "Margaret" "Rossalind" "Elizabeth" "Nusha" "Ayumi" "Tara" "Sita" "Sophia" "Emma" "Olivia" "Mia" "Zoe" "Layla" "Hailey" "Evelyn" "Kaitlyn") 
  ]
  if g = "m"[
    set forenames (list "Jack" "Oliver" "Charlie" "Harry" "Jacob" "Alfie" "Noah" "Oscar" "George" "James" "Thomas" "Jon" "Joseph" "Toby" "Biedrik" "Logan" "Freddie" "Jake" "Aiden" "Barry" "Larry" "Ethan" "Theo" "Luke" "Ollie" "Lewis" "Adam" "Isaac" "Benjamin" "Harley" "Tyler" "Alex" "Tommy" "Connor" "Nathan" "Matthew")
  ]
  
  let len length forenames
  
  report item random(len) forenames
  
end

to-report generate-surname
  let surnames (list "Smith" "Evans" "Tinsley" "Wallace" "Officer" "Edwards" "Thomas" "Norton" "Rees" "Lees" "Stokell" "Bramwell" "Entwistle" "Scott" "Broome" "Mercer" "Cook" "Mennim" "Stark" "Bolton" "Snow" "Baratheon" "Malek" "Slater" "Doubleday" "Walker" "Marshall" "Womack" "Beardwood" "Gunn" "Gray" "Griffiths" "Orry")
  
  let len length surnames
  
  report item random(len) surnames
  
end

to who-is[them]
  
  clear-output
  
  ;;PARENTS
  
  ask turtle them[
    output-print (word "Bio for: " forename " " surname)
    let mum ""
    
    if mother != -1[
      ask turtle mother[
        set mum forename
        set mum (word mum " " surname) 
      ]
    ]
    
    output-print (word "Mother: " mum)
    
    let dad ""
    
    if father != -1[
      ask turtle father[
        set dad forename
        set dad (word dad " " surname) 
      ]
    ]
    
    output-print (word "Father: " dad)
  ]
  
  
  ;;SIBLINGS
  
  ask turtle them[
    
    let mum-siblings (list)
    let dad-siblings (list)
    let full-siblings (list)
    let half-siblings (list)
    
    ask turtle mother[
      set mum-siblings children
    ]
    ask turtle father[
      set dad-siblings children
    ]

    
    foreach mum-siblings[
      let m-s ?
      let dupe false
      
      foreach dad-siblings[
        let d-s ?
        if d-s = m-s[
          if d-s != who or m-s != who[
            set full-siblings fput d-s full-siblings
            set dupe true
          ]
        ]
      ]
      if dupe = false[
        if m-s != who[
          set half-siblings fput m-s half-siblings
        ]
      ]
    ]
    
    let sisters ""
    let brothers ""
    let half-sisters ""
    let half-brothers ""
    
    foreach full-siblings[
      ask turtle ? [
        let full-name (word forename " " surname)
        
        if gender = "f"[
          set sisters (word sisters full-name ", ")
        ]
        if gender = "m"[
          set brothers (word brothers full-name ", ")
        ]
      ]
    ]
    
    foreach half-siblings[
      ask turtle ? [
        let full-name (word forename " " surname)
        
        if gender = "f"[
          set half-sisters (word half-sisters full-name ", ")
        ]
        if gender = "m"[
          set half-brothers (word half-brothers full-name ", ")
        ]
      ]
    ]
    
     output-print (word "Sisters: " sisters)
     output-print (word "Brothers: " brothers)
     output-print (word "Half-sisters: " half-sisters)
     output-print (word "Half-brothers: " half-brothers)
    
  ]
  
end

to move
  layout-spring (turtles with [any? link-neighbors]) links 0.4 3 1 
end
@#$#@#$#@
GRAPHICS-WINDOW
485
70
924
530
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
278
174
341
207
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
41
215
165
248
NIL
generation-cycle
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
316
215
379
248
NIL
move
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
17
25
189
58
STARTING-COUPLES
STARTING-COUPLES
1
10
1
1
1
NIL
HORIZONTAL

SLIDER
18
71
190
104
MAX-CHILDREN
MAX-CHILDREN
1
10
10
1
1
NIL
HORIZONTAL

SLIDER
18
116
190
149
OUTSIDER-CHANCE
OUTSIDER-CHANCE
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
16
163
196
196
HOMOSEXUAL-CHANCE
HOMOSEXUAL-CHANCE
0
100
0
1
1
NIL
HORIZONTAL

BUTTON
295
132
400
165
NIL
intrigue-cycle
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
264
28
436
61
DIVORCE-CHANCE
DIVORCE-CHANCE
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
264
72
436
105
AFAIR-CHANCE
AFAIR-CHANCE
0
100
10
1
1
NIL
HORIZONTAL

BUTTON
360
174
423
207
NIL
demo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
9
337
471
524
12

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
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
