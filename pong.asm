STACK SEGMENT PARA STACK 
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'

	WINDOW_WIDTH DW 140h ;The width of the window (320 pixels)
	WINDOW_HEIGHT DW  0C8h ; the height of the window (200 pixels)
	WINDOW_BOUNDS DW 6;variable used to check collsions eaerly
	
	TIME_AUX DB 0; variable used when checking if the time has changed
	
	BALL_ORIGINAL_X DW 0A0h
	BALL_ORIGINAL_Y DW 64h
	
	
	BALL_X DW 0A0h; x position (coloum) of the ball
	BALL_Y DW 64h; y position (line) of the ball 
	BALL_SIZE DW 06h;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 02h; x velocity of the ball (horizontal)
	BALL_VELOCITY_y DW 02h; y velocity of the ball (vertical)
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   start paddle   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;; Left Paddle ;;
	PADDLE_LEFT_X  DW 0AH                       ; position of left paddle  X
	PADDLE_LEFT_Y  DW 0AH			    ; position of left paddle  Y
	;; Right paddle ;;
	PADDLE_RIGHT_X  DW 130H                     ; position of right paddle  X
	PADDLE_RIGHT_Y  DW 0AH			    ; position of right paddle  Y
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
		JL RESET_POSITOIN
	
		;ball x > window_width -ball size - window bounds (y=>collided) 
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_X,AX
		JG RESET_POSITOIN 
		
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
CODE ENDS
END
