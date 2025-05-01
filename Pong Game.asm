.MODEL SMALL
.STACK 100H

.DATA
 
RESTART_X DB 14h     ;0Fc            ; restarting position
RESTART_Y DB 0Ch
 
 
BALL_X DB 14h      ;0Fc              ; Starting X (column)
BALL_Y DB 0Ch                        ; Starting Y (row)
 
 
TEMP_TIME DB 0                       ; comparing time vairable
  
  
WINDOW_WIDTH DB 2Ah      ;1Fh        ; 4Fh for full screen
WINDOW_HEIGHT DB 18h


INCREMENT_POSITION_X DB 2           ; speed of ball x
INCREMENT_POSITION_Y DB 1           ; speed of ball y


PADDLE_LEFT_X DB 03h                ; position of paddle right
PADDLE_LEFT_Y DB 12h


PADDLE_RIGHT_X DB 28h      ; 1Ch    ; 4Ch for full screen
PADDLE_RIGHT_Y DB 12h               ; position of paddle left
 
 
PADDLE_SIZE DW 5
PADDLE_MOVING_SPEED DB 2
   
   
COLISSION_PADDLE_LEFT_X DB ?        ; storing paddle collision info
COLISSION_PADDLE_LEFT_Y DB ?
   
   
PLAYER_ONE_TEXT DW "PLAYER 1: $"    ; player text one 
PLAYER_ONE_TEXT_X DB 2Bh            ; player text position
PLAYER_ONE_TEXT_Y DB 05h
   
   
PLAYER_ONE_SCORE DB 0               ; player point one and its postion
PLAYER_ONE_SCORE_X DB 35h
PLAYER_ONE_SCORE_Y DB 05h
     
     
PLAYER_TWO_TEXT DW "PLAYER 2: $"    ; player text two
PLAYER_TWO_TEXT_X DB 2Bh            ; player text position
PLAYER_TWO_TEXT_Y DB 07h
       
       
PLAYER_TWO_SCORE DB 0               ; player point two and its postion
PLAYER_TWO_SCORE_X DB 35h
PLAYER_TWO_SCORE_Y DB 07h
        
        
GAME_OVER_TEXT DW 10, "GAME OVER $"
PLAYER_ONE_WIN_TEXT DB 13, 10, 13, 10, "PLAYER 1 HAS WON", "$"
PLAYER_TWO_WIN_TEXT DB 13, 10, 13, 10, "PLAYER 2 HAS WON", "$"
RESTART_MESSAGE DB 13, 10, 13, 10, "Do you want to play again? (y/n): $"



WINNING_SCORE DB 03h               ; the score player needs to win


