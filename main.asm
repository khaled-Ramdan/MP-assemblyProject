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
    ;;-------------------DRAW FUNCTIONS--------------------------    
    
    ;Left Paddle
    drawPaddleL:
        push ax
        push bx
        push cx
        
        mov ax, lpad[0]
        mov bx, lpad[2]
        mov cx, lpad[6]
        call vert_line_unplot
        
        mov ax, lpad[8]
        mov bx, lpad[10]
        call verticallBoundry
        
        pop cx
        pop bx
        pop ax
        ret
    
    ;Right Paddle
    drawPaddleR:
        push ax
        push bx
        push cx
        
        mov ax, rpad[0]
        mov bx, rpad[2]
        mov cx, rpad[6]
        call vert_line_unplot
        
        mov ax, rpad[8]
        mov bx, rpad[10]
        call verticallBoundry
        
        pop cx
        pop bx
        pop ax
        ret
      
      ;Draws Ball
    drawBall:
        push ax
        push bx
        push cx
        push dx
        
        
        mov ax, ball[0]
        mov cx, ax
        mov bx, ball[2]
        mov dx, bx
        
        add cx, ball[8]
        dec cx
        add dx, ball[8]
        dec dx
        
        call rect_unplot
        
        mov ax, ball[10]
        mov cx, ax
        mov bx, ball[12]
        mov dx, bx
        
        add cx, ball[8]
        dec cx
        add dx, ball[8]
        dec dx
        
        call rect_plot
        
        pop dx
        pop cx
        pop bx
        pop ax 
        ret           
        
