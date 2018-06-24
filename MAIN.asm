;;;;GROUP 29;;;;
;1942606 M. Rasit Ozdemir ;;;;
;2188423 Tahsincan Kose ;;;;

list P=18F8722

#include <p18f8722.inc>
config OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF

v1      udata 0x21
v1

v2      udata 0x22
v2

v3      udata 0x23
v3

v4      udata 0x24
v4

v5      udata 0x25
v5

v6      udata 0x26
v6

i       udata 0x27
i

fruit   udata 0x28
fruit

live    udata 0x29
live

gameLevel udata 0x2a
gameLevel

v7   udata 0x2b
v7

v8   udata 0x2c
v8

wSaved   udata 0x2d
wSaved

pcLathSaved udata 0x2e
pcLatchSaved

statusSaved   udata 0x2f
statusSaved

counter   udata 0x30
counter

counter2 udata 0x35
counter2


direction udata 0x31
direction


user_location udata 0x32
user_location

blink_state udata 0x33
blink_state

movement_flag udata 0x34
movement_flag

blink_level udata 0x36
blink_level

blink_counter udata 0x37
blink_counter

movement_counter udata 0x38
movement_counter

hit_flag udata 0x39
hit_flag

direction_change udata 0x3a
direction_change

portb_shadow udata 0x3b
portb_shadow

fruitTimeCounter udata 0x3c
fruitTimeCounter

fruit_flag udata 0x3d
fruit_flag

seed udata 0x3e
seed

rowIndex udata 0x3f
rowIndex

columnIndex udata 0x40
columnIndex

score0 udata 0x41
score0

score1 udata 0x42
score1

first_bit udata 0x43
first_bit

fruit_location udata 0x44
fruit_location

fruit_kill_counter udata 0x45
fruit_kill_counter

fruit_kill_flag udata 0x46
fruit_kill_flag

sFlag udata 0x47
sFlag
 
actualFruit udata 0x48
actualFruit
 
wSaved2   udata 0x49
wSaved2

pcLathSaved2 udata 0x4a
pcLatchSaved2

statusSaved2   udata 0x4b
statusSaved2

fruit_open	udata 0x4c
fruit_open
   
org     0x00
goto    init

org     0x08
call saveRegisters2
btfsc	INTCON,2
goto    timerISR
call restore_registers2
retfie
 
org	0x18
call saveRegisters
btfsc	INTCON,0
goto	portbISR
call restore_registers
retfie
 
