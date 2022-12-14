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

maindata:
   
    mov dx, offset msg1
    mov ah, 9
    int 21h
    
    
    mov ah, 1
    int 21h
    
    cmp al,31h
    jz colorBlue 
     
    cmp al,32h
    jz colorRed   
    
    cmp al,33h
    jz colorMagenta 
    
    cmp al,34h
    jz colorCyan     
    
    cmp al,35h
    jz colorGreen
    
    colorBlue:   
    mov player1,0c01h   
    jmp plot
    
    colorRed:  
    mov player1,0c04h   
    jmp plot
    
    colorMagenta:  
    mov player1,0c05h 
    jmp plot
    
    colorCyan:
    mov player1,0c0bh
    jmp plot 
    
    colorGreen:
    mov player1,0c02h
    jmp plot 

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
        
;;---------------------PLOT PLAY AREA----------------------------   

     rect_plot:
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        
        push ax                         ;Store the origin x in the stack
        
        mov di, cx 
        mov si, dx 
         
        mov cx, ax
        mov dx, bx
        mov ax, 0c0eh                   ;Color of rectangle - the right-most hex char 
        
        rect_loop:
        int 10h                         ;Draw Pixel
        
        inc cx 
        cmp cx, di                      ;Check if xpos > destination x
        jng rect_loop
        
        pop cx                          ;Xpos to the origin x
        push cx
        
        inc dx
        cmp dx, si                      ;Check if ypos > destination y
        jng rect_loop
        
        pop si
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
        
        rect_unplot:
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        
        push ax 
        
        mov di, cx
        mov si, dx 
        mov cx, ax
        mov dx, bx
        mov ax, 0c00h              ;the right-most hex char is the color of the rectangle   - change color to see path - 0c03h
        
        rect_loop2:
        int 10h 
        
        inc cx 
        cmp cx, di                  
        jng rect_loop2
        
        pop cx                     
        push cx
        
        inc dx
        cmp dx, si                 
        jng rect_loop2
        pop si
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
    

    
    verticallBoundry:
        push ax
        push bx
        push cx
        push dx
        
        ;moving values around for pixel plotting
        mov dx, bx
        mov bx, cx
        mov cx, ax
        mov ax, player1
        
        vert_loop:
        int 10h
        inc dx
        dec bx
        jns vert_loop
        
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret

    vert_line_unplot:
        push ax
        push bx
        push cx
        push dx
        
        ;moving values around for pixel plotting
        mov dx, bx
        mov bx, cx
        mov cx, ax
        mov ax, 0c00h
        
        vert_loopu:
        int 10h
        inc dx
        dec bx
        jns vert_loopu
        
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
        
         horizontalBoundry:
        push ax
        push bx
        push cx
        push dx
        
        ;moving values around for pixel plotting
        mov dx, bx
        mov bx, cx
        mov cx, ax
        mov ax, 0c01h
        horiz_loop:
        int 10h
        inc cx
        dec bx
        jns horiz_loop
        
        pop dx
        pop cx
        pop bx
        pop ax 
        
        ret
        
        move_pixel:
        push bx
        push ax
        
        ;cx and dx are popped within the function
        push dx
        push cx
        
        mov cx, ax
        mov dx, bx
        
        ;store the old color in bl
        mov ax, 0d00h
        int 10h
        mov bl, al
        
        ;un-plot the old pixel   - replace with black
        mov ax, 0c00h
        int 10h
        
        ;plot the new pixel
        mov al, bl
        mov ah, 0ch
        pop cx
        pop dx
        int 10h
        
        pop ax
        pop bx
        ret
        
         plot_pixel:
        push ax
        push cx
        push dx
        
        mov cx, ax
        mov dx, bx
        mov ax, 0c0fh
        int 10h
        
        pop dx
        pop cx
        pop ax
        ret
