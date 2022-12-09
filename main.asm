org 100h 
mov cx, 0


;;-------------- SETTING UP INITIAL VALUES---------------
jmp maindata
gameWidth dw 50
gameHeight dw 50

;Order - xpos, ypos, xvel, yvel, size, newx, newy
ball dw 17,17,5,4,2,17,17     

;Order -  xpos, ypos, speed, length, newx, newy   
lpad dw 5, 14, 7, 11, 02, 14    ; Left Paddle  
rpad dw 5, 14, 7, 11, 48, 14    ; Right Paddle  

player1 dw 0c00h
  
s1 db 100,?, 100 dup(' ') 
msg1  db  "Choose player theme: (1) Blue (2) Red (3) Magenta (4) Cyan (5) Green $"

score dw 02h   

;;-------------- PROGRAM STARTS-------------------------


;;-------------------------SET BOUNDRY/PLAY AREA -------
    plot:     
        ;SET TO GRAPHICS DISPLAY MODE   
    
        mov ax, 0013h
        int 10h
    
        mov ax, 0
        mov bx, 0   
        mov cx, gameWidth
        call horizontalBoundry
        
        mov cx, gameHeight
        call verticallBoundry 
           
        add ax, gameWidth
        call verticallBoundry
        
        mov ax, 0
        mov bx, gameHeight
        mov cx, gameWidth
        call horizontalBoundry  
    
 ;;---------------------MAIN LOOP----------------------------
    mov cx, 0  
    mainloop:
        call drawPaddleL 
        call drawPaddleR 
        call drawBall
        call updateBall 
        call updatePadL 
        call checkBall_CollisionL     
        call updatePadR   
        call checkBall_CollisionR 
        
    
    loop mainloop
    
       
    ret    