.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX
     
    START:                  ; restarting point
    
    ; LOADING THE SCREEN
    MOV AH, 00h             ; set video mode.
    MOV AL, 03h             ; text mode (80 columns x 25 rows)
    INT 10h                 ; video service int
    
    
    MOV PLAYER_ONE_SCORE, 00h      ; setting the score to zero
    MOV PLAYER_TWO_SCORE, 00h   
    
    
    ; DISPLAYING THE PLAYER TEXT (NOT SCORE)
    CALL PLAYER_SCORE_TEXT
    
        
    TIME_LOOP:
    
        
        MOV AH, 2Ch         ; Get current time
        INT 21h
    
        CMP DL, TEMP_TIME   ; DL Hundredths of a second (0-99)
        JE TIME_LOOP        ; Compare current 1/100s with TEMP TIME
    
        
        MOV TEMP_TIME, DL   
        
        ; REMOVING THE PREVIOUS POSITION OF THE BALL
        CALL ERASE_BALL    
        
        ; MAKING THE BALL MOVE        
        CALL MOVE_BALL
        
        ; DRAWING THE NEW POSITION OF THE BALL    
        CALL DRAW_BALL
        
        ; MOVE PADDLE IF THERE ARE ANY INPUT
        CALL MOVE_PADDLE
        
        ; DRAW THE PADDLE
        CALL DRAW_PADDLE
        
        ; CALLING FOR THE PLAYER SCORE        
        CALL PLAYER_SCORE
        
        MOV CL, WINNING_SCORE
        CMP PLAYER_ONE_SCORE, CL      ; if player 1 score == winning point
        JE  GAME_OVER_SCREEN          
        
        
        MOV CL, WINNING_SCORE
        CMP PLAYER_TWO_SCORE, CL      ; if player 2 score == winning point
        JE  GAME_OVER_SCREEN
        
                 
        JMP TIME_LOOP
        
        
    ;---------------------------------------------------
        
    GAME_OVER_SCREEN:
    
        ; LOADING THE SCREEN
        MOV AH, 00h             ; set video mode.
        MOV AL, 03h             ; text mode (80 columns x 25 rows)
        INT 10h
            
            
        ; LOADIN GAME OVER TEXT     
        LEA DX, GAME_OVER_TEXT
        MOV AH,09h
        INT 21h
            
            
        MOV CL, WINNING_SCORE
        CMP PLAYER_ONE_SCORE, CL       ; if player 1 == winning point
        JE  PLAYER_ONE_WON             ; showing player 1 win text (JUMP)
        
        
        ; LOADING PLAYER TWO WIN TEXT
        LEA DX, PLAYER_TWO_WIN_TEXT    ; else show player 2 win
        MOV AH,09h
        INT 21h
        
        JMP EXIT_OR_RESTART            ; jump to  EXIT_OR_RESTART so that player 1
                                       ; text not printed
                                       
    
        ; LOADING PLAYER ONE WIN TEXT
        PLAYER_ONE_WON:
            LEA DX, PLAYER_ONE_WIN_TEXT
            MOV AH,09h
            INT 21h
            
            
        ; LOADING RESTART TEXT 
        EXIT_OR_RESTART:
            LEA DX, RESTART_MESSAGE
            MOV AH,09h
            INT 21h
            
            MOV AH, 08h                ; Wait for any key press, returns ASCII in AL
            INT 21h       
    
            
            CMP AL, 79h                ; if keypress letter == y (small)
            JE START
                          
             
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
    
    MOV AL, INCREMENT_POSITION_Y      ; changing Y position
    ADD BALL_Y, AL
    
    
    ;---------------------------------------------------
    
    ; CHECKING THE RIGHT PADDLE COLLISION
    MOV AL, PADDLE_RIGHT_X
    CMP BALL_X, AL
    JL CHECK_LEFT_PADDLE            ; if ball_x is less than paddle x-axis
    
                                                                              
    MOV BL, PADDLE_RIGHT_Y
    MOV CX, PADDLE_SIZE
    
    RIGHT_PADDLE_COLLISION_CHECK:         ; for i in range(paddle length)
        MOV COLISSION_PADDLE_LEFT_Y, BL
        CMP BALL_Y, BL                    ; if ball_x == paddle any position revert the ball velosity
        JE BOUNCE_LEFT_PADDLE
        INC BL
        LOOP RIGHT_PADDLE_COLLISION_CHECK
    
    
    ;---------------------------------------------------
    
    
    CHECK_LEFT_PADDLE:
    ; CHECKING THE LEFT PADDLE COLLISION
    MOV AL, PADDLE_LEFT_X
    CMP BALL_X, AL
    JG OTHER_COLLISION            ; if ball_x is GREATER than paddle x-axis
    
                                                                              
    MOV BL, PADDLE_LEFT_Y
    MOV CX, PADDLE_SIZE
    
    LEFT_PADDLE_COLLISION_CHECK:         ; for i in range(paddle length)
        MOV COLISSION_PADDLE_LEFT_X, BL
        CMP BALL_Y, BL                    ; if ball_x == paddle any position revert the ball velosity
        JE BOUNCE_RIGHT_PADDLE
        INC BL
        LOOP LEFT_PADDLE_COLLISION_CHECK
    
    
    OTHER_COLLISION:
    
    ;---------------------------------------------------
    
    ; CHECKING X-AXIS COLLISION
    CMP BALL_X, 0                     ; if ball_x < 0
    JL BOUNCE_X_RESTART_LEFT
    MOV AL, WINDOW_WIDTH
    CMP BALL_X, AL                    ; if ball_x > window width
    JG BOUNCE_X_RESTART_RIGHT

    
    
    ; CHECKING Y-AXIS COLLISION
    CMP BALL_Y, 0                     ; if ball_y < 0
    JL BOUNCE_Y_TOP
    MOV AL, WINDOW_HEIGHT
    CMP BALL_Y, AL                    ; if ball_y > window height
    JG BOUNCE_Y_BOTTOM
    

    RET

    ;---------------------------------------------------
    
    ; HANDLE BOUNCES
        
    BOUNCE_X_RESTART_LEFT:
        INC PLAYER_TWO_SCORE        ; increasing player 2 point if ball reach left end
        MOV AL, RESTART_X           ; setting the ball to restart postion
        MOV BALL_X, AL
        MOV AL, RESTART_Y
        MOV BALL_Y, AL
        RET
        
        
    BOUNCE_X_RESTART_RIGHT:
        INC PLAYER_ONE_SCORE        ; increasing player 1 point if ball reach right end
        MOV AL, RESTART_X           ; setting the ball to restart postion
        MOV BALL_X, AL
        MOV AL, RESTART_Y
        MOV BALL_Y, AL
        RET

        
    ; REVERSE THE DIRECTION
    ; SETTING NEW POSITION
    
    BOUNCE_Y_TOP:
        NEG INCREMENT_POSITION_Y
        MOV BALL_Y, 0
        RET
    
    BOUNCE_Y_BOTTOM:
        NEG INCREMENT_POSITION_Y
        MOV AL, WINDOW_HEIGHT
        MOV BALL_Y, AL
        RET
    
    
    ;---------------------------------------------------
        
    ; HANDLING LEFT PADDLE BOUNCE    
    BOUNCE_LEFT_PADDLE:    
        NEG INCREMENT_POSITION_X                 ; change the velocity x asis
        MOV AL, COLISSION_PADDLE_LEFT_Y
        MOV BALL_Y, AL
        MOV AL, PADDLE_RIGHT_X                   ; set the ball postion the point
        MOV BALL_X, AL                           ; where the ball collide        
        
        JMP CHECK_LEFT_PADDLE                    ; jump to left paddle cheking
        
        
    ; HANDLING RIGHT PADDLE BOUNCE    
    BOUNCE_RIGHT_PADDLE:    
        NEG INCREMENT_POSITION_X                 ; change the velocity x asis
        MOV AL, COLISSION_PADDLE_LEFT_X
        MOV BALL_Y, AL
        MOV AL, PADDLE_LEFT_X                   ; set the ball postion the point
        MOV BALL_X, AL                           ; where the ball collide        
        
        JMP OTHER_COLLISION                    ; jump to  OTHER_COLLISION
                                                 
    
    
    
        