init:
    clrf    LATA
    clrf    TRISA
    clrf    PORTA
    clrf    LATB
    clrf    TRISB
    clrf    PORTB
    clrf    LATC
    clrf    TRISC
    clrf    PORTC
    clrf    LATD
    clrf    TRISD
    clrf    PORTD
    clrf    LATE
    clrf    TRISE
    clrf    PORTE
    clrf    LATF
    clrf    TRISF
    clrf    PORTF
    clrf    LATG
    clrf    TRISG
    clrf    PORTG

    MOVLW 0x0F      ; CONFIGURE A/D TO DIGITAL.
    MOVWF ADCON1


    movlw 0x10
    movwf TRISA
    movlw 0x3f
    movwf TRISC
    movlw 0x00
    movwf TRISH
    movwf TRISJ
    movlw 0x05
    movwf v1
    movlw 0x00
    movwf v2
    movlw 0x01
    movwf v3
    movlw 0x00
    movwf v4
    movlw 0x0f
    movwf fruit
    movlw 0x03
    movwf live
    movlw 0x03
    movwf v5
    movwf gameLevel
    movwf v7
    movlw 0x00
    movwf v6
    movwf v8
    movwf blink_counter
    movwf movement_counter
    movwf movement_flag
    movwf hit_flag
    movwf direction_change
    movwf fruitTimeCounter
    movwf fruit_flag
    movwf fruit_kill_counter
    movwf fruit_kill_flag
    movlw 0XFF
    movwf sFlag
    lfsr FSR0, 100h         ;FSR0 is tail
    lfsr FSR1, 100h         ;FSR1 is head
    main:
    call phase1
    call phase2
    call phase3
    goto init

    phase3
    movlw 0x10
    movwf TRISA
    clrf INTCON
    clrf TMR0
    clrf PORTA
    clrf PORTC
    clrf PORTD
    clrf PORTE
    clrf PORTF
    movff score0,v1
    movff score1, v3
    movff live, v5
    movlw 0xAA
    movf live, f
    btfsc STATUS,Z
    movwf sFlag
    movff sFlag, v7

    phase3cont
    call sevenSeg
    btfsc PORTA, 4
    goto releasePortA
    goto phase3

    releasePortA
    btfss PORTA,4
    return
    goto releasePortA


    phase2
    movff v1, v5
    movff v2, v6
    movff v3, v7
    movff v4, v8

    movlw 0x00
    movwf TRISA
    movwf TRISC
    movwf TRISD
    movwf TRISE
    movwf TRISF
    movwf v1
    movwf v3
    movwf v2
    movwf v4
    movwf counter
    movwf counter2
    movwf user_location
    movwf score0
    movwf score1
    movwf fruit_open
    movlw 0xad
    movwf seed
    movff fruit, actualFruit


    movf gameLevel, W
    sublw 0x00
    btfsc STATUS,Z
    call blink_level_25
    movf gameLevel, W
    sublw 0x01
    btfsc STATUS,Z
    call blink_level_50
    movf gameLevel, W
    sublw 0x02
    btfsc STATUS,Z
    call blink_level_100
    movf gameLevel, W
    sublw 0x03
    btfsc STATUS, Z
    call blink_level_200
    call phase2_initialize

    phase2cont
    call porta_initialize
    call sevenSeg
    call user_blink
    btfsc movement_flag,0
    call movement_function
    btfsc fruit_flag,0
    call fruit_spawn
    movf fruit,f
    btfsc STATUS, Z
    return
    movf live,f
    btfsc STATUS, Z
    return
    goto phase2cont
    

    fruit_spawn
    clrf rowIndex
    clrf columnIndex
    clrf first_bit
    bcf fruit_flag,0
    btfsc seed,7
    bsf first_bit,0
    rlncf seed, f
    btfsc first_bit,0
    bsf seed,0
    btfsc first_bit,0
    call seedXor
    movlw 0x02
    btfsc seed,7
    addwf rowIndex,f
    btfsc seed,6
    incf rowIndex
    btfsc seed, 1
    addwf columnIndex,f
    btfsc seed,0
    incf columnIndex
    call fruit_encoder
    movf fruit_location, w
    movwf POSTINC1
    movf actualFruit, W
    sublw 0x00
    btfss STATUS, Z
    call fruit_adder
    btfsc fruit_kill_flag,0
    call fruit_killer
    return
    
    fruit_adder
    call fruit_location_encoder
    decf actualFruit
    return

    fruit_killer
    clrf fruit_open
    movff INDF0, fruit_location
    call fruit_location_encoder_clear
    clrf POSTINC0
    movf user_location, W
    subwf fruit_location, W
    btfsc STATUS, Z
    bsf fruit_open,0
    btfsc fruit_open,0
    call arithmetic0_phase2
    return

    fruit_encoder
    movlw 0x00
    addwf columnIndex, W
    addwf columnIndex, W
    addwf columnIndex, W
    addwf columnIndex, W
    addwf columnIndex, W
    addwf rowIndex, W
    movwf fruit_location
    return

    seedXor
    movlw 0xb8
    xorwf seed,f
    return

    direction_control
    btfsc PORTB, 4
    call set_direction_east
    btfsc PORTB, 5
    call set_direction_west
    btfsc PORTB, 6
    call set_direction_north
    btfsc PORTB, 7
    call set_direction_south
    bcf direction_change,0
    bcf hit_flag,0
    return


    mapDecoder
    movlw 0x00
    cpfseq user_location
    goto mapDecoder1
    btfsc PORTC, 0
    call score0_increment
    return

    mapDecoder1
    movlw 0x01
    cpfseq user_location
    goto mapDecoder2
    btfsc PORTC, 1
    call score0_increment
    return

    mapDecoder2
    movlw 0x02
    cpfseq user_location
    goto mapDecoder3
    btfsc PORTC, 2
    call score0_increment
    return

    mapDecoder3
    movlw 0x03
    cpfseq user_location
    goto mapDecoder4
    btfsc PORTC, 3
    call score0_increment
    return


    mapDecoder4
    movlw 0x05
    cpfseq user_location
    goto mapDecoder5
    btfsc PORTD, 0
    call score0_increment
    return

    mapDecoder5
    movlw 0x06
    cpfseq user_location
    goto mapDecoder6
    btfsc PORTD, 1
    call score0_increment
    return

    mapDecoder6
    movlw 0x07
    cpfseq user_location
    goto mapDecoder7
    btfsc PORTD, 2
    call score0_increment
    return

    mapDecoder7
    movlw 0x08
    cpfseq user_location
    goto mapDecoder8
    btfsc PORTD, 3
    call score0_increment
    return

    mapDecoder8
    movlw 0x0a
    cpfseq user_location
    goto mapDecoder9
    btfsc PORTE, 0
    call score0_increment
    return

    mapDecoder9
    movlw 0x0b
    cpfseq user_location
    goto mapDecoder10
    btfsc PORTE, 1
    call score0_increment
    return

    mapDecoder10
    movlw 0x0c
    cpfseq user_location
    goto mapDecoder11
    btfsc PORTE, 2
    call score0_increment
    return

    mapDecoder11
    movlw 0x0d
    cpfseq user_location
    goto mapDecoder12
    btfsc PORTE, 3
    call score0_increment
    return

    mapDecoder12
    movlw 0x0f
    cpfseq user_location
    goto mapDecoder13
    btfsc PORTF, 0
    call score0_increment
    return

    mapDecoder13
    movlw 0x10
    cpfseq user_location
    goto mapDecoder14
    btfsc PORTF, 1
    call score0_increment
    return

    mapDecoder14
    movlw 0x11
    cpfseq user_location
    goto mapDecoder15
    btfsc PORTF, 2
    call score0_increment
    return

    mapDecoder15
    btfsc PORTF, 3
    call score0_increment
    return



    movement_function
    bcf movement_flag,0
    movlw 0x03
    cpfseq direction                ; if direction==south :
    goto movement_function2
    movlw 0x03
    cpfseq user_location
    goto s1
    bsf hit_flag,0
    decf live
    return
    s1
    movlw 0x08
    cpfseq user_location
    goto s2
    bsf hit_flag,0
    decf live
    return
    s2
    movlw d'13'
    cpfseq user_location
    goto s3
    bsf hit_flag,0
    decf live
    return
    s3
    movlw d'18'
    cpfseq user_location
    goto s4
    bsf hit_flag,0
    decf live
    return
    s4
    call user_location_encoder_clear
    incf user_location
    call mapDecoder
    return


    movement_function2
    movlw 0x02
    cpfseq direction                ; if direction==north :
    goto movement_function3
    movlw 0x00
    cpfseq user_location
    goto n1
    bsf hit_flag,0
    decf live
    return
    n1
    movlw 0x05
    cpfseq user_location
    goto n2
    bsf hit_flag,0
    decf live
    return
    n2
    movlw d'10'
    cpfseq user_location
    goto n3
    bsf hit_flag,0
    decf live
    return
    n3
    movlw d'15'
    cpfseq user_location
    goto n4
    bsf hit_flag,0
    decf live
    return
    n4
    call user_location_encoder_clear
    decf user_location
    call mapDecoder
    return

    movement_function3
    movlw 0x01
    cpfseq direction                ; if direction==west :
    goto movement_function4
    movlw 0x00
    cpfseq user_location
    goto w1
    bsf hit_flag,0
    decf live
    return
    w1
    movlw 0x01
    cpfseq user_location
    goto w2
    bsf hit_flag,0
    decf live
    return
    w2
    movlw d'2'
    cpfseq user_location
    goto w3
    bsf hit_flag,0
    decf live
    return
    w3
    movlw d'3'
    cpfseq user_location
    goto w4
    bsf hit_flag,0
    decf live
    return
    w4
    call user_location_encoder_clear
    movlw 0x05
    subwf user_location, f
    call mapDecoder
    return

    movement_function4
    movlw 0x00
    cpfseq direction                ; if direction==east :
    return
    movlw d'15'
    cpfseq user_location
    goto e1
    bsf hit_flag,0
    decf live
    return
    e1
    movlw d'16'
    cpfseq user_location
    goto e2
    bsf hit_flag,0
    decf live
    return
    e2
    movlw d'17'
    cpfseq user_location
    goto e3
    bsf hit_flag,0
    decf live
    return
    e3
    movlw d'18'
    cpfseq user_location
    goto e4
    bsf hit_flag,0
    decf live
    return
    e4
    call user_location_encoder_clear
    movlw 0x05
    addwf user_location, f
    call mapDecoder
    return




    user_blink
    btfsc blink_state,0
    call user_location_encoder
    btfss blink_state,0
    call user_location_encoder_clear
    return

    blink_level_25
    movlw d'25'
    movwf blink_level
    return

    blink_level_50
    movlw d'50'
    movwf blink_level
    return

    blink_level_100
    movlw d'100'
    movwf blink_level
    return

    blink_level_200
    movlw d'200'
    movwf blink_level
    return

    user_location_encoder_clear
    movlw 0x00
    cpfseq user_location
    goto user_location_encoder_clear1
    bcf PORTC, 0
    return

    user_location_encoder_clear1
    movlw 0x01
    cpfseq user_location
    goto user_location_encoder_clear2
    bcf PORTC, 1
    return

    user_location_encoder_clear2
    movlw 0x02
    cpfseq user_location
    goto user_location_encoder_clear3
    bcf PORTC, 2
    return

    user_location_encoder_clear3
    movlw 0x03
    cpfseq user_location
    goto user_location_encoder_clear5
    bcf PORTC, 3
    return

    user_location_encoder_clear5
    movlw 0x05
    cpfseq user_location
    goto user_location_encoder_clear6
    bcf PORTD, 0
    return

    user_location_encoder_clear6
    movlw 0x06
    cpfseq user_location
    goto user_location_encoder_clear7
    bcf PORTD, 1
    return

    user_location_encoder_clear7
    movlw 0x07
    cpfseq user_location
    goto user_location_encoder_clear8
    bcf PORTD, 2
    return

    user_location_encoder_clear8
    movlw 0x08
    cpfseq user_location
    goto user_location_encoder_clear10
    bcf PORTD, 3
    return

    user_location_encoder_clear10
    movlw 0x0a
    cpfseq user_location
    goto user_location_encoder_clear11
    bcf PORTE, 0
    return

    user_location_encoder_clear11
    movlw 0x0b
    cpfseq user_location
    goto user_location_encoder_clear12
    bcf PORTE, 1
    return

    user_location_encoder_clear12
    movlw 0x0c
    cpfseq user_location
    goto user_location_encoder_clear13
    bcf PORTE, 2
    return

    user_location_encoder_clear13
    movlw 0x0d
    cpfseq user_location
    goto user_location_encoder_clear15
    bcf PORTE, 3
    return

    user_location_encoder_clear15
    movlw 0x0f
    cpfseq user_location
    goto user_location_encoder_clear16
    bcf PORTF, 0
    return

    user_location_encoder_clear16
    movlw 0x10
    cpfseq user_location
    goto user_location_encoder_clear17
    bcf PORTF, 1
    return

    user_location_encoder_clear17
    movlw 0x11
    cpfseq user_location
    goto user_location_encoder_clear18
    bcf PORTF, 2
    return

    user_location_encoder_clear18
    bcf PORTF, 3
    return



    user_location_encoder
    movlw 0x00
    cpfseq user_location
    goto user_location_encoder1
    bsf PORTC, 0
    return

    user_location_encoder1
    movlw 0x01
    cpfseq user_location
    goto user_location_encoder2
    bsf PORTC, 1
    return

    user_location_encoder2
    movlw 0x02
    cpfseq user_location
    goto user_location_encoder3
    bsf PORTC, 2
    return

    user_location_encoder3
    movlw 0x03
    cpfseq user_location
    goto user_location_encoder5
    bsf PORTC, 3
    return

    user_location_encoder5
    movlw 0x05
    cpfseq user_location
    goto user_location_encoder6
    bsf PORTD, 0
    return

    user_location_encoder6
    movlw 0x06
    cpfseq user_location
    goto user_location_encoder7
    bsf PORTD, 1
    return

    user_location_encoder7
    movlw 0x07
    cpfseq user_location
    goto user_location_encoder8
    bsf PORTD, 2
    return

    user_location_encoder8
    movlw 0x08
    cpfseq user_location
    goto user_location_encoder10
    bsf PORTD, 3
    return

    user_location_encoder10
    movlw 0x0a
    cpfseq user_location
    goto user_location_encoder11
    bsf PORTE, 0
    return

    user_location_encoder11
    movlw 0x0b
    cpfseq user_location
    goto user_location_encoder12
    bsf PORTE, 1
    return

    user_location_encoder12
    movlw 0x0c
    cpfseq user_location
    goto user_location_encoder13
    bsf PORTE, 2
    return

    user_location_encoder13
    movlw 0x0d
    cpfseq user_location
    goto user_location_encoder15
    bsf PORTE, 3
    return

    user_location_encoder15
    movlw 0x0f
    cpfseq user_location
    goto user_location_encoder16
    bsf PORTF, 0
    return

    user_location_encoder16
    movlw 0x10
    cpfseq user_location
    goto user_location_encoder17
    bsf PORTF, 1
    return

    user_location_encoder17
    movlw 0x11
    cpfseq user_location
    goto user_location_encoder18
    bsf PORTF, 2
    return

    user_location_encoder18
    bsf PORTF, 3
    return



    fruit_location_encoder_clear
    movlw 0x00
    cpfseq fruit_location
    goto fruit_location_encoder_clear1
    btfsc PORTC,0
    bsf fruit_open,0
    bcf PORTC, 0
    return

    fruit_location_encoder_clear1
    movlw 0x01
    cpfseq fruit_location
    goto fruit_location_encoder_clear2
    btfsc PORTC,1
    bsf fruit_open,0
    bcf PORTC, 1
    return

    fruit_location_encoder_clear2
    movlw 0x02
    cpfseq fruit_location
    goto fruit_location_encoder_clear3
    btfsc PORTC,2
    bsf fruit_open,0
    bcf PORTC, 2
    return

    fruit_location_encoder_clear3
    movlw 0x03
    cpfseq fruit_location
    goto fruit_location_encoder_clear5
    btfsc PORTC,3
    bsf fruit_open,0
    bcf PORTC, 3
    return

    fruit_location_encoder_clear5
    movlw 0x05
    cpfseq fruit_location
    goto fruit_location_encoder_clear6
    btfsc PORTD,0
    bsf fruit_open,0
    bcf PORTD, 0
    return

    fruit_location_encoder_clear6
    movlw 0x06
    cpfseq fruit_location
    goto fruit_location_encoder_clear7
    btfsc PORTD,1
    bsf fruit_open,0
    bcf PORTD, 1
    return

    fruit_location_encoder_clear7
    movlw 0x07
    cpfseq fruit_location
    goto fruit_location_encoder_clear8
    btfsc PORTD,2
    bsf fruit_open,0
    bcf PORTD, 2
    return

    fruit_location_encoder_clear8
    movlw 0x08
    cpfseq fruit_location
    goto fruit_location_encoder_clear10
    btfsc PORTD,3
    bsf fruit_open,0
    bcf PORTD, 3
    return

    fruit_location_encoder_clear10
    movlw 0x0a
    cpfseq fruit_location
    goto fruit_location_encoder_clear11
    btfsc PORTE,0
    bsf fruit_open,0
    bcf PORTE, 0
    return

    fruit_location_encoder_clear11
    movlw 0x0b
    cpfseq fruit_location
    goto fruit_location_encoder_clear12
    btfsc PORTE,1
    bsf fruit_open,0
    bcf PORTE, 1
    return

    fruit_location_encoder_clear12
    movlw 0x0c
    cpfseq fruit_location
    goto fruit_location_encoder_clear13
    btfsc PORTE,2
    bsf fruit_open,0
    bcf PORTE, 2
    return

    fruit_location_encoder_clear13
    movlw 0x0d
    cpfseq fruit_location
    goto fruit_location_encoder_clear15
    btfsc PORTE,3
    bsf fruit_open,0
    bcf PORTE, 3
    return

    fruit_location_encoder_clear15
    movlw 0x0f
    cpfseq fruit_location
    goto fruit_location_encoder_clear16
    btfsc PORTF,0
    bsf fruit_open,0
    bcf PORTF, 0
    return

    fruit_location_encoder_clear16
    movlw 0x10
    cpfseq fruit_location
    goto fruit_location_encoder_clear17
    btfsc PORTF,1
    bsf fruit_open,0
    bcf PORTF, 1
    return

    fruit_location_encoder_clear17
    movlw 0x11
    cpfseq fruit_location
    goto fruit_location_encoder_clear18
    btfsc PORTF,2
    bsf fruit_open,0
    bcf PORTF, 2
    return

    fruit_location_encoder_clear18
    btfsc PORTF,3
    bsf fruit_open,0
    bcf PORTF, 3
    return



    fruit_location_encoder
    movlw 0x00
    cpfseq fruit_location
    goto fruit_location_encoder1
    bsf PORTC, 0
    return

    fruit_location_encoder1
    movlw 0x01
    cpfseq fruit_location
    goto fruit_location_encoder2
    bsf PORTC, 1
    return

    fruit_location_encoder2
    movlw 0x02
    cpfseq fruit_location
    goto fruit_location_encoder3
    bsf PORTC, 2
    return

    fruit_location_encoder3
    movlw 0x03
    cpfseq fruit_location
    goto fruit_location_encoder5
    bsf PORTC, 3
    return

    fruit_location_encoder5
    movlw 0x05
    cpfseq fruit_location
    goto fruit_location_encoder6
    bsf PORTD, 0
    return

    fruit_location_encoder6
    movlw 0x06
    cpfseq fruit_location
    goto fruit_location_encoder7
    bsf PORTD, 1
    return

    fruit_location_encoder7
    movlw 0x07
    cpfseq fruit_location
    goto fruit_location_encoder8
    bsf PORTD, 2
    return

    fruit_location_encoder8
    movlw 0x08
    cpfseq fruit_location
    goto fruit_location_encoder10
    bsf PORTD, 3
    return

    fruit_location_encoder10
    movlw 0x0a
    cpfseq fruit_location
    goto fruit_location_encoder11
    bsf PORTE, 0
    return

    fruit_location_encoder11
    movlw 0x0b
    cpfseq fruit_location
    goto fruit_location_encoder12
    bsf PORTE, 1
    return

    fruit_location_encoder12
    movlw 0x0c
    cpfseq fruit_location
    goto fruit_location_encoder13
    bsf PORTE, 2
    return

    fruit_location_encoder13
    movlw 0x0d
    cpfseq fruit_location
    goto fruit_location_encoder15
    bsf PORTE, 3
    return

    fruit_location_encoder15
    movlw 0x0f
    cpfseq fruit_location
    goto fruit_location_encoder16
    bsf PORTF, 0
    return

    fruit_location_encoder16
    movlw 0x10
    cpfseq fruit_location
    goto fruit_location_encoder17
    bsf PORTF, 1
    return

    fruit_location_encoder17
    movlw 0x11
    cpfseq fruit_location
    goto fruit_location_encoder18
    bsf PORTF, 2
    return

    fruit_location_encoder18
    bsf PORTF, 3
    return





    porta_initialize
    movlw 0x00
    cpfseq live
    goto porta_initialize1
    movwf PORTA
    return
    porta_initialize1
    movlw 0x01
    cpfseq live
    goto porta_initialize2
    movlw b'00000001'
    movwf PORTA
    return
    porta_initialize2
    movlw 0x02
    cpfseq live
    goto porta_initialize3
    movlw b'00000011'
    movwf PORTA
    return
    porta_initialize3
    movlw 0x03
    cpfseq live
    goto porta_initialize4
    movlw b'00000111'
    movwf PORTA
    return
    porta_initialize4
    movlw 0x04
    cpfseq live
    goto porta_initialize5
    movlw b'00001111'
    movwf PORTA
    return
    porta_initialize5
    movlw 0x05
    cpfseq live
    goto porta_initialize6
    movlw b'00011111'
    movwf PORTA
    return
    porta_initialize6
    movlw b'00111111'
    movwf PORTA
    return

    phase2_initialize
    movlw b'11110000'
    movwf TRISB
    movlw d'3'
    movwf direction ; set to south initially
    clrf TMR0 ; TMR0 = 0
    ;bcf INTCON2,0
    clrf PORTB
    movlw 0x00
    movwf INTCON ;Interrupts disabled for now

    movlw   b'11000101' ;Disable Timer0 by setting TMR0ON to 0 (for now)
                        ;Configure Timer0 as an 8-bit timer/counter by setting T08BIT to 1
                        ;Timer0 increment from internal clock with a prescaler of 1:256.
    movwf   T0CON
    movlw   b'11101000' ;Enable Global, peripheral, Timer0 and RB interrupts by setting GIE, PEIE, TMR0IE and RBIE bits to 1
    movwf   INTCON
    bsf RCON, 7
    bcf INTCON2,0




    return

    phase1
    call sevenSeg
    btfsc PORTC,0
    call arithmetic0
    btfsc PORTC, 1
    call arithmetic1
    btfsc PORTC, 2
    call decrementLive
    btfsc PORTC, 3
    call incrementLive
    btfsc PORTC, 4
    call decrementLevel
    btfsc PORTC, 5
    call incrementLevel
    btfsc PORTA, 4
    goto releasePhase1
    goto phase1


    releasePhase1
    btfss PORTA,4
    goto releasePhase1
    return


    sevenSeg
    movlw 0x08
    movwf PORTH
    movff v2, PORTJ
    call FdigitEncoder9
    call SdigitEncoder9
    call TdigitEncoder9
    call LASTdigitEncoder9
    call delay
    movlw 0x04
    movwf PORTH
    movff v4, PORTJ
    call delay
    movlw 0x02
    movwf PORTH
    movff v6, PORTJ
    call delay
    movlw 0x01
    movwf PORTH
    movff v8, PORTJ
    call delay
    return

    LASTdigitEncoder9
    movlw 0x09
    cpfseq v7
    goto LASTdigitEncoder8
    movlw 0x6f
    movwf v8
    return

    LASTdigitEncoder8
    movlw 0x08
    cpfseq v7
    goto LASTdigitEncoder7
    movlw b'01111111'
    movwf v8
    return

    LASTdigitEncoder7
    movlw 0x07
    cpfseq v7
    goto LASTdigitEncoder6
    movlw b'00000111'
    movwf v8
    return

    LASTdigitEncoder6
    movlw 0x06
    cpfseq v7
    goto LASTdigitEncoder5
    movlw b'01111101'
    movwf v8
    return

    LASTdigitEncoder5
    movlw 0x05
    cpfseq v7
    goto LASTdigitEncoder4
    movlw b'01101101'
    movwf v8
    return

    LASTdigitEncoder4
    movlw 0x04
    cpfseq v7
    goto LASTdigitEncoder3
    movlw b'01100110'
    movwf v8
    return

    LASTdigitEncoder3
    movlw 0x03
    cpfseq v7
    goto LASTdigitEncoder2
    movlw b'01001111'
    movwf v8
    return

    LASTdigitEncoder2
    movlw 0x02
    cpfseq v7
    goto LASTdigitEncoder1
    movlw b'01011011'
    movwf v8
    return

    LASTdigitEncoder1
    movlw 0x01
    cpfseq v7
    goto LASTdigitEncoder0
    movlw b'00000110'
    movwf v8
    return

    LASTdigitEncoder0
    movlw 0x00
    cpfseq v7
    goto LASTdigitEncoderS
    movlw b'00111111'
    movwf v8
    return

    LASTdigitEncoderS
    movlw 0xFF
    cpfseq v7
    goto LASTdigitEncoderU
    movlw b'01101101'
    movwf v8
    return

    LASTdigitEncoderU
    movlw b'00111110'
    movwf v8
    return




    TdigitEncoder9
    movlw 0x09
    cpfseq v5
    goto TdigitEncoder8
    movlw 0x6f
    movwf v6
    return

    TdigitEncoder8
    movlw 0x08
    cpfseq v5
    goto TdigitEncoder7
    movlw b'01111111'
    movwf v6
    return

    TdigitEncoder7
    movlw 0x07
    cpfseq v5
    goto TdigitEncoder6
    movlw b'00000111'
    movwf v6
    return

    TdigitEncoder6
    movlw 0x06
    cpfseq v5
    goto TdigitEncoder5
    movlw b'01111101'
    movwf v6
    return

    TdigitEncoder5
    movlw 0x05
    cpfseq v5
    goto TdigitEncoder4
    movlw b'01101101'
    movwf v6
    return

    TdigitEncoder4
    movlw 0x04
    cpfseq v5
    goto TdigitEncoder3
    movlw b'01100110'
    movwf v6
    return

    TdigitEncoder3
    movlw 0x03
    cpfseq v5
    goto TdigitEncoder2
    movlw b'01001111'
    movwf v6
    return

    TdigitEncoder2
    movlw 0x02
    cpfseq v5
    goto TdigitEncoder1
    movlw b'01011011'
    movwf v6
    return

    TdigitEncoder1
    movlw 0x01
    cpfseq v5
    goto TdigitEncoder0
    movlw b'00000110'
    movwf v6
    return

    TdigitEncoder0
    movlw 0x00
    cpfseq v5
    return
    movlw b'00111111'
    movwf v6
    return


    SdigitEncoder9
    movlw 0x09
    cpfseq v3
    goto SdigitEncoder8
    movlw 0x6f
    movwf v4
    return

    SdigitEncoder8
    movlw 0x08
    cpfseq v3
    goto SdigitEncoder7
    movlw b'01111111'
    movwf v4
    return

    SdigitEncoder7
    movlw 0x07
    cpfseq v3
    goto SdigitEncoder6
    movlw b'00000111'
    movwf v4
    return

    SdigitEncoder6
    movlw 0x06
    cpfseq v3
    goto SdigitEncoder5
    movlw b'01111101'
    movwf v4
    return

    SdigitEncoder5
    movlw 0x05
    cpfseq v3
    goto SdigitEncoder4
    movlw b'01101101'
    movwf v4
    return

    SdigitEncoder4
    movlw 0x04
    cpfseq v3
    goto SdigitEncoder3
    movlw b'01100110'
    movwf v4
    return

    SdigitEncoder3
    movlw 0x03
    cpfseq v3
    goto SdigitEncoder2
    movlw b'01001111'
    movwf v4
    return

    SdigitEncoder2
    movlw 0x02
    cpfseq v3
    goto SdigitEncoder1
    movlw b'01011011'
    movwf v4
    return

    SdigitEncoder1
    movlw 0x01
    cpfseq v3
    goto SdigitEncoder0
    movlw b'00000110'
    movwf v4
    return

    SdigitEncoder0
    movlw 0x00
    cpfseq v3
    return
    movlw b'00111111'
    movwf v4
    return




    FdigitEncoder9
    movlw 0x09
    cpfseq v1
    goto FdigitEncoder8
    movlw 0x6f
    movwf v2
    return

    FdigitEncoder8
    movlw 0x08
    cpfseq v1
    goto FdigitEncoder7
    movlw b'01111111'
    movwf v2
    return

    FdigitEncoder7
    movlw 0x07
    cpfseq v1
    goto FdigitEncoder6
    movlw b'00000111'
    movwf v2
    return

    FdigitEncoder6
    movlw 0x06
    cpfseq v1
    goto FdigitEncoder5
    movlw b'01111101'
    movwf v2
    return

    FdigitEncoder5
    movlw 0x05
    cpfseq v1
    goto FdigitEncoder4
    movlw b'01101101'
    movwf v2
    return

    FdigitEncoder4
    movlw 0x04
    cpfseq v1
    goto FdigitEncoder3
    movlw b'01100110'
    movwf v2
    return

    FdigitEncoder3
    movlw 0x03
    cpfseq v1
    goto FdigitEncoder2
    movlw b'01001111'
    movwf v2
    return

    FdigitEncoder2
    movlw 0x02
    cpfseq v1
    goto FdigitEncoder1
    movlw b'01011011'
    movwf v2
    return

    FdigitEncoder1
    movlw 0x01
    cpfseq v1
    goto FdigitEncoder0
    movlw b'00000110'
    movwf v2
    return

    FdigitEncoder0
    movlw 0x00
    cpfseq v1
    return
    movlw b'00111111'
    movwf v2
    return


    arithmetic0
    btfsc PORTC,0
    goto arithmetic0
    tstfsz v1
    goto decv1
    movlw 0x09
    movwf v1
    call arithmetic2
    movlw 0x00
    cpfseq fruit
    goto decN
    movlw 0x63
    movwf fruit
    return
    decv1
    decf v1
    decf fruit
    return
    decN
    decf fruit
    return

    arithmetic0_phase2
    tstfsz v5
    goto decv5_phase2
    movlw 0x09
    movwf v5
    decf fruit
    call arithmetic2_phase2
    return
    decv5_phase2
    decf v5
    decf fruit
    return

    arithmetic2_phase2
    tstfsz v7
    goto decv7_phase2
    return
    decv7_phase2
    decf v7
    return


    arithmetic1
    btfsc PORTC,1
    goto arithmetic1
    movlw 0x09
    cpfseq v1
    goto incv1
    movlw 0x00
    movwf v1
    call arithmetic3
    movlw 0x63
    cpfseq fruit
    goto incN
    movlw 0x00
    movwf fruit
    return
    incv1
    incf v1
    incf fruit
    return
    incN
    incf fruit
    return

    arithmetic1_isr
    movlw 0x09
    cpfseq v1
    goto incv1_isr
    movlw 0x00
    movwf v1
    call arithmetic3_isr
    return
    incv1_isr
    incf v1
    return

    arithmetic3_isr
    movlw 0x09
    cpfseq v3
    goto incv3
    movlw 0x00
    movwf v3
    return

    score0_increment
    call arithmetic0_phase2
    movlw 0x09
    cpfseq score0
    goto incscore0
    movlw 0x00
    movwf score0
    call score1_increment
    return
    incscore0
    incf score0
    return

    score1_increment
    movlw 0x09
    cpfseq score1
    goto incscore1
    movlw 0x00
    movwf score1
    return
    incscore1
    incf score1
    return


    arithmetic2
    tstfsz v3
    goto decv3
    movlw 0x09
    movwf v3
    return
    decv3
    decf v3
    return

    arithmetic3
    movlw 0x09
    cpfseq v3
    goto incv3
    movlw 0x00
    movwf v3
    return
    incv3
    incf v3
    return

    decrementLive
    btfsc PORTC,2
    goto decrementLive
    tstfsz v5
    goto decv5
    movlw 0x06
    movwf v5
    movwf live
    return
    decv5
    decf v5
    decf live
    return

    incrementLive
    btfsc PORTC,3
    goto incrementLive
    movlw 0x06
    cpfseq v5
    goto incv5
    movlw 0x00
    movwf v5
    movwf live
    return
    incv5
    incf v5
    incf live
    return


    decrementLevel
    btfsc PORTC,4
    goto decrementLevel
    tstfsz v7
    goto decv7
    movlw 0x03
    movwf v7
    movwf gameLevel
    return
    decv7
    decf v7
    decf gameLevel
    return

    incrementLevel
    btfsc PORTC,5
    goto incrementLevel
    movlw 0x03
    cpfseq v7
    goto incv7
    movlw 0x00
    movwf v7
    movwf gameLevel
    return
    incv7
    incf v7
    incf gameLevel
    return

    delay
    MOVLW 0X62
    MOVWF i
    L1
    DECFSZ i, F
    GOTO L1
    return

    timerISR:
    incf blink_counter
    movf blink_counter,  W
    subwf blink_level, W
    btfss STATUS, Z
    goto timerISRcont
    comf blink_state
    clrf blink_counter
    incf movement_counter
    movf movement_counter,W
    sublw 0x04
    btfss STATUS, Z
    goto timerISRcont
    clrf movement_counter
    bsf movement_flag,0
    incf fruitTimeCounter
    movf fruitTimeCounter, W
    sublw 0x02
    btfss STATUS, Z
    goto timerISRcont
    clrf fruitTimeCounter
    bsf fruit_flag, 0
    btfsc fruit_kill_flag,0
    goto timerISRcont
    incf fruit_kill_counter
    movf fruit_kill_counter,W
    sublw 0x05
    btfss STATUS, Z
    goto timerISRcont
    clrf fruit_kill_counter
    bsf fruit_kill_flag,0
    timerISRcont:
    incf counter
    movf counter, W
    sublw d'200'
    btfss STATUS, Z
    goto timerISR_exit
    clrf counter
    incf counter2
    movf counter2,W
    sublw d'4'
    btfss STATUS, Z
    goto timerISR_exit
    clrf counter2
    call arithmetic1_isr


    timerISR_exit:
    bcf INTCON,2
    movlw 0x3d
    movwf TMR0
    call restore_registers2
    retfie

    portbISR:
    movf PORTB, W
    movwf portb_shadow
    btfsc portb_shadow, 4
    goto set_direction_east
    btfsc portb_shadow, 5
    goto set_direction_west
    btfsc portb_shadow, 6
    goto set_direction_north
    btfsc portb_shadow, 7
    goto set_direction_south
    movf portb_shadow, w
    movwf PORTB
    bcf INTCON,0
    call restore_registers
    retfie

    set_direction_south:
    movlw 0x03
    movwf direction
    bcf hit_flag,0
    movf portb_shadow, w
    movwf PORTB
    bcf INTCON,0
    call restore_registers
    retfie

    set_direction_north:
    movlw 0x02
    movwf direction
    bcf hit_flag,0
    movf portb_shadow, w
    movwf PORTB
    bcf INTCON,0
    call restore_registers
    retfie

    set_direction_west:
    movlw 0x01
    movwf direction
    bcf hit_flag,0
    movf portb_shadow, w
    movwf PORTB
    bcf INTCON,0
    call restore_registers
    retfie

    set_direction_east:
    movlw 0x00
    movwf direction
    bcf hit_flag,0
    movf portb_shadow, w
    movwf PORTB
    bcf INTCON,0
    call restore_registers
    retfie

    saveRegisters2:
    movwf wSaved2
    swapf STATUS, w
    clrf STATUS
    movwf statusSaved2
    movf 	PCLATH, w
    movwf 	pcLatchSaved2
    clrf 	PCLATH
	return

    restore_registers2:
    movf 	pcLatchSaved2, w
    movwf 	PCLATH
    swapf 	statusSaved2, w
    movwf 	STATUS
    swapf 	wSaved2, f
    swapf 	wSaved2, w
    return

    saveRegisters:
    movwf wSaved
    swapf STATUS, w
    clrf STATUS
    movwf statusSaved
    movf 	PCLATH, w
    movwf 	pcLatchSaved
    clrf 	PCLATH
	return

    restore_registers:
    movf 	pcLatchSaved, w
    movwf 	PCLATH
    swapf 	statusSaved, w
    movwf 	STATUS
    swapf 	wSaved, f
    swapf 	wSaved, w
    return


    END
