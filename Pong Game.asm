.MODEL SMALL
.STACK 100H

.DATA

BALL_X DB 5          ; Starting X (column)
BALL_Y DB 2          ; Starting Y (row)

TEMP_TIME DB 0       ; comparing time vairable

WINDOW_WIDTH DB 4Fh     
WINDOW_HEIGHT DB 18h


INCREMENT_POSITION_X DB 2        ; speed of ball
INCREMENT_POSITION_Y DB 2


PADDLE_LEFT_X DB 01h
PADDLE_LEFT_Y DB 12h


PADDLE_RIGHT_X DB 4Eh
PADDLE_RIGHT_Y DB 12h

PADDLE_SIZE DW 5
PADDLE_MOVING_SPEED DB 2

.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX
     
    
    MOV AH, 00h             ; set video mode.
    MOV AL, 03h             ; text mode (80 columns x 25 rows)
    INT 10h                 ; video service int
    
    
    TIME_LOOP:
    
        
        MOV AH, 2Ch         ; Get current time
        INT 21h
    
        CMP DL, TEMP_TIME   ; DL Hundredths of a second (0-99)
        JE TIME_LOOP        ; Compare current 1/100s with TEMP TIME
    
        
        MOV TEMP_TIME, DL   
    
        CALL ERASE_BALL    
                
        CALL MOVE_BALL
            
        CALL DRAW_BALL
        
        CALL MOVE_PADDLE
        
        
        CALL DRAW_PADDLE     
    
        JMP TIME_LOOP     
                          
             
    ; exit
    MOV AX, 4C00h
    INT 21h

MAIN ENDP


;---------------------------------------------------

DRAW_BALL PROC

    MOV DH, BALL_Y     ; Set row (Y)
    MOV DL, BALL_X     ; Set column (X)
    MOV BH, 00h        ; Page number
    MOV AH, 02h        ; Set cursor position
    INT 10h

    MOV AH, 0Eh        ; Print character
    MOV AL, 02h        ; Ball shape
    MOV BH, 00h
    INT 10h

    RET
DRAW_BALL ENDP

;---------------------------------------------------

ERASE_BALL PROC

    MOV DH, BALL_Y
    MOV DL, BALL_X
    MOV BH, 00h
    MOV AH, 02h        ; Set cursor
    INT 10h

    MOV AH, 0Eh
    MOV AL, ' '        ; Print space to erase
    MOV BH, 00h
    INT 10h

    RET
ERASE_BALL ENDP

;---------------------------------------------------

MOVE_BALL PROC 
    
    MOV AL, INCREMENT_POSITION_X      ; changing x position
    ADD BALL_X, AL
    
    ; Check X collision
    CMP BALL_X, 0                     ; if ball_x < 0
    JL BOUNCE_X_LEFT
    MOV AL, WINDOW_WIDTH
    CMP BALL_X, AL                    ; if ball_x > window width
    JG BOUNCE_X_RIGHT

    
    MOV AL, INCREMENT_POSITION_Y      ; changing x position
    ADD BALL_Y, AL
    
    ; Check Y collision
    CMP BALL_Y, 0                     ; if ball_y < 0
    JL BOUNCE_Y_TOP
    MOV AL, WINDOW_HEIGHT
    CMP BALL_Y, AL                    ; if ball_y > window height
    JG BOUNCE_Y_BOTTOM

    RET


    ; Handle bounces:
    ; reverse the direction
    ; setting new position 
        
    BOUNCE_X_LEFT:
        NEG INCREMENT_POSITION_X
        MOV BALL_X, 0
        RET
    
    BOUNCE_X_RIGHT:
        NEG INCREMENT_POSITION_X
        MOV AL, WINDOW_WIDTH
        MOV BALL_X, AL
        RET
    
    BOUNCE_Y_TOP:
        NEG INCREMENT_POSITION_Y
        MOV BALL_Y, 0
        RET
    
    BOUNCE_Y_BOTTOM:
        NEG INCREMENT_POSITION_Y
        MOV AL, WINDOW_HEIGHT
        MOV BALL_Y, AL
        RET    

MOVE_BALL ENDP

;---------------------------------------------------

DRAW_PADDLE PROC
    
    ;DRAWING LEFT PADDLE
    MOV DH, PADDLE_LEFT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_LEFT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_LEFT:
        ; Set cursor position
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; Print the character
        MOV AH, 0Eh             ; Function: Print character at cursor position
        MOV AL, 02h             ; Character to print
        MOV BH, 00h             ; Page number
        INT 10h
    
        INC DH                 
        LOOP DRAW_BODY_LEFT
        
        
    ;DRAWING RIGHT PADDLE
    MOV DH, PADDLE_RIGHT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_RIGHT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_RIGHT:
        ; Set cursor position
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; Print the character
        MOV AH, 0Eh             ; Function: Print character at cursor position
        MOV AL, 02h             ; Character to print
        MOV BH, 00h             ; Page number
        INT 10h
    
        INC DH                 
        LOOP DRAW_BODY_RIGHT
        
                 

    RET

    
