.syntax unified
.global main

.type main, %function
main:
  nop
  @ setup
  bl init
  bl BSP_AUDIO_Buffer
loop_song:
  nop
  @ the song is stored as a record in memory (see .data section for format)
  ldr r4, =song @ address of start of song record in r4
  ldrh r5, [r4], 2 @ record length in r5
  b loop_note
.size main, .-main

loop_note:
  nop
  @ the frequency 0 is reserved to indicate a delay
  ldrh r1, [r4]
  cmp r1, #0
  ITTT EQ
  
  @ if 0, make a delay of duration (ms) as in the last 16 bits of the element
  @ input r0: value of last sample played (delay always follows a note), returned by play_note
  @ input r1: target duration (ms)
  moveq r0, r6
  ldrheq r1, [r4, 4]
  bleq delay

  @ check again - branch must be last instruction in IT block
  ldrh r1, [r4]
  cmp r1, #0
  ITT NE
  @ otherwise, play a note
  @ input r0: address to the start of the record element
  movne r0, r4
  blne play_note_triangle
  mov r6, r0 @ store return value of last sample played in r6

  @ once the song is completed, start the song again
  sub r5, #1
  cmp r5, #0
  beq loop_song

  add r4, #6 @ change the address to the start of the next element
  b loop_note


@ triangle wave derived from assignment 1 code (see statement of originality)
.type play_note_triangle, %function
play_note_triangle:
  @ setup
  @ input r0: address to the start of the record element
  push {r4-r11, lr}
  mov r11, r0 @ move address to the start of the record element to r11

  @ triangle wave.
  @ customize the wave with r5 and r6.
  @ use a frequency of 440Hz (note A),
  @ and amplitude/2 of 0x7fff for full dynamic range (max volume).
  @ customize the duration with r10, 1000 = 1 second

  @ r5 stores the frequency (Hz)
  ldrh r5, [r11], #2

  @ r6 stores amplitude/2 (volume) or the max bound
  ldrh r6, [r11], #2
  @ r7 stores the min bound
  rsb r7, r6, #0
  sub r7, #1 @ account for 0

  @ r8 stores difference between each sample point 
  mov r0, #48000 @ output sample rate of board (48kHz)
  udiv r0, r5 @ samples per period
  lsr r0, #1 @ samples per half period
  add r1, r6, #1 @ account for 0
  lsl r1, #1 @ amplitude
  udiv r8, r1, r0 @ defined by amplitude and frequency
  mov r0, #0
  mov r1, #0

  @ r9 stores cycle iterations, or current duration
  mov r9, #0

  @ r10 stores target duration (ms)
  ldrh r10, [r11], #2
  
  @ use r4 for current sample, moved to r0 before samples are played

@ first half of period, r6 (upper) to r7 (lower)
decend_start:
  nop
  mov r4, r6
decend_loop:
  subs r4, r8
  bpl decend_skip @ only make check when below 0
  cmp r4, r7 
  ble ascend_start @ start ascending if lower bound is reached
decend_skip:
  mov r0, r4
  bl BSP_AUDIO_OUT_Play_Sample
  b decend_loop

@ second half of period, r7 (lower) to r6 (upper)
ascend_start:
  nop
  mov r4, r7
ascend_loop:
  adds r4, r8
  bmi ascend_skip @ only make check when above 0
  cmp r4, r6
  bge check_duration @ check duration if upper bound is reached (full cycle complete)
ascend_skip:
  mov r0, r4
  bl BSP_AUDIO_OUT_Play_Sample
  b ascend_loop

@ when every cycle is completed, check if the duration of the note has reached the target duration
check_duration:
  add r9, #1 @ increment cycle iterations counter
  mov r1, #1000 
  mul r0, r9, r1 @ convert to ms
  udiv r0, r5 @ divide duration by frequency
  @ check if the current duration does not exceed the target duration
  cmp r0, r10
  mov r0, #0
  mov r1, #0
  blt decend_start @ if so, start decending (next cycle)
  @ otherwise, end the note and cleanup function
  sub r0, r4, r8 @ return the last sample played in r0
  pop {r4-r11, lr}
  bx lr 
.size play_note_triangle, .-play_note_triangle

@ create a delay by making a sample 48 * ms input times (sample rate is 48kHz)
delay:
  @ input r0: value of last sample played (delay always follows a note), returned in r0 by play_note
  @ input r1: target duration (ms)
  push {r4-r11, lr}
  mov r6, r0 @ keep value in r6
  mov r2, #48
  mul r5, r1, r2 @ 48 samples/ms or 48000 samples/s, target duration in r5
  mov r4, #0 @ counter in r4
delay_loop:
  @ put value in r0 to be played.
  @ ensures the transition is smooth,
  @ and keeps the wave as a straight line during the delay
  mov r0, r6 
  bl BSP_AUDIO_OUT_Play_Sample

  add r4, #1 @ increment counter until it reaches the target duration
  cmp r4, r5
  blt delay_loop
  pop {r4-r11, lr}
  bx lr 

.data
@ stores data for each note or delay of the song in 6 bytes, preceded by record length
song:
  @ number of notes in song / record length (including delays)
  .hword 23
  @ note format - 48 bits or 6 bytes total: 
  @ frequency (Hz) - 16 bits, 
  @ amplitude/2 or loudness (signed, between 0x0 and 0x7fff) - 16 bits, 
  @ duration (ms) - 16 bits

  @ the frequency 0 is reserved to indicate a delay.
  @ duration (ms) is still in the last 16 bits.
  @ loudness is not used

  .hword 294, 0x7fff, 250
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 349, 0x7fff, 250
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 392, 0x7fff, 500
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 294, 0x7fff, 250
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 349, 0x7fff, 250
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 415, 0x7fff, 250
  .hword 392, 0x7fff, 500
  .hword 0, 0x0, 500 @ delay 0.5  
  .hword 294, 0x7fff, 250
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 349, 0x7fff, 250
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 392, 0x7fff, 500
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 349, 0x7fff, 250
  .hword 0, 0x0, 250 @ delay 0.25
  .hword 294, 0x7fff, 1000
  .hword 0, 0x0, 750 @ delay 0.75