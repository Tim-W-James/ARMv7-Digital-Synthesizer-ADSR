.syntax unified
.global main

.type main, %function
main:
  nop
  bl init
  bl BSP_AUDIO_Buffer

  nop

  @ use r4 for current sample, moved to r0 before samples are played
.size main, .-main

play_note_triangle:
  @ setup

  @ triangle wave.
  @ customize the wave with r5 and r6.
  @ use a frequency of 440Hz (note A),
  @ and amplitude/2 of 0x7fff for full dynamic range (max volume)

  @ r5 stores the frequency (Hz)
  mov r5, #440

  @ r6 stores amplitude/2 (volume) or the max bound
  mov r6, 0x7fff
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
  bge decend_loop @ start decending if upper bound is reached
ascend_skip:
  mov r0, r4
  bl BSP_AUDIO_OUT_Play_Sample
  b ascend_loop