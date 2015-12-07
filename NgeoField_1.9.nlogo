;; Perry Houser
;; Geo-Compuation
;; GeoField Sim - Main Project

;; Simulate geologic field mapping exercise (Mount Cristo Rey)
;; where users are given various degrees of information about the site and 
;; their possible behaviors moving about the field when given this information.
;; users are given various degrees of information about the site 
;; and their possible behaviors moving about the field when given this information.
;;
;; NOTE: the ticks option on the interface page should be set from Continuous to "on tick"
;;

extensions [array] ;; we are using an array to hold the cell geology data


turtles-own [
  goal
  ma10-13
  ]

patches-own [
  popularity
  pa10-13           
  ]
 
globals [
  feature
  ]

;; Create the start-up button
to setup
  clear-all ;; clear the main screen for a fresh start
  reset-ticks  ;; reset the clock to zero 
  set feature(list)

  import-pcolors "bound3.jpg" ;; this is the image of the fieldsite with boundaries and hazards

  setup-patches ;; run the function that will setup the ground level
  setup-geology ;; add the geologic features (faults/depo contacts/folds)
  setup-turtles ;; run the function that will setup the field mappers (people/turtles)
end

to go
  check-feature-placement
  ask turtles [move-turtles]
  decay-popularity
  tick
end

;; setup the ground features, aka the field site
to setup-patches
    ask patch 2 -3 [set plabel "Mine"]  ;; place 3 labels, 1 for each mine location
    ask patch -11 5 [set plabel "Mine"]
    ask patch -12 5 [set pcolor 14.9] ;; manual correction for cell that needed to be red
    ask patch -3 10 [set plabel "Mine"]
    ask patches [set popularity 1]
end

;; setup the mappers, aka the field-mappers, turtles
to setup-turtles
    create-turtles Mapping_Groups ;; create turtles using the number from the tcount slider
    ask turtles [setxy 12 -10] ;; place users at the starting site of the map
    ask turtles [set shape "person"] ;; change the arrows to a person shape
    ask turtle 0 [set color Yellow] ;; change colors of each person 1 of 3 - orange
    ask turtle 1 [set color blue] ;; change colors of each person 2 of 3 - blue 

end

to record_data10-13
 if xcor = 10 and ycor = -13 [
 if any? turtles-here
    [ask turtle 0 [set ma10-13 array:from-list n-values 7 [pa10-13] ] ];; record patch info to turtles array info
 
 if any? turtles-here
    [ask turtle 1 [set ma10-13 array:from-list n-values 7 [pa10-13] ] ];; record patch info to turtles array info
 ]
end

;; function to move the turtles around
to move-turtles  
  if plabel != "" [
    ;; found a geologic feature
    set plabel "•" ;; mark it as visited and recorded
    record_data10-13  ;; save the patch array data to the mappers array data     
    ]    
  if plabel = "•" [
    ;; found a geologic feature already visited 
    record_data10-13  ;; go to save the patch array data to the mappers array data 
    ]  
    right random 360 ;; pick a random direction to move toward from 0 - 360
    forward 1 ;; move 1 cell in that random direction
    decay-popularity 

    if pcolor = black [  ;; if the pcolor is black then it is a boundary line
      back 1  ;; cannot go foward anymore so move back and try random movement again
    ]
    if pcolor = 14.9 [ ;; if the pcolor is red then it is a Hazard (i.e. a Mine Shaft)
      back 1  ;; cannot go foward anymore so move back and try random movement again 
    ]
    set pcolor green ;; if person is on a cell then they have data, change it to green
  
  if plabel = "" [   ;; if patch label has nothing then keep moving
    right random 360 ;; pick a random direction to move toward from 0 - 360
    forward 1 ;; move 1 cell in that random direction
    
    if pcolor = black [  ;; if the pcolor is black then it is a boundary line
      back 1  ;; cannot go foward anymore so move back and try random movement again
    ]
    if pcolor = 14.9 [ ;; if the pcolor is red then it is a Hazard (i.e. a Mine Shaft)
      back 1  ;; cannot go foward anymore so move back and try random movement again 
    ]
    set pcolor green ;; if person is on a cell then they have data, change it to green
  ] ;; end if plabel
end

to check-feature-placement
  if mouse-down?
  [ask patch (round mouse-xcor) (round mouse-ycor) [
    ifelse pcolor = red
    [ unbecome-feature ]
    [ become-feature ]
  ]]
end

to unbecome-feature
  set pcolor grey
  set popularity 1
  set feature (remove self feature)
end

to become-feature
  set pcolor 25
  set feature (fput self feature)
end

