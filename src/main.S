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
  ldrb r1, [r4] @ get mode
  lsr r2, r1, #5
  and r2, 1
  cmp r2, 0 @ check if delay (0) or note (1)
  beq play_delay

play_note:
  @ otherwise, play a note
  ldrb r1, [r4] @ get mode
  and r7, r1, 0b1111 @ store waveform triangle (0) or sine (1) in r7
  lsr r1, #4 @ check if norm (0) or ADSR envelope (1)
  and r1, 1

  cmp r1, 0 @ normal note
  mov r1, r4 @ input r1: address to the start of the record element
  mov r2, r7 @ input r2: waveform
  ITT EQ
  addeq r4, #7 @ change the address to the start of the next element  
  bleq play_note_norm
  mov r6, r0 @ store return value of last sample played in r6
  
  ldrb r1, [r4] @ re-check if norm (0) or ADSR envelope (1)
  lsr r1, #4 
  and r1, 1

  cmp r1, 0 @ Attack - Decay - Sustain - Release note
  mov r1, r4 @ input r1: address to the start of the record element
  mov r2, r7 @ input r2: waveform
  ITT NE
  addne r4, #15 @ change the address to the start of the next element
  blne play_note_ADSR
  mov r6, r0 @ store return value of last sample played in r6
  b loop_continue

