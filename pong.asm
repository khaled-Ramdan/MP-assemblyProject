STACK SEGMENT PARA STACK 
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'

	WINDOW_WIDTH DW 140h ;The width of the window (320 pixels)
	WINDOW_HEIGHT DW  0C8h ; the height of the window (200 pixels)
	WINDOW_BOUNDS DW 6;variable used to check collsions eaerly
	
	TIME_AUX DB 0; variable used when checking if the time has changed
	GAME_ACTIVE DB 1                     ;is the game active? (1 -> Yes, 0 -> No (game over))
	WINNER_INDEX DB 0                    ;the index of the winner (1 -> player one, 2 -> player two)
	
	BALL_ORIGINAL_X DW 0A0h
	BALL_ORIGINAL_Y DW 64h
	
	
	BALL_X DW 0A0h; x position (coloum) of the ball
	BALL_Y DW 64h; y position (line) of the ball 
	BALL_SIZE DW 06h;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 04h; x velocity of the ball (horizontal)
	BALL_VELOCITY_y DW 04h; y velocity of the ball (vertical)
	
	TEXT_PLAYER_ONE_POINTS DB '0','$'    ;text with the player one points
	TEXT_PLAYER_TWO_POINTS DB '0','$'    ;text with the player two points
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   start paddle   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;; Left Paddle ;;
	PADDLE_LEFT_X  DW 0AH                       ; position of left paddle  X
	PADDLE_LEFT_Y  DW 0AH			    ; position of left paddle  Y
	PLAYER_ONE_POINTS DB 0              ;current points of the left player (player one)
	;; Right paddle ;;
	PADDLE_RIGHT_X  DW 130H                     ; position of right paddle  X
	PADDLE_RIGHT_Y  DW 0AH			    ; position of right paddle  Y
	PLAYER_TWO_POINTS DB 0             ;current points of the right player (player two)
	;; size of paddles ;;
	PADDLE_WIDTH   DW 05H                       ; width of the paddle
	PADDLE_HEIGHT  DW 1FH                       ; height of the paddle
	;; move by this value ;;
	PADDLE_VELOCITY DW 05H                      ; velocity of the paddle
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   end paddle   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
DATA ENDS 


CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
	ASSUME CS:CODE,DS:DATA,SS:STACK ;assume as code,data and stack with thier respective registers
	PUSH DS						 	; push to the stack DS segment 
	SUB AX,AX 						; clean the AX register 
	PUSH AX							; push AX to the stack
	MOV AX,DATA						;save on the AX register the contents of the DATA segment
	MOV DS,AX						;save on the Ds segment the content of AX
	POP AX							;release the top item of the stack to the Ax register
	POP AX							;release the top item of the stack to the Ax register
	
	
	
		CALL CLEAR_SCREAN
		CHECK_TIME:
			MOV AH,2Ch;get the system time 
			INT 21h ; CH = hour CL = minute DH = second DL = 1/100 second
			
			CMP DL,TIME_AUX; is the current time equal to the previous one(TIME_AUX)?
			JE CHECK_TIME	;if it is the same => check again
			MOV TIME_AUX, DL;update time
			
			CALL CLEAR_SCREAN;  clear the screen before drawing ball
			CALL MOVE_BALL; moving the ball procedure
			CALL DRAW_BALL; draw ball
			
			CALL DRAW_PADDLE    ; set the size of paddle
			CALL DRAW_UI                 ;draw the game User Interface
			JMP  CHECK_TIME ; after everything checks => check time again
			

		RET
	MAIN ENDP
	
	;...................................MOVE BALL..................
	MOVE_BALL PROC NEAR
	;move the ball horizontally
		MOV AX,BALL_VELOCITY_X 
		ADD BALL_X, AX		   
		
		;ball x < 0 (y => collided)
		MOV AX,WINDOW_BOUNDS
		CMP BALL_X,AX
		JL GIVE_POINT_TO_PLAYER_TWO
	
		;ball x > window_width -ball size - window bounds (y=>collided) 
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_X,AX
		JG GIVE_POINT_TO_PLAYER_ONE 
		JMP MOVE_BALL_VERTICALLY
		
	;move the ball vertically
		MOV AX,BALL_VELOCITY_Y 
		ADD BALL_Y, AX
		
		;ball y < 0 (x=>collided)
		MOV AX,WINDOW_BOUNDS
		CMP BALL_Y ,AX
		JL NEG_VELOCITY_Y
		;BALL Y > WINDOW_HEIGHT -ball size- window bounds  (X=>collided)
		MOV AX,WINDOW_HEIGHT
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_Y,AX
		JG NEG_VELOCITY_Y
		
		RET
		;.......negate velocity
		RESET_POSITOIN:
			CALL RESET_BALL_POSITION ; BALL_VELOCITY_X = -BALL_VELOCITY_X
			RET
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y ; BALL_VELOCITY_Y = -BALL_VELOCITY_Y
			RET
	MOVE_BALL ENDP
	
	
	;....................................CLEAR SCREAN................
	CLEAR_SCREAN PROC NEAR
		MOV AH,00h;set the configuration to vedio mode
		MOV AL,13h;choose the vedio mode
		INT 10h	  ;execute the configuration 
		
		
		MOV AH,0Bh;Set the configuration
		MOV BH,00h;to background color
		MOV BL,00H;choose black as background
		INT 10h; execute the configuration
	
		RET
	CLEAR_SCREAN ENDP
	
	
	;...................................DRAW BALL..................
	DRAW_BALL PROC NEAR                  
		
		MOV CX,BALL_X                    ;set the initial column (X)
		MOV DX,BALL_Y                    ;set the initial line (Y)
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch                   ;set the configuration to writing a pixel
			MOV AL,0Fh 					 ;choose white as color
			MOV BH,00h 					 ;set the page number 
			INT 10h    					 ;execute the configuration
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX          	  		 ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,BALL_X 				 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX             		 ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
		RET
	DRAW_BALL ENDP
	;..............................RESET BALL....................
	RESET_BALL_POSITION PROC NEAR
		MOV AX,BALL_ORIGINAL_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX
	
		RET
	RESET_BALL_POSITION ENDP
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  START PADDLE   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;; DRAW PADDLES ;;;;
	DRAW_PADDLE PROC NEAR                         
	
		;; left paddle ;;
		MOV CX,PADDLE_LEFT_X                  ; set the (x) position
		MOV DX,PADDLE_LEFT_Y                  ; set the (Y) position
		
		DRAW_PADDLE_LEFT_SIZE:                    ; loop to draw the pixels of the PADDLE
		
			MOV AH,0CH      		  ; set the configuration to write pixel
			MOV AL,0FH                        ; white color
			MOV BH,00H                        
			INT 10H
			
			;;;; horizontal ;;;;
			INC CX                            ; increment x"column" by one 
			;;;; check if paddle reaches to the specific size or not ;;;;
			MOV AX, CX
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH               ; if (cx-PADDLE_LEFT_X)>PADDLE_WIDTH , break ; else continue to the next column 
			JNG DRAW_PADDLE_LEFT_SIZE         ; Jump if Not Greater (not >).
			MOV CX,PADDLE_LEFT_X              ; cx return to the initial
			
			;;;; vertical  ;;;;
			INC DX                            ; increment Y"row" by one 
			;;;; check if PADDLE reaches to the specific size or not ;;;;
			MOV AX, DX
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT              ; if (Dx-PADDLE_LEFT_Y)>PADDLE_HEIGHT , break ; else continue to the next row
			JNG DRAW_PADDLE_LEFT_SIZE         ; Jump if Not Greater (not >).
			MOV DX,PADDLE_LEFT_Y              ; Dx return to the initial
			
			
		;; right paddle ;;
		MOV CX,PADDLE_RIGHT_X                 ; set the (x) position
		MOV DX,PADDLE_RIGHT_Y                 ; set the (Y) position
		
		DRAW_PADDLE_RIGHT_SIZE:                   ; loop to draw the pixels of the PADDLE
		
			MOV AH,0CH      		  ; set the configuration to write pixel
			MOV AL,0FH                        ; white color
			MOV BH,00H                        
			INT 10H
			
			;;;; horizontal ;;;;
			INC CX                            ; increment x"column" by one 
			;;;; check if paddle reaches to the specific size or not ;;;;
			MOV AX, CX
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH               ; if (cx-PADDLE_RIGHT_X)>PADDLE_WIDTH , break ; else continue to the next column 
			JNG DRAW_PADDLE_RIGHT_SIZE        ; Jump if Not Greater (not >).
			MOV CX,PADDLE_RIGHT_X             ; cx return to the initial
			
			;;;; vertical  ;;;;
			INC DX                            ; increment Y"row" by one 
			;;;; check if PADDLE reaches to the specific size or not ;;;;
			MOV AX, DX
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT              ; if (Dx-PADDLE_RIGHT_Y)>PADDLE_HEIGHT , break ; else continue to the next row
			JNG DRAW_PADDLE_RIGHT_SIZE        ; Jump if Not Greater (not >).
			MOV DX,PADDLE_RIGHT_Y             ; Dx return to the initial
		RET
	DRAW_PADDLE ENDP
	
	
	MOVE_PADDLES PROC NEAR                   
	
		;;;;;;; LEFT PADDLE  ;;;;;;;
		;;; check if any key is pressed and if not check the right paddle ;;;
		MOV AH,01H				          ; ZF = 0 if a key pressed
		INT 16H                                           ; execute int 16H for keyboard
		JZ CHECK_RIGHT_PALLLE_MOVEMENT                    ; if ZF = 1 "no key is preesed" go to check right paddle

		;;; check which key is being preesed  ;;;
		MOV AH, 00H										  ; AL = ASCII OF key
		INT 16H											  ; execute int 16H for keyboard
		; if it is 'K' or 'k' , move up 
		CMP AL,4BH                                         ; 'K' = 4B
		JE MOVE_LEFT_PADDLE_UP                             ; jump if equal
		CMP AL,6BH                                         ; 'k' = 6B
		JE MOVE_LEFT_PADDLE_UP                             ; jump if equal
		; if it is 'L' or 'l' , move down
		CMP AL,4CH                                         ; 'L' = 4C
		JE MOVE_LEFT_PADDLE_DOWN                           ; jump if equal
		CMP AL,6CH                                         ; 'l' = 6C
		JE MOVE_LEFT_PADDLE_DOWN                           ; jump if equal
		;; after check jump to check the right paddle too ;;
		JMP CHECK_RIGHT_PALLLE_MOVEMENT


		;;;;;;; MOVE_LEFT_PADDLE_UP ;;;;;;;
		MOVE_LEFT_PADDLE_UP :

			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y,AX	
			MOV AX,PADDLE_LEFT_Y
			CMP AX,WINDOW_BOUNDS                            ; check if the paddle is out the boundaries
			JL  FIX_PADDLE_LEFT_POSITION_UP                 ; if out, jump to fix
			JMP CHECK_RIGHT_PALLLE_MOVEMENT                 ; incase of more than one key is pressed

			FIX_PADDLE_LEFT_POSITION_UP:
				MOV AX,WINDOW_BOUNDS
				MOV PADDLE_LEFT_Y,AX                        ; put the paddle after WINDOW_BOUNDS  stay at the start of window
				JMP CHECK_RIGHT_PALLLE_MOVEMENT

		;;;;;;; MOVE_LEFT_PADDLE_DOWN ;;;;;;;
		MOVE_LEFT_PADDLE_DOWN :

			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y,AX	                        ; add the movement step to the paddle
			MOV AX,WINDOW_HEIGHT							; AX = WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS							; AX = WINDOW_HEIGHT - WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT							; AX = WINDOW_HEIGHT - WINDOW_BOUNDS - PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y,AX							; IF PADDLE_LEFT_Y > AX " out from the window "
			JG  FIX_PADDLE_LEFT_POSITION_DOWN				; jump if greater
			JMP CHECK_RIGHT_PALLLE_MOVEMENT                 ; incase of more than one key is pressed


			FIX_PADDLE_LEFT_POSITION_DOWN:
				MOV PADDLE_LEFT_Y,AX                        ; stay at the end of window
				JMP CHECK_RIGHT_PALLLE_MOVEMENT


		;;;;;;; Right PADDLE  ;;;;;;;
		CHECK_RIGHT_PALLLE_MOVEMENT :
		
			; if it is 'S' or 's' , move up 
			CMP AL,53H                                         ; 'S' = 53
			JE MOVE_RIGHT_PADDLE_UP                            ; jump if equal
			CMP AL,73H                                         ; 's' = 73
			JE MOVE_RIGHT_PADDLE_UP                            ; jump if equal
			; if it is 'D' or 'd' , move down
			CMP AL,44H                                         ; 'D' = 44
			JE MOVE_RIGHT_PADDLE_DOWN                          ; jump if equal
			CMP AL,64H                                         ; 'd' = 64
			JE MOVE_RIGHT_PADDLE_DOWN                          ; jump if equal
			;; after check jump to check the LEFT paddle too ;;
			JMP EXIT_PADDLE_MOVEMENT
			
			
			;;;;;;; MOVE_RIGHT_PADDLE_UP ;;;;;;;
			MOVE_RIGHT_PADDLE_UP :
				
				MOV AX,PADDLE_VELOCITY
				SUB PADDLE_RIGHT_Y,AX	
				MOV AX,PADDLE_RIGHT_Y
				CMP AX,WINDOW_BOUNDS                             ; check if the paddle is out the boundaries
				JL  FIX_PADDLE_RIGHT_POSITION_UP                 ; if out, jump to fix
				JMP EXIT_PADDLE_MOVEMENT                 
				
				FIX_PADDLE_RIGHT_POSITION_UP:
					MOV AX,WINDOW_BOUNDS
					MOV PADDLE_RIGHT_Y,AX                        ; put the paddle after WINDOW_BOUNDS  stay at the start of window
					JMP EXIT_PADDLE_MOVEMENT
			
			;;;;;;; MOVE_RIGHT_PADDLE_DOWN ;;;;;;;
			MOVE_RIGHT_PADDLE_DOWN :
				
				MOV AX,PADDLE_VELOCITY
				ADD PADDLE_RIGHT_Y,AX	                        ; add the movement step to the paddle
				MOV AX,WINDOW_HEIGHT							; AX = WINDOW_HEIGHT
				SUB AX,WINDOW_BOUNDS							; AX = WINDOW_HEIGHT - WINDOW_BOUNDS
				SUB AX,PADDLE_HEIGHT							; AX = WINDOW_HEIGHT - WINDOW_BOUNDS - PADDLE_HEIGHT
				CMP PADDLE_RIGHT_Y,AX							; IF PADDLE_RIGHT_Y > AX " out from the window "
				JG  FIX_PADDLE_RIGHT_POSITION_DOWN				; jump if greater
				JMP EXIT_PADDLE_MOVEMENT
			
			
				FIX_PADDLE_RIGHT_POSITION_DOWN:
					MOV PADDLE_RIGHT_Y,AX                        ; stay at the end of window
					JMP EXIT_PADDLE_MOVEMENT
			
			
			EXIT_PADDLE_MOVEMENT:
				RET


		RET
	MOVE_PADDLES ENDP
			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  END PADDLE   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			
			
			
CODE ENDS
END