to decay-popularity
  ask patches with [pcolor != red] [
    if popularity > 1 and not any? turtles-here [ set popularity popularity * (100 - popularity-decay-rate) / 100 ]
    ifelse pcolor = green
    [ if popularity < 1 [ set popularity 1 ] ]
    [ if popularity < 1 [ 
        set popularity 1 
        set pcolor green 
        ] ]    
  ]
end
to become-more-popular
  set popularity popularity + popularity-per-step
  if popularity > minimum-route-popularity [ set pcolor gray ]
end

to walk-towards-goal
  let last-distance distance goal
  let best-route-tile route-on-the-way-to goal last-distance

  ; boost the popularity of the route we're using
  if pcolor = green
  [ ask patch-here [become-more-popular] ]

  ifelse best-route-tile = nobody
  [ face goal ]
  [ face best-route-tile ]
  fd 1
end

to-report route-on-the-way-to [l current-distance]
  let routes-on-the-way-to-goal (patches in-radius person-vision-dist with [
      pcolor = brown and distance l < current-distance - 1
    ])
  report min-one-of routes-on-the-way-to-goal [distance self] 
end

to setup-geology    
    ;; add data for specific patches indicating a geologic feature
    ;; ask patch 0 0 [set plabel "∞§•–≠«∆¬≥≤≈"] ;;Symbol for features
    ;; ask patch 5 0 [set plabel "§"] ;;Symbol for Outcrop features
    ;; ask patch 5 10 [set plabel "∞"] ;;Symbol for Overturned Bed features
    ;;ask patch 1 0 [set plabel "||"] ;;Symbol for Vertical bed features
    ;;ask patch 2 0 [set plabel "≈"] ;;Symbol for Fold features
    ;;ask patch 3 0 [set plabel "•"] ;;Symbol for Station note 
    ;;ask patch 4 0 [set plabel "–"] ;;Symbol for Fault features
    ;;ask patch 5 0 [set plabel "«"] ;;Symbol for Normal Fault features
    ;;ask patch 6 0 [set plabel "∆"] ;;Symbol for Trust Fault features
    ;;ask patch 7 0 [set plabel "≥"] ;;Symbol for Dextral Fault features
    ;;ask patch 8 0 [set plabel "≤"] ;;Symbol for Sinstral Fault features
    ;;ask patch 9 0 [set plabel ""] ;;Symbol for Depositional Contact features
    ;;ask patch 10 0 [set plabel "¬"] ;;Symbol for Stike Dip measurement feature
    
    
    ;; set the data on the map
    ask patch 0 0 [set plabel "O"] ;;Symbol for Outcrop features
 
    ask patch 0 1 [set plabel "§≈"] ;;Symbol for Fold features
    ask patch 0 2 [set plabel "§≈"] ;;Symbol for Fold features
    ask patch 0 3 [set plabel "§∆"] ;;Symbol for Thrust features    
    ask patch 0 4 [set plabel "§"] ;;Symbol for Outcrop features    
    ask patch 0 7 [set plabel "§∆"] ;;Symbol for Thrust features        
    ask patch 0 8 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 0 10 [set plabel "§"] ;;Symbol for Outcrop features     
    ask patch 0 11 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 0 12 [set plabel "§∆"] ;;Symbol for Thrust features  
    
    ask patch 0 -4 [set plabel "§∆"] ;;Symbol for Thrust features    
    ask patch 0 -5 [set plabel "§∆"] ;;Symbol for Thrust features        
    ask patch 0 -6 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 0 -8 [set plabel "§"] ;;Symbol for Outcrop features   

    ask patch 2 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 4 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 5 0 [set plabel "§∆"] ;;Symbol for Thrust features
    ask patch 7 0 [set plabel "§≈"] ;;Symbol for Fold features
    
    ask patch -1 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -2 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -5 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -6 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -7 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -8 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -9 0 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -10 0 [set plabel "§∆"] ;;Symbol for Thrust features  
      
    ask patch 2 1 [set plabel "§≈"] ;;Symbol for Fold features
    ask patch 2 3 [set plabel "§≈"] ;;Symbol for Fold features  
    ask patch 2 5 [set plabel "§-"] ;;Symbol for Outcrop features    
    ask patch 2 6 [set plabel "§≈"] ;;Symbol for Fold features         
    ask patch 2 7 [set plabel "§-"] ;;Symbol for Fault features
    ask patch 2 8 [set plabel "§-"] ;;Symbol for Outcrop features     
    ask patch 2 9 [set plabel "§∆"] ;;Symbol for Thrust features  
    ask patch 2 10 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 2 11 [set plabel "§"] ;;Symbol for Outcrop features  
      
    ask patch -2 1 [set plabel "§≈"] ;;Symbol for Fold features
    ask patch -2 3 [set plabel "§≈"] ;;Symbol for Fold features  
    ask patch -2 5 [set plabel "§-"] ;;Symbol for Outcrop features    
    ask patch -2 6 [set plabel "§≈"] ;;Symbol for Fold features         
    ask patch -2 7 [set plabel "§-"] ;;Symbol for Fault features
    ask patch -2 8 [set plabel "§-"] ;;Symbol for Outcrop features     
    ask patch -2 9 [set plabel "§∆"] ;;Symbol for Thrust features  
    
    ask patch -2 -2 [set plabel "§-"] ;;Symbol for Fault features 
    ask patch -2 -3 [set plabel "§∆"] ;;Symbol for Thrust features    
    ask patch -2 -5 [set plabel "§"] ;;Symbol for Outcrop features 
    ask patch -2 -6 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -2 -7 [set plabel "§"] ;;Symbol for Outcrop features

    ask patch 2 -1 [set plabel "§"] ;;Symbol for Outcrop features 
    ask patch 2 -5 [set plabel "§≈"] ;;Symbol for Fold features         
    ask patch 2 -8 [set plabel "§"] ;;Symbol for Outcrop features
              
    ask patch 5 0 [set plabel "§∆"] ;;Symbol for Thrust features  
    ask patch 5 1 [set plabel "§≈"] ;;Symbol for Fold features      
    ask patch 5 2 [set plabel "§≈"] ;;Symbol for Fold features  
    
    ask patch -5 2 [set plabel "§-"] ;;Symbol for Fault features
    ask patch -5 4 [set plabel "§≈"] ;;Symbol for Fold features 
    ask patch -5 5 [set plabel "§≈"] ;;Symbol for Fold features 
    ask patch -5 6 [set plabel "§-"] ;;Symbol for Fault features
    ask patch -5 7 [set plabel "§-"] ;;Symbol for Fault features
    ask patch -5 8 [set plabel "§"] ;;Symbol for Outcrop features  
    ask patch -5 9 [set plabel "§"] ;;Symbol for Outcrop features  
    ask patch -5 10 [set plabel "§"] ;;Symbol for Outcrop features  
    ask patch -5 11 [set plabel "§"] ;;Symbol for Outcrop features      
    ask patch -5 12 [set plabel "§∆"] ;;Symbol for Fault features
    ask patch -5 13 [set plabel "§∆"] ;;Symbol for Fault features
    ask patch -5 14 [set plabel "§∆"] ;;Symbol for Fault features                    

    ask patch -5 -1 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -5 -3 [set plabel "§∆"] ;;Symbol for Fault features
    ask patch -5 -5 [set plabel "§"] ;;Symbol for Outcrop features 
    ask patch -5 -6 [set plabel "§"] ;;Symbol for Outcrop features  

    ask patch 5 -3 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 5 -4 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 5 -5 [set plabel "§"] ;;Symbol for Outcrop features            
    
    ask patch 10 -5 [set plabel "§∆"] ;;Symbol for Fault features   
    ask patch 10 -10 [set plabel "§≈"] ;;Symbol for Fold features 
    
    ask patch 10 -13 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch 10 -13 [set pa10-13 array:from-list n-values 7 [0]  ]         
    ask patch 10 -13 [array:set pa10-13 0 10 ] ;;Add the pcorX to array
    ask patch 10 -13 [array:set pa10-13 1 -13 ] ;;Add the pcorY to array
    ask patch 10 -13 [array:set pa10-13 2 "¢" ] ;;Add the Outcrop Type
    ask patch 10 -13 [array:set pa10-13 3 "Kmo" ] ;;Add the Outcrop Abbr.
    ask patch 10 -13 [array:set pa10-13 4 "Mojado" ] ;;Add the Outcrop Name
    ask patch 10 -13 [array:set pa10-13 5 315 ] ;;Add the Outcrop Strike
    ask patch 10 -13 [array:set pa10-13 6 "25" ] ;;Add the Outcrop Dip
   
                         
    ask patch -10 1 [set plabel "§∆"] ;;Symbol for Fault features                
    ask patch -10 3 [set plabel "§"] ;;Symbol for Outcrop features                   
    ask patch -10 4 [set plabel "§"] ;;Symbol for Outcrop features                   
    ask patch -10 7 [set plabel "§"] ;;Symbol for Outcrop features                   
    ask patch -10 8 [set plabel "§"] ;;Symbol for Outcrop features    
                   
    ask patch -10 -0 [set plabel "§∆"] ;;Symbol for Fault features  
    ask patch -10 -1 [set plabel "§∆"] ;;Symbol for Fault features  
    ask patch -10 -3 [set plabel "§"] ;;Symbol for Outcrop features  
    
    ask patch -15 3 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -15 4 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -15 5 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -15 6 [set plabel "§"] ;;Symbol for Outcrop features
    ask patch -15 7 [set plabel "§"] ;;Symbol for Outcrop features 
end
