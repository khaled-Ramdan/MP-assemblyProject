STACK SEGMENT PARA STACK 
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	BALL_X DW 0Ah; x position (coloum) of the ball
	BALL_Y DW 64h; y position (line) of the ball 
	BALL_SIZE DW 64h;size of the ball (how many pixels does the ball have in width and height)
	
	
	
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
	
	
	
		MOV AH,00h;set the configuration to vedio mode
		MOV AL,13h;choose the vedio mode
		INT 10h	  ;execute the configuration 
		
		
		MOV AH,0Bh;Set the configuration
		MOV BH,00h;to background color
		MOV BL,00H;choose black as background
		INT 10h; execute the configuration
		
		CALL DRAW_BALL

		RET
	MAIN ENDP
	
	
	DRAW_BALL PROC NEAR ;near so main procedure can call this procedure

		MOV CX,BALL_X;set the initial coloum (x)
		MOV DX,BALL_Y; set the intial line(Y)

		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch;set the configuration writing a pixel 
			MOV AL,0Fh;choose white as color of pixel 
			MOV BH,00h;set the page number 
			INT 10h;execute the configuration
			
			INC CX ; cx++
			MOV AX,CX;  CX - BALL_X > BALL_SIZE (True => we go to the next line, False => we continue to the next coloum )
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNC DRAW_BALL_HORIZONTAL
			
			MOV CX,BALL_X; the cx register goes back to the initial coloum
			INC DX		 ; we advance one line 
			
			MOV AX,DX 	; Dx - BALL_SIZE (True => we exit this procedure , False => we continue to the next line)
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNC DRAW_BALL_HORIZONTAL
		RET
	DRAW_BALL ENDP
CODE ENDS
END