MOVE_BALL ENDP

;---------------------------------------------------

DRAW_PADDLE PROC
    
    ;DRAWING LEFT PADDLE
    MOV DH, PADDLE_LEFT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_LEFT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_LEFT:
        ; SET CURSOR POSITION
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; PRINT THE CHARACTER
        MOV AH, 0Eh             ; Function: Print character at cursor position
        MOV AL, 02h             ; Character to print
        MOV BH, 00h             ; Page number
        INT 10h
    
        INC DH                 
        LOOP DRAW_BODY_LEFT 
        
        
    ;---------------------------------------------------
    
        
    ;DRAWING RIGHT PADDLE
    
    ; SET CURSOR POSITIO
    MOV DH, PADDLE_RIGHT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_RIGHT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_RIGHT:
        
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; PRINT THE CHARACTER
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
    
    
    ; SET CURSOR POSITION
    MOV DH, PADDLE_LEFT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_LEFT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_LEFT_X:
        
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; PRINT THE CHARACTER
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
    
    
    ; SET CURSOR POSITION
    MOV DH, PADDLE_RIGHT_Y        ; Set row (Y-axis)
    MOV DL, PADDLE_RIGHT_X        ; Set column (X-axis)
    MOV CX, PADDLE_SIZE          ; Snake size 

    DRAW_BODY_RIGHT_X:
        
        MOV AH, 02h             ; Function: Set cursor position
        MOV BH, 00h             ; Page number
        INT 10h
    
        ; PRINT THE CHARACTER
        MOV AH, 0Eh             ; Function: Print character at cursor position
        MOV AL, " "             ; Character to print
        MOV BH, 00h             ; Page number
        INT 10h
    
        INC DH                 
        LOOP DRAW_BODY_RIGHT_X
        
        
    RET
    