play_delay:
  mov r0, r6 @ input r0: value of last sample played (delay always follows a note), returned by play_note
  ldrh r1, [r4, #1] @ input r1: target duration (ms)
  bl delay
  add r4, #3 @ change the address to the start of the next element
loop_continue:
  @ once the song is completed, start the song again
  sub r5, #1
  cmp r5, #0
  beq loop_song
  b loop_note

play_note_norm:
  @ input r1: address to the start of the record element
  @ input r2: waveform
  push {r4-r11, lr}
  mov r10, r2 @ move waveform to r10
  mov r11, r1 @ move address to the start of the record element to r11
  nop
  @ norm note
  ldrh r0, [r11, #1] @ input r0: frequency
  ldrh r1, [r11, #3] @ input r1: initial amplitude
  ldrh r2, [r11, #3] @ input r2: final amplitude
  ldrh r3, [r11, #5] @ input r3: duration  
  cmp r10, 0 @ check waveform for triangle
  IT EQ
  bleq play_note_triangle
  cmp r10, 0 @ check waveform for sine
  IT NE
  blne play_note_sine

  pop {r4-r11, lr}
  bx lr

play_note_ADSR:
  @ input r1: address to the start of the record element
  @ input r2: waveform
  push {r4-r11, lr}
  mov r10, r2 @ move waveform to r10
  mov r11, r1 @ move address to the start of the record element to r11
  nop
  @ attack
  ldrh r0, [r11, #1] @ input r0: frequency
  mov r1, #0         @ input r1: initial amplitude
  ldrh r2, [r11, #5] @ input r2: final amplitude
  ldrh r3, [r11, #7] @ input r3: duration 
  cmp r10, 0 @ check waveform for triangle
  IT EQ
  bleq play_note_triangle
  cmp r10, 0 @ check waveform for sine
  IT NE
  blne play_note_sine
  nop
  @ decay
  ldrh r0, [r11, #1] @ input r0: frequency
  ldrh r1, [r11, #5] @ input r1: initial amplitude
  ldrh r2, [r11, #3] @ input r2: final amplitude
  ldrh r3, [r11, #9] @ input r3: duration 
  cmp r10, 0 @ check waveform for triangle
  IT EQ
  bleq play_note_triangle
  cmp r10, 0 @ check waveform for sine
  IT NE
  blne play_note_sine
  nop
  @ sustain
  ldrh r0, [r11, #1] @ input r0: frequency
  ldrh r1, [r11, #3] @ input r1: initial amplitude
  ldrh r2, [r11, #3] @ input r2: final amplitude
  ldrh r3, [r11, #11]@ input r3: duration 
  cmp r10, 0 @ check waveform for triangle
  IT EQ
  bleq play_note_triangle
  cmp r10, 0 @ check waveform for sine
  IT NE
  blne play_note_sine
  nop
  @ release
  ldrh r0, [r11, #1] @ input r0: frequency
  ldrh r1, [r11, #3] @ input r1: initial amplitude
  mov r2, #0         @ input r2: final amplitude
  ldrh r3, [r11, #13]@ input r3: duration 
  cmp r10, 0 @ check waveform for triangle
  IT EQ
  bleq play_note_triangle
  cmp r10, 0 @ check waveform for sine
  IT NE
  blne play_note_sine

  pop {r4-r11, lr}
  bx lr

@ ===
@ triangle wave
@ derived from assignment 1 code (see statement of originality)
@ ===

.type play_note_triangle, %function
play_note_triangle:
  @ setup
  @ input r0: frequency
  @ input r1: initial amplitude
  @ input r2: final amplitude
  @ input r3: duration
  push {r4-r11, lr}

  @ triangle wave.
  @ customize the wave with r5 and r6.
  @ use a frequency of 440Hz (note A),
  @ and amplitude/2 of 0x7fff for full dynamic range (max volume).
  @ customize the duration with r10, 1000 = 1 second.
  @ amplitude will shift from initial to final amplitude

  @ r5 stores the frequency (Hz)
  mov r5, r0

  @ r6 stores current amplitude/2 (volume) or the max bound
  mov r6, r1 @ start at initial amplitude

  @ r9 stores cycle iterations, or current duration
  mov r9, #0

  @ r10 stores target duration (ms)
  mov r10, r3

  @ r11 stores amount amplitude increments/decrements every cycle
  sub r0, r2, r6 @ difference between initial and final amplitude
  mul r1, r5, r10
  mov r2, #1000
  udiv r1, r2 @ cycles per duration
  sdiv r11, r0, r1 @ difference in amplitude between each cycle
  mov r0, #0
  mov r1, #0
  mov r2, #0

  @ use r4 for current sample, moved to r0 before samples are played

triangle_new_cycle:
  add r6, r11 @ increment/decrement amplitude

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

  cmp r8, #0 @ ensure that r8 is never 0
  IT EQ
  moveq r4, r6
  beq triangle_check_duration

  mov r0, #0
  mov r1, #0

@ first half of period, r6 (upper) to r7 (lower)
triangle_decend_start:
  nop
  mov r4, r6
triangle_decend_loop:
  subs r4, r8
  bpl triangle_decend_skip @ only make check when below 0
  cmp r4, r7 
  ble triangle_ascend_start @ start ascending if lower bound is reached
triangle_decend_skip:
  mov r0, r4
  bl BSP_AUDIO_OUT_Play_Sample
  b triangle_decend_loop

@ second half of period, r7 (lower) to r6 (upper)
triangle_ascend_start:
  nop
  mov r4, r7
triangle_ascend_loop:
  adds r4, r8
  bmi triangle_ascend_skip @ only make check when above 0
  cmp r4, r6
  bge triangle_check_duration @ check duration if upper bound is reached (full cycle complete)
triangle_ascend_skip:
  mov r0, r4
  bl BSP_AUDIO_OUT_Play_Sample
  b triangle_ascend_loop

@ when every cycle is completed, check if the duration of the note has reached the target duration
triangle_check_duration:
  add r9, #1 @ increment cycle iterations counter
  mov r1, #1000 
  mul r0, r9, r1 @ convert to ms
  udiv r0, r5 @ divide duration by frequency
  @ check if the current duration does not exceed the target duration
  cmp r0, r10
  mov r0, #0
  mov r1, #0
  blt triangle_new_cycle @ if so, start next cycle
  @ otherwise, end the note and cleanup function
  sub r0, r4, r8 @ return the last sample played in r0
  pop {r4-r11, lr}
  bx lr 
.size play_note_triangle, .-play_note_triangle

@ ===
@ sine wave
@ derived from assignment 1 code (see statement of originality)
@ ===

.type play_note_sine, %function
play_note_sine:
  @ setup
  @ input r0: frequency
  @ input r1: initial amplitude
  @ input r2: final amplitude
  @ input r3: duration
  push {r4-r11, lr}

  @ approximation of sine wave via Bhaskara I's sine approximation formula

  @ customize the wave with r5 and r6.
  @ use a base frequency of 440Hz (note A),
  @ and amplitude/2 of 0x7fff for full dynamic range (max volume).
  @ amplitude will shift from initial to final amplitude

  @ r5 stores the frequency (Hz)
  mov r5, r0

  @ r6 stores current amplitude/2 (volume) or the max bound
  mov r6, r1 @ start at initial amplitude

  @ r7 stores samples per half period
  mov r7, #48000 @ output sample rate of board (48kHz)
  udiv r7, r5 @ samples per period
  lsr r7, #1

  @ r8 stores factor to convert to degrees
  @ shifted twice for precision
  mov r8, #180
  lsl r8, #2
  lsl r0, r7, #2
  udiv r8, r7
  mov r0, #0

  @ r9 stores cycle iterations, or current duration
  mov r9, #0

  @ r10 stores target duration (ms)
  mov r10, r3

  @ r11 stores amount amplitude increments/decrements every cycle
  sub r0, r2, r6 @ difference between initial and final amplitude
  mul r1, r5, r10
  mov r2, #1000
  udiv r1, r2 @ cycles per duration
  sdiv r11, r0, r1 @ difference in amplitude between each cycle
  mov r0, #0
  mov r1, #0
  mov r2, #0

  @ use r4 to measure time (x axis), increments every sample

@ first half of period, positive values peaking at r6
sine_upper_start:  
  nop
  add r6, r11 @ increment/decrement amplitude
  mov r4, #0
sine_upper_loop:
  add r4, #1 @ increase time value
  bl sine_calculate_sample
  cmp r7, r4
  blt sine_lower_start @ start second half of period
  bl BSP_AUDIO_OUT_Play_Sample
  b sine_upper_loop

@ second half of period, negative values, trough at -r6
sine_lower_start:
  nop
  mov r4, #0
sine_lower_loop:
  add r4, #1 @ increase time value
  bl sine_calculate_sample
  rsb r0, #0
  cmp r7, r4
  blt sine_check_duration @ check duration if upper bound is reached (full cycle complete)
  bl BSP_AUDIO_OUT_Play_Sample
  b sine_lower_loop

@ calculates sample value (y axis) based on time (x axis, r4) and amplitude/2 (r6).
@ puts result in r0, ready for sample.
@ uses Bhaskara I's sine approximation formula,
@ (4x(180-x))/(40500-x(180-x)) in addition to scaling for amplitude
sine_calculate_sample:
  mul r1, r4, r8 @ convert to degrees (x in r1)
  lsr r1, #2
  mov r2, #180
  sub r2, r1
  mul r2, r1 @ x(180-x)
  mov r3, #4
  mul r0, r2, r3 @ 4x(180-x)
  mov r3, #40500
  sub r2, r3, r2 @ 40500-x(180-x)
  mul r0, r6 @ scale for amplitude
  udiv r0, r0, r2 @ result
  mov r1, #0
  mov r2, #0
  mov r3, #0
  bx lr

@ when every cycle is completed, check if the duration of the note has reached the target duration
sine_check_duration:
  add r9, #1 @ increment cycle iterations counter
  mov r1, #1000 
  mul r0, r9, r1 @ convert to ms
  udiv r0, r5 @ divide duration by frequency
  @ check if the current duration does not exceed the target duration
  cmp r0, r10
  mov r0, #0
  mov r1, #0
  blt sine_upper_start @ if so, start next cycle
  @ otherwise, end the note and cleanup function
  mov r0, r4 @ return the last sample played in r0
  pop {r4-r11, lr}
  bx lr 
.size play_note_sine, .-play_note_sine

@ ===
@ delay
@ ===

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
  @ ensures the transition is smooth by making the wave decend to 0,
  @ then form a straight line during the delay
  subs r6, #100
  IT MI
  movmi r6, #0
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
  .hword 16

  @ mode format - first 8 bits of any note/delay:
  @ 01010101
  @ ^^^^^^^^
  @ ||||waveform/instrument (0: triangle, 1: sine, 2-15: unused)
  @ |||envelope (0: normal, 1: ADSR)
  @ ||isDelay (0: delay, 1: note)
  @ most significant 2 bits are unused

  @ note (ADSR) format - 120 bits or 15 bytes total: 
  @ mode - 8 bits,
  @ frequency (Hz) - 16 bits, 
  @ sustain volume/loudness (signed, between 0x0 and 0x7fff) - 16 bits, 
  @ initial peak volume/loudness (signed, between 0x0 and 0x7fff) - 16 bits,
  @ attack duration (ms) - 16 bits,
  @ decay duration (ms) - 16 bits,
  @ sustain duration (ms) - 16 bits,
  @ release duration (ms) - 16 bits

  @ note (mode) format - 48 bits or 7 bytes total: 
  @ mode - 8 bits,
  @ frequency (Hz) - 16 bits, 
  @ volume/loudness (signed, between 0x0 and 0x7fff) - 16 bits,
  @ duration (ms) - 16 bits

  @ delay format - 24 bits or 3 bytes total:
  @ mode - 8 bits,
  @ duration (ms) - 16 bits

  @ DEMO (sounds to demonstrate what sounds the synth can produce)
  .byte 0b00100000 @ note, norm, triangle
  .hword 440, 0x7fff, 1000

  .byte 0b00000000 @ delay 250 ms
  .hword 250 

  .byte 0b00100001 @ note, norm, sine
  .hword 440, 0x7fff, 1000

  .byte 0b00000000 @ delay 250 ms
  .hword 250 

  .byte 0b00110000 @ note, ADSR, triangle
  .hword 440, 0x7fff, 0x7fff, 1000, 0, 0, 50

  .byte 0b00000000 @ delay 250 ms
  .hword 250 

  .byte 0b00110001 @ note, ADSR, sine
  .hword 440, 0x7fff, 0x7fff, 1000, 0, 0, 50

  .byte 0b00000000 @ delay 250 ms
  .hword 250 

  .byte 0b00110001 @ note, ADSR, sine
  .hword 440, 0x7fff, 0x7fff, 50, 0, 0, 1000

  .byte 0b00000000 @ delay 250 ms
  .hword 250  

  .byte 0b00110001 @ note, ADSR, sine
  .hword 220, 0x3fff, 0x7fff, 800, 100, 300, 1000

  .byte 0b00000000 @ delay 250 ms
  .hword 250 

  .byte 0b00110001 @ note, ADSR, sine
  .hword 660, 0x3fff, 0x7fff, 100, 50, 100, 300

  .byte 0b00110001 @ note, ADSR, sine
  .hword 700, 0x3fff, 0x7fff, 100, 50, 100, 300

  .byte 0b00110001 @ note, ADSR, sine
  .hword 620, 0x3fff, 0x7fff, 100, 50, 100, 300

  .byte 0b00000000 @ delay 250 ms
  .hword 250