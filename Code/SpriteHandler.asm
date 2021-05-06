include "Code/constants.asm"
include "Code/hardware.inc"
include "Code/Charmap.inc"
include "Code/Macros.asm"

SECTION "Sprite Handler", ROM0

;Update the player sprite, copy shadow OAM to real OAM, and flip the half timer
HandleSprites:
  ;Copy sprites to OAM
  ld  a, HIGH(wShadowOAM)
  di
  call hOAMDMA
  ei

  ;Flip the half timer
  ldh a, [bBooleans]
  xor B_HALFTIMER
  ldh [bBooleans], a

  reti

FillShadowOAM: 
  ;Only forwards for now
  ld hl, Object_Types
  ld de, wShadowOAM + 2 * 4
  ld b, 40-2

  .fillLoop
    ;Get object type
    ld c, l
    ld a, [hl+]

    ;If $FF, skip this entry
    inc a
    jr z, .fillLoop

    ;If $00, stop loop
    dec a
    jr z, .endLoop

    ;Get pointer to draw routine pointer
    push hl
    add a, a
    ld l, a
    ld h, high(Object_DrawRoutinePointers)

    ;Get pointer to draw routine
    ld a, [hl+]
    ld h, [hl]
    ld l, a

    call RunSubroutine

    pop hl

    ;Check if there are still sprite slots available (continue if B > 0)
    inc b
    dec b
    jr nz, .fillLoop

  .endLoop
  xor a ; ld a, 0
  .zeroTheRestLoop
    ;Write a zero, then check if L is zero, if so, stop writing
    ld [de], a
    inc e
    jr nz, .zeroTheRestLoop

  ret


;CREDIT TO https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
SECTION "OAM DMA routine", ROM0
CopyDMARoutine:
  ld  hl, DMARoutine
  ;ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ;ld  c, LOW(hOAMDMA) ; Low byte of the destination address
  lb bc, DMARoutineEnd - DMARoutine, LOW(hOAMDMA); ^ above but more efficient
.copy
  ld  a, [hl+]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ldh [rDMA], a
  
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

SECTION "OAM DMA", HRAM

hOAMDMA::
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to