REMOVE_PADDLE_RIGHT ENDP


;---------------------------------------------------

PLAYER_SCORE_TEXT PROC 
    
    ;PLAYER ONE TEXT
    
    ; SET CURSOR POSITION
    MOV DH, PLAYER_ONE_TEXT_Y        ; Set row (Y-axis)
    MOV DL, PLAYER_ONE_TEXT_X        ; Set column (X-axis)
    
    MOV AH, 02h                      ; Function: Set cursor position
    MOV BH, 00h                      ; Page number
    INT 10h
    
    ; PRINT THE STRING         
    LEA DX, PLAYER_ONE_TEXT          ; load the player one string
    MOV AH,09h
    INT 21h
        
     
    DONE_PRINTING_ONE:
        
    ;---------------------------------------------------
        
    ;PLAYER TWO TEXT
    
    ; SET CURSOR POSITION           
    MOV DH, PLAYER_TWO_TEXT_Y        ; Set row (Y-axis)
    MOV DL, PLAYER_TWO_TEXT_X        ; Set column (X-axis)
    
    MOV AH, 02h                      ; Function: Set cursor position
    MOV BH, 00h                      ; Page number
    INT 10h
    
    ; PRINT THE STRING
    LEA DX, PLAYER_TWO_TEXT          ; load the player one string
    MOV AH,09h
    INT 21h
            
    RET
        
PLAYER_SCORE_TEXT ENDP

;---------------------------------------------------

PLAYER_SCORE PROC
    
    ;PLAYER ONE SCORE
    
    ; SET CURSOR POSITION    
    MOV DH, PLAYER_ONE_SCORE_Y        ; Set row (Y-axis)
    MOV DL, PLAYER_ONE_SCORE_X        ; Set column (X-axis)
    
    MOV AH, 02h                       ; Function: Set cursor position
    MOV BH, 00h                       ; Page number
    INT 10h
    
    
    MOV AL, PLAYER_ONE_SCORE
    ADD AL, 30h                       ; Convert to ASCII  ('0' = 30h)

    MOV AH, 0Eh                       ; Function: Print character at cursor position      
    INT 10h 
    
    ;---------------------------------------------------
    
    ;PLAYER ONE SCORE
    
    ; SET CURSOR POSITION
    MOV DH, PLAYER_TWO_SCORE_Y        ; Set row (Y-axis)
    MOV DL, PLAYER_TWO_SCORE_X        ; Set column (X-axis)
    
    MOV AH, 02h                       ; Function: Set cursor position
    MOV BH, 00h                       ; Page number
    INT 10h
    
    
    MOV AL, PLAYER_TWO_SCORE
    ADD AL, 30h                       ; Convert to ASCII  ('0' = 30h

    MOV AH, 0Eh                       ; Function: Print character at cursor position
    INT 10h
           
    
    RET
        
PLAYER_SCORE ENDP


END MAIN