DRAW_PADDLE ENDP

;---------------------------------------------------


MOVE_PADDLE PROC
    
    
    MOV AH, 01h         ; check if any key is press or not
    INT 16h             ; int for checking keys
    JZ EXIT            ; if zero flag is set to 1 jump
                        ; zf=1 if no key is pressed or zf=0
                        
    
    MOV AH, 00h         ; get the ASCII value of the key which is pressed
    INT 16h             ; and store in AL
    
    
    ;CHECKING FOR LEFT PADDLE
    CMP AL, 77h                 ; if w is pressed (left paddle up)
    JE MOVE_LEFT_PADDLE_UP
    
    
    CMP AL, 73h
    JE  MOVE_LEFT_PADDLE_DOWN  ; if s is pressed (left paddle down)
    
    
    ;CHECKING FOR RIGHT PADDLE
    CMP AL, 6Fh                 ; if o is pressed (right paddle up)
    JE MOVE_RIGHT_PADDLE_UP
    
    
    CMP AL, 6Ch
    JE  MOVE_RIGHT_PADDLE_DOWN  ; if l is pressed (right paddle down)
    
    
    
    EXIT:
    
    
    
    RET 
    
    
    
    ;---------------------------------------------------
    
    
    ; HANDLING LEFT PADDLE
                                                 
    MOVE_LEFT_PADDLE_UP:
    
        CALL REMOVE_PADDLE_LEFT         ; remove the previous paddle
        
        MOV AL, PADDLE_MOVING_SPEED
        SUB PADDLE_LEFT_Y, AL           ; decresing the paddle y positon
        
        CMP PADDLE_LEFT_Y, 00h
        JL HOLD_PADDLE_LEFT_UP          ; if paddle y-axis position < 0
        RET
        
        
        HOLD_PADDLE_LEFT_UP:
            MOV PADDLE_LEFT_Y, 00h      ; setting y-asis value to 0 so that
            RET                         ; the paddle do not get out from screen
        
        
        
     MOVE_LEFT_PADDLE_DOWN:
    
        CALL REMOVE_PADDLE_LEFT
        
        MOV AL, PADDLE_MOVING_SPEED
        ADD PADDLE_LEFT_Y, AL
        
        CMP PADDLE_LEFT_Y, 13h
        JG HOLD_PADDLE_LEFT_DOWN
        RET
        
        
        HOLD_PADDLE_LEFT_DOWN:
            MOV PADDLE_LEFT_Y, 14h
            RET
            
             
             
     ;---------------------------------------------------
     
     ; HANDLING RIGHT PADDLE
      
     MOVE_RIGHT_PADDLE_UP:
    
        CALL REMOVE_PADDLE_RIGHT         ; remove the previous paddle
        
        MOV AL, PADDLE_MOVING_SPEED
        SUB PADDLE_RIGHT_Y, AL           ; decresing the paddle y positon
        
        CMP PADDLE_RIGHT_Y, 00h
        JL HOLD_PADDLE_RIGHT_UP          ; if paddle y-axis position < 0
        RET
        
        
        HOLD_PADDLE_RIGHT_UP:
            MOV PADDLE_RIGHT_Y, 00h      ; setting y-asis value to 0 so that
            RET                         ; the paddle do not get out from screen
        
        
        
     MOVE_RIGHT_PADDLE_DOWN:
    
        CALL REMOVE_PADDLE_RIGHT
        
        MOV AL, PADDLE_MOVING_SPEED
        ADD PADDLE_RIGHT_Y, AL
        
        CMP PADDLE_RIGHT_Y, 13h
        JG HOLD_PADDLE_RIGHT_DOWN
        RET
        
        
        HOLD_PADDLE_RIGHT_DOWN:
            MOV PADDLE_RIGHT_Y, 14h
            RET
        
      
                                                 
                                                 
 
                                                 
MOVE_PADDLE ENDP

;---------------------------------------------------

REMOVE_PADDLE_LEFT PROC
    
    
    MOV DH, PADDLE_LEFT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_LEFT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_LEFT_X:
        ; Set cursor position
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; Print the character
        MOV AH, 0Eh             ; Function: Print character at cursor position
        MOV AL, " "             ; Character to print
        MOV BH, 00h             ; Page number
        INT 10h
    
        INC DH                 
        LOOP DRAW_BODY_LEFT_X
        
        
    RET
    
REMOVE_PADDLE_LEFT ENDP

;---------------------------------------------------

REMOVE_PADDLE_RIGHT PROC
    
    
    MOV DH, PADDLE_RIGHT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_RIGHT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_RIGHT_X:
        ; Set cursor position
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; Print the character
        MOV AH, 0Eh             ; Function: Print character at cursor position
        MOV AL, " "             ; Character to print
        MOV BH, 00h             ; Page number
        INT 10h
    
        INC DH                 
        LOOP DRAW_BODY_RIGHT_X
        
        
    RET
    
REMOVE_PADDLE_RIGHT ENDP


END MAIN




